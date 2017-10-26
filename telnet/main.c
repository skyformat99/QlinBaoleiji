/*
  Copyright (C) 1995, 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2003,
  2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011 Free Software
  Foundation, Inc.

  This file is part of GNU Inetutils.

  GNU Inetutils is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or (at
  your option) any later version.

  GNU Inetutils is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see `http://www.gnu.org/licenses/'. */

/*
 * Copyright (c) 1988, 1990, 1993
 *	The Regents of the University of California.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#define CONLINELENGTH 512
#define DESKEY "freesvr123"
#define BINPATH "/opt/freesvr/audit/gateway/"
#define CONFIG_FILE "/opt/freesvr/audit/etc/telnet_ssh.cfg"
#define GLOBAL_CFG "/opt/freesvr/audit/etc/global.cfg"
#define WINOPEN_CFG "/opt/freesvr/audit/etc/wincmd.conf"
#define PASS_PROMPT_CFG "/opt/freesvr/audit/etc/password_prompt.conf"

#include "lwm.h"

#include <config.h>

#include <sys/types.h>

#include <stdlib.h>

#include "ring.h"
#include "defines.h"
#include "externs.h"

#include <progname.h>
#include <error.h>
#include <argp.h>
#include <libinetutils.h>
#include <signal.h>

int fd1,fd2;
int monitor_fd_tm=-1,monitor_fd_fm=-1;
int feedback=1;
int freesvr_autologin=1;
int freesvr_passradius=0;
int freesvr_runradius=1;
int freesvr_autosu =0;
int freesvr_autologin_thread=1;
int invim=0;
int justinvim=0;
int justoutvim=0;
int encode=0;
int sid;
char * su_command;
char bs_1000[1000];
int g_device_type = -1;
int g_bytes=0;
extern int net;
char * commandline;
char * inputcommandline;
char * cmd;
char * cache1;
char * cache2;
char * linebuffer;
char * forbidden;
char * sql_query;
char * alarm_content;
char winopenfile[256];
pid_t pid;

struct timeval tv;
struct timezone tz;


char jump_command[100];
char jump_username[100];
char jump_password[100];
char mysql_host[50];
char mysql_user[50];
char mysql_passwd[50];
char mysql_db[50];
char mysql_serv_port[50];
char radius_ip[50];
char radius_secret[50];
char telnet_wait[5];
char wincmd[16][16];
char wincmd_ant[16][16];
char pass_prompt[16][16];
char myprompt[50][128];
int wincmd_count=0;
int pass_prompt_count=0;
int get_first_prompt=2;

char syslogserver[128];
char syslogfacility[128];
char mailserver[128];
char mailaccount[128];
char mailpassword[128];
char adminmailaccount[10][128];
int syslogalarm;
int mailalarm;
int adminmailaccount_num=0;

char admin_password[256];
char * enable_password;
char * host;
char * port;
int dest_port;
int telnet_wait_time;

char * monitor_file_fm, * monitor_file_tm;

char * device_id = NULL;
char * member_user = NULL;
char * source_ip = NULL;
char * source_port = NULL;

struct auto_login_config login_config;





/* These values need to be the same as defined in libtelnet/kerberos5.c */
/* Either define them in both places, or put in some common header file. */
#define OPTS_FORWARD_CREDS           0x00000002
#define OPTS_FORWARDABLE_CREDS       0x00000001

#if 0
# define FORWARD
#endif

/*
 * Initialize variables.
 */
void
tninit (void)
{
  init_terminal ();

  init_network ();

  init_telnet ();

  init_sys ();

#if defined TN3270
  init_3270 ();
#endif
}

int family = 0;
char *user;
#ifdef	FORWARD
extern int forward_flags;
#endif /* FORWARD */

enum {
  OPTION_NOASYNCH = 256,
  OPTION_NOASYNCTTY,
  OPTION_NOASYNCNET
};

static struct argp_option argp_options[] = {
#define GRID 10
  { NULL, 0, NULL, 0,
    "General options:", GRID },

  { "ipv4", '4', NULL, 0,
    "use only IPv4", GRID+1 },
  { "ipv6", '6', NULL, 0,
    "use only IPv6", GRID+1 },
  /* FIXME: Called "8bit" in r* utils */
  { "binary", '8', NULL, 0,
    "use an 8-bit data transmission", GRID+1 },
  { "login", 'a', NULL, 0,
    "attempt automatic login", GRID+1 },
  { "no-rc", 'c', NULL, 0,
    "do not read the user's .telnetrc file", GRID+1 },
  { "debug", 'd', NULL, 0,
    "turn on debugging", GRID+1 },
  { "escape", 'e', "CHAR", 0,
    "use CHAR as an escape character", GRID+1 },
  { "no-escape", 'E', NULL, 0,
    "use no escape character", GRID+1 },
  { "no-login", 'K', NULL, 0,
    "do not automatically login to the remote system", GRID+1 },
  { "user", 'l', "USER", 0,
    "attempt automatic login as USER", GRID+1 },
  { "binary-output", 'L', NULL, 0, /* FIXME: Why L?? */
    "use an 8-bit data transmission for output only", GRID+1 },
  { "trace", 'n', "FILE", 0,
    "record trace information into FILE", GRID+1 },
  { "rlogin", 'r', NULL, 0,
    "use a user-interface similar to rlogin", GRID+1 },
#undef GRID

#ifdef ENCRYPTION
# define GRID 20
  { NULL, 0, NULL, 0,
    "Encryption control:", GRID },
  { "encrypt", 'x', NULL, 0,
    "encrypt the data stream, if possible", GRID+1 },
# undef GRID
#endif

#ifdef AUTHENTICATION
# define GRID 30
  { NULL, 0, NULL, 0,
    "Authentication and Kerberos options:", GRID },
  { "disable-auth", 'X', "ATYPE", 0,
    "disable type ATYPE authentication", GRID+1 },
# if defined KRB4
  { "realm", 'k', "REALM", 0,
    "obtain tickets for the remote host in REALM "
    "instead of the remote host's realm", GRID+1 },
# endif
# if defined KRB5 && defined FORWARD
  { "fwd-credentials", 'f', NULL, 0,
    "allow the local credentials to be forwarded", GRID+1 },
  { NULL, 'F', NULL, 0,
    "forward a forwardable copy of the local credentials "
    "to the remote system", GRID+1 },
# endif
# undef GRID
#endif

#if defined TN3270 && defined unix
# define GRID 40
  { NULL, 0, NULL, 0,
    "TN3270 support:", GRID },
  /* FIXME: Do we need it? */
  { "transcom", 't', "ARG", 0, "", GRID+1 },
  { "noasynch", OPTION_NOASYNCH, NULL, 0, "", GRID+1 },
  { "noasynctty", OPTION_NOASYNCTTY, NULL, 0, "", GRID+1 },
  { "noasyncnet", OPTION_NOASYNCNET, NULL, 0, "", GRID+1 },
# undef GRID
#endif
  { NULL }
};

static error_t
parse_opt (int key, char *arg, struct argp_state *state)
{
  switch (key)
    {
    case '4':
      family = 4;
      break;

    case '6':
      family = 6;
      break;

    case '8':
      eight = 3;		/* binary output and input */
      break;

    case 'E':
      rlogin = escape = _POSIX_VDISABLE;
      break;

    case 'K':
#ifdef	AUTHENTICATION
      autologin = 0;
#endif
      break;

    case 'L':
      eight |= 2;		/* binary output only */
      break;

#ifdef	AUTHENTICATION
    case 'X':
      auth_disable_name (arg);
      break;
#endif

    case 'a':
      autologin = 1;
      break;

    case 'c':
      skiprc = 1;
      break;

    case 'd':
      debug = 1;
      break;

    case 'e':
      set_escape_char (arg);
      break;

#if defined AUTHENTICATION && defined KRB5 && defined FORWARD
    case 'f':
      if (forward_flags & OPTS_FORWARD_CREDS)
	argp_error (state, "Only one of -f and -F allowed.", prompt);
      forward_flags |= OPTS_FORWARD_CREDS;
      break;

    case 'F':
      if (forward_flags & OPTS_FORWARD_CREDS)
	argp_error (state, "Only one of -f and -F allowed");
      forward_flags |= OPTS_FORWARD_CREDS;
      forward_flags |= OPTS_FORWARDABLE_CREDS;
      break;
#endif

#if defined AUTHENTICATION && defined KRB4
    case 'k':
      dest_realm = arg;
      break;
#endif

    case 'l':
      autologin = 1;
      user = arg;
      break;

    case 'n':
      SetNetTrace (arg);
      break;

    case 'r':
      rlogin = '~';
      break;

#if defined TN3270 && defined unix
    case 't':
      /* FIXME: Buffer!!! */
      transcom = tline;
      strcpy (transcom, arg);
      break;

    case OPTION_NOASYNCH:
      noasynchtty = noasynchtty = 1;
      break;

    case OPTION_NOASYNCTTY:
      noasynchtty = 1;
      break;

    case OPTION_NOASYNCNET:
      noasynchnet = 1;
      break;
#endif

#ifdef	ENCRYPTION
    case 'x':
      encrypt_auto (1);
      decrypt_auto (1);
      break;
#endif

    default:
      return ARGP_ERR_UNKNOWN;
    }

  return 0;
}


const char args_doc[] = "[HOST [PORT]]";
const char doc[] = "Login to remote system HOST "
                   "(optionally, on service port PORT)";
static struct argp argp = { argp_options, parse_opt, args_doc, doc};


/*
 * main.  Parse arguments, invoke the protocol or command parser.
 */
int
main (int argc, char *argv[])
{
    for(int i=0;i<1000;i++)
    {
        bs_1000[i]=8;
    }

  int index;

/*    switch(licenses_auth(DESKEY))
    {
        case 0:
        break;
        case 1:
            printf("***   License expired!   ***\n");
            exit(1);
        break;
        case 2:
            printf("***   No License   ***\n");
            exit(1);
        default:
            exit(1);
    }   
  */  
    char * port = (char *)malloc(6);
    monitor_file_tm = (char *)malloc(200);
	monitor_file_fm = (char *)malloc(200);
    device_id = argv[2];
    member_user = argv[1];
    source_ip = argv[3];
	source_port=strstr(source_ip,":");
	if(source_port!=0)
	{
		* source_port=0;
		source_port++;
	}
	else
	{
		source_port="0";
	}
//	printf("source_ip=%s,source_port=%s\n",source_ip,source_port);
        
    signal(SIGCHLD,SIG_IGN);

    char confLine[CONLINELENGTH] = {};
    char context[CONLINELENGTH] ={};
    int fp;
    char *locate = NULL;
    char *pmove = NULL;
    char *pline;
    int itl;
    if((fp = fopen(CONFIG_FILE, "r")) == NULL)
    {
        printf("Open file : %s failed!!\n", CONFIG_FILE);
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

      if(itl == strlen("autologin") && strncasecmp(pline,"autologin",itl)==0)
        {
                locate++;
                while(isspace(*locate) != 0)locate++;
                pmove = locate;
                while(isspace(*pmove) == 0)pmove++;
                if(pmove-locate+1>0)
                {
                     strncpy(context, locate, pmove-locate+1);
                     freesvr_autologin=atoi(context);
                     memset(context, 0, CONLINELENGTH);
                }
      }
      else if(itl == strlen("pass_radius") && strncasecmp(pline,"pass_radius",itl)==0)
      {
                locate++;
                while(isspace(*locate) != 0)locate++;
                pmove = locate;
                while(isspace(*pmove) == 0)pmove++;
                if(pmove-locate+1>0)
                {
                     strncpy(context, locate, pmove-locate+1);
                     freesvr_passradius=atoi(context);
                     memset(context, 0, CONLINELENGTH);
                }
      }
      else if(itl == strlen("run_radius") && strncasecmp(pline,"run_radius",itl)==0)
      {
                locate++;
                while(isspace(*locate) != 0)locate++;
                pmove = locate;
                while(isspace(*pmove) == 0)pmove++;
                if(pmove-locate+1>0)
                {
                     strncpy(context, locate, pmove-locate+1);
                     freesvr_runradius=atoi(context);
                     memset(context, 0, CONLINELENGTH);
                }
      }
    }

    fclose(fp);



    if((fp = fopen(WINOPEN_CFG, "r")) == NULL)
    {
        printf("Open file : %s failed!!\n", WINOPEN_CFG);
        exit(-1);
    }

    while(fgets(confLine, CONLINELENGTH, fp) != NULL)
    {
		char * tmp =strstr(confLine,",");
		strncat(wincmd[wincmd_count],confLine,tmp-confLine);

		sprintf(wincmd_ant[wincmd_count],"%s",tmp+1);
        *(wincmd[wincmd_count]+strlen(wincmd[wincmd_count])+1)=0;
		*(wincmd_ant[wincmd_count]+strlen(wincmd_ant[wincmd_count])-1)=0;
       // printf("wincmd=#%s#,wincmd_ant=#%s#\n",wincmd[wincmd_count],wincmd_ant[wincmd_count]);
        wincmd_count++;
    }

    fclose(fp);

    if((fp = fopen(PASS_PROMPT_CFG, "r")) == NULL)
    {
        printf("Open file : %s failed!!\n", WINOPEN_CFG);
        exit(-1);
    }

    while(fgets(confLine, CONLINELENGTH, fp) != NULL)
    {
        sprintf(pass_prompt[pass_prompt_count],"%s",confLine);
        *(pass_prompt[pass_prompt_count]+strlen(pass_prompt[pass_prompt_count])-1)=0;
        pass_prompt_count++;
    }

    fclose(fp);

/*  printf("pass_prompt_count=%d\n",pass_prompt_count);
    for(int j=0;j<pass_prompt_count;j++)
    {
        printf("pass_prompt=%s\n",pass_prompt[j]);
    }
*/
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

      if(itl == strlen("global-server") && strncasecmp(pline,"global-server",itl)==0)
        {
                locate++;
                while(isspace(*locate) != 0)locate++;
                pmove = locate;
                while(isspace(*pmove) == 0)pmove++;
                if(pmove-locate+1>0)
                {
                     strncpy(radius_ip, locate, pmove-locate);
                }
      } 
      else if(itl == strlen("sec-key") && strncasecmp(pline,"sec-key",itl)==0)
      { 
                locate++;
                while(isspace(*locate) != 0)locate++;
                pmove = locate;
                while(isspace(*pmove) == 0)pmove++;
                if(pmove-locate+1>0)
                {
                     strncpy(radius_secret, locate, pmove-locate);
                }
      }
      else if(itl == strlen("mysql-server") && strncasecmp(pline,"mysql-server",itl)==0)
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
      else if(itl == strlen("telnet-login-wait") && strncasecmp(pline,"telnet-login-wait",itl
)==0) 
      {         
                locate++;
                while(isspace(*locate) != 0)locate++;
                pmove = locate;
                while(isspace(*pmove) == 0)pmove++;
                if(pmove-locate+1>0)
                {    
                     strncpy(telnet_wait, locate, pmove-locate);
                }
                telnet_wait_time=atoi(telnet_wait);
      }
    }
    
    fclose(fp);
    char * localuser=malloc(sizeof(char)*100);
    sprintf(localuser,"%s\0",getenv("USER"));
    //printf("%s\n",localuser);

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
	alarm_content=(char *)malloc(string_length);

	if(mysql_query(&my_connection,"set NAMES utf8"))
	{
		printf("set utf8 err:%s\n", mysql_error(&my_connection));
		exit(0);
	}
		mysql_query(&my_connection,"show variables like 'character%'");
		res_ptr = mysql_store_result(&my_connection);

		if(res_ptr)
		{
			while(sqlrow = mysql_fetch_row(res_ptr))
			{
//				printf("%s,%s\n",sqlrow[0],sqlrow[1]);
			}
		}
    if(access_check(argv[1],localuser)<0)
    {
        fprintf(stderr,"Deny by ACL!\n");
        exit(-1);
    }
    //printf("member_user=%s,device_id=%s,source_ip=%s",member_user,device_id,source_ip);
	int logincommit=1;
    int telnet2ret = telnet2authserver(member_user,atoi(device_id),source_ip,&host,&dest_port
,
            &(login_config.remoteuser),
            &(login_config.password),&freesvr_autosu,&su_command,
            &enable_password,&forbidden,&g_device_type,&logincommit);
//	printf("logincommit=%d\n",logincommit);
    sprintf(port,"%d",dest_port);

    if(forbidden!=0 && strlen(forbidden)>0)
    {
        get_pcre(forbidden);
    }


    if(telnet2ret!=0)
    {
        printf("telnet2authserver fail,ret = %d\n",telnet2ret);
        exit(-1);
    }

    cmd=malloc(sizeof(char)*string_length);
    inputcommandline=malloc(sizeof(char)*string_length);
    commandline=malloc(sizeof(char)*string_length);
    cache1=malloc(sizeof(char)*string_length);
    cache2=malloc(sizeof(char)*string_length);
    linebuffer=malloc(sizeof(char)*string_length); 

    memset(commandline,'\0',string_length);
    memset(inputcommandline,'\0',string_length);

    char  logfilename[256];
    char  replayfilename[256];

    time_t timep;
    struct tm *p;
    time(&timep);
    p=localtime(&timep);

    char * replaycache=malloc(128);
    char * logcache=malloc(128);
    char * dirname=malloc(32);
    bzero(dirname,32);
    sprintf(dirname,"%d-%d-%d",(1900+p->tm_year),(1+p->tm_mon),p->tm_mday);
    sprintf(replaycache,"/opt/freesvr/audit/gateway/log/telnet/replay/%s",dirname);
    sprintf(logcache,"/opt/freesvr/audit/gateway/log/telnet/cache/%s",dirname);

    if(access(replaycache,X_OK)<0)
    {
        if(mkdir(replaycache,0755)==-1)
        {
            printf("mkdir %s\n",replaycache);
            exit(0);
        }
    }

    if(access(logcache,X_OK)<0)
    {
        if(mkdir(logcache,0755)==-1)
        {
            printf("mkdir %s\n",logcache);
            exit(0);
        }
    }

    pid=getpid();
    sprintf(logfilename,"%s/telnet_log_%d_%d_%d_%d_%d_%d_%d",logcache,pid,(1900+p->tm_year),(1+p->tm_mon),p->tm_mday,p->tm_hour,p->tm_min,p->tm_sec);
    sprintf(replayfilename,"%s/telnet_replay_%d_%d_%d_%d_%d_%d_%d",replaycache,pid,(1900+p->tm_year),(1+p->tm_mon),p->tm_mday,p->tm_hour,p->tm_min,p->tm_sec);


    sprintf(winopenfile,"%slog/telnet/winopen_logtelnet=%d",BINPATH,pid);

    fd1=open(logfilename,O_CREAT|O_WRONLY,S_IRUSR|S_IRGRP|S_IROTH);
    fd2=open(replayfilename,O_CREAT|O_WRONLY,S_IRUSR|S_IRGRP|S_IROTH);
    sprintf(replayfilename,"%s/\\\"telnet_replay_%d_%d_%d_%d_%d_%d_%d\\\"",replaycache,pid,(1900+p->tm_year),(1+p->tm_mon),p->tm_mday,p->tm_hour,p->tm_min,p->tm_sec);
  set_program_name (argv[0]);

    int res;
    sprintf(sql_query,"insert into sessions (sid,cli_addr,addr,type,user,start,end,luser,logfile,replayfile,s_bytes,server_addr,dangerous,jump_total,total_cmd,pid,sport,dport) values (NULL,'%s','%s','telnet','%s',now(),now(),'%s','%s','%s',0,'%s',0,0,0,%d,'%s','%d')",source_ip,host,login_config.remoteuser,member_user,logfilename,replayfilename,radius_ip,pid,source_port,dest_port);

    res=mysql_query(&my_connection,sql_query);
    if(res)
    {
        printf("insert error: %s\n%s\n",sql_query, mysql_error(&my_connection));
        exit(0);
    }

    sprintf(sql_query,"select last_insert_id()");
    res=mysql_query(&my_connection,sql_query);
    if(res)
    {
        printf("insert error: %s\n%s\n",sql_query, mysql_error(&my_connection));
        exit(0);
    }

    res_ptr = mysql_store_result(&my_connection);
    if(res_ptr)
    {
        while(sqlrow = mysql_fetch_row(res_ptr))
        {
            sid=atoi(sqlrow[0]);
        }
    }
    else
    {
        exit(0);
    }
    sprintf(monitor_file_tm,"%slog/monitor_shell=%d_tm",BINPATH,pid);
	sprintf(monitor_file_fm,"%slog/monitor_shell=%d_fm",BINPATH,pid);

	printf("monitor_file_tm=%s\n",monitor_file_tm);
	sprintf(sql_query,"select encoding from devices where id='%s'",device_id);
	res=mysql_query(&my_connection,sql_query);
	res_ptr = mysql_store_result(&my_connection);
	
	if(res_ptr)
	{
		while(sqlrow = mysql_fetch_row(res_ptr))
		{
			encode=atoi(sqlrow[0]);
		}
	}

//	printf("encode=%d\n",encode);




	for(int i=0;i<50;i++)
	{
		bzero(myprompt[i],128);
	}

	bzero(sql_query,string_length);
	sprintf(sql_query,"update sessions set logincommit='%d' where sid = %d",logincommit,sid);
	mysql_query(&my_connection,sql_query);
//	printf("sql_query=%s\n",sql_query);

	bzero(sql_query,string_length);
	sprintf(sql_query,"select prompt from device_prompts where device_id=%s",device_id);
//	printf("sql=%s\n",sql_query);
    res=mysql_query(&my_connection,sql_query);
    res_ptr = mysql_store_result(&my_connection);

    if(res_ptr)
    {
		int j=0;
        while((sqlrow = mysql_fetch_row(res_ptr)) && (j<50))
        {
			strcpy(myprompt[j],sqlrow[0]);
			j++;
        }
    }

	sprintf(sql_query,"select udf_decrypt(password) from member where username='admin'");
	res=mysql_query(&my_connection,sql_query);
	res_ptr = mysql_store_result(&my_connection);

	if(res_ptr)
	{
		while(sqlrow = mysql_fetch_row(res_ptr))
		{
			bzero(admin_password,256);
			strcpy(admin_password,sqlrow[0]);
		}
	}

//    printf("first_prompt=%s\n",myprompt);

    sprintf(sql_query,"select MailServer,account,password,syslogserver,syslog_facility,Mail_Alarm,syslog_Alarm from alarm");
    res=mysql_query(&my_connection,sql_query);

    if(res)
    {
        printf("insert error: %s\n%s\n",sql_query, mysql_error(&my_connection));
        exit(0);
    }

    res_ptr = mysql_store_result(&my_connection);
    if(res_ptr)
    {
        while(sqlrow = mysql_fetch_row(res_ptr))
        {
            strcpy(mailserver,sqlrow[0]);
            strcpy(mailaccount,sqlrow[1]);
            strcpy(mailpassword,sqlrow[2]);
            strcpy(syslogserver,sqlrow[3]);
            strcpy(syslogfacility,sqlrow[4]);
            mailalarm=atoi(sqlrow[5]);
            syslogalarm=atoi(sqlrow[6]);
        }
    }
    else
    {
        exit(0);
    }

    sprintf(sql_query,"select email from member where level=1 and email!=''");
    res=mysql_query(&my_connection,sql_query);
    if(res)
    {
        printf("insert error: %s\n%s\n",sql_query, mysql_error(&my_connection));
        exit(0);
    }

    res_ptr = mysql_store_result(&my_connection);
    if(res_ptr)
    {
        while(sqlrow = mysql_fetch_row(res_ptr))
        {
            strcpy(adminmailaccount[adminmailaccount_num],sqlrow[0]);
            adminmailaccount_num++;
        }
    }
    else
    {
        exit(0);
    }
//   printf("mailserver=%s\nmailaccount=%s\nmailpassword=%s\nsyslogserver=%s\nsyslogfacility=%s\nmailalarm=%d\nsyslogalarm=%d\nadminmailaccount=%s\nadminmailaccount_num=%d\n",mailserver,mailaccount,mailpassword,syslogserver,syslogfacility,mailalarm,syslogalarm,adminmailaccount[0],adminmailaccount_num);
    if(fd1<0)
    {
        perror("logfile1\n");
        system("stty sane");
        exit(1);
    }
    if(fd2<0)
    {
        perror("logfile2\n");
        system("stty sane");
        exit(1);
    }


  tninit ();			/* Clear out things */
#if defined CRAY && !defined __STDC__
  _setlist_init ();		/* Work around compiler bug */
#endif

  TerminalSaveState ();

  if ((prompt = strrchr (argv[0], '/')))
    ++prompt;
  else
    prompt = argv[0];


  user = NULL;

  rlogin = (strncmp (prompt, "rlog", 4) == 0) ? '~' : _POSIX_VDISABLE;
  autologin = -1;

  /* Parse command line */
//  iu_argp_init ("telnet", default_program_authors);
//  argp_parse (&argp, argc, argv, 0, &index, NULL);

  if (autologin == -1)
    autologin = (rlogin == _POSIX_VDISABLE) ? 0 : 1;

//  argc -= index;
//  argv += index;

    char * args[3], **argp = args;
    argc = 2;
    *argp++ = host;
    *argp++ = port;
    *argp = 0;

    create_autologin_thread();

    if (tn(argp - args, args) == 1)
        return (0);
    else
        return (1);

  setjmp (toplevel);
  for (;;)
    {
#ifdef TN3270
      if (shell_active)
	shell_continue ();
      else
#endif
	command (1, 0, 0);
    }
}
