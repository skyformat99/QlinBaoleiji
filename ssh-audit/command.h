#include "/opt/freesvr/sql/include/mysql/mysql.h"
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>
#include <termios.h>
#include <unistd.h>
#include <pthread.h>
#define _XOPEN_SOURCE
#include <stdlib.h>
#define monitor_path "/opt/freesvr/audit/log/monitor_shell_%d"
#include <string.h>
#include <pcre.h>
#include <iconv.h>
#include "rsyslog.h"

static int string_length=100000;

struct black_cmd
{
    int level;
    char cmd[50];
};

//MYSQL my_connection;
MYSQL_RES *res_ptr;
MYSQL_ROW sqlrow;

extern char mysql_address[64];
extern char mysql_username[64];
extern char mysql_password[64];
extern char mysql_database[64];
extern char admin_password[256];
extern int did;
extern int twin_checked;

char wincmd[16][16];
char wincmd_ant[16][16];
char pass_prompt[16][16];

int wincmd_count=0;
int pass_prompt_count=0;

volatile int block_command_flag = 0;
volatile int block_session_id = 0;
volatile int fd_flag = 1;
volatile int by_operate_thread_running=0;

extern void send_message_2_client(int block_session_id, const char *str);
extern void send_message_2_server(int sp[], int, const char *);
extern int send_su_2_server(int sp[], int, const char *, const char *, const char *);
extern char *process_client_input_string(int cfd, int block_session_id, const char *prompt, int echo);


struct auto_su_thread_arg
{
    char * commandline;
    int * sp;
    int session_id;
    char password[128];
} auto_su_thread_arg;

struct by_operate_thread_arg
{
    int fm_fd;
    int * sp;
    int session_id;
} by_operate_thread_arg;

volatile struct by_operate_thread_arg by_arg;

char * autosu_pass_check(char * username,char * radius_username,char * sstr,char * user,MYSQL * my_connection)
{
    MYSQL_RES *myres_ptr;
    MYSQL_ROW mysqlrow;
    printf("autosu_pass_check\n");
    char dip[128];
    bzero(dip,128);
    strcpy(dip,sstr);
    char * t = strstr(dip,":");
    *t = 0;
    char autosu_password[1024];
    char sql_query[10000];
    bzero(sql_query,10000);
    printf("here1\n");
    sprintf(sql_query,
            "select udf_decrypt(cur_password) from devices where username=(select username from \n\r"
            "(select distinct member.uid,member.username webuser,member.realname webrealname,\n\r"
            "member.groupid,member.lastdate,luser.devicesid,devices.device_ip,devices.username,\n\r"
            "devices.login_method,devices.device_type,luser.forbidden_commands_groups,\n\r"
            "luser.weektime,luser.sourceip,luser.autosu,luser.syslogalert,luser.mailalert,\n\r"
            "luser.loginlock from luser left join member on luser.memberid=member.uid left \n\r"
            "join devices on luser.devicesid=devices.id where member.uid and luser.devicesid \n\r"
            "AND 1 AND device_ip = '%s' AND devices.username = '%s' \n\r"
            "AND member.username = '%s' union select \n\r"
            "distinct member.uid,member.username webuser,member.realname webrealname,\n\r"
            "member.groupid,member.lastdate,t.devicesid,devices.device_ip,devices.username,\n\r"
            "devices.login_method,devices.device_type,a.forbidden_commands_groups,a.weektime,\n\r"
            "a.sourceip,a.autosu,a.syslogalert,a.mailalert,a.loginlock from luser_resourcegrp \n\r"
            "a left join (select a.id,b.devicesid from resourcegroup a left join resourcegroup \n\r"
            "b on a.groupname=b.groupname where a.devicesid=0 ) t on a.resourceid=t.id left \n\r"
            "join member on a.memberid=member.uid left join devices on t.devicesid=devices.id\n\r"
            " where t.id and member.uid and t.devicesid AND 1 AND device_ip = '%s'\n\r"
            " AND devices.username = '%s' AND member.username = '%s' \n\r"
            " union select distinct member.uid,member.username webuser,\n\r"
            "member.realname webrealname,member.groupid,member.lastdate,lgroup.devicesid,\n\r"
            "devices.device_ip,devices.username,devices.login_method,devices.device_type,\n\r"
            "lgroup.forbidden_commands_groups,lgroup.weektime,lgroup.sourceip,lgroup.autosu,\n\r"
            "lgroup.syslogalert,lgroup.mailalert,lgroup.loginlock from lgroup left join member\n\r"
            " on lgroup.groupid=member.groupid left join devices on lgroup.devicesid=devices.id\n\r"
            " where member.uid and lgroup.devicesid AND 1 AND device_ip = '%s'\n\r"
            " AND devices.username = '%s' AND member.username = '%s' \n\r"
            " union select distinct member.uid,member.username webuser,\n\r"
            "member.realname webrealname,member.groupid,member.lastdate,t.devicesid,devices.device_ip,\n\r"
            "devices.username,devices.login_method,devices.device_type,a.forbidden_commands_groups,\n\r"
            "a.weektime,a.sourceip,a.autosu,a.syslogalert,a.mailalert,a.loginlock from\n\r"
            " lgroup_resourcegrp a left join (select a.id,b.devicesid from resourcegroup\n\r"
            " a left join resourcegroup b on a.groupname=b.groupname where a.devicesid=0 )\n\r"
            " t on a.resourceid=t.id left join member on a.groupid=member.groupid left join\n\r"
            " devices on t.devicesid=devices.id where t.id and member.uid and t.devicesid\n\r"
            " AND 1 AND device_ip = '%s' AND devices.username = '%s'\n\r"
            " AND member.username = '%s' ORDER BY device_ip asc, device_ip ASC,\n\r"
            " username ASC, webuser ASC) as mt) and device_ip='%s'",
             dip,user,radius_username,dip,user,radius_username,dip,user,radius_username,dip,user,radius_username,dip);
    int res = mysql_query(my_connection,sql_query);
    printf("here201\n");
    if(res)
    {
        fprintf(stderr, "Retrive error: %s\n",mysql_error(my_connection));
        printf("here202\n");
    }
    else
    {
        printf("here203\n");
        myres_ptr = mysql_store_result(my_connection);
        if (myres_ptr)
        {
            if((unsigned long)mysql_num_rows(myres_ptr)==0)
            {
                printf("NO pass found\n");
                mysql_free_result(myres_ptr);
                printf("here21\n");
                return 0;
            }
            while ((mysqlrow = mysql_fetch_row(myres_ptr)))
            {
                bzero(autosu_password,1024);
                strcpy(autosu_password,mysqlrow[0]);
                printf("here22,%s\n",mysqlrow[0]);
                break;
            }
            if (mysql_errno(my_connection))
            {
                fprintf(stderr, "Retrive error: %s\n",mysql_error(my_connection));
            }
        }
        mysql_free_result(myres_ptr);
    }
    printf("here23,(password)=%s\n",autosu_password);
    return autosu_password;
}

void * by_operate_thread_callback(struct by_operate_thread_arg * tm_arg)
{
    int ret=0;
    char buf[1025];

    while(1)
    {
        if(by_operate_thread_running==0)
        {
            printf("by_operate_thread_callback exit\n");
            break;
        }

        bzero(buf,1025);
        ret = read(tm_arg->fm_fd,buf,1024);

        if(ret>0)
        {
            printf("read success\n");
            send_message_2_server(tm_arg->sp, tm_arg->session_id, buf);
        }

        usleep(100);
    }
}


//void * auto_su_thread_callback(char * password,char * commandline,int sp[],int session_id)

void * auto_su_thread_callback(struct auto_su_thread_arg * tm_arg)
{
    /*
    printf("tm_arg=%p\n",tm_arg);
    printf("tm_arg->commandline=%p\n",tm_arg->commandline);
    printf("session_id = %d\n",tm_arg->session_id);
    printf("auto_su_thread_callback\n");
    */

    fd_flag = 0;
    sleep(3);
    printf("auto_su_thread_callback 1\n");
    if(pcre_match(tm_arg->commandline,"assword:")==0)
    {
        printf("auto_su_thread_callback 2,sessoin_id,password=%s\n",tm_arg->password);
        send_message_2_server(tm_arg->sp, tm_arg->session_id, tm_arg->password);
        printf("auto_su_thread_callback 3\n");
        send_message_2_server(tm_arg->sp, tm_arg->session_id, "\n");
        printf("auto_su_thread_callback 4\n");
        send_message_2_server(tm_arg->sp, tm_arg->session_id, "\r");
    }
    printf("auto_su_thread_callback 5\n");
    fd_flag = 1;
}

void autosu_any(char * cmd,char * radius_username,char * sstr,char * user,char * sql_query,int sp[],int session_id,char * commandline,MYSQL * my_connection)
{
	return;
    printf("autosu_any\n");
    char * p = cmd;
    int i = 0;
    int do_autosu = 0;
    int get_username =0;
    char * username;
    for(i=0;i<strlen(cmd)-1;i++)
    {
        if(p[i]=='s' && p[i+1]=='u' && (p[i+2]==0 || p[i+2]==' '))
        {
            if(p[i+2]==' ')
            {
                get_username=1;
            }
            do_autosu=1;
            break;
        }
    }

    if(get_username==1)
    {
        for(i=strlen(cmd);i>0;i--)
        {
            if(p[i]==' ')
            {
                break;
            }
        }
        username=p+i+1;
//        printf("\n\rusername=%s\n\r",username);
//        printf("\n\rpassword=%s\n\r",autosu_pass_check(username));
        if(autosu_pass_check(username,radius_username,sstr,user,my_connection)!=0)
        {
           pthread_t thread;
           static struct auto_su_thread_arg tm_arg;
           bzero(tm_arg.password,128);
           printf("here31\n");
           strcpy(tm_arg.password,autosu_pass_check(username,radius_username,sstr,user,my_connection));
           printf("here32\n");

           tm_arg.sp = sp;
           tm_arg.session_id = session_id;

           tm_arg.commandline = commandline;

           printf("(session_id,commandline,password)=%d,%p,%s\n",session_id,commandline,tm_arg.password);
           int ret = pthread_create(&thread,NULL,auto_su_thread_callback,&tm_arg);
//        int ret = pthread_create(&thread,NULL,auto_su_thread_callback,autosu_pass_check(username,radius_username,sstr,user,sql_query));
        if(ret<0)
        {
            printf("auto su error,will exit...\n");
            exit(0);
        }
        }
    }
    else if(do_autosu==1)
    {
//        printf("\n\rpassword=%s\n\r",autosu_pass_check("root"));

    if(autosu_pass_check("root",radius_username,sstr,user,my_connection)!=0)
    {
       static struct auto_su_thread_arg tm_arg;
       bzero(tm_arg.password,128);
       printf("here31\n");
       strcpy(tm_arg.password,autosu_pass_check(username,radius_username,sstr,user,my_connection));
       printf("here32\n");

       tm_arg.sp = sp;
       tm_arg.session_id = session_id;

       tm_arg.commandline = commandline;

        pthread_t thread;
        printf("(session_id,commandline,password)=%d,%p,%s\n",session_id,commandline,tm_arg.password);
        int ret = pthread_create(&thread,NULL,auto_su_thread_callback,&tm_arg);
//        int ret = pthread_create(&thread,NULL,auto_su_thread_callback,autosu_pass_check("root",,radius_username,sstr,user,sql_query));
        if(ret<0)
        {
            printf("auto su error,will exit...\n");
            exit(0);
        }
    }
    }
}


void freesvr_alarm(char * my_alarm_content,int level, char * syslogserver,char * syslogfacility,char * mailserver,char * mailaccount,char * mailpassword,char adminmailaccount[10][128],int syslogalarm,int mailalarm,int adminmailaccount_num)
{
    pid_t alarm_pid;

//    printf("my_alarm_content=%s,mailserver=%s,mailaccount=%s,mailpassword=%s,level=%d\n",my_alarm_content,mailserver,mailaccount,mailpassword,level);

    if(syslogalarm>0)
    {
//        alarm_pid=fork();
//        if(alarm_pid==0)
        {
            if(level==0)
            {
                rsyslog(syslogserver,514,syslogfacility,"info",my_alarm_content);
            }
            else if(level==1)
            {
                rsyslog(syslogserver,514,syslogfacility,"emerg",my_alarm_content);
            }
            else if(level==2)
            {
                rsyslog(syslogserver,514,syslogfacility,"alert",my_alarm_content);
            }
//            exit(0);
        }
    }

    if(level>0 && mailalarm>0)
    {
#if 0
        alarm_pid=fork();
        if(alarm_pid==0)
        {
				int ret;
				//printf("%s: pid=%d, ppid=%d\n", __func__, getpid(), getppid());
            for(int i=0;i<adminmailaccount_num;i++)
            {
				//strcpy(adminmailaccount[i], "yangqg@tirank.com");
                ret=lib_send_mail(adminmailaccount[i],mailserver,mailaccount,mailpassword,"freesvr dangerous command alarm mail",my_alarm_content, NULL);
				//printf("adminmailaccount=%s\nmailserver=%s\nmailaccount=%s\nmailpassword=%s\nmy_alarm_content=%s\n",adminmailaccount[i],mailserver,mailaccount,mailpassword,my_alarm_content);
				fprintf(stderr, "email ret=%d\n",ret);
            }

          exit(ret);
        }
		/* Add by zhangzhong for sending mail */
		else {
				int ret_s;
			pid_t pr=wait(&ret_s); 
			fprintf(stderr, "i am parent, pr = %d, return=%d\n", pr, WEXITSTATUS(ret_s));
		}
#else
		int ret;
		for(int i=0;i<adminmailaccount_num;i++)
		{
				ret=lib_send_mail(adminmailaccount[i],mailserver,mailaccount,mailpassword,"freesvr dangerous command alarm mail",my_alarm_content, NULL);
				fprintf(stderr, "email ret=%d\n",ret);
		}
#endif
    }
}


void deal_special_char(char * sql)
{
	int length=strlen(sql);
	int i = 0;
	while(i<length+1)
	{
		if(sql[i]=='\\' || sql[i]=='\'' || sql[i]=='(' || sql[i]==')')
		{
			for(int j=length;j>i-1;j--)
			{
				sql[j+1]=sql[j];
			}
			length++;
			sql[i]='\\';
			i++;
		}
		i++;
	}
	printf("deal_sql=%s\n",sql);
}

void termfunc(char * string,char * ret1,char * ret2, int chomp)
{       
    char *p=string;
	if(chomp==1 && (*(p+strlen(p)-1)=='\r' || *(p+strlen(p)-1)=='\n'))
	{
    	*(p+strlen(p)-1)=0;
	}
    int i=0;


    while(i<strlen(p))
    {
        if((unsigned char)p[i]==(unsigned char)0x8a)
        {
            i+=1;
            bzero(ret2,string_length);
            continue;
        }
        if(p[i]==0x0f)
        {
//			printf("here1\n");
            i+=1;
            continue;
        }
        if((i+2)<strlen(p) && p[i+2]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]=='m')
        {
//			printf("here2\n");
            i+=3;
            continue;
        }
        if((i+3)<strlen(p) && p[i+3]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]<('9'+1) && p[i+2]>('0'-1) && p[i+3]=='m')
        {
//			printf("here3\n");
            i+=4;
            continue;
        }
        if((i+4)<strlen(p) && p[i+4]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]<('9'+1) && p[i+2]>('0'-1) && p[i+3]<('9'+1) && p[i+3]>('0'-1) && p[i+4]=='m')
        {
//			printf("here4\n");
            i+=5;
            continue;
        }
        if((i+5)<strlen(p) && p[i+5]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]<('9'+1) && p[i+2]>('0'-1) && p[i+3]==';' && p[i+4]<('9'+1) && p[i+4]>('0'-1) && (p[i+5]=='H' || p[i+5]=='m'))
        {
//			printf("here5\n");
            i+=6;
            continue;
        }
        if((i+6)<strlen(p) && p[i+6]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]<('9'+1) && p[i+2]>('0'-1) && p[i+3]==';' && p[i+4]<('9'+1) && p[i+4]>('0'-1) && p[i+5]<('9'+1) && p[i+5]>('0'-1) && (p[i+6]=='H' || p[i+6]=='m'))
        {
//			printf("here6\n");
            i+=7;
            continue;
        }
        if((i+6)<strlen(p) && p[i+6]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]<('9'+1) && p[i+2]>('0'-1) && p[i+3]<('9'+1) && p[i+3]>('0'-1) && p[i+4]==';' && p[i+5]<('9'+1) && p[i+5]>('0'-1) && (p[i+6]=='H' || p[i+6]=='m'))
        {
//			printf("here7\n");
            i+=7;
            continue;
        }
        if((i+7)<strlen(p) && p[i+7]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]<('9'+1) && p[i+2]>('0'-1) && p[i+3]<('9'+1) && p[i+3]>('0'-1) && p[i+4]==';' && p[i+5]<('9'+1) && p[i+5]>('0'-1) && p[i+6]<('9'+1) && p[i+6]>('0'-1) && (p[i+7]=='H' || p[i+7]=='m'))
        {
//			printf("here8\n");
            i+=8;
            continue;
        }
        if((i+6)<strlen(p) && p[i+6]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]=='0' && p[i+3]=='0' && p[i+4]==0x1b && p[i+5]=='[' && p[i+6]=='m')
        {
//			printf("here9\n");
            i+=7;
            continue;
        }
        if((i+4)<strlen(p) && p[i+4]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]=='4' && p[i+3]<('9'+1) && p[i+3]>('0'-1) && p[i+4]=='m')
        {
//			printf("here10\n");
            i+=5;
            continue;
        }
        if((i+10)<strlen(p) && p[i+10]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]<('9'+1) && p[i+2]>('0'-1) && p[i+3]<('9'+1) && p[i+3]>('0'-1) && p[i+4]==';' && p[i+5]<('9'+1) && p[i+5]>('0'-1) && p[i+6]=='H' && p[i+7]==0x1b && p[i+8]=='[' && p[i+9]<('9'+1) && p[i+9]>('0'-1) && p[i+10]=='K')
        {
			printf("here11\n");
            i+=11;
            continue;
        }
        if((i+21)<strlen(p) && p[i+21]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]=='7' && p[i+3]=='m' && p[i+4]=='S' && p[i+5]=='t'
                && p[i+6]=='a' && p[i+7]=='n' && p[i+8]=='d' && p[i+9]=='a' && p[i+10]=='r' && p[i+11]=='d'
                && p[i+12]==' ' && p[i+13]=='i' && p[i+14]=='n' && p[i+15]=='p' && p[i+16]=='u' && p[i+17]=='t'
                && p[i+18]==0x1b && p[i+19]=='[' && p[i+20]=='0' && p[i+21]=='m')
        {
			printf("here12\n");
            i+=22;
            continue;
        }


        if((i+7)<strlen(p) && p[i+7]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]=='0' && p[i+3]=='1' && p[i+4]==';' && p[i+7]=='m')
        {
			printf("here13\n");
            i+=8;
            continue;
        }
        if((i+4)<strlen(p) && p[i+4]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]=='0' && p[i+3]=='0' && p[i+4]=='m')
        {
			printf("here14\n");
            i+=5;
            continue;
        }
        if((i+2)<strlen(p) && p[i+2]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]=='m')
        {
			printf("here15\n");
            i+=3;
            continue;
        }
		if(i<strlen(p))
		{
	        strncat(ret2+strlen(ret2),p+i,1);
		}
        i++;
    }

    bzero(ret1,string_length);
    p=ret2;i=0;
    while(i<strlen(ret2))
    {
        if(p[i+2]!=0 && p[i]==0x1b && p[i+1]==0x5d && p[i+2]==0x30)
        {
            int j=1;
            while(i+j<strlen(ret2))
            {
                if(p[i+j]==0x07)
                {
                    i+=j;
                    break;
                }
                j++;
            }
        }
        strncat(ret1+strlen(ret1),ret2+i,1);
        i++;
    }

    bzero(ret2,string_length);
    if(ret1[0]==0x0d)
    {
        strcpy(ret2,ret1+1);
    }
    else
    {
        strcpy(ret2,ret1);
    }

    if(*(ret2+strlen(ret2)-1)==0x0d)
    {
        *(ret2+strlen(ret2)-1)=0;
    }

    i=strlen(ret2);
    bzero(ret1,string_length);
    p=ret2;


    while(i>0)
    {
        if(p[i+5]!=0 && p[i]==0x1b && p[i+1]==0x5b && p[i+2]==0x48 && p[i+3]==0x1b && p[i+4]==0x5b && p[i+5]==0x4a)
        {
            i+=6;
            break;
        }
        i--;
    }

    strcpy(ret1,ret2+i);

    bzero(ret2,string_length);
    p=ret1;
    i=0;

    while(i<strlen(ret1))
    {
        if(p[i]==0x07)
        {
            i++;
            continue;
        }
        strncpy(ret2+strlen(ret2),ret1+i,1);
        i++;
    }


    p=ret2;

	/*
    i=0;
    bzero(ret1,string_length);
    int H_count=0;
    int H_from=0;
    int H_to=0;
	int g_H_count=0;

	while(i<strlen(ret2))
	{
		while(i<strlen(ret2))
		{
			if(p[i]==8)
			{
				if(H_count==0)
				{
					H_from=i;
				}
				H_count++;
			}
			else
			{
				if(H_count>30 && (g_H_count==0 || H_count>g_H_count-2))
				{
					g_H_count=H_count;
					H_to=i+2;
					break;
				}
				H_count=0;
				H_to=0;
				H_from=0;
			}
			i++;
		}
		printf("H_from=%d,H_to=%d,H_count=%d\n",H_from,H_to,H_count);

		if(H_to!=0)
		{
			strncpy(ret1,ret2,H_from);
			char H_arr[H_count/2];
			for(int i=0;i<H_count/2;i++)
			{
				H_arr[i]=8;
			}
			strncpy(ret1+strlen(ret1),H_arr,H_count/2);
			strncpy(ret1+strlen(ret1),ret2+H_to,strlen(ret2)-H_to);

			bzero(ret2,string_length);
			strcpy(ret2,ret1);
			bzero(ret1,string_length);
			H_from=0;
			H_to=0;
			H_count=0;
		}
		else
		{
			strcpy(ret1,ret2);
		}
		i++;
	}
	*/


    bzero(ret1,string_length);
    strcpy(ret1,ret2);

    p=ret1;
    i=0;
    bzero(ret2,string_length);
//    int column=132;
    int ant=0;


    for(i=0;i<strlen(ret1);i++)
    {
//        if(ant==column)
        {
//            ant=0;
        }
        if(ant<0)
        {
            ant=0;
        }

        if(ret1[i]==0x0d)
        {
            if(ret1[i+1]==0x0d)
            {
                bzero(ret2,string_length);
                ant=0;
                i++;
                continue;
            }
            else if(ret1[i+1]==0x1b && ret1[i+2]=='[' &&  ret1[i+3]>('0'-1) && ret1[i+3]<('9'+1) && ret1[i+4]>('0'-1) && ret1[i+4]<('9'+1) && ret1[i+5]=='G')
            {
                bzero(ret2,string_length);
                ant=0;
                i+=5;
                continue;
            }
            else
            {
                ant=0;
                continue;
            }
        }

        if(ret1[i]==0x08)
        {
            ant--;
            continue;
        }

        if(ret1[i]==0x1b)
        {
            if(ret1[i+1]=='[' && ret1[i+2]=='D')
            {
                ant = ant-1;
                i+=2;
                continue;
            }
            else if(ret1[i+1]=='[' && ret1[i+2]>('0'-1) && ret1[i+2]<('9'+1) && ret1[i+3]=='D')
            {
                int times = ret1[i+2]-'0';
                ant=ant-times;
//              ret2[ant]=0;
                i+=3;
                continue;
            }
            else if(ret1[i+1]=='[' &&  ret1[i+2]>('0'-1) && ret1[i+2]<('9'+1) && ret1[i+3]>('0'-1) && ret1[i+3]<('9'+1) && ret1[i+4]=='D')
            {
                int times=(ret1[i+2]-'0') * 10 + (ret1[i+3]-'0');
                ant = ant-times;
                i+=4;
                continue;
            }
            else if(ret1[i+1]=='[' && ret1[i+2]>('0'-1) && ret1[i+2]<('9'+1) && ret1[i+3]=='C')
            {
                int times = ret1[i+2]-'0';
                ant=ant+times;
//              ret2[ant]=0;
                i+=3;
                continue;
            }
            else if(ret1[i+1]=='[' &&  ret1[i+2]>('0'-1) && ret1[i+2]<('9'+1) && ret1[i+3]>('0'-1) && ret1[i+3]<('9'+1) && ret1[i+4]=='C')
            {
                int times=(ret1[i+2]-'0') * 10 + (ret1[i+3]-'0');
                ant = ant+times;
                i+=4;
                continue;
            }
            else if(ret1[i+1]=='[' && ret1[i+2]=='C')
            {
                ant++;
                i+=2;
                continue;
            }
            else if(ret1[i+1]=='[' && ret1[i+2]=='K')
            {
                i+=2;
                int j=0;
                bzero(ret2+ant,string_length-ant);
                continue;
            }
            else if(ret1[i+1]=='[' && ret1[i+2]=='A')
            {
                i+=2;
                continue;
            }
            else if(ret1[i+1]=='[' &&  ret1[i+2]>('0'-1) && ret1[i+2]<('9'+1) && ret1[i+3]>('0'-1) && ret1[i+3]<('9'+1) && ret1[i+4]=='P')
            {
                int times=(ret1[i+2]-'0') * 10 + (ret1[i+3]-'0');
                char * tmp_p = ret2+strlen(ret2)-times;
                int len=strlen(ret2);
				if(len-ant-times>0)
				{
                	memmove(ret2+ant,ret2+ant+times,len-ant-times);
                	bzero(tmp_p,times);
				}
                i+=4;
                continue;
            }
            else if(ret1[i+1]=='[' &&  ret1[i+2]>('0'-1) && ret1[i+2]<('9'+1) && ret1[i+3]=='P')
            {
                int times=ret1[i+2]-'0';
                char * tmp_p = ret2+strlen(ret2)-times;
                int len=strlen(ret2);
				if(len-ant-times>0)
				{
                	memmove(ret2+ant,ret2+ant+times,len-ant-times);
                	bzero(tmp_p,times);
				}
                i+=3;
                continue;
            }
            else if(ret1[i+1]=='[' &&  ret1[i+2]>('0'-1) && ret1[i+2]<('9'+1) && ret1[i+3]=='@')
            {
                int len=strlen(ret2);
				if(len-ant+1>0)
				{
                	memmove(ret2+ant,ret2+ant-1,len-ant+1);
				}
                ret2[ant]=ret1[i+4];
                i+=4;
                ant++;
                //printf("ret2=%s\n",ret2);
                continue;
            }
            else if(ret1[i+1]=='[')
            {
                i+=2;
                continue;
            }
        }

        ret2[ant]=ret1[i];
        ant++;
    }
}

void to_get_a_prompt(char prompts[50][128],char * aprompt,int n,MYSQL * my_connection,char * sql_query)
{
    for(int i=49;i>0;i--)
    {
		if(strcmp(prompts[i],aprompt)==0)
		{
			return;
		}
    }

    if(n<128)
    {       
        for(int i=49;i>0;i--)
        {
            bzero(prompts[i],128);
            strncpy(prompts[i],prompts[i-1],128);
        }
            
        bzero(prompts[0],128);
        strncpy(prompts[0],aprompt,n);
        
        bzero(sql_query,string_length);
        sprintf(sql_query,"insert into device_prompts values (%d,'%s',now())",did,prompts[0]);
                
        int res = mysql_query(my_connection,sql_query);
        if (res)
        {   
//          printf("insert error: %s\n", mysql_error(&my_connection));
        }
    }
}


void check_invim(char * p,int * invim,char prompts[50][128],MYSQL * my_connection,char * sql_query)
{
    for(int i=0;i<wincmd_count;i++)
    {
        if(pcre_match(p,wincmd[i])==0)
        {
//          printf("invim,wincmd+ant=%s\n",wincmd_ant[i]);
            char * t = strstr(p,wincmd_ant[i]);
//          printf("t=%p,p=%p\n",t,p);
            int j = t-p;
//          printf("j=%d\n",j);
            int get_a_prompt=0;
            while(j>0)
            {
                if(p+j!=' ')
                {
                    get_a_prompt=1;
                    break;
                }
            }
            if(get_a_prompt==1)
            {
                to_get_a_prompt(prompts,p,t-p,my_connection,sql_query);
//              printf("myprompt=%s\n",myprompt);
            }

            (* invim)=2;
			printf("invim\n");
			for(int j=0;j<50;j++)
			{
				printf("prompt[%d]=%s\n\r",j,prompts[j]);
			}
            return;
        }
    }
}

void check_outvim(char * p,int n,char prompts[50][128],int * invim,int * justoutvim,int * insz)
{
	/*
    int i = 0;
    while(i<n)
    {
        if(p[i+20]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]=='?' && p[i+3]=='2' && p[i+4]=='5' && p[i+5]=='h' && p[i+6]==0x1b && p[i+7]=='[' && p[i+9]==';' && p[i+10]=='1' && p[i+11]=='H' && p[i+12]==0x1b && p[i+13]=='[' && p[i+14]=='K'
 && p[i+15]==0x1b && p[i+16]=='[' && p[i+18]==';' && p[i+19]=='1' && p[i+20]=='H')
        {
            (* invim)=0;
            (* justoutvim)=1;
            printf("\n\routvim1\n\r");
            return;
        }   
        else if(p[i+18]!=0 && p[i]==0x0d && p[i+1]=='?' && p[i+2]==0x1b && p[i+3]=='[' && p[i+4]=='2' && p[i+5]=='5' && p[i+6]==';' && p[i+7]=='1' && p[i+8]=='H' && p[i+9]==0x1b && p[i+10]=='[' && p[i+11]=='K' && p[i+12]==0x1b && p[i+13]
=='[' && p[i+14]=='2' && p[i+15]=='5' && p[i+16]==';' && p[i+17]=='1' && p[i+18]=='H') 
        {
            (* invim)=0;
            (* justoutvim)=1;
            printf("\n\routvim2\n\r");
            return;
        }
        else if(p[i+5]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]=='?' && p[i+3]=='1' && p[i+4]=='l' && p[i+5]==0x1b)
        {
            (* invim)=0;
            (* justoutvim)=1;
            printf("\n\routvim3\n\r");
            return;
        }
        else if(p[i+6]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]=='?' && p[i+3]=='1' && p[i+4]=='0' && p[i+5]=='4' && p[i+6]=='9')
        {
            (* invim)=0;
            (* justoutvim)=1;
            printf("\n\routvim4\n\r");
            return;
        }
        else if(p[i+1]!=0 && p[i]==0x1b && p[i+1]=='>')
        {
            (* invim)=0;
            (* justoutvim)=1;
            printf("\n\routvim5\n\r");
            return;
        }
		else if(p[i+2]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]=='J')
		{
			(* invim)=0;
			(* justoutvim)=1;
			printf("\n\routvim5.1\n\r");
			return;
		}
//		else if(p[i+4]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]=='?' && p[i+3]=='1' && p[i+4]=='l')
		else if(p[i]=='[' && p[i+1]=='?' && p[i+2]=='1' && p[i+3]=='l')
		{
			(* invim)=0;
			(* justoutvim)=1;
			printf("\n\n\n\noutvim5.5\n\n\n\n");
			return;
		}
        i++;
    }
	*/

	for(int i=0;i<50;i++)
	{
		if(strlen(prompts[i])>0 && strstr(p,prompts[i])!=0)
		{
			(* invim)=0;
			(* justoutvim)=1;
			(* insz)=0;
			return;
		}
	}
	/*
    i = 0;
    while(i<n)
    {
        if(p[i+8]!=0 && p[i]=='[' && p[i+1]=='?' && p[i+2]=='7' && p[i+3]=='h' && p[i+4]=='>' && p[i+5]=='[' && p[i+6]=='?' && p[i+7]=='7' && p[i+8]=='h' && strstr(p,prompt)!=0)
        {
            (* invim)=0;
            (* justoutvim)=1;
            printf("\n\routvim7\n\r");
            return;
        }
        else if(p[i+6]!=0 && p[i]=='[' && p[i+1]=='?' && p[i+2]=='1' && p[i+3]=='0' && p[i+4]=='4' && p[i+5]=='9' && p[i+6]=='l' && strstr(p,prompt)!=0)
        {
            (* invim)=0;
            (* justoutvim)=1;
            printf("\n\routvim8\n\r");
            return;
        }
		else if(p[i+15]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]=='?' && p[i+3]=='1' && p[i+4]=='c' && p[i+5]==0x1b && p[i+6]=='[' && p[i+7]=='?' && p[i+8]=='2' && p[i+9]=='5' && p[i+10]=='h' && p[i+11]==0x1b && p[i+12]=='[' && p[i+13]=='?' && p[i+14]=='0' && p[i+15]=='c')
        {
            (* invim)=0;
            (* justoutvim)=1;
            printf("\n\routvim9\n\r");
            return;
        }
        else if(p[i+4]!=0 && p[i]=='[' && p[i+1]=='H' && p[i+2]=='[' && p[i+3]=='2' && p[i+4]=='J' && strstr(p,prompt)!=0)
        {
            (* invim)=0;
            (* justoutvim)=1;
            printf("\n\routvim10\n\r");
            return;
        }
        i++;
    }*/
}

int get_pcre(char * name,struct black_cmd black_cmd_list[],int * black_cmd_num,MYSQL * my_connection,MYSQL_RES * my_res_ptr,MYSQL_ROW my_sqlrow,int * black_or_white, char * sql_query)
{
	printf("\n\rblack = %s\n\r",name);
    int res;
	bzero(sql_query,string_length);
    sprintf(sql_query,"select cmd,level from forbidden_commands_groups where gid = '%s'",name);
	printf("\n\n\n\n\nsql_query=%s\n\n\n\n\n\n\n",sql_query);
    
    res = mysql_query(my_connection,sql_query);
    if (res)
    {
        //printf("SELECT error: %s\n", mysql_error(my_connection));
    }
    else
    {
        my_res_ptr = mysql_store_result(my_connection);
        if (my_res_ptr)
        {
            if((unsigned long)mysql_num_rows(my_res_ptr)==0)
            {
                //printf("USER not in config error\n");
                mysql_free_result(my_res_ptr);
//              mysql_close(my_connection);
                return 1;
            }
            while ((my_sqlrow = mysql_fetch_row(my_res_ptr)))
            {
				printf("black_cmd=%s,level=%s\n",my_sqlrow[0],my_sqlrow[1]);
				printf("\n1\n");
                strcpy(black_cmd_list[* black_cmd_num].cmd,my_sqlrow[0]);
				printf("\n2\n");
                black_cmd_list[* black_cmd_num].level=atoi(my_sqlrow[1]);
				printf("\n3\n");
                (* black_cmd_num)++;
				printf("\n4\n");
            }
            if (mysql_errno(my_connection))
            {
                fprintf(stderr, "Retrive error: s%\n",mysql_error(my_connection));
            }
        }
        mysql_free_result(my_res_ptr);
    }

	bzero(sql_query,string_length);
	sprintf(sql_query,"select black_or_white from forbidden_groups where gname='%s'",name);
	printf("\n\n\n\nsql_query = %s\n\n\n",sql_query);
    res = mysql_query(my_connection,sql_query);
    if(res)
    {
    }
    else
    {   
        my_res_ptr = mysql_store_result(my_connection);
        if (my_res_ptr)
        {   
            if((unsigned long)mysql_num_rows(my_res_ptr)==0)
            {   
                //printf("USER not in config error\n");
                mysql_free_result(my_res_ptr);
                return 1;
            }   
            while ((my_sqlrow = mysql_fetch_row(my_res_ptr)))
            {   
                * black_or_white=atoi(my_sqlrow[0]);
				printf("\n\n\n\nblack_or_white=%d\n\n\n\n",* black_or_white);
            }   
            if (mysql_errno(my_connection))
            {   
                fprintf(stderr, "Retrive error: s%\n",mysql_error(my_connection));
            }
        }   
        mysql_free_result(my_res_ptr);
    }
}

int pcre_match (char *src, char *pattern)
{
    pcre *re;

    const char *error;

    int erroffset;

    int rc;

    re = pcre_compile (pattern,       /* the pattern */
               0,       /* default options */
               &error,       /* for error message */
               &erroffset, /* for error offset */
               NULL);       /* use default character tables */

/* Compilation failed: print the error message and exit */
    if (re == NULL)
    {
    printf ("PCRE compilation failed at offset %d: %s\n", erroffset,
        error);
    return -1;
    }

    rc = pcre_exec (re,        /* the compiled pattern */
            NULL, /* no extra data - we didn't study the pattern */
            src, /* the src string */
            strlen (src), /* the length of the src */
            0,        /* start at offset 0 in the src */
            0,        /* default options */
            NULL, 0);

/* If Matching failed: */
    if (rc < 0)
    {
    free (re);
    return -1;
    }

    free (re);
    return rc;
}


void in_out_sz(char * buff, int * insz)
{
	int len = strlen(buff)-1;
	if(len<0)
	{
		return;
	}

	int i = 0;
	while(i<len)
	{
		if(buff[i]==0x0d && (unsigned char)buff[i+1]==(unsigned char)0x8a 
				&& (unsigned char)buff[i+2]==(unsigned char)0x11)
		{
			printf("\nin rzsz\n");
			(* insz)=1;
			return;
		}
//		else if(buff[i]==0x0d && (unsigned char)buff[i+1]==(unsigned char)0x8a)
		else if(strstr(buff,"B0800000000022d") || strstr(buff,"070000000067d4"))
		{
			printf("\nout rzsz\n");
			(* insz)=0;
			return;
		}
		else if((unsigned char)buff[i]==(unsigned char)0x08 && (unsigned char)buff[i+1]==(unsigned char)0x08
				&& (unsigned char)buff[i+2]==(unsigned char)0x08 && (unsigned char)buff[i+3]==(unsigned char)0x08)
		{
            printf("\nout rzsz\n");
            (* insz)=0;
            return;
		}

		i++;
	}
}

int command_filter(char * str)
{
	if(strlen(str)==0)
	{
		return -1;
	}
	if(pcre_match(str,"\d+H\d+")==0)
	{
		return -1;
	}
	return 1;
}

void telnet_writelogfile(char * buff,int n,char * monitor_shell_pipe_name_fm, char * monitor_shell_pipe_name_tm,
                        int fd1,int fd2,char * inputcommandline,char * commandline,char * cache1,char * cache2,
						char * linebuffer,char * cmd,char * sql_query, char prompts[50][128],
                        struct black_cmd black_cmd_list[],int black_cmd_num,int sid,int * waitforline, int * g_bytes, int * invim,int * insz, int * justoutvim, int session_id,int black_or_white, MYSQL * my_connection,char * syslogserver,char * syslogfacility,char * mailserver,char * mailaccount,char * mailpassword,char adminmailaccount[10][128],char * alarm_content,int syslogalarm,int mailalarm,int adminmailaccount_num,char * radius_username,char * sstr,char * user,int encode,int * get_first_prompt, int cfd, int sp[])
{
//	char tmptmp[10240];
//	bzero(tmptmp,10240);
//	strncpy(tmptmp,buff,n);
//	printf("tmp=%s\nbuff=%s\nn=%d\n",tmptmp,buff,n);
    printf("n1=%d\n",n);

	

    if(linebuffer==0) 
    {
		printf("return for null\n");
		return;
        linebuffer=malloc(sizeof(char)*string_length);
        bzero(linebuffer,string_length);
    }
    if(commandline==0)
    {
		printf("return for null\n");
		return;
        commandline=malloc(sizeof(char)*string_length);
        bzero(commandline,string_length);
    }
    if(inputcommandline==0)
    {
		printf("return for null\n");
		return;
        inputcommandline=malloc(sizeof(char)*string_length);
        bzero(inputcommandline,string_length);
    }       

    if(strlen(inputcommandline)>(string_length-10000) || strlen(commandline)>(string_length-10000))
    {   
        bzero(inputcommandline,string_length);
//      bzero(commandline,string_length);
    }

    (* g_bytes)+=n; 
    int monitor_fd;
	//printf("monitor_shell_pipe_name_tm=%s\n",monitor_shell_pipe_name_tm);
	
	in_out_sz(buff,insz);

    if(access(monitor_shell_pipe_name_tm,W_OK)==0)
    {   
        monitor_fd=open(monitor_shell_pipe_name_tm,O_WRONLY);
        if(monitor_fd<0)
        {
            perror("monitor fd open fail\n");
        }
        else
        {
            write(monitor_fd,buff,n);
        }

        if(by_operate_thread_running==0)
        {
            by_arg.fm_fd=open(monitor_shell_pipe_name_fm,O_RDONLY);
            by_arg.sp=sp;
            by_arg.session_id=session_id;

            pthread_t thread;
            int ret = pthread_create(&thread,NULL,by_operate_thread_callback,&by_arg);
            if(ret<0)
            {
                printf("by_operate create error, will exist...\n");
                exit(0);
            }
            ret = pthread_detach(thread);
            if(ret<0)
            {
                printf("by_operate detach error, will exist...\n");
                exit(0);
            }
            
            by_operate_thread_running=1;
        }
    }
    else
    {
        by_operate_thread_running=0;
    }

	int alarm_length=74;
    struct timeval tv;
	struct timezone tz;
    gettimeofday (&tv , &tz);

	if((* insz)==0)
	{
			write(fd2,&tv,sizeof(tv));
			write(fd2,"1",1);   //1:content 2:command
			write(fd2,&n,sizeof(n));
			write(fd2,buff,n);
	}

    int i=0;
    
	//printf("\ninvim==%d\n",(* invim));

	char * p=buff;

    if((* invim)==1)
    {      
        bzero(commandline,string_length);
        bzero(inputcommandline,string_length);
        bzero(linebuffer,string_length);     
        check_outvim(buff,n,prompts,invim,justoutvim,insz);
        return; 
    }           
    else if((* invim)==2)
    {     
        bzero(cache1,string_length);
        bzero(cache2,string_length);
        termfunc(linebuffer,cache1,cache2,1);

        write(fd1,cache2,strlen(cache2));
        write(fd1,"\n",1);
		char * t = strlen(cmd)>0 ? strstr(cache2,cmd) : 0;
		printf("invim==2\n");
		printf("cmd=%s\n",cmd);
		printf("cache2=%s\n",cache2);
        if((* justoutvim)==0 && t!=0 && t!=cache2 && (t-cache2)<128)
        {
			printf("get_a_prompt here\n");
			to_get_a_prompt(prompts,cache2,t-cache2,my_connection,sql_query);
            if((*get_first_prompt)>0)
            {
                bzero(sql_query,string_length);
                sprintf(sql_query,"update devices set first_prompt='%s' where id=%d",prompts[0],did);
                printf("sql_query1=%s\n",sql_query);
                mysql_query(my_connection,sql_query);
                (*get_first_prompt)=0;
            }
		//	printf("p=%p,cache2=%p,myprompt=#%s#,p-cache2=%d\n",p,cache2,myprompt,p-cache2);
			bzero(cache2,string_length); //lwm
        //    printf("cmd=%s\n,myprompt=%s\n",cmd,myprompt);
        }
        (* invim)--;
        return; 
    }
    

    while(i<n)  
    {           
        if(p[i]=='\n')
        {   
			bzero(cache1,string_length);
            bzero(cache2,string_length);
            termfunc(linebuffer,cache1,cache2,1);
                            
            write(fd1,cache2,strlen(cache2));
            write(fd1,"\n",1);
			char * t = strlen(cmd)>0 ? strstr(cache2,cmd) : 0;
			
			if((* justoutvim)==0 && 
				t!=0 && 
				t!=cache2 && 
				(t-cache2)<128)
			{   
				to_get_a_prompt(prompts,cache2,t-cache2,my_connection,sql_query);
				if((*get_first_prompt>0))
				{
					bzero(sql_query,string_length);
					sprintf(sql_query,"update devices set first_prompt='%s' where id=%d",prompts[0],did);
					printf("sql_query2=%s\n",sql_query);
					mysql_query(my_connection,sql_query);
					(*get_first_prompt)=0;
				}
		//		printf("p=%p,cache2=%p,myprompt=#%s#,p-cache2=%d\n",p,cache2,myprompt,p-cache2);
				bzero(cache2,string_length);//lwm
				bzero(cmd,string_length);
            }               
            else if((* justoutvim)==1)
            {               
                (* justoutvim)=0;
            }
            bzero(linebuffer,string_length);
        }       
        else
        {       
            //printf("\n\rstrlen(linebuffer)=%d\n\r",strlen(linebuffer));
            strncpy(linebuffer+strlen(linebuffer),p+i,1);
            if(strlen(linebuffer)>(string_length-5000))
            {
                bzero(cache1,string_length);
                bzero(cache2,string_length);
                termfunc(linebuffer,cache1,cache2,1);
             	write(fd1,cache2,strlen(cache2));
             	write(fd1,"\n",1);
                bzero(linebuffer,string_length);
            }
        }
        i++;
    }


    i=0;
    p=buff;

    while(i<n)
    {
        memcpy(commandline+strlen(commandline),p+i,1);

        if(strlen(commandline)>(string_length-5000))
        {
            bzero(commandline,string_length);
            bzero(inputcommandline,string_length);
            return;
        }

        if(p[i]=='\n')
        {
            if((* waitforline)==0)
            {
                bzero(commandline,string_length);
            }
            else
            {
				printf("\n\nwaitforline\n\n");
                bzero(cache1,string_length);
                bzero(cache2,string_length);
                termfunc(commandline,cache1,cache2,1);

				if(strlen(cache2)>0)
				{
					sprintf(cmd,"%s",cache2);
					check_invim(cmd,invim,prompts,my_connection,sql_query);

                    int level=black_or_white;

                    for(int j=0;j<black_cmd_num;j++)
                    {
                        if(black_or_white==0)
                        {
                            if(pcre_match(cmd,black_cmd_list[j].cmd)==0)
                            {
                                level = black_cmd_list[j].level + 1;
                                break;
                            }
                        }
                        else
                        {
                            if(pcre_match(cmd,black_cmd_list[j].cmd)==0)
                            {
                                level = 0;
                                break;
                            }
                        }
                    }

                    for(int i=0;i<pass_prompt_count;i++)
                    {
                        if(pcre_match(commandline,pass_prompt[i])==0)
                        {
                            bzero(inputcommandline,string_length);
                            bzero(commandline,string_length);
                            return;
                        }
                    }

                    if((*get_first_prompt)>0)
                    {
                        (*get_first_prompt)--;
                    }

//                  void autosu_any(char * cmd,char * radius_username,char * sstr,char * user,char * sql_query,int sp[],int session_id,char * commandline)
                    autosu_any(cache2,radius_username,sstr,user,sql_query,sp,session_id,commandline,my_connection);
					bzero(sql_query,string_length);

					if((* insz)==0)
					{
						/*
							for(int i=0;i<50;i++)
							{
									if(strlen(prompts[i])>0 && strstr(cache2,prompts[i])!=0)
									{
											char cache_tmp[string_length];
											bzero(cache_tmp,string_length);
											memcpy(cache_tmp,cache2+strlen(prompts[i]),strlen(cache2+strlen(prompts[i])));
											bzero(cache2,string_length);
											memcpy(cache2,cache_tmp,strlen(cache_tmp));
											break;
									}
							}
							*/

							if(encode==1)
							{
								bzero(cache1,string_length);
								myg2u(cache2,strlen(cache2),cache1,string_length);
								deal_special_char(cache1);
								if(command_filter(cache1)==-1)
								{
									bzero(inputcommandline,string_length);
									bzero(commandline,string_length);
									return;
								}

								sprintf(sql_query,"insert into commands (cid,sid,at,cmd,dangerlevel,jump_session) values  (NULL,%d,now(),'%s',%d,0)",sid,cache1,level);
								gettimeofday (&tv , &tz);
								write(fd2,&tv,sizeof(tv));
								write(fd2,"2",1);   //1:content 2:command
								int cmd_length=0;
								cmd_length=strlen(cache1);
								write(fd2,&cmd_length,sizeof(cmd_length));
								write(fd2,cache1,cmd_length);
							}
							else
							{
								deal_special_char(cache2);

								if(command_filter(cache2)==-1)
								{
									bzero(inputcommandline,string_length);
									bzero(commandline,string_length);
									return;
								}
								sprintf(sql_query,"insert into commands (cid,sid,at,cmd,dangerlevel,jump_session) values  (NULL,%d,now(),'%s',%d,0)",sid,cache2,level);
								gettimeofday (&tv , &tz);
								write(fd2,&tv,sizeof(tv));
								write(fd2,"2",1);   //1:content 2:command
								int cmd_length=0;
								cmd_length=strlen(cache1);
								write(fd2,&cmd_length,sizeof(cmd_length));
								write(fd2,cache1,cmd_length);
							}

							printf("\n\nsql1=%s\n\nencode=%d\n",sql_query,encode);
							mysql_query(my_connection,sql_query);

							bzero(sql_query,string_length);
							sprintf(sql_query,"update sessions set total_cmd=total_cmd+1,end=now(),s_bytes=%lf where sid=%d",(float)(* g_bytes)/1000,sid);
							mysql_query(my_connection,sql_query);

							bzero(sql_query,string_length);
							sprintf(sql_query,"update sessions set dangerous=%d where sid=%d and dangerous<%d",level,level);
							mysql_query(my_connection,sql_query);

							bzero(alarm_content,string_length);
							sprintf(alarm_content,"%s run command '%s' on device '%s' as the account '%s' in session %d",radius_username,cache2,sstr,user,sid);
							freesvr_alarm(alarm_content,level,syslogserver,syslogfacility,mailserver,mailaccount,mailpassword,adminmailaccount,syslogalarm,mailalarm,adminmailaccount_num);
					}

					if(level==1)
					{
						write(fd1,"\n**************************",27);
						write(fd1,"\nforbidden command!\n",20);
						write(fd1,"**************************\n",27);

						gettimeofday (&tv , &tz);
						write(fd2,&tv,sizeof(tv));
                        write(fd2,"1",1);
						write(fd2,&alarm_length,sizeof(alarm_length));

						write(fd2,"\n**************************",27);
						write(fd2,"\nforbidden command!\n",20);
						write(fd2,"**************************\n",27);

						block_command_flag = 1;
						block_session_id = session_id;
					}
					else if(level==2)
					{
						write(fd1,"\n**************************",27);
						write(fd1,"\nforbidden command!\n",20);
						write(fd1,"**************************\n",27);

						gettimeofday (&tv , &tz);
						write(fd2,&tv,sizeof(tv));
                        write(fd2,"1",1);
						write(fd2,&alarm_length,sizeof(alarm_length));

						write(fd2,"\n**************************",27);
						write(fd2,"\nforbidden command!\n",20);
						write(fd2,"**************************\n",27);

						cleanup_exit( 255 );
					}
					else if(level==4)
					{
                        int count=0;
                        char tmp_buf[256]={0};
                        int echo_length=74;

                        send_message_2_client(session_id,"\n\r AUTH_TERM: this command needs authority from manager,are you sure?[Y/n]");
                        write(fd1,"\n\r AUTH_TERM: this command needs authority from manager,are you sure?[Y/n]",74);

                        gettimeofday (&tv , &tz);
                        write(fd2,&tv,sizeof(tv));
                        write(fd2,"1",1);
                        write(fd2,&echo_length,sizeof(echo_length));
                        write(fd2,"\n\r AUTH_TERM: this command needs authority from manager,are you sure?[Y/n]",74);

                        char * t = process_client_input_string(cfd,session_id,"",0);
                        if(t[0]!='Y' && t[0]!='y')
                        {
                            printf("here3\n");
                            printf("\n\rBad Password!\n\r");

                            block_command_flag = 1;
                            block_session_id = session_id;

                            echo_length=89;
                            write(fd1,"\nBad Password!\n",15);
                            write(fd1,"\n**************************",27);
                            write(fd1,"\nforbidden command!\n",20);
                            write(fd1,"**************************\n",27);


                            gettimeofday (&tv , &tz);
                            write(fd2,&tv,sizeof(tv));
                            write(fd2,"1",1);
                            write(fd2,&echo_length,sizeof(echo_length));


                            write(fd2,"\nBad Password!\n",15);
                            write(fd2,"\n**************************",27);
                            write(fd2,"\nforbidden command!\n",20);
                            write(fd2,"**************************\n",27);


                            printf("\r\n\n**************************");
                            printf("\r\n*** forbidden command! ***\n");
                            printf("\r**************************\n\n");

                            bzero(inputcommandline,string_length);
                            bzero(commandline,string_length);
                            return;
                        }
                        if(access(monitor_shell_pipe_name_tm,W_OK)==0)
                        {
                            twin_checked=0;
                            int monitor_fd=open(monitor_shell_pipe_name_tm,O_WRONLY);
                            if(monitor_fd<0)
                            {
                                perror("monitor fd open fail\n");
                            }   
                            else
                            {
                                char start_monitor_admin_pass_check_str[11]={1,3,3,7,0,1,8,8,5,2,9};
                                write(monitor_fd,start_monitor_admin_pass_check_str,11);
                                
                                echo_length=84;
                                send_message_2_client(session_id,"\n\rwaiting confirm until timeout...\n\r");
                                
                                write(fd1,"\n\rwaiting confirm until timeout...\n\r",36);
                                gettimeofday (&tv , &tz);
                                write(fd2,&tv,sizeof(tv));
                                write(fd2,"1",1);
                                write(fd2,&echo_length,sizeof(echo_length));
                                write(fd2,"\n\rwaiting confirm until timeout...\n\r",36);
                                
                                int wait_time=0;
                                while(1)
                                {
                                    if(wait_time>10)
                                    {
                                        write(monitor_fd,10,1);
                                        break;
                                    }
                                    if(twin_checked!=0)
                                    {
                                        break;
                                    }
                                    sleep(1);
                                    wait_time++;
                                }
                                if(twin_checked==2)
                                {
                                    send_message_2_client(session_id,"OK\n");
                                    write(fd1,"OK\n",3);

                                    echo_length=3;
                                    gettimeofday (&tv , &tz);
                                    write(fd2,&tv,sizeof(tv));
                                    write(fd2,"1",1);
                                    write(fd2,&echo_length,sizeof(echo_length));
                                    write(fd2,"OK\n",3);

                                    bzero(inputcommandline,string_length);
                                    bzero(commandline,string_length);
                                    return;
                                }
                                else
                                {
                                    send_message_2_client(session_id,"\n\rBad Password!\n\r");


                                    block_command_flag = 1;
                                    block_session_id = session_id;

                                    write(fd1,"\nBad Password!\n",15);
                                    write(fd1,"\n**************************",27);
                                    write(fd1,"\nforbidden command!\n",20);
                                    write(fd1,"**************************\n",27);

                                    echo_length=89;
                                    gettimeofday (&tv , &tz);
                                    write(fd2,&tv,sizeof(tv));
                                    write(fd2,"1",1);
                                    write(fd2,&echo_length,sizeof(echo_length));

                                    write(fd2,"\nBad Password!\n",15);
                                    write(fd2,"\n**************************",27);
                                    write(fd2,"\nforbidden command!\n",20);
                                    write(fd2,"**************************\n",27);

                                    bzero(inputcommandline,string_length);
                                    bzero(commandline,string_length);
                                    return;
                                }
                            }
                        }
                        else
                        {
                            send_message_2_client(session_id, "\n\rinput password:");
                        //    write(fileno(stdout),"\n\rinput password:",17);
                            write(fd1,"\n\rinput password:\n",18);

                            echo_length=18;
                            gettimeofday (&tv , &tz);
                            write(fd2,&tv,sizeof(tv));
                            write(fd2,"1",1);
                            write(fd2,&echo_length,sizeof(echo_length));
                            write(fd2,"\n\rinput password:\n",18);

                            t = process_client_input_string(cfd,session_id,"",0);

                            if(strcmp(t,admin_password)==0)
                            {
                                send_message_2_client(session_id,"OK!\n");
                                bzero(inputcommandline,string_length);
                                bzero(commandline,string_length);
                                return;
                            }
                            else
                            {
                                send_message_2_client(session_id,"\n\rBad Password!\n\r");

                                block_command_flag = 1;
                                block_session_id = session_id;

                                write(fd1,"\nBad Password!\n",15);
                                write(fd1,"\n**************************",27);
                                write(fd1,"\nforbidden command!\n",20);
                                write(fd1,"**************************\n",27);

                                echo_length=89;
                                gettimeofday (&tv , &tz);
                                write(fd2,&tv,sizeof(tv));
                                write(fd2,"1",1);
                                write(fd2,&echo_length,sizeof(echo_length));

                                write(fd2,"\nBad Password!\n",15);
                                write(fd2,"\n**************************",27);
                                write(fd2,"\nforbidden command!\n",20);
                                write(fd2,"**************************\n",27);

                                printf("\r\n\n**************************");
                                printf("\r\n*** forbidden command! ***\n");
                                printf("\r**************************\n\n");

                                bzero(inputcommandline,string_length);
                                bzero(commandline,string_length);
                                return;
                            }
                        }
					}
				}

                bzero(inputcommandline,string_length);
                bzero(commandline,string_length);
                (* waitforline)=0;
            }
        }
        i++;
    }
}

void telnet_writelogfile2(char * buff,int n,char * monitor_shell_pipe_name_fm, char * monitor_shell_pipe_name_tm,
                        int fd1, int fd2, char * inputcommandline,char * commandline,char * cache1,char * cache2,char * linebuffer,char * cmd,char * sql_query,char prompts[50][128],
                        struct black_cmd black_cmd_list[], int black_cmd_num,int sid,int * waitforline,int * g_bytes,int * invim, int * insz,
						int session_id, int black_or_white, MYSQL * my_connection,char * syslogserver,char * syslogfacility,char * mailserver,char * mailaccount,char * mailpassword,char adminmailaccount[10][128],char * alarm_content,int syslogalarm,int mailalarm,int adminmailaccount_num,char * radius_username,char * sstr,char * user,int encode,int * get_first_prompt,int cfd, int sp[])
{
//	char tmptmp[10240];
//	bzero(tmptmp,10240);
//	strncpy(tmptmp,buff,n);
//	printf("tmp=%s\nbuff=%s\nn=%d\n",tmptmp,buff,n);
    printf("n2=%d\n",n);

    if(linebuffer==0) 
    {
		printf("return for null\n");
		return;
        linebuffer=malloc(sizeof(char)*string_length);
        bzero(linebuffer,string_length);
    }
    if(commandline==0)
    {
		printf("return for null\n");
		return;
        commandline=malloc(sizeof(char)*string_length);
        bzero(commandline,string_length);
    }
    if(inputcommandline==0)
    {
		printf("return for null\n");
		return;
        inputcommandline=malloc(sizeof(char)*string_length);
        bzero(inputcommandline,string_length);
    }       

    if(strlen(inputcommandline)>(string_length-10000) || strlen(commandline)>(string_length-10000))
    {
        bzero(inputcommandline,string_length);
        bzero(commandline,string_length);
    }

    if((* invim)!=0)
    {
        return;
    }
	int alarm_length=74;
    struct timeval tv;
    struct timezone tz;

    (* g_bytes)+=n;
    (* waitforline)=0;
    char * p=buff;
    int i=0;
    int j=0;
    while(i<n)
    {
        if(p[i]=='')
        {
            bzero(commandline,string_length);
            bzero(inputcommandline,string_length);
        }
        i++;
    }
    i=0;
    int inputok=1;
    int selfhandle_mode=0;
    int line_number=0;
    char * t=inputcommandline;
    while(i<n)
    {
        if(p[i]=='\n' || p[i]=='\r')
        {
           selfhandle_mode=1;
           break;
        }
        i++;
    }
    i=0;
    p=buff;
    while(i<strlen(inputcommandline))
    {
        if(((int)t[i]>126 || (int)t[i]<33 || t[i]=='q' || t[i]==9) && t[i]!=' ' && t[i]!="\n" && t[i]!="\r") // 9 is tab
        {
            inputok=0;
            break;
        }
        else
        {
            inputok=1;
        }
        i++;
    }
    i=0;
    p=buff;
    if(p[0]=='\r' || p[0]=='\n' && selfhandle_mode==0 )
    {
		if(inputok==1)
        {
            if((* invim)==0)
            {
                bzero(cache1,string_length);
                bzero(cache2,string_length);
                termfunc(commandline,cache1,cache2,1);


				if(strlen(inputcommandline)>0)
				{
					sprintf(cmd,"%s",inputcommandline);
					check_invim(cmd,invim,prompts,my_connection,sql_query);

                    int level=black_or_white;

                    for(int j=0;j<black_cmd_num;j++)
                    {
                        if(black_or_white==0)
                        {
                            if(pcre_match(cmd,black_cmd_list[j].cmd)==0)
                            {
                                level = black_cmd_list[j].level + 1;
                                break;
                            }
                        }
                        else
                        {
                            if(pcre_match(cmd,black_cmd_list[j].cmd)==0)
                            {
                                level = 0;
                                break;
                            }
                        }
                    }

                    for(int i=0;i<pass_prompt_count;i++)
                    {
                        if(pcre_match(commandline,pass_prompt[i])==0)
                        {
                            bzero(inputcommandline,string_length);
                            bzero(commandline,string_length);
                            return;
                        }
                    }

					bzero(sql_query,string_length);

                    if((*get_first_prompt)>0)
                    {
                        (*get_first_prompt)--;
                    }

                    autosu_any(inputcommandline,radius_username,sstr,user,sql_query,sp,session_id,commandline,my_connection);

					if((* insz)==0)
					{
						/*
							for(int i=0;i<50;i++)
							{
									if(strlen(prompts[i])>0 && strstr(inputcommandline,prompts[i])!=0)
									{
											char cache_tmp[string_length];
											bzero(cache_tmp,string_length);
											memcpy(cache_tmp,inputcommandline+strlen(prompts[i]),strlen(inputcommandline+strlen(prompts[i])));
											bzero(inputcommandline,string_length);
											memcpy(inputcommandline,cache_tmp,strlen(cache_tmp));
											break;
									}
							}
							*/

							if(encode==1)
							{
								bzero(cache1,string_length);
								myg2u(inputcommandline,strlen(inputcommandline),cache1,string_length);
								deal_special_char(cache1);

								if(command_filter(cache1)==-1)
								{
									bzero(inputcommandline,string_length);
									bzero(commandline,string_length);
									return;
								}

								sprintf(sql_query,"insert into commands (cid,sid,at,cmd,dangerlevel,jump_session) values  (NULL,%d,now(),'%s',%d,0)",sid,cache1,level);
								gettimeofday (&tv , &tz);
								write(fd2,&tv,sizeof(tv));
								write(fd2,"2",1);   //1:content 2:command
								int cmd_length=0;
								cmd_length=strlen(cache1);
								write(fd2,&cmd_length,sizeof(cmd_length));
								write(fd2,cache1,cmd_length);
							}
							else
							{
								deal_special_char(inputcommandline);

								if(command_filter(inputcommandline)==-1)
								{
									bzero(inputcommandline,string_length);
									bzero(commandline,string_length);
									return;
								}
								sprintf(sql_query,"insert into commands (cid,sid,at,cmd,dangerlevel,jump_session) values  (NULL,%d,now(),'%s',%d,0)",sid,inputcommandline,level);
								gettimeofday (&tv , &tz);
								write(fd2,&tv,sizeof(tv));
								write(fd2,"2",1);   //1:content 2:command
								int cmd_length=0;
								cmd_length=strlen(cache1);
								write(fd2,&cmd_length,sizeof(cmd_length));
								write(fd2,cache1,cmd_length);
							}
							printf("\n\nsql2=%s\n\nencode=%d\n",sql_query,encode);
							mysql_query(my_connection,sql_query);

							bzero(sql_query,string_length);
							sprintf(sql_query,"update sessions set total_cmd=total_cmd+1,end=now(),s_bytes=%lf where sid=%d",(float)(* g_bytes)/1000,sid);
							mysql_query(my_connection,sql_query);

							bzero(sql_query,string_length);
							sprintf(sql_query,"update sessions set dangerous=%d where sid=%d and dangerous<%d",level,level);
							mysql_query(my_connection,sql_query);

							bzero(alarm_content,string_length);
							sprintf(alarm_content,"%s run command '%s' on device '%s' as the account '%s' in session %d",radius_username,inputcommandline,sstr,user,sid);
							printf("3\n");
							freesvr_alarm(alarm_content,level,syslogserver,syslogfacility,mailserver,mailaccount,mailpassword,adminmailaccount,syslogalarm,mailalarm,adminmailaccount_num);
					}
					if(level==1)
					{
						write(fd1,"\n**************************",27);
						write(fd1,"\nforbidden command!\n",20);
						write(fd1,"**************************\n",27);

						gettimeofday (&tv , &tz);
						write(fd2,&tv,sizeof(tv));
                        write(fd2,"1",1);
						write(fd2,&alarm_length,sizeof(alarm_length));

						write(fd2,"\n**************************",27);
						write(fd2,"\nforbidden command!\n",20);
						write(fd2,"**************************\n",27);

						block_command_flag = 1;
						block_session_id = session_id;
					}
					else if(level==2)
					{
						write(fd1,"\n**************************",27);
						write(fd1,"\nforbidden command!\n",20);
						write(fd1,"**************************\n",27);

						gettimeofday (&tv , &tz);
						write(fd2,&tv,sizeof(tv));
                        write(fd2,"1",1);
						write(fd2,&alarm_length,sizeof(alarm_length));

						write(fd2,"\n**************************",27);
						write(fd2,"\nforbidden command!\n",20);
						write(fd2,"**************************\n",27);

						cleanup_exit( 255 );
					}
                    else if(level==4)
                    {
                        int count=0;
                        char tmp_buf[256]={0};
                        int echo_length=74;

						send_message_2_client(session_id,"\n\r AUTH_TERM: this command needs authority from manager,are you sure?[Y/n]");
//                      write(fileno(stdout),"\n\r AUTH_TERM: this command needs authority from manager,are you sure?[Y/n]",74);
                        write(fd1,"\n\r AUTH_TERM: this command needs authority from manager,are you sure?[Y/n]",74);

                        gettimeofday (&tv , &tz);
                        write(fd2,&tv,sizeof(tv));
                        write(fd2,"1",1);
                        write(fd2,&echo_length,sizeof(echo_length));
                        write(fd2,"\n\r AUTH_TERM: this command needs authority from manager,are you sure?[Y/n]",74);

						char * t = process_client_input_string(cfd,session_id,"",0);
						if(t[0]!='Y' && t[0]!='y')
						{
							printf("here3\n");
							printf("\n\rBad Password!\n\r");

							block_command_flag = 1;
							block_session_id = session_id;

							echo_length=89;
							write(fd1,"\nBad Password!\n",15);
							write(fd1,"\n**************************",27);
							write(fd1,"\nforbidden command!\n",20);
							write(fd1,"**************************\n",27);


							gettimeofday (&tv , &tz);
							write(fd2,&tv,sizeof(tv));
                            write(fd2,"1",1);
							write(fd2,&echo_length,sizeof(echo_length));


							write(fd2,"\nBad Password!\n",15);
							write(fd2,"\n**************************",27);
							write(fd2,"\nforbidden command!\n",20);
							write(fd2,"**************************\n",27);


							printf("\r\n\n**************************");
							printf("\r\n*** forbidden command! ***\n");
							printf("\r**************************\n\n");

							bzero(inputcommandline,string_length);
							bzero(commandline,string_length);
							return;
						}
                        if(access(monitor_shell_pipe_name_tm,W_OK)==0)
                        {
                            twin_checked=0;
                            int monitor_fd=open(monitor_shell_pipe_name_tm,O_WRONLY);
                            if(monitor_fd<0)
                            {
                                perror("monitor fd open fail\n");
                            }
                            else
                            {
                                char start_monitor_admin_pass_check_str[11]={1,3,3,7,0,1,8,8,5,2,9};
                                write(monitor_fd,start_monitor_admin_pass_check_str,11);

                                echo_length=84;
                                send_message_2_client(session_id,"\n\rwaiting confirm until timeout...\n\r");

                                write(fd1,"\n\rwaiting confirm until timeout...\n\r",36);
                                gettimeofday (&tv , &tz);
                                write(fd2,&tv,sizeof(tv));
                                write(fd2,"1",1);
                                write(fd2,&echo_length,sizeof(echo_length));
                                write(fd2,"\n\rwaiting confirm until timeout...\n\r",36);

								int wait_time=0;
                                while(1)
                                {
									if(wait_time>10)
									{
										write(monitor_fd,10,1);
										break;
									}
                                    if(twin_checked!=0)
                                    {
                                        break;
                                    }
									sleep(1);
									wait_time++;
                                }
                                if(twin_checked==2)
                                {
									send_message_2_client(session_id,"OK\n");
                                    write(fd1,"OK\n",3);

                                    echo_length=3;
                                    gettimeofday (&tv , &tz);
                                    write(fd2,&tv,sizeof(tv));
                                    write(fd2,"1",1);
                                    write(fd2,&echo_length,sizeof(echo_length));
                                    write(fd2,"OK\n",3);

                                    bzero(inputcommandline,string_length);
                                    bzero(commandline,string_length);
                                    return;
                                }
                                else
                                {
									send_message_2_client(session_id,"\n\rBad Password!\n\r");


	                                block_command_flag = 1;
	                                block_session_id = session_id;

                                    write(fd1,"\nBad Password!\n",15);
                                    write(fd1,"\n**************************",27);
                                    write(fd1,"\nforbidden command!\n",20);
                                    write(fd1,"**************************\n",27);

                                    echo_length=89;
                                    gettimeofday (&tv , &tz);
                                    write(fd2,&tv,sizeof(tv));
                                    write(fd2,"1",1);
                                    write(fd2,&echo_length,sizeof(echo_length));

                                    write(fd2,"\nBad Password!\n",15);
                                    write(fd2,"\n**************************",27);
                                    write(fd2,"\nforbidden command!\n",20);
                                    write(fd2,"**************************\n",27);

                                    bzero(inputcommandline,string_length);
                                    bzero(commandline,string_length);
                                    return;
                                }
                            }
                        }
                        else
                        {
							send_message_2_client(session_id, "\n\rinput password:");
                        //    write(fileno(stdout),"\n\rinput password:",17);
                            write(fd1,"\n\rinput password:\n",18);

                            echo_length=18;
                            gettimeofday (&tv , &tz);
                            write(fd2,&tv,sizeof(tv));
                            write(fd2,"1",1);
                            write(fd2,&echo_length,sizeof(echo_length));
                            write(fd2,"\n\rinput password:\n",18);

							t = process_client_input_string(cfd,session_id,"",0);							

                            if(strcmp(t,admin_password)==0)
                            {
								send_message_2_client(session_id,"OK!\n");
                                bzero(inputcommandline,string_length);
                                bzero(commandline,string_length);
                                return;
                            }
                            else
                            {
								send_message_2_client(session_id,"\n\rBad Password!\n\r");

		                        block_command_flag = 1;
		                        block_session_id = session_id;

                                write(fd1,"\nBad Password!\n",15);
                                write(fd1,"\n**************************",27);
                                write(fd1,"\nforbidden command!\n",20);
                                write(fd1,"**************************\n",27);

                                echo_length=89;
                                gettimeofday (&tv , &tz);
                                write(fd2,&tv,sizeof(tv));
                                write(fd2,"1",1);
                                write(fd2,&echo_length,sizeof(echo_length));

                                write(fd2,"\nBad Password!\n",15);
                                write(fd2,"\n**************************",27);
                                write(fd2,"\nforbidden command!\n",20);
                                write(fd2,"**************************\n",27);

                                printf("\r\n\n**************************");
                                printf("\r\n*** forbidden command! ***\n");
                                printf("\r**************************\n\n");

                                bzero(inputcommandline,string_length);
                                bzero(commandline,string_length);
                                return;
                            }
                        }
                    }
				}
				else
				{
                    if(strlen(linebuffer)>0 && strlen(linebuffer)<128)
                    {
						to_get_a_prompt(prompts,linebuffer,strlen(linebuffer),my_connection,sql_query);
						if((*get_first_prompt)>0)
						{
							bzero(sql_query,string_length);
							sprintf(sql_query,"update devices set first_prompt='%s' where id=%d",prompts[0],did);
			                printf("sql_query1=%s\n",sql_query);
							mysql_query(my_connection,sql_query);
							(*get_first_prompt)=0;
						}
                    }
				}
            }
        bzero(inputcommandline,string_length);
        bzero(commandline,string_length);
        return;
        }
        if((* invim)==0)
        {
            if((char)(commandline+strlen(commandline)=='\n'))
            {
                bzero(cache1,string_length);
                bzero(cache2,string_length);
                termfunc(commandline,cache1,cache2,1);

				if(strlen(cache2)>0)
				{
					sprintf(cmd,"%s",cache2);
					check_invim(cmd,invim,prompts,my_connection,sql_query);

                    int level=black_or_white;

                    for(int j=0;j<black_cmd_num;j++)
                    {
                        if(black_or_white==0)
                        {
                            if(pcre_match(cmd,black_cmd_list[j].cmd)==0)
                            {
                                level = black_cmd_list[j].level + 1;
                                break;
                            }
                        }
                        else
                        {
                            if(pcre_match(cmd,black_cmd_list[j].cmd)==0)
                            {
                                level = 0;
                                break;
                            }
                        }
                    }

                    for(int i=0;i<pass_prompt_count;i++)
                    {
                        if(pcre_match(commandline,pass_prompt[i])==0)
                        {
                            bzero(inputcommandline,string_length);
                            bzero(commandline,string_length);
                            return;
                        }
                    }

                    autosu_any(cache2,radius_username,sstr,user,sql_query,sp,session_id,commandline,my_connection);

					bzero(sql_query,string_length);

                    if((*get_first_prompt)>0)
                    {
                        (*get_first_prompt)--;
                    }

					if((* insz)==0)
					{
						/*
							for(int i=0;i<50;i++)
							{
									if(strlen(prompts[i])>0 && strstr(cache2,prompts[i])!=0)
									{
											char cache_tmp[string_length];
											bzero(cache_tmp,string_length);
											memcpy(cache_tmp,cache2+strlen(prompts[i]),strlen(cache2+strlen(prompts[i])));
											bzero(cache2,string_length);
											memcpy(cache2,cache_tmp,strlen(cache_tmp));
											break;
									}
							}
							*/

							if(encode==1)
							{
								bzero(cache1,string_length);
								myg2u(cache2,strlen(cache2),cache1,string_length);
								deal_special_char(cache1);

								if(command_filter(cache1)==-1)
								{
									bzero(inputcommandline,string_length);
									bzero(commandline,string_length);
									return;
								}
								sprintf(sql_query,"insert into commands (cid,sid,at,cmd,dangerlevel,jump_session) values  (NULL,%d,now(),'%s',%d,0)",sid,cache1,level);
								gettimeofday (&tv , &tz);
								write(fd2,&tv,sizeof(tv));
								write(fd2,"2",1);   //1:content 2:command
								int cmd_length=0;
								cmd_length=strlen(cache1);
								write(fd2,&cmd_length,sizeof(cmd_length));
								write(fd2,cache1,cmd_length);
							}
							else
							{
								deal_special_char(cache2);


								if(command_filter(cache2)==-1)
								{
									bzero(inputcommandline,string_length);
									bzero(commandline,string_length);
									return;
								}
								sprintf(sql_query,"insert into commands (cid,sid,at,cmd,dangerlevel,jump_session) values  (NULL,%d,now(),'%s',%d,0)",sid,cache2,level);
								gettimeofday (&tv , &tz);
								write(fd2,&tv,sizeof(tv));
								write(fd2,"2",1);   //1:content 2:command
								int cmd_length=0;
								cmd_length=strlen(cache1);
								write(fd2,&cmd_length,sizeof(cmd_length));
								write(fd2,cache1,cmd_length);
							}
							printf("\n\nsql3=%s\n\nencode=%d\n",sql_query,encode);
							mysql_query(my_connection,sql_query);


							bzero(sql_query,string_length);
							sprintf(sql_query,"update sessions set total_cmd=total_cmd+1,end=now(),s_bytes=%lf where sid=%d",(float)(* g_bytes)/1000,sid);
							mysql_query(my_connection,sql_query);

							bzero(sql_query,string_length);
							sprintf(sql_query,"update sessions set dangerous=%d where sid=%d and dangerous<%d",level,level);
							mysql_query(my_connection,sql_query);

							bzero(alarm_content,string_length);
							sprintf(alarm_content,"%s run command '%s' on device '%s' as the account '%s' in session %d",radius_username,cache2,sstr,user,sid);
							freesvr_alarm(alarm_content,level,syslogserver,syslogfacility,mailserver,mailaccount,mailpassword,adminmailaccount,syslogalarm,mailalarm,adminmailaccount_num);
					}

					if(level==1)
					{
						write(fd1,"\n**************************",27);
						write(fd1,"\nforbidden command!\n",20);
						write(fd1,"**************************\n",27);

						gettimeofday (&tv , &tz);
						write(fd2,&tv,sizeof(tv));
                        write(fd2,"1",1);
						write(fd2,&alarm_length,sizeof(alarm_length));

						write(fd2,"\n**************************",27);
						write(fd2,"\nforbidden command!\n",20);
						write(fd2,"**************************\n",27);

						block_command_flag = 1;
						block_session_id = session_id;
					}
					else if(level==2)
					{
						write(fd1,"\n**************************",27);
						write(fd1,"\nforbidden command!\n",20);
						write(fd1,"**************************\n",27);

						gettimeofday (&tv , &tz);
						write(fd2,&tv,sizeof(tv));
                        write(fd2,"1",1);
						write(fd2,&alarm_length,sizeof(alarm_length));

						write(fd2,"\n**************************",27);
						write(fd2,"\nforbidden command!\n",20);
						write(fd2,"**************************\n",27);

						cleanup_exit( 255 );
					}
                    else if(level==4)
                    {
                        int count=0;
                        char tmp_buf[256]={0};
                        int echo_length=74;

                        send_message_2_client(session_id,"\n\r AUTH_TERM: this command needs authority from manager,are you sure?[Y/n]");
                        write(fd1,"\n\r AUTH_TERM: this command needs authority from manager,are you sure?[Y/n]",74);

                        gettimeofday (&tv , &tz);
                        write(fd2,&tv,sizeof(tv));
                        write(fd2,"1",1);
                        write(fd2,&echo_length,sizeof(echo_length));
                        write(fd2,"\n\r AUTH_TERM: this command needs authority from manager,are you sure?[Y/n]",74);

                        char * t = process_client_input_string(cfd,session_id,"",0);
                        if(t[0]!='Y' && t[0]!='y')
                        {
                            printf("here3\n");
                            printf("\n\rBad Password!\n\r");

                            block_command_flag = 1;
                            block_session_id = session_id;

                            echo_length=89;
                            write(fd1,"\nBad Password!\n",15);
                            write(fd1,"\n**************************",27);
                            write(fd1,"\nforbidden command!\n",20);
                            write(fd1,"**************************\n",27);


                            gettimeofday (&tv , &tz);
                            write(fd2,&tv,sizeof(tv));
                            write(fd2,"1",1);
                            write(fd2,&echo_length,sizeof(echo_length));


                            write(fd2,"\nBad Password!\n",15);
                            write(fd2,"\n**************************",27);
                            write(fd2,"\nforbidden command!\n",20);
                            write(fd2,"**************************\n",27);


                            printf("\r\n\n**************************");
                            printf("\r\n*** forbidden command! ***\n");
                            printf("\r**************************\n\n");

                            bzero(inputcommandline,string_length);
                            bzero(commandline,string_length);
                            return;
                        }
                        if(access(monitor_shell_pipe_name_tm,W_OK)==0)
                        {
                            twin_checked=0;
                            int monitor_fd=open(monitor_shell_pipe_name_tm,O_WRONLY);
                            if(monitor_fd<0)
                            {
                                perror("monitor fd open fail\n");
                            }   
                            else
                            {
                                char start_monitor_admin_pass_check_str[11]={1,3,3,7,0,1,8,8,5,2,9};
                                write(monitor_fd,start_monitor_admin_pass_check_str,11);
                                
                                echo_length=84;
                                send_message_2_client(session_id,"\n\rwaiting confirm until timeout...\n\r");
                                
                                write(fd1,"\n\rwaiting confirm until timeout...\n\r",36);
                                gettimeofday (&tv , &tz);
                                write(fd2,&tv,sizeof(tv));
                                write(fd2,"1",1);
                                write(fd2,&echo_length,sizeof(echo_length));
                                write(fd2,"\n\rwaiting confirm until timeout...\n\r",36);
                                
                                int wait_time=0;
                                while(1)
                                {
                                    if(wait_time>10)
                                    {
                                        write(monitor_fd,10,1);
                                        break;
                                    }
                                    if(twin_checked!=0)
                                    {
                                        break;
                                    }
                                    sleep(1);
                                    wait_time++;
                                }
                                if(twin_checked==2)
                                {
                                    send_message_2_client(session_id,"OK\n");
                                    write(fd1,"OK\n",3);

                                    echo_length=3;
                                    gettimeofday (&tv , &tz);
                                    write(fd2,&tv,sizeof(tv));
                                    write(fd2,"1",1);
                                    write(fd2,&echo_length,sizeof(echo_length));
                                    write(fd2,"OK\n",3);

                                    bzero(inputcommandline,string_length);
                                    bzero(commandline,string_length);
                                    return;
                                }
                                else
                                {
                                    send_message_2_client(session_id,"\n\rBad Password!\n\r");


                                    block_command_flag = 1;
                                    block_session_id = session_id;

                                    write(fd1,"\nBad Password!\n",15);
                                    write(fd1,"\n**************************",27);
                                    write(fd1,"\nforbidden command!\n",20);
                                    write(fd1,"**************************\n",27);

                                    echo_length=89;
                                    gettimeofday (&tv , &tz);
                                    write(fd2,&tv,sizeof(tv));
                                    write(fd2,"1",1);
                                    write(fd2,&echo_length,sizeof(echo_length));

                                    write(fd2,"\nBad Password!\n",15);
                                    write(fd2,"\n**************************",27);
                                    write(fd2,"\nforbidden command!\n",20);
                                    write(fd2,"**************************\n",27);

                                    bzero(inputcommandline,string_length);
                                    bzero(commandline,string_length);
                                    return;
                                }
                            }
                        }
                        else
                        {
                            send_message_2_client(session_id, "\n\rinput password:");
                        //    write(fileno(stdout),"\n\rinput password:",17);
                            write(fd1,"\n\rinput password:\n",18);

                            echo_length=18;
                            gettimeofday (&tv , &tz);
                            write(fd2,&tv,sizeof(tv));
                            write(fd2,"1",1);
                            write(fd2,&echo_length,sizeof(echo_length));
                            write(fd2,"\n\rinput password:\n",18);

                            t = process_client_input_string(cfd,session_id,"",0);

                            if(strcmp(t,admin_password)==0)
                            {
                                send_message_2_client(session_id,"OK!\n");
                                bzero(inputcommandline,string_length);
                                bzero(commandline,string_length);
                                return;
                            }
                            else
                            {
                                send_message_2_client(session_id,"\n\rBad Password!\n\r");

                                block_command_flag = 1;
                                block_session_id = session_id;

                                write(fd1,"\nBad Password!\n",15);
                                write(fd1,"\n**************************",27);
                                write(fd1,"\nforbidden command!\n",20);
                                write(fd1,"**************************\n",27);

                                echo_length=89;
                                gettimeofday (&tv , &tz);
                                write(fd2,&tv,sizeof(tv));
                                write(fd2,"1",1);
                                write(fd2,&echo_length,sizeof(echo_length));

                                write(fd2,"\nBad Password!\n",15);
                                write(fd2,"\n**************************",27);
                                write(fd2,"\nforbidden command!\n",20);
                                write(fd2,"**************************\n",27);

                                printf("\r\n\n**************************");
                                printf("\r\n*** forbidden command! ***\n");
                                printf("\r**************************\n\n");

                                bzero(inputcommandline,string_length);
                                bzero(commandline,string_length);
                                return;
                            }
                        }
                    }
				}

                bzero(inputcommandline,string_length);
                bzero(commandline,string_length);
            }
            else
            {
                (* waitforline)=1;
				bzero(cache1,string_length);
				bzero(cache2,string_length);
				termfunc(commandline,cache1,cache2,0);

                if(strlen(cache2)>0)
                {
					printf("\n\ncache2=%s\n\n",cache2);
                    sprintf(cmd,"%s",cache2);
                    check_invim(cmd,invim,prompts,my_connection,sql_query);

                    int level=black_or_white;

                    for(int j=0;j<black_cmd_num;j++)
                    {
                        if(black_or_white==0)
                        {
                            if(pcre_match(cmd,black_cmd_list[j].cmd)==0)
                            {
                                level = black_cmd_list[j].level + 1;
                                break;
                            }
                        }
                        else
                        {
                            if(pcre_match(cmd,black_cmd_list[j].cmd)==0)
                            {
                                level = 0;
                                break;
                            }
                        }
                    }

                    for(int i=0;i<pass_prompt_count;i++)
                    {
                        if(pcre_match(commandline,pass_prompt[i])==0)
                        {
                            bzero(inputcommandline,string_length);
                            bzero(commandline,string_length);
                            return;
                        }
                    }

					(* waitforline)=0; 

                    autosu_any(cache2,radius_username,sstr,user,sql_query,sp,session_id,commandline,my_connection);
                    bzero(sql_query,string_length);

                    if((*get_first_prompt)>0)
                    {
                        (*get_first_prompt)--;
                    }

					if((* insz)==0)
					{
						/*
							for(int i=0;i<50;i++)
							{
									if(strlen(prompts[i])>0 && strstr(cache2,prompts[i])!=0)
									{
											char cache_tmp[string_length];
											bzero(cache_tmp,string_length);
											memcpy(cache_tmp,cache2+strlen(prompts[i]),strlen(cache2+strlen(prompts[i])));
											bzero(cache2,string_length);
											memcpy(cache2,cache_tmp,strlen(cache_tmp));

											printf("match prompt\n");
											break;
									}
							}
						*/


							if(encode==1)
							{
								bzero(cache1,string_length);
								myg2u(cache2,strlen(cache2),cache1,string_length);
								deal_special_char(cache1);

								if(command_filter(cache1)==-1)
								{
									bzero(inputcommandline,string_length);
									bzero(commandline,string_length);
									return;
								}
								sprintf(sql_query,"insert into commands (cid,sid,at,cmd,dangerlevel,jump_session) values  (NULL,%d,now(),'%s',%d,0)",sid,cache1,level);
								gettimeofday (&tv , &tz);
								write(fd2,&tv,sizeof(tv));
								write(fd2,"2",1);   //1:content 2:command
								int cmd_length=0;
								cmd_length=strlen(cache1);
								write(fd2,&cmd_length,sizeof(cmd_length));
								write(fd2,cache1,cmd_length);
							}
							else
							{
								deal_special_char(cache2);

								if(command_filter(cache2)==-1)
								{
									bzero(inputcommandline,string_length);
									bzero(commandline,string_length);
									return;
								}
								sprintf(sql_query,"insert into commands (cid,sid,at,cmd,dangerlevel,jump_session) values  (NULL,%d,now(),'%s',%d,0)",sid,cache2,level);
								gettimeofday (&tv , &tz);
								write(fd2,&tv,sizeof(tv));
								write(fd2,"2",1);   //1:content 2:command
								int cmd_length=0;
								cmd_length=strlen(cache1);
								write(fd2,&cmd_length,sizeof(cmd_length));
								write(fd2,cache1,cmd_length);
							}
							printf("\n\nsql4=%s\n\nencode=%d\n",sql_query,encode);
							mysql_query(my_connection,sql_query);

							bzero(sql_query,string_length);
							sprintf(sql_query,"update sessions set total_cmd=total_cmd+1,end=now(),s_bytes=%lf where sid=%d",(float)(* g_bytes)/1000,sid);
							mysql_query(my_connection,sql_query);

							bzero(sql_query,string_length);
							sprintf(sql_query,"update sessions set dangerous=%d where sid=%d and dangerous<%d",level,level);
							mysql_query(my_connection,sql_query);

							bzero(alarm_content,string_length);
							sprintf(alarm_content,"%s run command '%s' on device '%s' as the account '%s' in session %d",radius_username,cache2,sstr,user,sid);
							freesvr_alarm(alarm_content,level,syslogserver,syslogfacility,mailserver,mailaccount,mailpassword,adminmailaccount,syslogalarm,mailalarm,adminmailaccount_num);
					}

                    if(level==1)
                    {
						write(fd1,"\n**************************",27);
						write(fd1,"\nforbidden command!\n",20);
						write(fd1,"**************************\n",27);

						gettimeofday (&tv , &tz);
						write(fd2,&tv,sizeof(tv));
                        write(fd2,"1",1);
						write(fd2,&alarm_length,sizeof(alarm_length));

						write(fd2,"\n**************************",27);
						write(fd2,"\nforbidden command!\n",20);
						write(fd2,"**************************\n",27);

                        block_command_flag = 1;
                        block_session_id = session_id;
                    }
                    else if(level==2)
                    {
						write(fd1,"\n**************************",27);
						write(fd1,"\nforbidden command!\n",20);
						write(fd1,"**************************\n",27);

						gettimeofday (&tv , &tz);
						write(fd2,&tv,sizeof(tv));
                        write(fd2,"1",1);
						write(fd2,&alarm_length,sizeof(alarm_length));

						write(fd2,"\n**************************",27);
						write(fd2,"\nforbidden command!\n",20);
						write(fd2,"**************************\n",27);

                        cleanup_exit( 255 );
                    }
                    else if(level==4)
                    {
                        int count=0;
                        char tmp_buf[256]={0};
                        int echo_length=74;

                        send_message_2_client(session_id,"\n\r AUTH_TERM: this command needs authority from manager,are you sure?[Y/n]");
                        write(fd1,"\n\r AUTH_TERM: this command needs authority from manager,are you sure?[Y/n]",74);

                        gettimeofday (&tv , &tz);
                        write(fd2,&tv,sizeof(tv));
                        write(fd2,"1",1);
                        write(fd2,&echo_length,sizeof(echo_length));
                        write(fd2,"\n\r AUTH_TERM: this command needs authority from manager,are you sure?[Y/n]",74);

                        char * t = process_client_input_string(cfd,session_id,"",0);
                        if(t[0]!='Y' && t[0]!='y')
                        {
                            printf("here3\n");
                            printf("\n\rBad Password!\n\r");

                            block_command_flag = 1;
                            block_session_id = session_id;

                            echo_length=89;
                            write(fd1,"\nBad Password!\n",15);
                            write(fd1,"\n**************************",27);
                            write(fd1,"\nforbidden command!\n",20);
                            write(fd1,"**************************\n",27);


                            gettimeofday (&tv , &tz);
                            write(fd2,&tv,sizeof(tv));
                            write(fd2,"1",1);
                            write(fd2,&echo_length,sizeof(echo_length));


                            write(fd2,"\nBad Password!\n",15);
                            write(fd2,"\n**************************",27);
                            write(fd2,"\nforbidden command!\n",20);
                            write(fd2,"**************************\n",27);


                            printf("\r\n\n**************************");
                            printf("\r\n*** forbidden command! ***\n");
                            printf("\r**************************\n\n");

                            bzero(inputcommandline,string_length);
                            bzero(commandline,string_length);
                            return;
                        }
                        if(access(monitor_shell_pipe_name_tm,W_OK)==0)
                        {
                            twin_checked=0;
                            int monitor_fd=open(monitor_shell_pipe_name_tm,O_WRONLY);
                            if(monitor_fd<0)
                            {
                                perror("monitor fd open fail\n");
                            }   
                            else
                            {
                                char start_monitor_admin_pass_check_str[11]={1,3,3,7,0,1,8,8,5,2,9};
                                write(monitor_fd,start_monitor_admin_pass_check_str,11);
                                
                                echo_length=84;
                                send_message_2_client(session_id,"\n\rwaiting confirm until timeout...\n\r");
                                
                                write(fd1,"\n\rwaiting confirm until timeout...\n\r",36);
                                gettimeofday (&tv , &tz);
                                write(fd2,&tv,sizeof(tv));
                                write(fd2,"1",1);
                                write(fd2,&echo_length,sizeof(echo_length));
                                write(fd2,"\n\rwaiting confirm until timeout...\n\r",36);
                                
                                int wait_time=0;
                                while(1)
                                {
                                    if(wait_time>10)
                                    {
                                        write(monitor_fd,10,1);
                                        break;
                                    }
                                    if(twin_checked!=0)
                                    {
                                        break;
                                    }
                                    sleep(1);
                                    wait_time++;
                                }
                                if(twin_checked==2)
                                {
                                    send_message_2_client(session_id,"OK\n");
                                    write(fd1,"OK\n",3);

                                    echo_length=3;
                                    gettimeofday (&tv , &tz);
                                    write(fd2,&tv,sizeof(tv));
                                    write(fd2,"1",1);
                                    write(fd2,&echo_length,sizeof(echo_length));
                                    write(fd2,"OK\n",3);

                                    bzero(inputcommandline,string_length);
                                    bzero(commandline,string_length);
                                    return;
                                }
                                else
                                {
                                    send_message_2_client(session_id,"\n\rBad Password!\n\r");


                                    block_command_flag = 1;
                                    block_session_id = session_id;

                                    write(fd1,"\nBad Password!\n",15);
                                    write(fd1,"\n**************************",27);
                                    write(fd1,"\nforbidden command!\n",20);
                                    write(fd1,"**************************\n",27);

                                    echo_length=89;
                                    gettimeofday (&tv , &tz);
                                    write(fd2,&tv,sizeof(tv));
                                    write(fd2,"1",1);
                                    write(fd2,&echo_length,sizeof(echo_length));

                                    write(fd2,"\nBad Password!\n",15);
                                    write(fd2,"\n**************************",27);
                                    write(fd2,"\nforbidden command!\n",20);
                                    write(fd2,"**************************\n",27);

                                    bzero(inputcommandline,string_length);
                                    bzero(commandline,string_length);
                                    return;
                                }
                            }
                        }
                        else
                        {
                            send_message_2_client(session_id, "\n\rinput password:");
                        //    write(fileno(stdout),"\n\rinput password:",17);
                            write(fd1,"\n\rinput password:\n",18);

                            echo_length=18;
                            gettimeofday (&tv , &tz);
                            write(fd2,&tv,sizeof(tv));
                            write(fd2,"1",1);
                            write(fd2,&echo_length,sizeof(echo_length));
                            write(fd2,"\n\rinput password:\n",18);

                            t = process_client_input_string(cfd,session_id,"",0);

                            if(strcmp(t,admin_password)==0)
                            {
                                send_message_2_client(session_id,"OK!\n");
                                bzero(inputcommandline,string_length);
                                bzero(commandline,string_length);
                                return;
                            }
                            else
                            {
                                send_message_2_client(session_id,"\n\rBad Password!\n\r");

                                block_command_flag = 1;
                                block_session_id = session_id;

                                write(fd1,"\nBad Password!\n",15);
                                write(fd1,"\n**************************",27);
                                write(fd1,"\nforbidden command!\n",20);
                                write(fd1,"**************************\n",27);

                                echo_length=89;
                                gettimeofday (&tv , &tz);
                                write(fd2,&tv,sizeof(tv));
                                write(fd2,"1",1);
                                write(fd2,&echo_length,sizeof(echo_length));

                                write(fd2,"\nBad Password!\n",15);
                                write(fd2,"\n**************************",27);
                                write(fd2,"\nforbidden command!\n",20);
                                write(fd2,"**************************\n",27);

                                printf("\r\n\n**************************");
                                printf("\r\n*** forbidden command! ***\n");
                                printf("\r**************************\n\n");

                                bzero(inputcommandline,string_length);
                                bzero(commandline,string_length);
                                return;
                            }
                        }
                    }
                }

                bzero(inputcommandline,string_length);
                bzero(commandline,string_length);
            }
        }
        bzero(inputcommandline,string_length);
        return;
    }

    if(selfhandle_mode==0)
    {
    }
    if(selfhandle_mode)
    {
        int count=0;
        i=0;
        while(i<n)
        {
            if((p[i]=='\n' || p[i]=='\r') && count==0 && inputok==0)
            {
                if((* invim)==0)
                {
                    if((char)(commandline+strlen(commandline)=='\n'))
                    {
                        bzero(cache1,string_length);
                        bzero(cache2,string_length);
                        termfunc(commandline,cache1,cache2,1);

						if(strlen(cache2)>0)
						{
							sprintf(cmd,"%s",cache2);
							check_invim(cmd,invim,prompts,my_connection,sql_query);

							int level=black_or_white;

							for(int j=0;j<black_cmd_num;j++)
							{
								if(black_or_white==0)
								{
									if(pcre_match(cmd,black_cmd_list[j].cmd)==0)
									{
										level = black_cmd_list[j].level + 1;
										break;
									}
								}
								else
								{
									if(pcre_match(cmd,black_cmd_list[j].cmd)==0)
									{
										level = 0;
										break;
									}
								}
							}

							for(int i=0;i<pass_prompt_count;i++)
							{
								if(pcre_match(commandline,pass_prompt[i])==0)
								{
									bzero(inputcommandline,string_length);
									bzero(commandline,string_length);
									return;
								}
							}

                            autosu_any(cache2,radius_username,sstr,user,sql_query,sp,session_id,commandline,my_connection);
							bzero(sql_query,string_length);

							if((*get_first_prompt)>0)
							{
								(*get_first_prompt)--;
							}

                            line_number++;
                            printf("\n\rline_number = %d\n",line_number);

							if(line_number==1 && (* insz)==0)
							{
								/*
									for(int i=0;i<50;i++)
									{
											if(strlen(prompts[i])>0 && strstr(cache2,prompts[i])!=0)
											{
													char cache_tmp[string_length];
													bzero(cache_tmp,string_length);
													memcpy(cache_tmp,cache2+strlen(prompts[i]),strlen(cache2+strlen(prompts[i])));
													bzero(cache2,string_length);
													memcpy(cache2,cache_tmp,strlen(cache_tmp));
													break;
											}
									}
									*/

									if(encode==1)
									{
										bzero(cache1,string_length);
										myg2u(cache2,strlen(cache2),cache1,string_length);
										deal_special_char(cache1);
										if(str_isprint(cache1)==0)
										{
											break;
										}

										if(command_filter(cache1)==-1)
										{
											bzero(inputcommandline,string_length);
											bzero(commandline,string_length);
											return;
										}
										sprintf(sql_query,"insert into commands (cid,sid,at,cmd,dangerlevel,jump_session) values  (NULL,%d,now(),'%s',%d,0)",sid,cache1,level);
										gettimeofday (&tv , &tz);
										write(fd2,&tv,sizeof(tv));
										write(fd2,"2",1);   //1:content 2:command
										int cmd_length=0;
										cmd_length=strlen(cache1);
										write(fd2,&cmd_length,sizeof(cmd_length));
										write(fd2,cache1,cmd_length);
									}
									else
									{
										deal_special_char(cache2);
										if(str_isprint(cache2)==0)
										{
											break;
										}

										if(command_filter(cache2)==-1)
										{
											bzero(inputcommandline,string_length);
											bzero(commandline,string_length);
											return;
										}
										sprintf(sql_query,"insert into commands (cid,sid,at,cmd,dangerlevel,jump_session) values  (NULL,%d,now(),'%s',%d,0)",sid,cache2,level);
										gettimeofday (&tv , &tz);
										write(fd2,&tv,sizeof(tv));
										write(fd2,"2",1);   //1:content 2:command
										int cmd_length=0;
										cmd_length=strlen(cache1);
										write(fd2,&cmd_length,sizeof(cmd_length));
										write(fd2,cache1,cmd_length);
									}
									printf("\n\nsql5=%s\n\nencode=%d\n",sql_query,encode);

									mysql_query(my_connection,sql_query);


									bzero(sql_query,string_length);
									sprintf(sql_query,"update sessions set total_cmd=total_cmd+1,end=now(),s_bytes=%lf where sid=%d",(float)(* g_bytes)/1000,sid);
									mysql_query(my_connection,sql_query);

									bzero(sql_query,string_length);
									sprintf(sql_query,"update sessions set dangerous=%d where sid=%d and dangerous<%d",level,level);
									mysql_query(my_connection,sql_query);

									bzero(alarm_content,string_length);
									sprintf(alarm_content,"%s run command '%s' on device '%s' as the account '%s' in session %d",radius_username,cache2,sstr,user,sid);
									freesvr_alarm(alarm_content,level,syslogserver,syslogfacility,mailserver,mailaccount,mailpassword,adminmailaccount,syslogalarm,mailalarm,adminmailaccount_num);
							}

							if(level==1)
							{
								write(fd1,"\n**************************",27);
								write(fd1,"\nforbidden command!\n",20);
								write(fd1,"**************************\n",27);

								gettimeofday (&tv , &tz);
								write(fd2,&tv,sizeof(tv));
                                write(fd2,"1",1);
								write(fd2,&alarm_length,sizeof(alarm_length));

								write(fd2,"\n**************************",27);
								write(fd2,"\nforbidden command!\n",20);
								write(fd2,"**************************\n",27);

								block_command_flag = 1;
								block_session_id = session_id;
							}
							else if(level==2)
							{
								write(fd1,"\n**************************",27);
								write(fd1,"\nforbidden command!\n",20);
								write(fd1,"**************************\n",27);

								gettimeofday (&tv , &tz);
								write(fd2,&tv,sizeof(tv));
                                write(fd2,"1",1);
								write(fd2,&alarm_length,sizeof(alarm_length));

								write(fd2,"\n**************************",27);
								write(fd2,"\nforbidden command!\n",20);
								write(fd2,"**************************\n",27);

								cleanup_exit( 255 );
							}
							else if(level==4)
							{
                        int count=0;
                        char tmp_buf[256]={0};
                        int echo_length=74;

                        send_message_2_client(session_id,"\n\r AUTH_TERM: this command needs authority from manager,are you sure?[Y/n]");
                        write(fd1,"\n\r AUTH_TERM: this command needs authority from manager,are you sure?[Y/n]",74);

                        gettimeofday (&tv , &tz);
                        write(fd2,&tv,sizeof(tv));
                        write(fd2,"1",1);
                        write(fd2,&echo_length,sizeof(echo_length));
                        write(fd2,"\n\r AUTH_TERM: this command needs authority from manager,are you sure?[Y/n]",74);

                        char * t = process_client_input_string(cfd,session_id,"",0);
                        if(t[0]!='Y' && t[0]!='y')
                        {
                            printf("here3\n");
                            printf("\n\rBad Password!\n\r");

                            block_command_flag = 1;
                            block_session_id = session_id;

                            echo_length=89;
                            write(fd1,"\nBad Password!\n",15);
                            write(fd1,"\n**************************",27);
                            write(fd1,"\nforbidden command!\n",20);
                            write(fd1,"**************************\n",27);


                            gettimeofday (&tv , &tz);
                            write(fd2,&tv,sizeof(tv));
                            write(fd2,"1",1);
                            write(fd2,&echo_length,sizeof(echo_length));


                            write(fd2,"\nBad Password!\n",15);
                            write(fd2,"\n**************************",27);
                            write(fd2,"\nforbidden command!\n",20);
                            write(fd2,"**************************\n",27);


                            printf("\r\n\n**************************");
                            printf("\r\n*** forbidden command! ***\n");
                            printf("\r**************************\n\n");

                            bzero(inputcommandline,string_length);
                            bzero(commandline,string_length);
                            return;
                        }
                        if(access(monitor_shell_pipe_name_tm,W_OK)==0)
                        {
                            twin_checked=0;
                            int monitor_fd=open(monitor_shell_pipe_name_tm,O_WRONLY);
                            if(monitor_fd<0)
                            {
                                perror("monitor fd open fail\n");
                            }   
                            else
                            {
                                char start_monitor_admin_pass_check_str[11]={1,3,3,7,0,1,8,8,5,2,9};
                                write(monitor_fd,start_monitor_admin_pass_check_str,11);
                                
                                echo_length=84;
                                send_message_2_client(session_id,"\n\rwaiting confirm until timeout...\n\r");
                                
                                write(fd1,"\n\rwaiting confirm until timeout...\n\r",36);
                                gettimeofday (&tv , &tz);
                                write(fd2,&tv,sizeof(tv));
                                write(fd2,"1",1);
                                write(fd2,&echo_length,sizeof(echo_length));
                                write(fd2,"\n\rwaiting confirm until timeout...\n\r",36);
                                
                                int wait_time=0;
                                while(1)
                                {
                                    if(wait_time>10)
                                    {
                                        write(monitor_fd,10,1);
                                        break;
                                    }
                                    if(twin_checked!=0)
                                    {
                                        break;
                                    }
                                    sleep(1);
                                    wait_time++;
                                }
                                if(twin_checked==2)
                                {
                                    send_message_2_client(session_id,"OK\n");
                                    write(fd1,"OK\n",3);

                                    echo_length=3;
                                    gettimeofday (&tv , &tz);
                                    write(fd2,&tv,sizeof(tv));
                                    write(fd2,"1",1);
                                    write(fd2,&echo_length,sizeof(echo_length));
                                    write(fd2,"OK\n",3);

                                    bzero(inputcommandline,string_length);
                                    bzero(commandline,string_length);
                                    return;
                                }
                                else
                                {
                                    send_message_2_client(session_id,"\n\rBad Password!\n\r");


                                    block_command_flag = 1;
                                    block_session_id = session_id;

                                    write(fd1,"\nBad Password!\n",15);
                                    write(fd1,"\n**************************",27);
                                    write(fd1,"\nforbidden command!\n",20);
                                    write(fd1,"**************************\n",27);

                                    echo_length=89;
                                    gettimeofday (&tv , &tz);
                                    write(fd2,&tv,sizeof(tv));
                                    write(fd2,"1",1);
                                    write(fd2,&echo_length,sizeof(echo_length));

                                    write(fd2,"\nBad Password!\n",15);
                                    write(fd2,"\n**************************",27);
                                    write(fd2,"\nforbidden command!\n",20);
                                    write(fd2,"**************************\n",27);

                                    bzero(inputcommandline,string_length);
                                    bzero(commandline,string_length);
                                    return;
                                }
                            }
                        }
                        else
                        {
                            send_message_2_client(session_id, "\n\rinput password:");
                        //    write(fileno(stdout),"\n\rinput password:",17);
                            write(fd1,"\n\rinput password:\n",18);

                            echo_length=18;
                            gettimeofday (&tv , &tz);
                            write(fd2,&tv,sizeof(tv));
                            write(fd2,"1",1);
                            write(fd2,&echo_length,sizeof(echo_length));
                            write(fd2,"\n\rinput password:\n",18);

                            t = process_client_input_string(cfd,session_id,"",0);

                            if(strcmp(t,admin_password)==0)
                            {
                                send_message_2_client(session_id,"OK!\n");
                                bzero(inputcommandline,string_length);
                                bzero(commandline,string_length);
                                return;
                            }
                            else
                            {
                                send_message_2_client(session_id,"\n\rBad Password!\n\r");

                                block_command_flag = 1;
                                block_session_id = session_id;

                                write(fd1,"\nBad Password!\n",15);
                                write(fd1,"\n**************************",27);
                                write(fd1,"\nforbidden command!\n",20);
                                write(fd1,"**************************\n",27);

                                echo_length=89;
                                gettimeofday (&tv , &tz);
                                write(fd2,&tv,sizeof(tv));
                                write(fd2,"1",1);
                                write(fd2,&echo_length,sizeof(echo_length));

                                write(fd2,"\nBad Password!\n",15);
                                write(fd2,"\n**************************",27);
                                write(fd2,"\nforbidden command!\n",20);
                                write(fd2,"**************************\n",27);

                                printf("\r\n\n**************************");
                                printf("\r\n*** forbidden command! ***\n");
                                printf("\r**************************\n\n");

                                bzero(inputcommandline,string_length);
                                bzero(commandline,string_length);
                                return;
                            }
                        }
							}
						}
                        bzero(inputcommandline,string_length);
                        bzero(commandline,string_length);
                    }
                    else
                    {
                        (* waitforline)=1;
						bzero(cache1,string_length);
						bzero(cache2,string_length);
						termfunc(commandline,cache1,cache2,0);

						if(strlen(cache2)>0)
						{   
							printf("\n\ncache2=%s\n\n",cache2);
							sprintf(cmd,"%s",cache2);
							check_invim(cmd,invim,prompts,my_connection,sql_query);
							
				
							int level=black_or_white;

							for(int j=0;j<black_cmd_num;j++)
							{
								if(black_or_white==0)
								{
									if(pcre_match(cmd,black_cmd_list[j].cmd)==0)
									{
										level = black_cmd_list[j].level + 1;
										break;
									}
								}
								else
								{
									if(pcre_match(cmd,black_cmd_list[j].cmd)==0)
									{
										level = 0;
										break;
									}
								}
							}


							for(int i=0;i<pass_prompt_count;i++)
							{
								if(pcre_match(commandline,pass_prompt[i])==0)
								{
									bzero(inputcommandline,string_length);
									bzero(commandline,string_length);
									return;
								}
							}

                            autosu_any(cache2,radius_username,sstr,user,sql_query,sp,session_id,commandline,my_connection);

                            bzero(sql_query,string_length);

							if((*get_first_prompt)>0)
							{
								(*get_first_prompt)--;
							}

                            line_number++;
                            printf("\n\rline_number = %d\n",line_number);

							if(line_number==1 && (* insz)==0)
							{
								/*
									for(int i=0;i<50;i++)
									{
											if(strlen(prompts[i])>0 && strstr(cache2,prompts[i])!=0)
											{
													char cache_tmp[string_length];
													bzero(cache_tmp,string_length);
													memcpy(cache_tmp,cache2+strlen(prompts[i]),strlen(cache2+strlen(prompts[i])));
													bzero(cache2,string_length);
													memcpy(cache2,cache_tmp,strlen(cache_tmp));
													break;
											}
									}
									*/

									if(encode==1)
									{
										bzero(cache1,string_length);
										myg2u(cache2,strlen(cache2),cache1,string_length);
										deal_special_char(cache1);
										if(str_isprint(cache1)==0)
										{
											break;
										}
										sprintf(sql_query,"insert into commands (cid,sid,at,cmd,dangerlevel,jump_session) values  (NULL,%d,now(),'%s',%d,0)",sid,cache1,level);
										gettimeofday (&tv , &tz);
										write(fd2,&tv,sizeof(tv));
										write(fd2,"2",1);   //1:content 2:command
										int cmd_length=0;
										cmd_length=strlen(cache1);
										write(fd2,&cmd_length,sizeof(cmd_length));
										write(fd2,cache1,cmd_length);
									}
									else
									{
										deal_special_char(cache2);
										if(str_isprint(cache2)==0)
										{
											break;
										}
										sprintf(sql_query,"insert into commands (cid,sid,at,cmd,dangerlevel,jump_session) values  (NULL,%d,now(),'%s',%d,0)",sid,cache2,level);
										gettimeofday (&tv , &tz);
										write(fd2,&tv,sizeof(tv));
										write(fd2,"2",1);   //1:content 2:command
										int cmd_length=0;
										cmd_length=strlen(cache1);
										write(fd2,&cmd_length,sizeof(cmd_length));
										write(fd2,cache1,cmd_length);
									}
									printf("\n\nsql6=%s\n\nencode=%d\n",sql_query,encode);

									mysql_query(my_connection,sql_query);
											
											
									bzero(sql_query,string_length);
									sprintf(sql_query,"update sessions set total_cmd=total_cmd+1,end=now(),s_bytes=%lf where sid=%d",(float)(* g_bytes)/1000,sid);
									mysql_query(my_connection,sql_query);

									bzero(sql_query,string_length);
									sprintf(sql_query,"update sessions set dangerous=%d where sid=%d and dangerous<%d",level,level);
									mysql_query(my_connection,sql_query);

									bzero(alarm_content,string_length);
									sprintf(alarm_content,"%s run command '%s' on device '%s' as the account '%s' in session %d",radius_username,cache2,sstr,user,sid);
									freesvr_alarm(alarm_content,level,syslogserver,syslogfacility,mailserver,mailaccount,mailpassword,adminmailaccount,syslogalarm,mailalarm,adminmailaccount_num);
                            }

                            if(level==1)
                            {   
                                block_command_flag = 1;
                                block_session_id = session_id;
                                bzero(inputcommandline,string_length); 
                                bzero(commandline,string_length); 
                                return; 
                            }           
                            else if(level==2)
                            {       
                                cleanup_exit( 255 );
                            }
							else if(level==4)
							{
                        int count=0;
                        char tmp_buf[256]={0};
                        int echo_length=74;

                        send_message_2_client(session_id,"\n\r AUTH_TERM: this command needs authority from manager,are you sure?[Y/n]");
                        write(fd1,"\n\r AUTH_TERM: this command needs authority from manager,are you sure?[Y/n]",74);

                        gettimeofday (&tv , &tz);
                        write(fd2,&tv,sizeof(tv));
                        write(fd2,"1",1);
                        write(fd2,&echo_length,sizeof(echo_length));
                        write(fd2,"\n\r AUTH_TERM: this command needs authority from manager,are you sure?[Y/n]",74);

                        char * t = process_client_input_string(cfd,session_id,"",0);
                        if(t[0]!='Y' && t[0]!='y')
                        {
                            printf("here3\n");
                            printf("\n\rBad Password!\n\r");

                            block_command_flag = 1;
                            block_session_id = session_id;

                            echo_length=89;
                            write(fd1,"\nBad Password!\n",15);
                            write(fd1,"\n**************************",27);
                            write(fd1,"\nforbidden command!\n",20);
                            write(fd1,"**************************\n",27);


                            gettimeofday (&tv , &tz);
                            write(fd2,&tv,sizeof(tv));
                            write(fd2,"1",1);
                            write(fd2,&echo_length,sizeof(echo_length));


                            write(fd2,"\nBad Password!\n",15);
                            write(fd2,"\n**************************",27);
                            write(fd2,"\nforbidden command!\n",20);
                            write(fd2,"**************************\n",27);


                            printf("\r\n\n**************************");
                            printf("\r\n*** forbidden command! ***\n");
                            printf("\r**************************\n\n");

                            bzero(inputcommandline,string_length);
                            bzero(commandline,string_length);
                            return;
                        }
                        if(access(monitor_shell_pipe_name_tm,W_OK)==0)
                        {
                            twin_checked=0;
                            int monitor_fd=open(monitor_shell_pipe_name_tm,O_WRONLY);
                            if(monitor_fd<0)
                            {
                                perror("monitor fd open fail\n");
                            }   
                            else
                            {
                                char start_monitor_admin_pass_check_str[11]={1,3,3,7,0,1,8,8,5,2,9};
                                write(monitor_fd,start_monitor_admin_pass_check_str,11);
                                
                                echo_length=84;
                                send_message_2_client(session_id,"\n\rwaiting confirm until timeout...\n\r");
                                
                                write(fd1,"\n\rwaiting confirm until timeout...\n\r",36);
                                gettimeofday (&tv , &tz);
                                write(fd2,&tv,sizeof(tv));
                                write(fd2,"1",1);
                                write(fd2,&echo_length,sizeof(echo_length));
                                write(fd2,"\n\rwaiting confirm until timeout...\n\r",36);
                                
                                int wait_time=0;
                                while(1)
                                {
                                    if(wait_time>10)
                                    {
                                        write(monitor_fd,10,1);
                                        break;
                                    }
                                    if(twin_checked!=0)
                                    {
                                        break;
                                    }
                                    sleep(1);
                                    wait_time++;
                                }
                                if(twin_checked==2)
                                {
                                    send_message_2_client(session_id,"OK\n");
                                    write(fd1,"OK\n",3);

                                    echo_length=3;
                                    gettimeofday (&tv , &tz);
                                    write(fd2,&tv,sizeof(tv));
                                    write(fd2,"1",1);
                                    write(fd2,&echo_length,sizeof(echo_length));
                                    write(fd2,"OK\n",3);

                                    bzero(inputcommandline,string_length);
                                    bzero(commandline,string_length);
                                    return;
                                }
                                else
                                {
                                    send_message_2_client(session_id,"\n\rBad Password!\n\r");


                                    block_command_flag = 1;
                                    block_session_id = session_id;

                                    write(fd1,"\nBad Password!\n",15);
                                    write(fd1,"\n**************************",27);
                                    write(fd1,"\nforbidden command!\n",20);
                                    write(fd1,"**************************\n",27);

                                    echo_length=89;
                                    gettimeofday (&tv , &tz);
                                    write(fd2,&tv,sizeof(tv));
                                    write(fd2,"1",1);
                                    write(fd2,&echo_length,sizeof(echo_length));

                                    write(fd2,"\nBad Password!\n",15);
                                    write(fd2,"\n**************************",27);
                                    write(fd2,"\nforbidden command!\n",20);
                                    write(fd2,"**************************\n",27);

                                    bzero(inputcommandline,string_length);
                                    bzero(commandline,string_length);
                                    return;
                                }
                            }
                        }
                        else
                        {
                            send_message_2_client(session_id, "\n\rinput password:");
                        //    write(fileno(stdout),"\n\rinput password:",17);
                            write(fd1,"\n\rinput password:\n",18);

                            echo_length=18;
                            gettimeofday (&tv , &tz);
                            write(fd2,&tv,sizeof(tv));
                            write(fd2,"1",1);
                            write(fd2,&echo_length,sizeof(echo_length));
                            write(fd2,"\n\rinput password:\n",18);

                            t = process_client_input_string(cfd,session_id,"",0);

                            if(strcmp(t,admin_password)==0)
                            {
                                send_message_2_client(session_id,"OK!\n");
                                bzero(inputcommandline,string_length);
                                bzero(commandline,string_length);
                                return;
                            }
                            else
                            {
                                send_message_2_client(session_id,"\n\rBad Password!\n\r");

                                block_command_flag = 1;
                                block_session_id = session_id;

                                write(fd1,"\nBad Password!\n",15);
                                write(fd1,"\n**************************",27);
                                write(fd1,"\nforbidden command!\n",20);
                                write(fd1,"**************************\n",27);

                                echo_length=89;
                                gettimeofday (&tv , &tz);
                                write(fd2,&tv,sizeof(tv));
                                write(fd2,"1",1);
                                write(fd2,&echo_length,sizeof(echo_length));

                                write(fd2,"\nBad Password!\n",15);
                                write(fd2,"\n**************************",27);
                                write(fd2,"\nforbidden command!\n",20);
                                write(fd2,"**************************\n",27);

                                printf("\r\n\n**************************");
                                printf("\r\n*** forbidden command! ***\n");
                                printf("\r**************************\n\n");

                                bzero(inputcommandline,string_length);
                                bzero(commandline,string_length);
                                return;
                            }
                        }
							}
						}
                    }
                }
                count=1;
                i++;
                continue;
            }
            else if((p[i]=='\n' || p[i]=='\r') && count==0 && inputok==1)
            {
                if((* invim)==0)
                {
					if(strlen(inputcommandline)>0)
					{
						sprintf(cmd,"%s",inputcommandline);
						check_invim(cmd,invim,prompts,my_connection,sql_query);

						int level=black_or_white;

						
						for(int j=0;j<black_cmd_num;j++)
						{
							if(black_or_white==0)
							{
								if(pcre_match(cmd,black_cmd_list[j].cmd)==0)
								{
									level = black_cmd_list[j].level + 1;
									break;
								}
							}
							else
							{
								if(pcre_match(cmd,black_cmd_list[j].cmd)==0)
								{
									level = 0;
									break;
								}
							}
						}

						for(int i=0;i<pass_prompt_count;i++)
						{
							if(pcre_match(commandline,pass_prompt[i])==0)
							{
								bzero(inputcommandline,string_length);
								bzero(commandline,string_length);
								return;
							}
						}

                        autosu_any(inputcommandline,radius_username,sstr,user,sql_query,sp,session_id,commandline,my_connection);

						bzero(sql_query,string_length);

						if((*get_first_prompt)>0)
						{
							(*get_first_prompt)--;
						}


                        line_number++;
                        printf("\n\rline_number = %d\n",line_number);

						if(line_number==1 && (* insz)==0)
						{
							/*
								for(int i=0;i<50;i++)
								{
										if(strlen(prompts[i])>0 && strstr(inputcommandline,prompts[i])!=0)
										{
												char cache_tmp[string_length];
												bzero(cache_tmp,string_length);
												memcpy(cache_tmp,inputcommandline+strlen(prompts[i]),strlen(inputcommandline+strlen(prompts[i])));
												bzero(inputcommandline,string_length);
												memcpy(inputcommandline,cache_tmp,strlen(cache_tmp));
												break;
										}
								}
							*/

								if(encode==1)
								{
									bzero(cache1,string_length);
									myg2u(inputcommandline,strlen(inputcommandline),cache1,string_length);
									deal_special_char(cache1);
									if(str_isprint(cache1)==0)
									{
										break;
									}
									sprintf(sql_query,"insert into commands (cid,sid,at,cmd,dangerlevel,jump_session) values  (NULL,%d,now(),'%s',%d,0)",sid,cache1,level);
									gettimeofday (&tv , &tz);
									write(fd2,&tv,sizeof(tv));
									write(fd2,"2",1);   //1:content 2:command
									int cmd_length=0;
									cmd_length=strlen(cache1);
									write(fd2,&cmd_length,sizeof(cmd_length));
									write(fd2,cache1,cmd_length);
								}
								else
								{
									deal_special_char(inputcommandline);
									if(str_isprint(inputcommandline)==0)
									{
										break;
									}
									sprintf(sql_query,"insert into commands (cid,sid,at,cmd,dangerlevel,jump_session) values  (NULL,%d,now(),'%s',%d,0)",sid,inputcommandline,level);
									gettimeofday (&tv , &tz);
									write(fd2,&tv,sizeof(tv));
									write(fd2,"2",1);   //1:content 2:command
									int cmd_length=0;
									cmd_length=strlen(cache1);
									write(fd2,&cmd_length,sizeof(cmd_length));
									write(fd2,cache1,cmd_length);
								}
								printf("\n\nsql7=%s\n\nencode=%d\n",sql_query,encode);

								mysql_query(my_connection,sql_query);


								bzero(sql_query,string_length);
								sprintf(sql_query,"update sessions set total_cmd=total_cmd+1,end=now(),s_bytes=%lf where sid=%d",(float)(* g_bytes)/1000,sid);
								mysql_query(my_connection,sql_query);

								bzero(sql_query,string_length);
								sprintf(sql_query,"update sessions set dangerous=%d where sid=%d and dangerous<%d",level,level);
								mysql_query(my_connection,sql_query);

								bzero(alarm_content,string_length);
								sprintf(alarm_content,"%s run command '%s' on device '%s' as the account '%s' in session %d",radius_username,inputcommandline,sstr,user,sid);
								freesvr_alarm(alarm_content,level,syslogserver,syslogfacility,mailserver,mailaccount,mailpassword,adminmailaccount,syslogalarm,mailalarm,adminmailaccount_num);
						}

						if(level==1)
						{
							block_command_flag = 1;
							block_session_id = session_id;
						}
						else if(level==2)
						{
							cleanup_exit( 255 );
						}
						else if(level==4)
						{
                        int count=0;
                        char tmp_buf[256]={0};
                        int echo_length=74;

                        send_message_2_client(session_id,"\n\r AUTH_TERM: this command needs authority from manager,are you sure?[Y/n]");
                        write(fd1,"\n\r AUTH_TERM: this command needs authority from manager,are you sure?[Y/n]",74);

                        gettimeofday (&tv , &tz);
                        write(fd2,&tv,sizeof(tv));
                        write(fd2,"1",1);
                        write(fd2,&echo_length,sizeof(echo_length));
                        write(fd2,"\n\r AUTH_TERM: this command needs authority from manager,are you sure?[Y/n]",74);

                        char * t = process_client_input_string(cfd,session_id,"",0);
                        if(t[0]!='Y' && t[0]!='y')
                        {
                            printf("here3\n");
                            printf("\n\rBad Password!\n\r");

                            block_command_flag = 1;
                            block_session_id = session_id;

                            echo_length=89;
                            write(fd1,"\nBad Password!\n",15);
                            write(fd1,"\n**************************",27);
                            write(fd1,"\nforbidden command!\n",20);
                            write(fd1,"**************************\n",27);


                            gettimeofday (&tv , &tz);
                            write(fd2,&tv,sizeof(tv));
                            write(fd2,"1",1);
                            write(fd2,&echo_length,sizeof(echo_length));


                            write(fd2,"\nBad Password!\n",15);
                            write(fd2,"\n**************************",27);
                            write(fd2,"\nforbidden command!\n",20);
                            write(fd2,"**************************\n",27);


                            printf("\r\n\n**************************");
                            printf("\r\n*** forbidden command! ***\n");
                            printf("\r**************************\n\n");

                            bzero(inputcommandline,string_length);
                            bzero(commandline,string_length);
                            return;
                        }
                        if(access(monitor_shell_pipe_name_tm,W_OK)==0)
                        {
                            twin_checked=0;
                            int monitor_fd=open(monitor_shell_pipe_name_tm,O_WRONLY);
                            if(monitor_fd<0)
                            {
                                perror("monitor fd open fail\n");
                            }   
                            else
                            {
                                char start_monitor_admin_pass_check_str[11]={1,3,3,7,0,1,8,8,5,2,9};
                                write(monitor_fd,start_monitor_admin_pass_check_str,11);
                                
                                echo_length=84;
                                send_message_2_client(session_id,"\n\rwaiting confirm until timeout...\n\r");
                                
                                write(fd1,"\n\rwaiting confirm until timeout...\n\r",36);
                                gettimeofday (&tv , &tz);
                                write(fd2,&tv,sizeof(tv));
                                write(fd2,"1",1);
                                write(fd2,&echo_length,sizeof(echo_length));
                                write(fd2,"\n\rwaiting confirm until timeout...\n\r",36);
                                
                                int wait_time=0;
                                while(1)
                                {
                                    if(wait_time>10)
                                    {
                                        write(monitor_fd,10,1);
                                        break;
                                    }
                                    if(twin_checked!=0)
                                    {
                                        break;
                                    }
                                    sleep(1);
                                    wait_time++;
                                }
                                if(twin_checked==2)
                                {
                                    send_message_2_client(session_id,"OK\n");
                                    write(fd1,"OK\n",3);

                                    echo_length=3;
                                    gettimeofday (&tv , &tz);
                                    write(fd2,&tv,sizeof(tv));
                                    write(fd2,"1",1);
                                    write(fd2,&echo_length,sizeof(echo_length));
                                    write(fd2,"OK\n",3);

                                    bzero(inputcommandline,string_length);
                                    bzero(commandline,string_length);
                                    return;
                                }
                                else
                                {
                                    send_message_2_client(session_id,"\n\rBad Password!\n\r");


                                    block_command_flag = 1;
                                    block_session_id = session_id;

                                    write(fd1,"\nBad Password!\n",15);
                                    write(fd1,"\n**************************",27);
                                    write(fd1,"\nforbidden command!\n",20);
                                    write(fd1,"**************************\n",27);

                                    echo_length=89;
                                    gettimeofday (&tv , &tz);
                                    write(fd2,&tv,sizeof(tv));
                                    write(fd2,"1",1);
                                    write(fd2,&echo_length,sizeof(echo_length));

                                    write(fd2,"\nBad Password!\n",15);
                                    write(fd2,"\n**************************",27);
                                    write(fd2,"\nforbidden command!\n",20);
                                    write(fd2,"**************************\n",27);

                                    bzero(inputcommandline,string_length);
                                    bzero(commandline,string_length);
                                    return;
                                }
                            }
                        }
                        else
                        {
                            send_message_2_client(session_id, "\n\rinput password:");
                        //    write(fileno(stdout),"\n\rinput password:",17);
                            write(fd1,"\n\rinput password:\n",18);

                            echo_length=18;
                            gettimeofday (&tv , &tz);
                            write(fd2,&tv,sizeof(tv));
                            write(fd2,"1",1);
                            write(fd2,&echo_length,sizeof(echo_length));
                            write(fd2,"\n\rinput password:\n",18);

                            t = process_client_input_string(cfd,session_id,"",0);

                            if(strcmp(t,admin_password)==0)
                            {
                                send_message_2_client(session_id,"OK!\n");
                                bzero(inputcommandline,string_length);
                                bzero(commandline,string_length);
                                return;
                            }
                            else
                            {
                                send_message_2_client(session_id,"\n\rBad Password!\n\r");

                                block_command_flag = 1;
                                block_session_id = session_id;

                                write(fd1,"\nBad Password!\n",15);
                                write(fd1,"\n**************************",27);
                                write(fd1,"\nforbidden command!\n",20);
                                write(fd1,"**************************\n",27);

                                echo_length=89;
                                gettimeofday (&tv , &tz);
                                write(fd2,&tv,sizeof(tv));
                                write(fd2,"1",1);
                                write(fd2,&echo_length,sizeof(echo_length));

                                write(fd2,"\nBad Password!\n",15);
                                write(fd2,"\n**************************",27);
                                write(fd2,"\nforbidden command!\n",20);
                                write(fd2,"**************************\n",27);

                                printf("\r\n\n**************************");
                                printf("\r\n*** forbidden command! ***\n");
                                printf("\r**************************\n\n");

                                bzero(inputcommandline,string_length);
                                bzero(commandline,string_length);
                                return;
                            }
                        }
						}
					}
					else
					{
						if(strlen(linebuffer)>0 && strlen(linebuffer)<128)
						{
							to_get_a_prompt(prompts,linebuffer,strlen(linebuffer),my_connection,sql_query);
							if((*get_first_prompt)>0)
							{
								bzero(sql_query,string_length);
								sprintf(sql_query,"update devices set first_prompt='%s' where id=%d",prompts[0],did);
								printf("sql_query1=%s\n",sql_query);
								mysql_query(my_connection,sql_query);
								(*get_first_prompt)=0;
							}
						}
					}
                }
                bzero(inputcommandline,string_length);
                bzero(commandline,string_length);
                i++;
                continue;
            }
            else if((p[i]=='\n' || p[i]=='\r') && count==1)
            {
                if((* invim)==0)
                {
					if(strlen(inputcommandline))
					{
						sprintf(cmd,"%s",inputcommandline);
						check_invim(cmd,invim,prompts,my_connection,sql_query);

						int level=black_or_white;

						for(int j=0;j<black_cmd_num;j++)
						{
							if(black_or_white==0)
							{
								if(pcre_match(cmd,black_cmd_list[j].cmd)==0)
								{
									level = black_cmd_list[j].level + 1;
									break;
								}
							}
							else
							{
								if(pcre_match(cmd,black_cmd_list[j].cmd)==0)
								{
									level = 0;
									break;
								}
							}
						}

						for(int i=0;i<pass_prompt_count;i++)
						{
							if(pcre_match(commandline,pass_prompt[i])==0)
							{
								bzero(inputcommandline,string_length);
								bzero(commandline,string_length);
								return;
							}
						}

                        autosu_any(inputcommandline,radius_username,sstr,user,sql_query,sp,session_id,commandline,my_connection);

						bzero(sql_query,string_length);

						if((*get_first_prompt)>0)
						{
							(*get_first_prompt)--;
						}

                        line_number++;
                        printf("\n\rline_number = %d\n",line_number);

						if(line_number==1 && (* insz)==0)
						{
							/*
								for(int i=0;i<50;i++)
								{
										if(strlen(prompts[i])>0 && strstr(inputcommandline,prompts[i])!=0)
										{
												char cache_tmp[string_length];
												bzero(cache_tmp,string_length);
												memcpy(cache_tmp,inputcommandline+strlen(prompts[i]),strlen(inputcommandline+strlen(prompts[i])));
												bzero(inputcommandline,string_length);
												memcpy(inputcommandline,cache_tmp,strlen(cache_tmp));
												break;
										}
								}
							*/

                        if(encode==1)
                        {
                            bzero(cache1,string_length);
                            myg2u(inputcommandline,strlen(inputcommandline),cache1,string_length);
                            deal_special_char(cache1);
                            if(str_isprint(cache1)==0)
                            {
                                break;
                            }
                            sprintf(sql_query,"insert into commands (cid,sid,at,cmd,dangerlevel,jump_session) values  (NULL,%d,now(),'%s',%d,0)",sid,cache1,level);
                            gettimeofday (&tv , &tz);
                            write(fd2,&tv,sizeof(tv));
                            write(fd2,"2",1);   //1:content 2:command
                            int cmd_length=0;
                            cmd_length=strlen(cache1);
                            write(fd2,&cmd_length,sizeof(cmd_length));
                            write(fd2,cache1,cmd_length);
                        }
                        else
                        {
                            deal_special_char(inputcommandline);
                            if(str_isprint(inputcommandline)==0)
                            {
                                break;
                            }
                            sprintf(sql_query,"insert into commands (cid,sid,at,cmd,dangerlevel,jump_session) values  (NULL,%d,now(),'%s',%d,0)",sid,inputcommandline,level);
                            gettimeofday (&tv , &tz);
                            write(fd2,&tv,sizeof(tv));
                            write(fd2,"2",1);   //1:content 2:command
                            int cmd_length=0;
                            cmd_length=strlen(cache1);
                            write(fd2,&cmd_length,sizeof(cmd_length));
                            write(fd2,cache1,cmd_length);
                        }
						printf("\n\nsql8=%s\n\nencode=%d\n",sql_query,encode);

						mysql_query(my_connection,sql_query);

						bzero(sql_query,string_length);
						sprintf(sql_query,"update sessions set total_cmd=total_cmd+1,end=now(),s_bytes=%lf where sid=%d",(float)(* g_bytes)/1000,sid);
						mysql_query(my_connection,sql_query);

						bzero(sql_query,string_length);
						sprintf(sql_query,"update sessions set dangerous=%d where sid=%d and dangerous<%d",level,level);
						mysql_query(my_connection,sql_query);

						bzero(alarm_content,string_length);
						sprintf(alarm_content,"%s run command '%s' on device '%s' as the account '%s' in session %d",radius_username,inputcommandline,sstr,user,sid);
						freesvr_alarm(alarm_content,level,syslogserver,syslogfacility,mailserver,mailaccount,mailpassword,adminmailaccount,syslogalarm,mailalarm,adminmailaccount_num);
						}

						if(level==1)
						{   
							block_command_flag = 1;
							block_session_id = session_id;
						}
						else if(level==2)
						{   
							cleanup_exit( 255 );
						}
						else if(level==4)
						{
                        int count=0;
                        char tmp_buf[256]={0};
                        int echo_length=74;

                        send_message_2_client(session_id,"\n\r AUTH_TERM: this command needs authority from manager,are you sure?[Y/n]");
                        write(fd1,"\n\r AUTH_TERM: this command needs authority from manager,are you sure?[Y/n]",74);

                        gettimeofday (&tv , &tz);
                        write(fd2,&tv,sizeof(tv));
                        write(fd2,"1",1);
                        write(fd2,&echo_length,sizeof(echo_length));
                        write(fd2,"\n\r AUTH_TERM: this command needs authority from manager,are you sure?[Y/n]",74);

                        char * t = process_client_input_string(cfd,session_id,"",0);
                        if(t[0]!='Y' && t[0]!='y')
                        {
                            printf("here3\n");
                            printf("\n\rBad Password!\n\r");

                            block_command_flag = 1;
                            block_session_id = session_id;

                            echo_length=89;
                            write(fd1,"\nBad Password!\n",15);
                            write(fd1,"\n**************************",27);
                            write(fd1,"\nforbidden command!\n",20);
                            write(fd1,"**************************\n",27);


                            gettimeofday (&tv , &tz);
                            write(fd2,&tv,sizeof(tv));
                            write(fd2,"1",1);
                            write(fd2,&echo_length,sizeof(echo_length));


                            write(fd2,"\nBad Password!\n",15);
                            write(fd2,"\n**************************",27);
                            write(fd2,"\nforbidden command!\n",20);
                            write(fd2,"**************************\n",27);


                            printf("\r\n\n**************************");
                            printf("\r\n*** forbidden command! ***\n");
                            printf("\r**************************\n\n");

                            bzero(inputcommandline,string_length);
                            bzero(commandline,string_length);
                            return;
                        }
                        if(access(monitor_shell_pipe_name_tm,W_OK)==0)
                        {
                            twin_checked=0;
                            int monitor_fd=open(monitor_shell_pipe_name_tm,O_WRONLY);
                            if(monitor_fd<0)
                            {
                                perror("monitor fd open fail\n");
                            }   
                            else
                            {
                                char start_monitor_admin_pass_check_str[11]={1,3,3,7,0,1,8,8,5,2,9};
                                write(monitor_fd,start_monitor_admin_pass_check_str,11);
                                
                                echo_length=84;
                                send_message_2_client(session_id,"\n\rwaiting confirm until timeout...\n\r");
                                
                                write(fd1,"\n\rwaiting confirm until timeout...\n\r",36);
                                gettimeofday (&tv , &tz);
                                write(fd2,&tv,sizeof(tv));
                                write(fd2,"1",1);
                                write(fd2,&echo_length,sizeof(echo_length));
                                write(fd2,"\n\rwaiting confirm until timeout...\n\r",36);
                                
                                int wait_time=0;
                                while(1)
                                {
                                    if(wait_time>10)
                                    {
                                        write(monitor_fd,10,1);
                                        break;
                                    }
                                    if(twin_checked!=0)
                                    {
                                        break;
                                    }
                                    sleep(1);
                                    wait_time++;
                                }
                                if(twin_checked==2)
                                {
                                    send_message_2_client(session_id,"OK\n");
                                    write(fd1,"OK\n",3);

                                    echo_length=3;
                                    gettimeofday (&tv , &tz);
                                    write(fd2,&tv,sizeof(tv));
                                    write(fd2,"1",1);
                                    write(fd2,&echo_length,sizeof(echo_length));
                                    write(fd2,"OK\n",3);

                                    bzero(inputcommandline,string_length);
                                    bzero(commandline,string_length);
                                    return;
                                }
                                else
                                {
                                    send_message_2_client(session_id,"\n\rBad Password!\n\r");


                                    block_command_flag = 1;
                                    block_session_id = session_id;

                                    write(fd1,"\nBad Password!\n",15);
                                    write(fd1,"\n**************************",27);
                                    write(fd1,"\nforbidden command!\n",20);
                                    write(fd1,"**************************\n",27);

                                    echo_length=89;
                                    gettimeofday (&tv , &tz);
                                    write(fd2,&tv,sizeof(tv));
                                    write(fd2,"1",1);
                                    write(fd2,&echo_length,sizeof(echo_length));

                                    write(fd2,"\nBad Password!\n",15);
                                    write(fd2,"\n**************************",27);
                                    write(fd2,"\nforbidden command!\n",20);
                                    write(fd2,"**************************\n",27);

                                    bzero(inputcommandline,string_length);
                                    bzero(commandline,string_length);
                                    return;
                                }
                            }
                        }
                        else
                        {
                            send_message_2_client(session_id, "\n\rinput password:");
                        //    write(fileno(stdout),"\n\rinput password:",17);
                            write(fd1,"\n\rinput password:\n",18);

                            echo_length=18;
                            gettimeofday (&tv , &tz);
                            write(fd2,&tv,sizeof(tv));
                            write(fd2,"1",1);
                            write(fd2,&echo_length,sizeof(echo_length));
                            write(fd2,"\n\rinput password:\n",18);

                            t = process_client_input_string(cfd,session_id,"",0);

                            if(strcmp(t,admin_password)==0)
                            {
                                send_message_2_client(session_id,"OK!\n");
                                bzero(inputcommandline,string_length);
                                bzero(commandline,string_length);
                                return;
                            }
                            else
                            {
                                send_message_2_client(session_id,"\n\rBad Password!\n\r");

                                block_command_flag = 1;
                                block_session_id = session_id;

                                write(fd1,"\nBad Password!\n",15);
                                write(fd1,"\n**************************",27);
                                write(fd1,"\nforbidden command!\n",20);
                                write(fd1,"**************************\n",27);

                                echo_length=89;
                                gettimeofday (&tv , &tz);
                                write(fd2,&tv,sizeof(tv));
                                write(fd2,"1",1);
                                write(fd2,&echo_length,sizeof(echo_length));

                                write(fd2,"\nBad Password!\n",15);
                                write(fd2,"\n**************************",27);
                                write(fd2,"\nforbidden command!\n",20);
                                write(fd2,"**************************\n",27);

                                printf("\r\n\n**************************");
                                printf("\r\n*** forbidden command! ***\n");
                                printf("\r**************************\n\n");

                                bzero(inputcommandline,string_length);
                                bzero(commandline,string_length);
                                return;
                            }
                        }
						}
					}
                }
                bzero(inputcommandline,string_length);
                bzero(commandline,string_length);
                i++;
                continue;
            }
            memcpy(inputcommandline+strlen(inputcommandline),&p[i],1);

			if(strlen(inputcommandline)>(string_length-5000))
			{
				bzero(inputcommandline,string_length);
                bzero(commandline,string_length);
			}
            i++;
        }
        return;
    }
    memcpy(inputcommandline+strlen(inputcommandline),buff,n);
    if(strlen(inputcommandline)>(string_length-5000))
    {
        bzero(inputcommandline,string_length);
        bzero(commandline,string_length);
    }
}

int myu2g(char *inbuf,int inlen,char *outbuf,int outlen)
{
    return mycode_convert("utf-8","gb2312",inbuf,inlen,outbuf,outlen);
}

int myg2u(char *inbuf,size_t inlen,char *outbuf,size_t outlen)
{
    return mycode_convert("gb2312","utf-8",inbuf,inlen,outbuf,outlen);
}

int mycode_convert(char *from_charset,char *to_charset,char *inbuf,int inlen,char *outbuf,int outlen)
{
    iconv_t cd;
    int rc;
    char **pin = &inbuf;
    char **pout = &outbuf;

    cd = iconv_open(to_charset,from_charset);
    if (cd==0) return -1;
    memset(outbuf,0,outlen);
    if (iconv(cd,pin,&inlen,pout,&outlen)==-1) return -1;
    iconv_close(cd);
    return 0;
}

int str_isprint(char * s)
{
    int len= strlen(s);
    int i = 0;
    while(i<len)
    {
        if(!isprint(s[i]))
        {
            return 0;
        }
        i++;
    }
    return 1;
}
