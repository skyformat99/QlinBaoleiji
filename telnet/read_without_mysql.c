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
#define CONLINELENGTH 512

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


void * keyread_thread_callback(void * arg)
{
    tcgetattr(key_fd,&saveterm);
    nt=saveterm;
    
    nt.c_lflag &= ~ECHO;
    nt.c_lflag &= ~ISIG;
    nt.c_lflag &= ~ICANON;
    
    tcsetattr(key_fd,TCSANOW,&nt);
    
    FD_ZERO(&rs);
    FD_SET(key_fd,&rs);
    key_tv.tv_sec=0;
    key_tv.tv_usec=0;
    
    i=0; q=0;
    while(1)
    {
        read(key_fd,buf+i,1);
        i++;
        if(i>31)
        {
           write(1,"Too many data\n",14);
           break;
        }  
        r=select(key_fd+1,&rfds,NULL,NULL,&key_tv);
        if(r<0)
        {
           write(1,"select() error.\n",16);
           break;
        }  
        if(r==1)
            continue;
        rfds=rs;
        
        if(i==1)
        {
            if(buf[0]==32) //space
            {
        //      printf("space\n");
                if(g_stop==0)
                {
                    g_stop=1;
                }
                else
                {
                    g_stop=0;
                }
            }
        }
        i=0;
    }

    tcsetattr(key_fd,TCSANOW,&saveterm);
}

void my_exit(int i)
{
    printf("\n\r<<Replay End,code: %d>>\n\r",i);
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
		my_exit(2);
	}

	memcpy(&tvpre,&tv,sizeof(tv));
	memcpy(&tvstart,&tv,sizeof(tv));

    if(read(fd,&content_command,1)<1)
    {
        my_exit(3);
    }

	if(read(fd,&strlength,sizeof(strlength))<sizeof(strlength))
	{
		my_exit(4);
	}

	read(fd,string,strlength);
	if(tv.tv_sec>start_time && content_command=='1')
	{
		write(1,string,strlength);
	}


    pthread_t thread;
    int ret = pthread_create(&thread,NULL,keyread_thread_callback,NULL);
    if(ret<0)   
    {           
        printf("auto error,will my_exit...\n");
        my_exit(0);
    }  
    

	while(1)
	{
        while(g_stop==1)
        {
            sleep(1);
        }

		if(read(fd,&tv,sizeof(tv))<sizeof(tv))
		{
			my_exit(5);
		}

        if(read(fd,&content_command,1)<1)
        {
            my_exit(6);
        }

		if(read(fd,&strlength,sizeof(strlength))<sizeof(strlength))
		{
			my_exit(7);
		}
		
		if(read(fd,string,strlength)<strlength)
		{
//			printf("read3 err\n");
			my_exit(8);
		}

        if(tv.tv_sec<start_time)
        {
//          printf("continue2\n");
            memcpy(&tvpre,&tv,sizeof(tv));
            continue;
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
	my_exit(9);
}
