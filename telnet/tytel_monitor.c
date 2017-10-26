#include <unistd.h>
#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <pthread.h>
#include<termios.h>
#include<fcntl.h>
#include <strings.h>
#include<signal.h>

int in_fd=0;
struct termios saveterm,nt;
fd_set rs;
struct timeval in_tv;
char buf[1024];

int monitor_fd_tm=-1,monitor_fd_fm=-1;
char tm_pipename[256],fm_pipename[256];

void clear_pipe()
{
	close(monitor_fd_tm);
	close(monitor_fd_fm);
	unlink(tm_pipename);
	unlink(fm_pipename);
	exit(1);
}

int main(int argc, char ** argv)
{
	signal(SIGHUP,clear_pipe);
	signal(SIGINT,clear_pipe);
	signal(SIGKILL,clear_pipe);
	signal(SIGTERM,clear_pipe);
	signal(SIGPIPE,clear_pipe);

	sprintf(tm_pipename,"%s_tm",argv[1]);
	sprintf(fm_pipename,"%s_fm",argv[1]);


	mkfifo(tm_pipename,0777);
	

    mkfifo(fm_pipename,0777);


	monitor_fd_tm = open(tm_pipename,O_RDONLY);
	monitor_fd_fm = open(fm_pipename,O_WRONLY);

	if(monitor_fd_tm<0)
	{
		perror("open monitor fd r:");
	}

    tcgetattr(in_fd,&saveterm);
    nt=saveterm;

    nt.c_lflag &= ~ECHO;
    nt.c_lflag &= ~ISIG;
    nt.c_lflag &= ~ICANON;

    tcsetattr(in_fd,TCSANOW,&nt);

	int r=0;

	while(1)
	{
		FD_ZERO(&rs);
		FD_SET(monitor_fd_tm,&rs);
		FD_SET(in_fd,&rs);

		in_tv.tv_sec=0;
		in_tv.tv_usec=500;
		if(access(fm_pipename,O_RDWR)==0)
		{
			if(monitor_fd_fm<0)
			{
				monitor_fd_fm = open(fm_pipename,O_WRONLY);
				if(monitor_fd_fm<0)
				{
					perror("monitor_fd open error:");
				}
			}
		}

		r=select(monitor_fd_tm+1,&rs,NULL,NULL,&in_tv);

		if(r<0)
		{
			perror("select()");
		}
		else if(r)
		{
			if(FD_ISSET(monitor_fd_tm,&rs))
			{
				int len=read(monitor_fd_tm,buf,1024);
				if(len>0)
				{
					write(1,buf,len);
					bzero(buf,1024);
				}
				else if(len==0)
				{
					printf("disconnect\n");
					clear_pipe();
					exit(1);
				}
			}
			else if(FD_ISSET(in_fd,&rs))
			{
				int len=read(in_fd,buf,1024);
				if(len>0 && monitor_fd_fm>0)
				{
					write(monitor_fd_fm,buf,len);
					bzero(buf,1024);
				}
			}
		}
	}
}
