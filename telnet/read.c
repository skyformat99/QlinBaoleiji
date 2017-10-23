#include <unistd.h>
#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <sys/stat.h>
#include <fcntl.h>
#include<termios.h>
#include<fcntl.h>
#include<string.h>
#include "/opt/freesvr/sql/include/mysql/mysql.h"
#define CONLINELENGTH 512
#define GLOBAL_CFG "/opt/freesvr/audit/etc/global.cfg"

struct timeval tv,tvpre,tvstart,tvend;
struct timezone tz;
int sid;
int fd;
int start_time=0;
int strlength=0;
double speed=1;
double progress_rate=0;
int g_stop=0;
char * string;
char content_command;

MYSQL my_connection;
MYSQL_RES *res_ptr;
MYSQL_ROW sqlrow;

fd_set rfds,rs;
struct timeval key_tv;

int i,r,q,j;
struct termios saveterm,nt;
int key_fd=0;
unsigned char c,buf[32];

char confLine[CONLINELENGTH] = {};
char context[CONLINELENGTH] ={};
FILE * fp;
char *locate = NULL;
char *pmove = NULL;
char *pline;
char *sql_query;
int string_length=10000;
int itl;

char mysql_host[50];
char mysql_user[50];
char mysql_passwd[50];
char mysql_db[50];
char mysql_serv_port[50];

void my_exit()
{
    printf("\n\r<<Replay End>>\n\r");
    sleep(3);
    printf("\n\rpress ENTER to quit\n\r");
    getchar();
	tcsetattr(key_fd,TCSANOW,&saveterm);
	system("stty sane");
	exit(1);
}

void seek_replay(int time)
{
	start_time=time;
	if(time>tvend.tv_sec)
	{
		return;
	}
//	printf("%c%c%c%c%c%c",0x1b,0x5b,0x48,0x1b,0x5b,0x4a);
	lseek(fd,0,SEEK_SET);
	if(start_time<tvstart.tv_sec)
	{
		return;
	}
}

int main(int argc, char *argv[])
{
    if((fp = fopen(GLOBAL_CFG, "r")) == NULL)
    {
        printf("Open file : %s failed!!\n", GLOBAL_CFG);
        exit(-1);
    }   
    while(fgets(confLine, CONLINELENGTH, fp) != NULL)
    {
        pline = confLine;
        if(*pline == '#')
        {
            memset(confLine, 0, CONLINELENGTH);
            continue;
        }   
        while(isspace(*pline) != 0) pline++;
        locate = strchr(pline, '=');
        if(locate == NULL)
        {
            memset(confLine, 0, CONLINELENGTH);
            continue;
        }   
        pmove = locate;
        pmove--;
        while(isspace(*pmove) != 0)pmove--;
        itl = pmove - pline + 1; 
        
      if(itl == strlen("mysql-server") && strncasecmp(pline,"mysql-server",itl)==0)
      {
                locate++;
                while(isspace(*locate) != 0)locate++;
                pmove = locate;
                while(isspace(*pmove) == 0)pmove++;
                if(pmove-locate+1>0)
                {
                     strncpy(mysql_host, locate, pmove-locate);
                }
      }
      else if(itl == strlen("mysql-port") && strncasecmp(pline,"mysql-port",itl)==0)
      {
                locate++;
                while(isspace(*locate) != 0)locate++;
                pmove = locate;
                while(isspace(*pmove) == 0)pmove++;
                if(pmove-locate+1>0)
                {
                     strncpy(mysql_serv_port, locate, pmove-locate);
                }
      }
      else if(itl == strlen("mysql-user") && strncasecmp(pline,"mysql-user",itl)==0)
      {
                locate++;
                while(isspace(*locate) != 0)locate++;
                pmove = locate;
                while(isspace(*pmove) == 0)pmove++;
                if(pmove-locate+1>0)
                {
                     strncpy(mysql_user, locate, pmove-locate);
                }
      }
      else if(itl == strlen("mysql-pass") && strncasecmp(pline,"mysql-pass",itl)==0)
      {
                locate++;
                while(isspace(*locate) != 0)locate++;
                pmove = locate;
                while(isspace(*pmove) == 0)pmove++;
                if(pmove-locate+1>0)
                {
                     strncpy(mysql_passwd, locate, pmove-locate);
                }
      }
      else if(itl == strlen("mysql-db") && strncasecmp(pline,"mysql-db",itl)==0)
      {
                locate++;
                while(isspace(*locate) != 0)locate++;
                pmove = locate;
                while(isspace(*pmove) == 0)pmove++;
                if(pmove-locate+1>0)
                {
                     strncpy(mysql_db, locate, pmove-locate);
                }
      }
    }

    fclose(fp);

    mysql_init(&my_connection);
    if (mysql_real_connect(&my_connection,mysql_host,mysql_user,mysql_passwd,mysql_db,mysql_serv_port,NULL,0))
    {
        //printf("Connection DB success\n");
    }   
    else
    {
        printf("Connect DB Fail\n");
    }
    sql_query=(char *)malloc(string_length);
    if(mysql_query(&my_connection,"set NAMES utf8"))
    {
        printf("set utf8 err:%s\n", mysql_error(&my_connection));
        exit(0);
    }
    bzero(sql_query,string_length);
    sprintf(sql_query,"select sid from sessions where replace(replayfile,'\"','')='%s'",argv[1]);
    if(mysql_query(&my_connection,sql_query))
    {
        printf("%s err:%s\n",sql_query,mysql_error(&my_connection));
        exit(0);
    }
    res_ptr = mysql_store_result(&my_connection);

    if(res_ptr)
    {
        while(sqlrow = mysql_fetch_row(res_ptr))
        {
            sid = atoi(sqlrow[0]);
            printf("sid = %d\n",sid);
        }
    }
    bzero(sql_query,string_length);
    sprintf(sql_query,"insert into replay_progress values ('%d',0,1,0,0,0)",sid);
    mysql_query(&my_connection,sql_query);
    
    bzero(sql_query,string_length);
    sprintf(sql_query,"update replay_progress set rate=0,speed=1 where sid=%d",sid);
    mysql_query(&my_connection,sql_query);


	fd = open(argv[1],O_RDONLY);

	if(argc==3)
	{
		start_time=atoi(argv[2]);
	}

	if(fd<0)
	{
		my_exit(1);
	}

	string=malloc(10000);
	bzero(string,10000);

    while(1)
    {
        if(read(fd,&tv,sizeof(tv))<sizeof(tv))
        {
			break;
        }

        if(read(fd,&content_command,1)<1)
        {
            break;
        }

        if(read(fd,&strlength,sizeof(strlength))<sizeof(strlength))
        {
			break;
        }

        if(read(fd,string,strlength)<strlength)
        {
			break;
        }
        bzero(string,10000);
    }
	memcpy(&tvend,&tv,sizeof(tv));

	lseek(fd,0,SEEK_SET);
	if(read(fd,&tv,sizeof(tv))<sizeof(tv))
	{
		my_exit(1);
	}

	memcpy(&tvpre,&tv,sizeof(tv));
	memcpy(&tvstart,&tv,sizeof(tv));

    if(read(fd,&content_command,1)<1)
    {
        my_exit(1);
    }

	if(read(fd,&strlength,sizeof(strlength))<sizeof(strlength))
	{
		my_exit(1);
	}

	read(fd,string,strlength);
	if(tv.tv_sec>start_time && content_command=='1')
	{
		write(1,string,strlength);
	}

	while(1)
	{
		if(read(fd,&tv,sizeof(tv))<sizeof(tv))
		{
			my_exit(1);
		}

        if(read(fd,&content_command,1)<1)
        {
            my_exit(1);
        }

		if(read(fd,&strlength,sizeof(strlength))<sizeof(strlength))
		{
			my_exit(1);
		}
		
		if(read(fd,string,strlength)<strlength)
		{
//			printf("read3 err\n");
			my_exit(1);
		}

        if(tv.tv_sec<start_time)
        {
//          printf("continue2\n");
            memcpy(&tvpre,&tv,sizeof(tv));
            continue;
        }
        
        bzero(sql_query,string_length);
        sprintf(sql_query,"select rate,speed,stop,seek_replay from replay_progress where read_arg=1 and sid=%d",sid);
        mysql_query(&my_connection,sql_query);
        res_ptr = mysql_store_result(&my_connection);

        if(res_ptr)
        {
            while(sqlrow = mysql_fetch_row(res_ptr))
            {
                progress_rate = atof(sqlrow[0]);
                speed = atof(sqlrow[1]);
                g_stop = atoi(sqlrow[2]);
                printf("progress_rate=%f,speed=%f,g_stop=%d\n",progress_rate,speed,g_stop);
                bzero(sql_query,string_length);
                sprintf(sql_query,"update replay_progress set read_arg=0,seek_replay=0 where sid=%d",sid);
                mysql_query(&my_connection,sql_query);
                if(atoi(sqlrow[3])==1)
                {
                    seek_replay(tvstart.tv_sec+(tvend.tv_sec-tvstart.tv_sec)*progress_rate);
                }
            }
        }

        bzero(sql_query,string_length);
        sprintf(sql_query,"update replay_progress set rate = (%d-%d)/(%d-%d) where sid=%d and read_arg=0",tv.tv_sec,tvstart.tv_sec,tvend.tv_sec,tvstart.tv_sec,sid);
        //printf("sql_query=%s\n",sql_query);
        mysql_query(&my_connection,sql_query);

        while(g_stop==1)
        {
            bzero(sql_query,string_length);
            sprintf(sql_query,"select rate,speed,seek_replay from replay_progress where read_arg=1 and sid=%d and stop=0",sid);
            mysql_query(&my_connection,sql_query);
            res_ptr = mysql_store_result(&my_connection);

            if(res_ptr)
            {
                while(sqlrow = mysql_fetch_row(res_ptr))
                {
                    progress_rate = atof(sqlrow[0]);
                    speed = atof(sqlrow[1]);
                    g_stop = 0;
                    printf("progress_rate=%f,speed=%f,g_stop=%d\n",progress_rate,speed,g_stop);
                    bzero(sql_query,string_length);
                    sprintf(sql_query,"update replay_progress set read_arg=0,seek_replay=0 where sid=%d",sid);
                    mysql_query(&my_connection,sql_query);
                    if(atoi(sqlrow[2])==1)
                    {
                        seek_replay(tvstart.tv_sec+(tvend.tv_sec-tvstart.tv_sec)*progress_rate);
                    }
                    break;
                }
            }
            sleep(1);
        }

		if(tv.tv_sec<start_time)
		{
//			printf("continue2\n");
			memcpy(&tvpre,&tv,sizeof(tv));
			continue;
		}
		if(tv.tv_sec-tvpre.tv_sec>2)
		{
			sleep(2);
		}
		else if((1000000*(tv.tv_sec-tvpre.tv_sec)+(tv.tv_usec-tvpre.tv_usec))>0)
		{
			usleep((1000000*(tv.tv_sec-tvpre.tv_sec)+(tv.tv_usec-tvpre.tv_usec))/speed);
		}
        if(content_command=='1')
        {
		    write(1,string,strlength);
        }
		bzero(string,10000);
		memcpy(&tvpre,&tv,sizeof(tv));
	}
	my_exit(1);
}
