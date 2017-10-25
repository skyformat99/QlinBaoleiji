#include "ci.h"
#include "command.h"

extern char audit_address[64];
extern int ssh_ver;
int fd1, fd2, waitforline,black_or_white,sid,g_bytes,invim,insz,justoutvim,
encode,get_first_prompt;
	char * inputcommandline,* commandline,
	* cache1,* cache2,* linebuffer,* sql_query,	
	* cmd,* replaycache,* logcache,* dirname,
	* alarm_content,
	myprompt[50][128];
	
	char syslogserver[128];
	char syslogfacility[128];
	char mailserver[128];
	char mailaccount[128];
	char mailpassword[128];
	char adminmailaccount[10][128];
	int syslogalarm;
	int mailalarm;
	int adminmailaccount_num=0;
	struct tm *p;
	struct black_cmd black_cmd_list[50];
	int black_cmd_num;
	
/* Local functions */
static void distory_ci(CI_INFO *ci);
static int 
recv_struct(int fd, unsigned int seqno, CI_RET *cr);
static int 
send_struct(int fd, CI_RET *cr);
static int
recv_spkt(int fd, unsigned int *seqno, unsigned char *c2s, struct simple_packet *spkt);
static int 
send_spkt(int fd, unsigned int seqno, unsigned char c2s, struct simple_packet *spkt);
static void
do_command_inspection_c2s(CI_INFO *ci, struct simple_packet *spkt);
static void
do_command_inspection_s2c(CI_INFO *ci, struct simple_packet *spkt);

/*
 * Write N bytes to a file descriptor
 */
static ssize_t
writen( int fd, void *buf, size_t n )
{
    size_t tot = 0;
    ssize_t w;

    do
    {
        if(( w = write( fd, ( void * )(( u_char * )buf + tot ), n - tot ) ) <= 0 )
            return( w );

        tot += w;
    }
    while( tot < n );

    return( tot );
}

/*
 * Read N bytes from a file descriptor
 */
static ssize_t
readn( int fd, void *buf, size_t n )
{
    size_t tot = 0;
    ssize_t r;

    do
    {
        if(( r = read( fd, ( void * )(( u_char * )buf + tot ), n - tot ) ) <= 0 )
            return( r );

        tot += r;
    }
    while( tot < n );

    return( tot );
}

int command_inspection_fork(CI_INFO *ci)
{
	int sp[2];
	int ret, pid;

	/* Set up the unencrypted data channel to the client */
	if (socketpair(AF_LOCAL, SOCK_STREAM, 0, sp) < 0) {
		return (-1);
	}

	/* Fork off the child that connects to the real target */
	if ((pid = fork()) < 0) {
		return (-1);
	}
	/* Child process, Command Inspection */
	else if (pid == 0) {
		/* Child use sp[1] */
		close(sp[0]);
		command_inspection_child_loop(sp[1], ci);

		/* Nerver got here */
		exit(0);
	}
	/* Parent process, SSH sessions */
	else {
		/* Parent use sp[0] */
		signal(SIGPIPE, SIG_IGN);
		//signal(SIGCHLD, SIG_IGN);
		close(sp[1]);
		command_inspection_parent_wait_fork(sp[0], ci);
	}

	fprintf(stderr, "[%s] fd=%d\n", __func__, sp[0]);
	ci->sp = sp[0];
	return sp[0];
}

/* Command Inspection */
int
command_inspection_child_loop(int fd, CI_INFO *ci)
{
	int nfd, ret, pid;
	int pktlen, nread, nwritten;
	unsigned char pktbuf[BUFSIZE];
	fd_set readfds, tmpfds;
	CI_RET cr;
	struct simple_packet spkt;
	unsigned int seqno;
	unsigned char c2s;

	/* Initialize local variables */
	//todo
#if 1	
	get_first_prompt=2;
	cmd=malloc(sizeof(char)*string_length);
	inputcommandline=malloc(sizeof(char)*string_length);
	commandline=malloc(sizeof(char)*string_length);
	cache1=malloc(sizeof(char)*string_length);
	cache2=malloc(sizeof(char)*string_length);
	linebuffer=malloc(sizeof(char)*string_length);
	sql_query=malloc(sizeof(char)*string_length);
	alarm_content=malloc(sizeof(char)*string_length);

	bzero(cmd,string_length);
	bzero(inputcommandline,string_length);
	bzero(commandline,string_length);
	bzero(cache1,string_length);
	bzero(cache2,string_length);
	bzero(linebuffer,string_length);
	bzero(sql_query,string_length);
	
	MYSQL * my_connection = ci->sql;

	printf("here1\n");
	if(strlen(ci->forbidden)>0)
	{
	sprintf(sql_query,"select cmd,level from forbidden_commands_groups where gid = '%s'",ci->forbidden);
	printf("\n\n\n\n\nsql_query=%s\n\n\n\n\n\n\n",sql_query);
  
    
    int res = mysql_query(my_connection,sql_query);
    if (res)
    {
        printf("SELECT error: %s\n", mysql_error(my_connection));
    }
    else
    {
		printf("here1\n");
        res_ptr = mysql_store_result(my_connection);
        if (res_ptr)
        {
            if((unsigned long)mysql_num_rows(res_ptr)==0)
            {
                printf("USER not in config error\n");
                mysql_free_result(res_ptr);
                return 1;
            }
            while ((sqlrow = mysql_fetch_row(res_ptr)))
            {
				printf("black_cmd=%s,level=%s\n",sqlrow[0],sqlrow[1]);
				printf("\n1\n");
                strcpy(black_cmd_list[black_cmd_num].cmd,sqlrow[0]);
				printf("\n2\n");
                black_cmd_list[black_cmd_num].level=atoi(sqlrow[1]);
				printf("\n3\n");
                (black_cmd_num)++;
				printf("\n4\n");
            }
            if (mysql_errno(my_connection))
            {
                fprintf(stderr, "Retrive error: s%\n",mysql_error(my_connection));
            }
        }
        mysql_free_result(res_ptr);
    }

	bzero(sql_query,string_length);
	sprintf(sql_query,"select black_or_white from forbidden_groups where gname='%s'",ci->forbidden);
	printf("\n\n\n\nsql_query = %s\n\n\n",sql_query);
    res = mysql_query(my_connection,sql_query);
    if(res)
    {
    }
    else
    {   
        res_ptr = mysql_store_result(my_connection);
        if (res_ptr)
        {   
            if((unsigned long)mysql_num_rows(res_ptr)==0)
            {   
                //printf("USER not in config error\n");
                mysql_free_result(res_ptr);
                return 1;
            }   
            while ((sqlrow = mysql_fetch_row(res_ptr)))
            {   
                black_or_white=atoi(sqlrow[0]);
								printf("\n\n\n\nblack_or_white=%d\n\n\n\n",black_or_white);
            }   
            if (mysql_errno(my_connection))
            {   
                fprintf(stderr, "Retrive error: s%\n",mysql_error(my_connection));
            }
        }   
        mysql_free_result(res_ptr);
    }
	}
	printf("here2\n");

	waitforline = 0;
	sid = ci->sid;
	g_bytes = ci->g_bytes;
	invim = ci->invim;
	insz = ci->insz;
	justoutvim = 0;
	
	fd1 = open( ci->logfilename, O_CREAT|O_WRONLY ,S_IRUSR|S_IRGRP|S_IROTH);
	fd2 = open( ci->replayfilename, O_CREAT|O_WRONLY ,S_IRUSR|S_IRGRP|S_IROTH);
	
	if( fd1 < 0 )
	{
		//  printerror(0,"-ERR","logfile open error:%s\n",logfilename1);
		perror( ci->logfilename );
		exit( -1 );
	}

	if( fd2 < 0 )
	{
		//  printerror(0,"-ERR","logfile open error:%s\n",logfilename2);
		perror( ci->replayfilename );
		exit( -1 );
	}
	
	
  bzero(sql_query,string_length);
  sprintf(sql_query,"select udf_decrypt(password) from member where username='admin'");
  printf("here3\n");
  mysql_query(my_connection,sql_query);
  printf("here4\n");
  res_ptr = mysql_store_result(my_connection);
  if(res_ptr)
  {
      while(sqlrow = mysql_fetch_row(res_ptr))
      {
          bzero(admin_password,256);																				        
          strcpy(admin_password,sqlrow[0]);
      }
  }

  printf("here5\n");
	bzero(sql_query,string_length);
	sprintf(sql_query,"select encoding from devices where id=%d",did);    
	mysql_query(my_connection,sql_query);
	res_ptr = mysql_store_result(my_connection);

	encode=1;

	if(res_ptr)
	{
		while(sqlrow = mysql_fetch_row(res_ptr))
		{
			encode=atoi(sqlrow[0]);
		}
	}

	printf("sql4=%s\n",sql_query);
	printf("encode=%d\n",encode);

	for(int i=0;i<50;i++)
	{
		bzero(myprompt[i],128);
	}

	bzero(sql_query,string_length);
	sprintf(sql_query,"select prompt from device_prompts where device_id=%d",did);     
	mysql_query(my_connection,sql_query);
	res_ptr = mysql_store_result(my_connection);

	if(res_ptr)
	{
		int j=0;
		while((sqlrow = mysql_fetch_row(res_ptr)) && j<50)
		{
			strcpy(myprompt[j],sqlrow[0]);
			j++;
		}
	}
#endif				
							
	
	/* Send successed to parent */
	memset(&cr, 0x00, sizeof(cr));
	pid = getpid();
	cr.pid = pid;
	cr.seqno = ci->seqno;
	send_struct(fd, &cr);
	
	/* main loop... */
	FD_ZERO(&readfds);
	FD_SET(fd, &readfds);
	nfd = fd + 1;
	
	while (1) {
		/* reset readfds */
		memcpy(&tmpfds, &readfds, sizeof(fd_set));

		ret = select(nfd, &tmpfds, (fd_set *) NULL, (fd_set *) NULL, NULL);
		if (ret == -1)
		{
			if (errno == EINTR)
				continue;
			else {
				perror("select");
				continue;
			}
		}
		else if (ret == 0) {
			/* Never got here! */
		}
		else if (FD_ISSET(fd, &tmpfds)) {
			memset(&spkt, 0x00, sizeof(spkt));
			
			if (recv_spkt(fd, &seqno, &c2s, &spkt) == -1) {
				return -1;
			}
			else {
				cr.block = 0;

				if (c2s == 0x01) {
					do_command_inspection_c2s(ci, &spkt);
				}
				else {
					do_command_inspection_s2c(ci, &spkt);
				}

				cr.seqno = seqno;
				cr.g_bytes = g_bytes;
				cr.invim = invim;
				cr.insz = insz;
				cr.block = block_command_flag;
                if(cr.block==1)
                {
                    printf("\nclient cr.block=%d\n",cr.block);
                }
				block_command_flag = 0;
				send_struct(fd, &cr);
			}
		}
	}

	/* Never got here! */
	return 0;
}

int
command_inspection_parent_wait_fork(int fd, CI_INFO *ci)
{
	int nfd, ret;
	int pktlen, nread, nwritten;
	fd_set readfds, tmpfds;
	CI_RET cr;

	ret = recv_struct(fd, ci->seqno, &cr);
	if (ret == -1) {
		close(fd);
		command_inspection_fork(ci);
	}
	else {
		fprintf(stderr, "Fork successed, pid=%d\n", cr.pid);
	}
	/* Never got here! */
	return 0;
}

int 
command_inspection_parent_wait_ci_c2s(CI_INFO *ci, struct simple_packet *spkt)
{
	int ret, fd;
	CI_RET cr;
	unsigned char c2s = 0x01;

	memset(&cr, 0x00, sizeof(cr));
	fd = ci->sp;
	ci->seqno++;
	ret = send_spkt(fd, ci->seqno, c2s, spkt);
	if (ret == -1) {
		close(fd);
		command_inspection_fork(ci);
	}

	ret = recv_struct(fd, ci->seqno, &cr);
	if (ret == -1) {
		close(fd);
		command_inspection_fork(ci);
	}

	ci->g_bytes = cr.g_bytes;
	ci->invim = cr.invim;
	ci->insz = cr.insz;

	return cr.block;
}

int 
command_inspection_parent_wait_ci_s2c(CI_INFO *ci, struct simple_packet *spkt)
{
	int ret, fd;
	CI_RET cr;
	unsigned char c2s = 0x00;
	
	memset(&cr, 0x00, sizeof(cr));
	fd = ci->sp;
	ci->seqno++;
	ret = send_spkt(fd, ci->seqno, c2s, spkt);
	if (ret == -1) {
		close(fd);
		command_inspection_fork(ci);
	}

	ret = recv_struct(fd, ci->seqno, &cr);
	if (ret == -1) {
		close(fd);
		command_inspection_fork(ci);
	}

	ci->g_bytes = cr.g_bytes;
	ci->invim = cr.invim;
	ci->insz = cr.insz; 

	return cr.block;
}

CI_INFO *
initialize_ci_at_first(int session_id, int devices_id, const char *radius_username, const char *dest_ip, int dest_port, const char *dest_username, 
					   const char *client_ip, int client_port, MYSQL *sql, const char *forbidden, int login_commit)
{
	CI_INFO *ci = NULL;
	struct tm *p;
	struct timeval tv;
	char tstamp[128];
	char replaycache[256], logcache[256];
	int pid, last_insert_id, ret;
	struct stat filestat;
	char query[4096];
	MYSQL_ROW row;
	MYSQL_RES *res;

    pid = getpid();
	gettimeofday(&tv, NULL);
	p = localtime(&(tv.tv_sec));
	strftime(tstamp, sizeof(tstamp), "%Y_%m_%d", p);
	snprintf(logcache, sizeof(logcache), "/opt/freesvr/audit/gateway/log/ssh/replay/%s", tstamp);
	snprintf(replaycache, sizeof(replaycache), "/opt/freesvr/audit/gateway/log/ssh/replay/%s", tstamp);

    //from
    char dirname[32];
    bzero(dirname,32);
    bzero(replaycache,256);
    bzero(logcache,256);
    time_t timep;
    time(&timep);
    p=localtime(&timep);
    sprintf(dirname,"%d-%d-%d",(1900+p->tm_year),(1+p->tm_mon),p->tm_mday);
    sprintf(replaycache,"/opt/freesvr/audit/gateway/log/ssh/replay/%s",dirname);
    sprintf(logcache,"/opt/freesvr/audit/gateway/log/ssh/cache/%s",dirname);


    //to

	if (stat(logcache, &filestat) != 0) {
		mkdir(logcache, S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
	}

	if (stat(replaycache, &filestat) != 0) {
		mkdir(replaycache, S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
	}

	if ((ci = malloc(sizeof(CI_INFO))) == NULL) {
		perror("malloc");
		distory_ci(ci);
		return NULL;
	}
	else {
		memset(ci, 0x00, sizeof(CI_INFO));
	}

	if ((ci->monitor_shell_pipe_name_tm = malloc(512)) == NULL) {
		perror("malloc");
		distory_ci(ci);
		return NULL;
	}

	if ((ci->monitor_shell_pipe_name_fm = malloc(512)) == NULL) {
		perror("malloc");
		distory_ci(ci);
		return NULL;
	}

	if ((ci->logfilename = malloc(512)) == NULL) {
		perror("malloc");
		distory_ci(ci);
		return NULL;
	}

	if ((ci->replayfilename = malloc(512)) == NULL) {
		perror("malloc");
		distory_ci(ci);
		return NULL;
	}

	if ((ci->radius_username = malloc(strlen(radius_username) + 1)) == NULL) {
		perror("malloc");
		distory_ci(ci);
		return NULL;
	}

	if ((ci->dest_ip = malloc(strlen(dest_ip) + 1)) == NULL) {
		perror("malloc");
		distory_ci(ci);
		return NULL;
	}

	if ((ci->dest_username = malloc(strlen(dest_username) + 1)) == NULL) {
		perror("malloc");
		distory_ci(ci);
		return NULL;
	}

	sprintf(ci->monitor_shell_pipe_name_tm, "%s/monitor_shell=%d.0_tm", BINPATH, getpid());
	sprintf(ci->monitor_shell_pipe_name_fm, "%s/monitor_shell=%d.0_fm", BINPATH, getpid());

	bzero(tstamp, sizeof(tstamp));
	strftime(tstamp, sizeof(tstamp), "%Y_%m_%d_%I:%M:%S", p);
	snprintf(&tstamp[strlen(tstamp)], sizeof(tstamp) - strlen(tstamp), "_%06lu", tv.tv_usec);

	snprintf(ci->logfilename, 512, "%s/ssh_log_%d_%s", logcache, pid, tstamp);
	snprintf(ci->replayfilename, 512, "%s/ssh_replay_%d_%s", replaycache, pid, tstamp); 
	
	snprintf(ci->radius_username, strlen(radius_username) + 1, "%s", radius_username);
	snprintf(ci->dest_ip, strlen(dest_ip) + 1, "%s", dest_ip);
	snprintf(ci->dest_username, strlen(dest_username) + 1, "%s", dest_username);

	/*if ((ci->fd1 = open(ci->logfilename, O_CREAT|O_WRONLY, S_IRUSR|S_IRGRP|S_IROTH)) < 0 ||
		(ci->fd2 = open(ci->replayfilename, O_CREAT|O_WRONLY, S_IRUSR|S_IRGRP|S_IROTH)) < 0) {
		perror("open");
		distory_ci(ci);
		return NULL;
	}*/
#if 1	
	snprintf(query, sizeof(query), 
			"INSERT INTO sessions (sid,cli_addr,addr,type,user,start,end,luser,logfile,replayfile,s_bytes,server_addr,dangerous,jump_total,total_cmd,pid,sport,dport,logincommit) values (NULL,'%s','%s','ssh','%s',now(),now(),'%s','%s','%s',0,'%s',0,0,0,%d,%d,%d,%d)", 
			client_ip, dest_ip, dest_username, radius_username, ci->logfilename, ci->replayfilename, audit_address/*audit_address*/, getpid(), client_port, dest_port, login_commit);
	#endif
	//snprintf(query, sizeof(query), "INSERT INTO sessions (addr) VALUES('%s')", dest_ip);
	ret = mysql_query(sql, query);
	fprintf(stderr, "mysql ret=%d\n", ret);
	snprintf(query, sizeof(query), "select last_insert_id()");
	mysql_query(sql, query);
	res = mysql_store_result(sql);
	row = mysql_fetch_row(res);
	last_insert_id = atoi(row[0]);
	
	ci->session_id = session_id;
	ci->devices_id = devices_id;
	ci->sql = sql;
	ci->sid = last_insert_id;
	strcpy(ci->forbidden, forbidden);	
	return ci;
}

static void
distory_ci(CI_INFO *ci)
{
	if (ci != NULL) {
		if (ci->monitor_shell_pipe_name_fm != NULL) {
			free(ci->monitor_shell_pipe_name_fm);
			ci->monitor_shell_pipe_name_fm = NULL;
		}
		if (ci->monitor_shell_pipe_name_tm != NULL) {
			free(ci->monitor_shell_pipe_name_tm);
			ci->monitor_shell_pipe_name_tm = NULL;
		}
		if (ci->logfilename != NULL) {
			free(ci->logfilename);
			ci->logfilename = NULL;
		}
		if (ci->replayfilename != NULL) {
			free(ci->replayfilename);
			ci->replayfilename = NULL;
		}
		if (ci->radius_username != NULL) {
			free(ci->radius_username);
			ci->radius_username = NULL;
		}
		if (ci->dest_ip != NULL) {
			free(ci->dest_ip);
			ci->dest_ip = NULL;
		}
		if (ci->dest_username != NULL) {
			free(ci->dest_username);
			ci->dest_username = NULL;
		}

		free(ci);
	}
}

static int 
recv_struct(int fd, unsigned int seqno, CI_RET *cr)
{
	int nfd, ret, failure;
	int pktlen, nread;
	fd_set readfds, tmpfds;
	unsigned char pktbuf[BUFSIZE];
	struct timeval timeout;
	
	FD_ZERO(&readfds);
	FD_SET(fd, &readfds);
	nfd = fd + 1;

//	timeout.tv_sec = 0;
//	timeout.tv_usec = 50 * 1000;
    timeout.tv_sec = 1;
    timeout.tv_usec = 0;
	failure = 0;
	
	while (1) {
		/* reset readfds */
		memcpy(&tmpfds, &readfds, sizeof(fd_set));

		ret = select(nfd, &tmpfds, (fd_set *) NULL, (fd_set *) NULL, &timeout);
		if (ret == -1)
		{
			if (errno == EINTR)
				continue;
			else {
				perror("select");
				continue;
			}
		}
		else if (ret == 0) {
			//fprintf(stderr, "[%s] timeout.\n", __func__);
			break;
		}
		else if (FD_ISSET(fd, &tmpfds)) {
			if ((nread = read(fd, &pktlen, sizeof(pktlen))) < sizeof(pktlen)) {
				failure = -1;
				perror("read");
				break;
			}
			pktlen = ntohl(pktlen);
			if ((nread = read(fd, cr, pktlen)) < pktlen) {
				failure = -1;
				perror("read");
				break;
			}

            printf("\nserver cr.block=%d\n",cr->block);
			
			if (cr->seqno == seqno) {
			//	fprintf(stderr, "seqno=%d\n", seqno);
				break;
			}
			else {
				fprintf(stderr, "%06lu cr->seqno=%u, seqno=%u\n", timeout.tv_usec, cr->seqno, seqno);
			}	
		}
	}
	
	return failure;
}

static int
send_struct(int fd, CI_RET *cr)
{
	int len, pktlen, nwritten;
	unsigned char pktbuf[BUFSIZE];
	
	len = sizeof(CI_RET);
	pktlen = htonl(len);
	if ((nwritten = write(fd, &pktlen, sizeof(pktlen))) < sizeof(pktlen)) {
		perror("write");
		return (-1);
	}
	if ((nwritten = write(fd, cr, len)) < len) {
		perror("write");
		return (-1);
	}

    fsync(fd);
	
	return 0;
}

static int
recv_spkt(int fd, unsigned int *seqno, unsigned char *c2s, struct simple_packet *spkt)
{
	int nread;
	unsigned int seq;
	unsigned char c2s_flags;

	/* recv seqno */
	if ((nread = readn(fd, &seq, sizeof(seq))) <= 0) {
		return -1;
	}

	if (seqno != NULL) {
		*seqno = ntohl(seq);
	}
	
	/* recv stream direct */
	if ((nread = readn(fd, &c2s_flags, sizeof(c2s_flags))) <= 0) {
		return -1;
	}

	if (c2s != NULL) {
		*c2s = c2s_flags;
	}

	/* recv spkt */
	if ((nread = readn(fd, spkt, 8)) <= 0) {
		return -1;
	}

	fprintf(stderr, "recv len=%d\n", spkt->len);
	if (spkt->len > sizeof(spkt->data)) {
        fprintf(stderr, "** Darn, buffer to small (%u) for received packet (%u)\n", spkt->len, sizeof(spkt->data));
    }
	
    if (spkt->len && (nread = readn(fd, spkt->data, spkt->len)) <= 0) {
		return -1;
	}
	
	return 0;
}

static int 
send_spkt(int fd, unsigned int seqno, unsigned char c2s, struct simple_packet *spkt)
{
	int len, nwritten;
	unsigned int seq;
	unsigned char c2s_flags = c2s;

	/* Send seqno */
	len = sizeof(unsigned int);
	seq = htonl(seqno);
	if ((nwritten = write(fd, &seq, len)) < len) {
		fprintf(stderr, "nwritten = %u\n", nwritten);
		perror("write");
		return (-1);
	}

	/* Send stream direct */
	fprintf(stderr, "send len=%d\n", spkt->len);
	if ((nwritten = write(fd, &c2s_flags, sizeof(c2s_flags))) < sizeof(c2s_flags)) {
		fprintf(stderr, "nwritten = %u\n", nwritten);
		perror("write");
		return (-1);
	}

	/* Send spkt */
	if (write(fd, spkt, spkt->len + 8) != spkt->len + 8) {
		fprintf(stderr, "nwritten = %u\n", nwritten);
	    perror("write");
		return (-1);	
	}
	
    return 0;
}

void
do_command_inspection_c2s(CI_INFO *ci, struct simple_packet *spkt)
{
	    /* telnet_write2log2 */
    int offset=(ssh_ver==1)?4:8;
telnet_writelogfile2( &spkt->data[offset], spkt->len - offset, ci->monitor_shell_pipe_name_fm, ci->monitor_shell_pipe_name_tm,
                        fd1, fd2, inputcommandline, commandline,
						cache1, cache2, linebuffer, cmd, sql_query, myprompt,
                        black_cmd_list, black_cmd_num, sid,
						&waitforline , &g_bytes , &invim, &insz, ci->sid, black_or_white, ci->sql,
						syslogserver,syslogfacility,mailserver,mailaccount,mailpassword,adminmailaccount,alarm_content,syslogalarm,mailalarm,adminmailaccount_num,ci->radius_username,
						ci->dest_ip,ci->dest_username,encode,&get_first_prompt,0,0);
}

void
do_command_inspection_s2c(CI_INFO *ci, struct simple_packet *spkt)
{
	    /* telnet_write2log */
    int offset=(ssh_ver==1)?4:8;
telnet_writelogfile( &spkt->data[offset], spkt->len - offset, ci->monitor_shell_pipe_name_fm, ci->monitor_shell_pipe_name_tm,
                        fd1, fd2, inputcommandline, commandline,
						cache1, cache2, linebuffer, cmd, sql_query, myprompt,
                        black_cmd_list, black_cmd_num, sid,
						&waitforline , &g_bytes , &invim, &insz, &justoutvim, ci->sid, black_or_white, ci->sql,
						syslogserver,syslogfacility,mailserver,mailaccount,mailpassword,adminmailaccount,alarm_content,syslogalarm,mailalarm,adminmailaccount_num,ci->radius_username,
						ci->dest_ip,ci->dest_username,encode,&get_first_prompt,0,0);
}


#if 0
int main()
{
	/* Initialize ci for each ssh session */
	CI_INFO *g_ci;
	int fd;
	g_ci = initialize_ci_at_first(0, 515, "admin", "172.16.210.99", "root");

	puts(g_ci->monitor_shell_pipe_name_fm);
	puts(g_ci->monitor_shell_pipe_name_tm);
	puts(g_ci->logfilename);
	puts(g_ci->replayfilename);
	puts(g_ci->radius_username);
	puts(g_ci->dest_ip);
	puts(g_ci->dest_username);
	
	fd = command_inspection_fork(g_ci);

	while (1) {
		struct simple_packet spkt;
		CI_RET cr;
		spkt.type = 94;
		spkt.len = 1;
		spkt.data[0] = 'a';
		command_inspection_parent_wait_ci_c2s(g_ci, &spkt);
		usleep(100 * 1000);
	}

	return 0;
}
#endif
