
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <time.h>
#include <errno.h>
#include <mysql.h>
#include <libgen.h>
#include <wchar.h>
#include <iconv.h>

#define  __USE_GNU  /* for crypt_r */
#include <crypt.h>
#include "md5.h"
#include "config.h"

#define  MAX_PASSWD_LEN 255 /* the same as max-len of result */
#define  RANDOM_PASSWD_LEN 6
#define  ID_LEN 64
#define  QUERY_LEN 256
//#define  TIME_SLOT 15       /* 20 seconds */
//#define  NR_MINUTE 3        /* time range we exame, better to be an odd number */
//#define  NR_RAN_PASSWD (60 * NR_MINUTE / TIME_SLOT)
#define  DEVICE_ID_PAD 4    /* we won't use the last DEVICE_ID_PAD characters in device ID string */

/*
 * sql table definition
 */
#define  SQL_DEVID_TABLE "device"
#define  SQL_AUTH_TABLE "radcheck"
#define  SQL_PASSWD_TABLE "passwd_cache"
/* pc id */
#define  SQL_KEY_TABLE "radkey"
/* phone id */
#define  SQL_WMKEY_TABLE "radwmkey"
#define  SQL_MEMBER_TABLE "member"
/*
 * sql query string definition
 */
#define  SQL_PHONEID_QUERY "select keyid from "SQL_WMKEY_TABLE" where id=(" \
    "select phone_id from "SQL_DEVID_TABLE" where username=\'%s\')"
#define  SQL_PCID_QUERY "select pc_index from "SQL_KEY_TABLE" where keyid=(" \
    "select usbkey from "SQL_MEMBER_TABLE" where username=\'%s\')"
#define  SQL_PASSWD_QUERY "select value from "SQL_AUTH_TABLE" where username=\'%s\'"
#define  SQL_DEL_QUERY "delete from "SQL_PASSWD_TABLE" where (unix_timestamp(now())-unix_timestamp(time))>%d"
#define  SQL_REPEAT_QUERY "select id from "SQL_PASSWD_TABLE" where passwd=\'%s\'"
#define  SQL_INS_PASSWD_QUERY "insert into "SQL_PASSWD_TABLE" (passwd, time) values (\'%s\', \'%s\')"

/* DES key definition */
const char des_key[12] = { '$', '1', '$', 'q', 'Y', '9', 'g', '/', '6', 'K', '4', '\0'};

/* sql server definition */
const char *sql_server = "localhost";
const char *sql_user = "freesvr";
const char *sql_passwd = "freesvr";
const char *sql_database = "audit_sec";
static int sql_port = 3306;

int debug;

my_bool rad_getpasswd_init( UDF_INIT *initid, UDF_ARGS *args, char *message );
void rad_getpasswd_deinit( UDF_INIT *initid );
char *rad_getpasswd( UDF_INIT *initid, UDF_ARGS *args, char *result,
                     unsigned long *res_length, char *null_value, char *error );

my_bool rad_getpasswd_init( UDF_INIT *initid, UDF_ARGS *args, char *message )
{
    /* make sure user has provided exactly three string arguments */
    if( args->arg_count != 4 ||
            args->arg_type[0] != STRING_RESULT || args->arg_type[1] != STRING_RESULT ||
            args->arg_type[2] != STRING_RESULT || args->arg_type[3] != STRING_RESULT ||
            args->args[0] == NULL || args->args[1] == NULL ||
            args->args[2] == NULL || args->args[3] == NULL )
    {
        strcpy( message, "rad_getpasswd requires four string arguments (username, recv_passwd, source_ip, nas_ip)" );
        return 1;
    }

        initid->ptr = ( char * )malloc( sizeof( struct options ) );

    /* will not be returning null */
    initid->maybe_null = 0;

    return 0;
}

void rad_getpasswd_deinit( UDF_INIT *initid __attribute__(( unused ) ) )
{
        if( initid->ptr )
                free( initid->ptr );
}

/*
 * divide recv_passwd into two parts, store each part in saved_passwd and
 * ran_passwd respectively. ran_passwd is the last 6 bytes of recv_passwd
 */
static void divide_passwd( const char *recv_passwd, char *saved_passwd,
                           int saved_passwd_len, char *ran_passwd, int ran_passwd_len )
{
    int i, j;
    int len;

    saved_passwd[0] = ran_passwd[0] = '\0';
    len = strlen( recv_passwd );

    if( len <= RANDOM_PASSWD_LEN )
    {
        fprintf( stderr, "the length of recv_passwd <= %d\n", RANDOM_PASSWD_LEN );
        return;
    }

    for( i = 0 ; i < len - RANDOM_PASSWD_LEN ; i++ ) ;
    strncpy( ran_passwd, recv_passwd + i, ran_passwd_len );
    for( j = 0 ; j < i ; j++ )
    {
        saved_passwd[j] = recv_passwd[j];
    }
    saved_passwd[j] = '\0';

    return;
}

static char *des_encrypt( const char *clear_text, char *encrypted_text, int len, const char *des_key )
{
    char *result;
    struct crypt_data *data;

    /* MUST alloc memory for data, it's too big for mysqld to alloc an automatic variable */
    if(( data = malloc( sizeof( struct crypt_data ) ) ) == NULL )
    {
        fprintf( stderr, "des_encrypt: malloc for struct crypt_data error\n" );
        return NULL;
    }

    data->initialized = 0;

    result = crypt_r( clear_text, des_key, data );
    if( result == NULL )
    {
        fprintf( stderr, "des_encrypt: crypt_r error: %s\n", strerror( errno ) );
        return NULL;
    }
    if( len <= strlen( result ) )
    {
        fprintf( stderr, "des_encrypt: crypt_r's return-string is too long\n" );
        return NULL;
    }
    strncpy( encrypted_text, result, len );
    free( data );
    return encrypted_text;
}

static int fetch_info( const char *server, const char *user,
                       const char *passwd, const char *database, int port, const char *username,
                       char *phone_id, int phone_id_len, char *pc_id, int pc_id_len, char *en_saved_passwd, int passwd_len )
{
    MYSQL *conn;
    MYSQL_RES *res;
    MYSQL_ROW row;
    char query[QUERY_LEN];

    if( !( conn = mysql_init( NULL ) ) )
    {
        fprintf( stderr, "fetch_info: mysql_init error\n" );
        return -1;
    }

    /* Connect to database */
    if( !mysql_real_connect( conn, server, user, passwd, database, port, NULL, 0 ) )
    {
        fprintf( stderr, "mysql_real_connect error with error code (%d): %s\n", mysql_errno( conn ), mysql_error( conn ) );
        return -1;
    }

    snprintf( query, QUERY_LEN, SQL_PASSWD_QUERY, username );
    /* send SQL query */
    if( mysql_query( conn, query ) )
    {
        fprintf( stderr, "mysql_query error (%d): %s\n", mysql_errno( conn ), mysql_error( conn ) );
        mysql_close( conn );
        return -1;
    }
    res = mysql_store_result( conn );
    row = mysql_fetch_row( res );

    if( row == NULL )
    {
        fprintf( stderr, "fetch_info: no such name %s in database\n", username );
        return -1;
    }

    if( row[0] == NULL )
    {
        fprintf( stderr, "fetch_info: user \'%s\' has no password\n", username );
        return -1;
    }
    else if( strlen( row[0] ) > passwd_len )
    {
        fprintf( stderr, "saved password is too long, must be less than %d\n", passwd_len );
        return -1;
    }
    else
    {
        strncpy( en_saved_passwd, row[0], passwd_len );
    }


    /*
     * The third query, fetch pc id
     */
    snprintf( query, QUERY_LEN, SQL_PCID_QUERY, username );
    fprintf( stderr, "query = %s\n", query );
    if( mysql_query( conn, query ) )
    {
        fprintf( stderr, "mysql_query error (%d): %s\n", mysql_errno( conn ), mysql_error( conn ) );
        mysql_close( conn );
        return -1;
    }
    res = mysql_store_result( conn );
    row = mysql_fetch_row( res );

    if( row == NULL )
    {
        pc_id[0] = '\0';
    }
    else if( strlen( row[0] ) > pc_id_len )
    {
        fprintf( stderr, "pc_id is too long, must be less than %d\n", pc_id_len );
        return -1;
    }
    else
    {
        strncpy( pc_id, row[0], strlen( row[0] ) - DEVICE_ID_PAD );
        pc_id[strlen( row[0] ) - DEVICE_ID_PAD] = '\0';
        if( debug )
            fprintf( stderr, "pc_id is %s\n", pc_id );
    }

    mysql_free_result( res );
    mysql_close( conn );
    return 0;
}

int ip_in_subnet( char * ip, char * subnet )
{
    char * sourceip = strdup( ip );
    char * group    = strdup( subnet );
    int index = 0, i, sip[4], net[8], sub[4], num;

    char* token = strtok( sourceip, "." );
    while( token != NULL )
    {
        sip[index++] = atoi( token );
        token = strtok( NULL, "." );
    }

    if( index != 4 )
    {
        free( sourceip );
        free( group );
        return -1;
    }

    index = 0;
    token = strtok( group, "./" );
    while( token != NULL )
    {
        net[index++] = atoi( token );
        token = strtok( NULL, "./" );
    }

    if( index == 5 )
    {
        for( i = 0; i < 4; i++ )
        {
            num = net[4] >= 8 ? 8 : net[4];
            sub[i] = ( 1 << num ) - 1;
            sub[i] = sub[i] << ( 8 - num );
            net[4] = net[4] >= 8 ? ( net[4] - 8 ) : 0;
        }
    }
    else if( index == 8 )
    {
        for( i = 0; i < 4; i++ )
        {
            sub[i] = net[i+4];
        }
    }
    else
    {
        free( sourceip );
        free( group );
        return -1;
    }
    for( i = 0; i < 4; i++ )
    {
        if(( sip[i] & sub[i] ) != ( net[i] & sub[i] ) )
        {
            free( sourceip );
            free( group );
            return -1;
        }
    }
    free( sourceip );
    free( group );
    return 0;
}

static int fetch_time_ip( const char *server, const char *user,
                          const char *passwd, const char *database, int port, const char *username,
                          char *phone_id, int phone_id_len, char *pc_id, int pc_id_len, char *en_saved_passwd, int passwd_len, char 
* ipaddr )
{
    MYSQL *conn;
    MYSQL_RES *res;
    MYSQL_ROW row;
    char query[QUERY_LEN], datenow[32], timenow[16], weektime[32], sourceip[32];

    int result, wday = 0, nullip_allow = 1;
    time_t timep;
    struct tm *p;
    time( &timep );
    p = localtime( &timep );

    wday = p->tm_wday ? p->tm_wday : 7;

    bzero( datenow,  sizeof( datenow ) );
    bzero( timenow,  sizeof( timenow ) );
    bzero( weektime, sizeof( weektime ) );
    bzero( sourceip, sizeof( sourceip ) );

    snprintf( datenow, sizeof( datenow ), "%04d-%02d-%02d %02d:%02d:%02d", 1900 + p->tm_year, 1 + p->tm_mon, p->tm_mday,
              p->tm_hour, p->tm_min, p->tm_sec );
    snprintf( timenow, sizeof( timenow ), "%02d:%02d:%02d", p->tm_hour, p->tm_min, p->tm_sec );

    fprintf( stderr, "%s: date is %s, time is %s, ipaddr is %s\n", __func__, datenow, timenow, ipaddr );

    if( !( conn = mysql_init( NULL ) ) )
    {
        fprintf( stderr, "%s: mysql_init error\n", __func__ );
        return -1;
    }

    /* Connect to database */
    if( !mysql_real_connect( conn, server, user, passwd, database, port, NULL, 0 ) )
    {
        fprintf( stderr, "mysql_real_connect error with error code (%d): %s\n", mysql_errno( conn ), mysql_error( conn ) );
        return -1;
    }

    snprintf( query, QUERY_LEN, "SELECT start_time,end_time,weektime,sourceip,nullsourceipallow FROM member WHERE username='%s'",
              username );
    /* send SQL query */
    if( mysql_query( conn, query ) )
    {
        fprintf( stderr, "mysql_query error (%d): %s\n", mysql_errno( conn ), mysql_error( conn ) );
        mysql_close( conn );
        return -1;
    }
    res = mysql_store_result( conn );
    row = mysql_fetch_row( res );

    if( row == NULL )
    {
        fprintf( stderr, "%s: no such name %s in database\n", __func__, username );
        return -1;
    }

    if( row[2] ) strcpy( weektime, row[2] );
    if( row[3] ) strcpy( sourceip, row[3] );
    if( row[4] ) nullip_allow = atoi( row[4] );
    fprintf( stderr, "%s: start_time=%s,end_time=%s,weektime=%s,sourceip=%s,nullip_allow=%d\n",
             __func__, row[0], row[1], row[2], row[3], row[4] );

    /* judge start_time */
    if( row[0] != NULL )
    {
        if( strcmp( datenow, row[0] ) < 0 )
        {
            fprintf( stderr, "%s: user \'%s\' start_time is in the future!\n", __func__, username );
            fprintf( stderr, "%s: user \'%s\' start_time is %s, now date is %s\n", __func__, username, row[0], datenow );
            return -1;
        }
    }
    /* judge end_time */
    if( row[1] != NULL )
    {
        if( strcmp( datenow, row[1] ) > 0 )
        {
            fprintf( stderr, "%s: user \'%s\' end_time is in the past!\n", __func__, username );
            fprintf( stderr, "%s: user \'%s\' end_time is %s, now date is %s\n", __func__, username, row[1], datenow );
            return -1;
        }
    }

    //mysql_free_result(res);

    if( strlen( weektime ) != 0 )
    {
        bzero( query, QUERY_LEN );
        snprintf( query, QUERY_LEN, "SELECT start_time%d,end_time%d FROM weektime WHERE policyname='%s'", wday, wday, weektime );

        if( mysql_query( conn, query ) )
        {
            fprintf( stderr, "mysql_query error (%d): %s\n", mysql_errno( conn ), mysql_error( conn ) );
            mysql_close( conn );
            return -1;
        }
        res = mysql_store_result( conn );
        row = mysql_fetch_row( res );

        if( row == NULL )
        {
            fprintf( stderr, "%s: no such policyname %s in TABLE weektime\n", __func__, weektime );
            return -1;
        }

        fprintf( stderr, "%s: user \'%s\' weektime start_time is %s, weektime end_time is %s, now wday is %d\n",
                 __func__, username, row[0], row[1], wday );

        if( row[0] != NULL )
        {
            if( strcmp( timenow, row[0] ) < 0 )
            {
                fprintf( stderr, "%s: user \'%s\' weektime start_time is in the future!\n", __func__, username );
                fprintf( stderr, "%s: user \'%s\' weektime start_time is %s, now time is %s\n", __func__, username, row[0], timenow 
);
                return -1;
            }
        }

        if( row[1] != NULL )
        {
            if( strcmp( timenow, row[1] ) > 0 )
            {
                fprintf( stderr, "%s: user \'%s\' weektime end_time is in the past!\n", username, __func__ );
                fprintf( stderr, "%s: user \'%s\' weektime end_time is %s, now time is %s\n", __func__, username, row[1], timenow );
                return -1;
            }
        }
    }

    if( strlen( sourceip ) != 0 )
    {
        if( ipaddr == NULL || strlen( ipaddr ) == 0 )
        {
            mysql_free_result( res );
            mysql_close( conn );

            if( nullip_allow == 1 )
                return 0;
            else return -1;
        }

        bzero( query, QUERY_LEN );
        snprintf( query, QUERY_LEN, "SELECT sourceip FROM sourceip WHERE groupname='%s'", sourceip );

        if( mysql_query( conn, query ) )
        {
            fprintf( stderr, "mysql_query error (%d): %s\n", mysql_errno( conn ), mysql_error( conn ) );
            mysql_close( conn );
            return -1;
        }
        res = mysql_store_result( conn );
        while( 1 )
        {
            row = mysql_fetch_row( res );

            if( row == NULL )
            {
                fprintf( stderr, "%s: no more groupname %s in TABLE sourceip\n", __func__, sourceip );
                return -1;
            }

            if( row[0] != NULL )
            {
                fprintf( stderr, "%s: sourceip is %s\n", __func__, row[0] );
                if(( result = ip_in_subnet( ipaddr, row[0] ) ) == 0 )
                {
                    fprintf( stderr, "%s: Successed! source_ipaddr is %s, and subnet is %s\n", __func__, ipaddr, row[0] );
                    break;
                }
                else
                {
                    fprintf( stderr, "%s: Failed! source_ipaddr is %s, and subnet is %s\n", __func__, ipaddr, row[0] );
                }
            }
        }
    }

    mysql_free_result( res );
    mysql_close( conn );
    return 0;
}

static char *convert_ascii_to_utf16( char **dest, char **src )
{
#if 0
    int n;
    for( n = 0; n < strlen( src ) ; n++ )
    {
        dest[n*2+1] = 0;
        dest[n*2] = src[n];
    }

    return dest;
#endif
    iconv_t icd;
    size_t msg_len = strlen( *src );
    size_t utf16_msg_len = msg_len * 2;
    char *fromcode = "ASCII";
    char *tocode = "UTF16LE";

    icd = iconv_open( tocode, fromcode );
    if( icd < 0 )
    {
        fprintf( stderr, "convert_ascii_to_utf16: iconv_open error : %s\n", strerror( errno ) );
        return NULL;
    }
    if( iconv( icd, src, &msg_len, dest, &utf16_msg_len ) < 0 )
    {
        fprintf( stderr, "convert_ascii_to_utf16: iconv error : %s\n", strerror( errno ) );
        return NULL;
    }

    iconv_close( icd );
    return *dest;
}

/*
 * Return the first 6 types of md5-hash(dev_id+yyyymmddhhmmss)
 * dev_id is fetched from database, hash(MAGIC_KEY+phone_id)
 */
static char *get_random_passwd( char *result, int len, const char *dev_id, const char *time )
{
   本处已经删除
}

/*
 * Convert the time since the Epoch (00:00:00 UTC, January 1, 1970, measured in seconds.)
 * "time" into string like "20090220113000"
 */
static char *get_timestr( char *timestr, int len, time_t time )
{
 本处已经删除
}

/*
 * According to now, get the basetime for later use.
 * now      - 1234571 - 2009.02.20.11.11.11
 * basetime - 1234500 - 2009.02.20.11.10.00
 * [0-19] -> 00 [20 - 39] -> 20 [40 - 59] -> 40 according to TIME_SLOT
 */
static time_t get_basetime( time_t now, int nr_minute )
{
    time_t mod;
    time_t ret;

    mod = now % 60;
    ret = now - mod - 60 * ( nr_minute / 2 );
    return ret;
}

/*
 * Computing random passwords, compare with the string pointerd by check.
 * On success return 1, otherwise 0 will be returned
 */
static int check_ran_passwd( const char *check, const char *dev_id, time_t basetime, int time_slot, int nr_minute )
{
    //char to_check[NR_RAN_PASSWD][RANDOM_PASSWD_LEN + 1];
    //char timestr[NR_RAN_PASSWD][14 + 1];    /* yyyymmddhhmmss */

    char to_check[192][RANDOM_PASSWD_LEN + 1];
    char timestr[192][14 + 1];    /* yyyymmddhhmmss */

    int i, nr_ran_passwd;

    nr_ran_passwd = 60 * nr_minute / time_slot;

    for( i = 0; i < nr_ran_passwd; i++ )
    {
        if( get_timestr( timestr[i], 14 + 1, basetime + i * time_slot ) == NULL )
        {
            fprintf( stderr, "check_ran_passwd: get_timestr error\n" );
            return 0;
        }
        if( get_random_passwd( to_check[i], RANDOM_PASSWD_LEN + 1, dev_id, timestr[i] ) == NULL )
        {
            fprintf( stderr, "check_ran_passwd: get_random_passwd error\n" );
            return 0;
        }
    }

    if( debug )
    {
        fprintf( stderr, "Comparing two random passwords:\n" );
        fprintf( stderr, "check is %s\n", check );
    }

    for( i = 0; i < nr_ran_passwd; i++ )
    {
        if( debug )
            fprintf( stderr, "to_check[%d]  is %s, timestr[%d] is %s\n", i, to_check[i], i, timestr[i] );

        if( strncmp( check, to_check[i], RANDOM_PASSWD_LEN ) == 0 )
        {
            if( debug )
                fprintf( stderr, "check_ran_passwd: found match, return\n" );

            /* match found */
            return 1;
        }
    }

    /* match not found */
    return 0;
}

/*
 * Check wether there is a valid random password.
 * On success return 1, otherwise 0 will be returned
 */
static int valid_ran_passwd( const char *check, int time_slot, const char *phone_id, const char *pc_id, int nr_minute )
{
    int ret1 = 0;
    int ret2 = 0;
    time_t now;
    time_t basetime;

    now = time( NULL );
    basetime = get_basetime( now, nr_minute );

    if( debug )
        fprintf( stderr, "basetime is %ld\n", ( long )basetime );

    if( pc_id[0] != '\0' )
    {
        ret2 = check_ran_passwd( check, pc_id, basetime, time_slot, nr_minute );
    }

    if(( ret2 != 1 ) )
    {
        /* no match found */
        return 0;
    }

    return 1;
}

/*
 * Delete expired passwords in table SQL_PASSWD_TABLE
 * return 0 when everything is OK
 * return -1 on error
 */
static int del_expired( const char *server, const char *user, const char *passwd,
                        const char *database, int port, int exp_time, int vpn_exp_hour )
{
    MYSQL *conn;
    char query[QUERY_LEN];

    if( !( conn = mysql_init( NULL ) ) )
    {
        fprintf( stderr, "del_expired: mysql_init error\n" );
        return -1;
    }

    /* Connect to database */
    if( !mysql_real_connect( conn, server, user, passwd, database, port, NULL, 0 ) )
    {
        fprintf( stderr, "mysql_real_connect error with error code (%d): %s\n", mysql_errno( conn ), mysql_error( conn ) );
        return -1;
    }

    snprintf( query, QUERY_LEN, SQL_DEL_QUERY, exp_time * 60 );
    /* send SQL query */
    if( mysql_query( conn, query ) )
    {
        fprintf( stderr, "mysql_query error (%d): %s\n", mysql_errno( conn ), mysql_error( conn ) );
        mysql_close( conn );
        return -1;
    }

    snprintf( query, QUERY_LEN, "delete from vpndynamicpassword where TIMESTAMPDIFF(HOUR,authtime,now())>%d", vpn_exp_hour );
    /* send SQL query */
    if( mysql_query( conn, query ) )
    {
        fprintf( stderr, "mysql_query error (%d): %s\n", mysql_errno( conn ), mysql_error( conn ) );
        mysql_close( conn );
        return -1;
    }

    mysql_close( conn );
    return 0;
}

/*
 * Check whether the givev password is still in table passwd_cache,
 * if so return -1 indicates authentication fails,
 * if the given password is not in table passwd_cache, insert it in
 * the table, return 0 indicates authentication succeeds.
 */
static int check_repeat( const char* given_passwd, const char *server,
                         const char *user, const char *passwd, const char *database, int port )
{
    MYSQL *conn;
    MYSQL_RES *res;
    MYSQL_ROW row;
    char query[QUERY_LEN];
    char timestr[14 + 1];
    time_t now;

    now = time( NULL );
    if( get_timestr( timestr, 15, now ) == NULL )
    {
        fprintf( stderr, "check_repeat: get_timestr error\n" );
        return -1;
    }

    if( !( conn = mysql_init( NULL ) ) )
    {
        fprintf( stderr, "check_repeat: mysql_init error\n" );
        return -1;
    }

    /* Connect to database */
    if( !mysql_real_connect( conn, server, user, passwd, database, port, NULL, 0 ) )
    {
        fprintf( stderr, "check_repeat: mysql_real_connect error with error code (%d): %s\n",
                 mysql_errno( conn ), mysql_error( conn ) );
        return -1;
    }

    snprintf( query, QUERY_LEN, SQL_REPEAT_QUERY, given_passwd );
    /* send SQL query */
    if( mysql_query( conn, query ) )
    {
        fprintf( stderr, "check_repeat: mysql_query error (%d): %s\n", mysql_errno( conn ), mysql_error( conn ) );
        mysql_close( conn );
        return -1;
    }
    res = mysql_store_result( conn );
    row = mysql_fetch_row( res );

    /* the given password is still in table SQL_PASSWD_TABLE */
    if( row != NULL )
    {
        if( debug )
            fprintf( stderr, "check_repeat: the given password is still in table %s\n", SQL_PASSWD_TABLE );

        return -1;
    }

    snprintf( query, QUERY_LEN, SQL_INS_PASSWD_QUERY, given_passwd, timestr );
    /* send SQL query */
    if( mysql_query( conn, query ) )
    {
        fprintf( stderr, "check_repeat: mysql_query error (%d): %s\n", mysql_errno( conn ), mysql_error( conn ) );
        mysql_close( conn );
        return -1;
    }

    mysql_free_result( res );
    mysql_close( conn );
    return 0;
}

/*static const char *str_time(time_t caltime, const char *fmt)
{
    static char tstr[256];
    struct tm *tm;

    if (fmt == NULL)
      fmt = "%Y-%m-%d %H:%M:%S";

    memset(tstr, 0x00, sizeof(tstr));

    if ( (tm = localtime(&caltime)) == NULL)
      return(NULL);

    if (strftime(tstr, sizeof(tstr) -1, fmt, tm) == 0)
      return(NULL);

    return(tstr);
}*/

static int fetch_vpn_dynamic_password( const char *username, const char *rand_password,
                                       const char *sourceip, const char *nasip,
                                       const char *server, const char *user, const char *passwd,
                                       const char *database, int port )
{
    MYSQL *conn;
    MYSQL_RES *res;
    MYSQL_ROW row;
    char query[QUERY_LEN];
    int ret;

    if( !( conn = mysql_init( NULL ) ) )
    {
        fprintf( stderr, "fetch_info: mysql_init error\n" );
        return -1;
    }

    /* Connect to database */
    if( !mysql_real_connect( conn, server, user, passwd, database, port, NULL, 0 ) )
    {
        fprintf( stderr, "mysql_real_connect error with error code (%d): %s\n", mysql_errno( conn ), mysql_error( conn ) );
        return -1;
    }

    snprintf( query, QUERY_LEN, "SELECT id FROM vpndynamicpassword WHERE username='%s' AND dynamicpassword='%s' "\
              "AND callingstationid='%s' AND nasipaddress='%s'", username, rand_password, sourceip, nasip );

    /* send SQL query */
    if( mysql_query( conn, query ) )
    {
        fprintf( stderr, "mysql_query error (%d): %s\n", mysql_errno( conn ), mysql_error( conn ) );
        mysql_close( conn );
        return -1;
    }
    res = mysql_store_result( conn );
    row = mysql_fetch_row( res );

    if( row == NULL )
    {
        if( debug ) fprintf( stderr, "No record in vpn_dynamic_password.\n" );
        ret = -1;
    }
    else
    {
        if( debug ) fprintf( stderr, "fetch a record in vpn_dynamic_password\n" );
        ret = 0;
    }

    mysql_free_result( res );
    mysql_close( conn );
    return ret;
}

static int insert_vpn_dynamic_password( const char *username, const char *rand_password,
                                        const char *sourceip, const char *nasip,
                                        const char *server, const char *user, const char *passwd,
                                        const char *database, int port )
{
    MYSQL *conn;
    MYSQL_RES *res;
    MYSQL_ROW row;
    char query[QUERY_LEN];

    if( !( conn = mysql_init( NULL ) ) )
    {
        fprintf( stderr, "fetch_info: mysql_init error\n" );
        return -1;
    }

    /* Connect to database */
    if( !mysql_real_connect( conn, server, user, passwd, database, port, NULL, 0 ) )
    {
        fprintf( stderr, "mysql_real_connect error with error code (%d): %s\n", mysql_errno( conn ), mysql_error( conn ) );
        return -1;
    }

    snprintf( query, QUERY_LEN, "INSERT INTO vpndynamicpassword (authtime,username,dynamicpassword,callingstationid,nasipaddress) "\
              "VALUES(now(),'%s','%s','%s','%s')", username, rand_password, sourceip, nasip );

        //fprintf( stderr,"%s\n", query );

    /* send SQL query */
    if( mysql_query( conn, query ) )
    {
        fprintf( stderr, "mysql_query error (%d): %s\n", mysql_errno( conn ), mysql_error( conn ) );
        mysql_close( conn );
        return -1;
    }

    mysql_close( conn );
    return 0;
}

static int fetch_level_from_member(const char *username, const char *server, const char *user, const char *passwd,
                                        const char *database, int port )

{
        MYSQL *conn;
        MYSQL_RES *res;
    MYSQL_ROW row;
    char query[QUERY_LEN];
        int ret;

    if( !( conn = mysql_init( NULL ) ) )
    {
        fprintf( stderr, "fetch_info: mysql_init error\n" );
        return -1;
    }

    /* Connect to database */
    if( !mysql_real_connect( conn, server, user, passwd, database, port, NULL, 0 ) )
    {
        fprintf( stderr, "mysql_real_connect error with error code (%d): %s\n", mysql_errno( conn ), mysql_error( conn ) );
        return -1;
    }

    snprintf( query, QUERY_LEN, "select level from member where username='%s' limit 1", username);

    /* send SQL query */
    if( mysql_query( conn, query ) )
    {
        fprintf( stderr, "mysql_query error (%d): %s\n", mysql_errno( conn ), mysql_error( conn ) );
        mysql_close( conn );
        return -1;
    }

        res = mysql_store_result(conn);
        row = mysql_fetch_row(res);

        if (row != NULL && row[0] != NULL)
                ret = atoi(row[0]);
        else 
                ret = -1;

    mysql_free_result(res);
        mysql_close( conn );
    return ret;
}

static int fetch_result_from_devices(const char *username, const char *nasip, 
                const char *server, const char *user, const char *passwd,
        const char *database, int port )

{
        MYSQL *conn;
        MYSQL_RES *res;
    MYSQL_ROW row;
    char query[QUERY_LEN];
        int ret;

    if( !( conn = mysql_init( NULL ) ) )
    {
        fprintf( stderr, "fetch_info: mysql_init error\n" );
        return -1;
    }

    /* Connect to database */
    if( !mysql_real_connect( conn, server, user, passwd, database, port, NULL, 0 ) )
    {
        fprintf( stderr, "mysql_real_connect error with error code (%d): %s\n", mysql_errno( conn ), mysql_error( conn ) );
        return -1;
    }

    snprintf( query, QUERY_LEN, "SELECT username FROM devices WHERE username='%s' and device_ip='%s' limit 1", username, nasip);

    /* send SQL query */
    if( mysql_query( conn, query ) )
    {
        fprintf( stderr, "mysql_query error (%d): %s\n", mysql_errno( conn ), mysql_error( conn ) );
        mysql_close( conn );
        return -1;
    }

        res = mysql_store_result(conn);
        row = mysql_fetch_row(res);

        if (row != NULL && row[0] != NULL)
                ret = atoi(row[0]);
        else
                ret = -1;

    mysql_free_result(res);
        mysql_close( conn );
    return ret;
}

char *rad_getpasswd( UDF_INIT *initid, UDF_ARGS *args,
                     char *result, unsigned long *res_length,
                     char *null_value, char *error )
{
    /* encrypted form, maybe des, get this from radcheck table */
    char en_saved_passwd[MAX_PASSWD_LEN];
    char *username = args->args[0];
    /* Cleartext form saved_passwd+random_num */
    char prec_passwd[64], tmp[4];
    char *recv_passwd = args->args[1];

    char *ipaddr = args->args[2];
    char *nasip = args->args[3];

    /* saved password, cleartext */
    char saved_passwd[MAX_PASSWD_LEN];
    /* random password, +1 for the null byte */
    char ran_passwd[RANDOM_PASSWD_LEN + 1];
    /* des-encrypted save_passwd, will be compared with en_saved_passwd */
    char en_computed_passwd[MAX_PASSWD_LEN];
    /* Device ID binding with username */
    char phone_id[ID_LEN];
    char pc_id[ID_LEN];
    char pass_buffer[MAX_PASSWD_LEN];
    char *ptr;
    int i, j, ascii, vpn_auth, valid_nas_ip = 0, level;

    struct options *config = ( struct options * )initid->ptr;
    read_config( config );
    debug = config->debug;

        /*if (strlen(nasip))
        {
                if (fetch_result_from_devices(username, nasip, sql_server, sql_user, sql_passwd, sql_database, sql_port) != 0)
                {
                        if( debug ) fprintf( stderr, "Can not fetch result from devices when username=%s and nasip=%s\n", username, 
nasip );
                        sprintf( result, "xxxxxx" );
                        *res_length = RANDOM_PASSWD_LEN;
                        return result;
                }
        }*/

        if (strlen(nasip))
        {
                for( i = 0; i < 20; i++ )
                {
                        if( strcmp( config->nas_ip_address[i], nasip ) == 0 )
                        {
                                valid_nas_ip = 1;
                                //break;
                        }
                }
                if (valid_nas_ip == 0)
                {
                        level = fetch_level_from_member(username, sql_server, sql_user, sql_passwd, sql_database, sql_port);
                        if (debug) fprintf(stderr, "Level = %d\n", level);
                        if (level != 11)
                        {
                                if( debug ) fprintf( stderr, "LEVEL is not 11.\n" );
                                if( debug ) fprintf( stderr, "Invalid NAS IP Address %s\n", nasip );
                                sprintf( result, "xxxxxx" );
                                *res_length = RANDOM_PASSWD_LEN;
                                return result;
                        }
                        else
                        {
if (fetch_result_from_devices(username, nasip, sql_server, sql_user, sql_passwd, sql_database, sql_port) != 0)
                {
                        if( debug ) fprintf( stderr, "Can not fetch result from devices when username=%s and nasip=%s\n", username, 
nasip );
                        sprintf( result, "xxxxxx" );
                        *res_length = RANDOM_PASSWD_LEN;
                        return result;
                }
                        }
                }
        }

    if( strlen( ipaddr ) && strlen( nasip ) )
    {
        vpn_auth = 1;

        /*ptr = config.nas_ip_address[0];

        while( ptr != NULL )*/
                for( i = 0; i < 20; i++ )
        {
            if( strcmp( config->nas_ip_address[i], nasip ) == 0 )
            {
                valid_nas_ip = 1;
                break;
            }
        }

    }
    else
    {
        vpn_auth = 0;
        valid_nas_ip = 1;
    }

        if( debug )
                fprintf( stderr, "sourceip=%s, nasip=%s, vpn_auth = %d\n", ipaddr, nasip, vpn_auth );

    /*if( strlen(ipaddr) == 0 && valid_nas_ip == 0 )
    {
        if( debug ) fprintf( stderr, "Invalid NAS IP Address %s\n", nasip );
        sprintf( result, "xxxxxx" );
        *res_length = RANDOM_PASSWD_LEN;
        return result;
    }*/



    bzero( prec_passwd, sizeof( prec_passwd ) );

    for( i = 0, j = 0; i < strlen( args->args[1] ); i++ )
    {
        if( recv_passwd[i] == '=' )
        {
            tmp[0] = recv_passwd[++i];
            tmp[1] = recv_passwd[++i];
            tmp[2] = 0x00;
            sscanf( tmp, "%x", &ascii );
            prec_passwd[j++] = ascii;
        }
        else
        {
            prec_passwd[j++] = recv_passwd[i];
        }
    }

    recv_passwd = prec_passwd;

    if( debug )
        fprintf( stderr, "rad_getpasswd: Comming user \'%s\' %s debug=%d\n", username, recv_passwd, config->debug );

    /*
     * Delete expired passwords, keep them for NR_MINUTE minutes
     */
    if( del_expired( sql_server, sql_user, sql_passwd, sql_database, sql_port, config->nr_minute, config->vpn_exp_hour ) != 0 )
    {
        sprintf( result, "xxxxxx" );
        *res_length = RANDOM_PASSWD_LEN;
        if( debug ) fprintf( stderr, "del_expired error\n" );
        return result;
    }

    /*if (fetch_time_ip(sql_server, sql_user, sql_passwd, sql_database, sql_port,
      username, phone_id, ID_LEN, pc_id, ID_LEN, en_saved_passwd, MAX_PASSWD_LEN, ipaddr) != 0)
      {
      sprintf(result, "xxxxxx");
     *res_length = RANDOM_PASSWD_LEN;
     fprintf(stderr, "fetch_info error\n");
     return result;
     }*/

    /*
     * Get some information from database, phone_id and pc_id binding
     * with the username. If there is no binding *_id, return en_computed_passwd
     */
    if( fetch_info( sql_server, sql_user, sql_passwd, sql_database, sql_port,
                    username, phone_id, ID_LEN, pc_id, ID_LEN, en_saved_passwd, MAX_PASSWD_LEN ) != 0 )
    {
        sprintf( result, "xxxxxx" );
        *res_length = RANDOM_PASSWD_LEN;
        fprintf( stderr, "fetch_info error\n" );
        return result;
    }

    /*
     * If there is no binding *_id, return des-encrypted en_saved_passwd as the result
     */
    if(( pc_id[0] == '\0' ) )
    {
#if 0
        ptr = des_encrypt( recv_passwd, pass_buffer, MAX_PASSWD_LEN, des_key );
        if( ptr == NULL )
        {
            *error = 1;
            sprintf( result, "xxxxxx" );
            *res_length = RANDOM_PASSWD_LEN;
            fprintf( stderr, "des_encrypt error\n" );
            return result;
        }
        strncpy( result, ptr, MAX_PASSWD_LEN );
        *res_length = strlen( ptr );
        if( *res_length >= MAX_PASSWD_LEN )
        {
            fprintf( stderr, "The encrypted recv_passwd might be too long\n" );
        }
#endif
        if( debug )
            fprintf( stderr, "no binding device ID, return en_saved_passwd\n" );

        strncpy( result, en_saved_passwd, MAX_PASSWD_LEN );
        *res_length = strlen( result );
        return result;
    }

    /*
     * Divide the recv_passwd into two parts
     */
    divide_passwd( recv_passwd, saved_passwd, MAX_PASSWD_LEN, ran_passwd, RANDOM_PASSWD_LEN + 1 );
    if( saved_passwd[0] == '\0' || ran_passwd[0] == '\0' )
    {
        sprintf( result, "xxxxxx" );
        *res_length = RANDOM_PASSWD_LEN;
        fprintf( stderr, "divide_passwd error\n" );
        return result;
    }
    if( debug )
    {
        fprintf( stderr, "recv_passwd is %s\n", recv_passwd );
        fprintf( stderr, "saved_passwd is %s\n", saved_passwd );
        fprintf( stderr, "ran_passwd is %s\n", ran_passwd );
    }

    /*
     * des-encrypt the saved password that user passes
     */
    ptr = des_encrypt( saved_passwd, pass_buffer, MAX_PASSWD_LEN, des_key );
    if( ptr == NULL )
    {
        sprintf( result, "xxxxxx" );
        *res_length = RANDOM_PASSWD_LEN;
        fprintf( stderr, "des_encrypt error\n" );
        return result;
    }
    strncpy( en_computed_passwd, ptr, MAX_PASSWD_LEN );

    /*
     * Compare the two passwords
     */
    if( strcmp( en_saved_passwd, en_computed_passwd ) != 0 )
    {
        if( debug )
            fprintf( stderr, "saved password not matched: saved_passwd is %s, computed_passwd is %s\n", en_saved_passwd, en_computed
_passwd );

        /* saved password not matched, return "xxxxxx" as the des-encrypted password */
        sprintf( result, "xxxxxx" );
        *res_length = RANDOM_PASSWD_LEN;
        return result;
    }

    if( vpn_auth &&
            fetch_vpn_dynamic_password( username, ran_passwd, ipaddr, nasip,
                                        sql_server, sql_user, sql_passwd, sql_database, sql_port ) == 0 )
    {
        ptr = des_encrypt( recv_passwd, pass_buffer, MAX_PASSWD_LEN, des_key );
        if( ptr == NULL )
        {
            sprintf( result, "xxxxxx" );
            *res_length = RANDOM_PASSWD_LEN;
            fprintf( stderr, "the second des_encrypt error\n" );
            return result;
        }

        if( strlen( ptr ) > MAX_PASSWD_LEN - 1 )
        {
            sprintf( result, "xxxxxx" );
            *res_length = RANDOM_PASSWD_LEN;
            fprintf( stderr, "The result string is too long. max_len is %d\n", MAX_PASSWD_LEN - 1 );
            return result;
        }

        strncpy( result, pass_buffer, MAX_PASSWD_LEN );
        *res_length = strlen( pass_buffer );
        if( debug )
            fprintf( stderr, "rad_getpasswd: Congratulations!! All passwords are matched!!\n" );

        return result;
    }

    /*
     * Now, compute 18 or 24 random passwords, comparing with ran_passwd
     */
    if( valid_ran_passwd( ran_passwd, config->slot, phone_id, pc_id, config->nr_minute ) != 1 )
    {
        if( debug )
            fprintf( stderr, "random password not matched\n" );

        /* random password not matched, return "xxxxxx" as the des-encrypted password */
        sprintf( result, "xxxxxx" );
        *res_length = RANDOM_PASSWD_LEN;
        return result;
    }

    ptr = des_encrypt( recv_passwd, pass_buffer, MAX_PASSWD_LEN, des_key );
    if( ptr == NULL )
    {
        sprintf( result, "xxxxxx" );
        *res_length = RANDOM_PASSWD_LEN;
        fprintf( stderr, "the second des_encrypt error\n" );
        return result;
    }

    if( strlen( ptr ) > MAX_PASSWD_LEN - 1 )
    {
        sprintf( result, "xxxxxx" );
        *res_length = RANDOM_PASSWD_LEN;
        fprintf( stderr, "The result string is too long. max_len is %d\n", MAX_PASSWD_LEN - 1 );
        return result;
    }

    /*
     * Check if user inputs password repeatly within NR_MINUTE minute(s)
     */
    if( check_repeat( pass_buffer, sql_server, sql_user, sql_passwd, sql_database, sql_port ) != 0 )
    {
        if( debug )
            fprintf( stderr, "Please DO NOT input password too often. Please wait for %d minutes\n", config->nr_minute );

        sprintf( result, "xxxxxx" );
        *res_length = RANDOM_PASSWD_LEN;
        return result;
    }

    if( vpn_auth && insert_vpn_dynamic_password( username, ran_passwd, ipaddr, nasip,
                                     sql_server, sql_user, sql_passwd, sql_database, sql_port ) != 0 )
    {
        if( debug )
            fprintf( stderr, "Insert into VPN_DYNAMIC_PASSWORD table failed.\n" );

        sprintf( result, "xxxxxx" );
        *res_length = RANDOM_PASSWD_LEN;
        return result;
    }

    /*
     * Everything is OK, return result
     */
    strncpy( result, pass_buffer, MAX_PASSWD_LEN );
    *res_length = strlen( pass_buffer );
    if( debug )
        fprintf( stderr, "rad_getpasswd: Congratulations!! All passwords are matched!!\n" );

    return result;
}
