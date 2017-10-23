#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

static int string_length=100000;


void termfunc(char * string,char * ret1,char * ret2,int chomp)
{
    char *p=string;
	if(chomp==1 && (*(p+strlen(p)-1)=='\r' || *(p+strlen(p)-1)=='\n'))
	{
		*(p+strlen(p)-1)=0;
	}
    int i=0;


    while(i<strlen(p))
    {
		if(p[i]==0x0f)
		{
			i++;
			continue;
		}

		if((i+2)<strlen(p) && p[i+2]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]=='m')
		{
            i+=3;
            continue;
		}
		if((i+3)<strlen(p) && p[i+3]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]<('9'+1) && p[i+2]>('0'-1) && p[i+3]=='m')
		{
            i+=4;
            continue;
		}
		if((i+4)<strlen(p) && p[i+4]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]<('9'+1) && p[i+2]>('0'-1) && p[i+3]<('9'+1) && p[i+3]>('0'-1) && p[i+4]=='m')
		{
            i+=5;
            continue;
		}
		if((i+5)<strlen(p) && p[i+5]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]<('9'+1) && p[i+2]>('0'-1) && p[i+3]==';' && p[i+4]<('9'+1) && p[i+4]>('0'-1) && (p[i+5]=='H' || p[i+5]=='m'))
		{
            i+=6;
            continue;
		}
		if((i+6)<strlen(p) && p[i+6]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]<('9'+1) && p[i+2]>('0'-1) && p[i+3]==';' && p[i+4]<('9'+1) && p[i+4]>('0'-1) && p[i+5]<('9'+1) && p[i+5]>('0'-1) && (p[i+6]=='H' || p[i+6]=='m'))
		{
            i+=7;
            continue;
		}
		if((i+6)<strlen(p) && p[i+6]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]<('9'+1) && p[i+2]>('0'-1) && p[i+3]<('9'+1) && p[i+3]>('0'-1) && p[i+4]==';' && p[i+5]<('9'+1) && p[i+5]>('0'-1) && (p[i+6]=='H' || p[i+6]=='m'))
		{
            i+=7;
            continue;
		}
		if((i+7)<strlen(p) && p[i+7]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]<('9'+1) && p[i+2]>('0'-1) && p[i+3]<('9'+1) && p[i+3]>('0'-1) && p[i+4]==';' && p[i+5]<('9'+1) && p[i+5]>('0'-1) && p[i+6]<('9'+1) && p[i+6]>('0'-1) && (p[i+7]=='H' || p[i+7]=='m'))
		{
            i+=8;
            continue;
		}
		if((i+6)<strlen(p) && p[i+6]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]=='0' && p[i+3]=='0' && p[i+4]==0x1b && p[i+5]=='[' && p[i+6]=='m')
		{
            i+=7;
            continue;
		}
		if((i+4)<strlen(p) && p[i+4]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]=='4' && p[i+3]<('9'+1) && p[i+3]>('0'-1) && p[i+4]=='m')
		{
            i+=5;
            continue;
		}
		if((i+10)<strlen(p) && p[i+10]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]<('9'+1) && p[i+2]>('0'-1) && p[i+3]<('9'+1) && p[i+3]>('0'-1) && p[i+4]==';' && p[i+5]<('9'+1) && p[i+5]>('0'-1) && p[i+6]=='H' && p[i+7]==0x1b && p[i+8]=='[' && p[i+9]<('9'+1) && p[i+9]>('0'-1) && p[i+10]=='K')
		{
            i+=11;
            continue;
		}
		if((i+21)<strlen(p) && p[i+21]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]=='7' && p[i+3]=='m' && p[i+4]=='S' && p[i+5]=='t' 
				&& p[i+6]=='a' && p[i+7]=='n' && p[i+8]=='d' && p[i+9]=='a' && p[i+10]=='r' && p[i+11]=='d' 
				&& p[i+12]==' ' && p[i+13]=='i' && p[i+14]=='n' && p[i+15]=='p' && p[i+16]=='u' && p[i+17]=='t' 
				&& p[i+18]==0x1b && p[i+19]=='[' && p[i+20]=='0' && p[i+21]=='m')
		{
            i+=22;
            continue;
		}


		if((i+7)<strlen(p) && p[i+7]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]=='0' && p[i+3]=='1' && p[i+4]==';' && p[i+7]=='m')
		{
			i+=8;
			continue;
		}
		if((i+4)<strlen(p) && p[i+4]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]=='0' && p[i+3]=='0' && p[i+4]=='m')
		{
			i+=5;
			continue;
		}
		if((i+2)<strlen(p) && p[i+2]!=0 && p[i]==0x1b && p[i+1]=='[' && p[i+2]=='m')
		{
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

    /*
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
    */
    strcpy(ret2,ret1);
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

    while(i<strlen(ret2))
    {
        if(p[i]==8)
        {
            H_count++;
            if(H_count==0)
            {
                H_from=i;
            }
        }
        else
        {
            H_count=0;
            H_to=0;
            H_from=0;
        }
        if(H_count==67 && p[i+1]=='$')
        {
            H_to=i+2;
            break;
        }
        i++;
    }

	if(H_to!=0)
    {
        strncpy(ret1,ret2,H_from);
        char H_arr[37];
        for(int i=0;i<37;i++)
        {
            H_arr[i]=8;
        }
        strncpy(ret1+strlen(ret1),H_arr,37);
        strncpy(ret1+strlen(ret1),ret2+H_to,strlen(ret2)-H_to);
    }
    else
    {
        strcpy(ret1,ret2);
    }
	*/
	bzero(ret1,string_length);
	strcpy(ret1,ret2);
    p=ret1;
    i=0;
    bzero(ret2,string_length);
//	int column=132;
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
            if(ret1[i+1]=='[' && ret1[i+2]>('0'-1) && ret1[i+2]<('9'+1) && ret1[i+3]=='D')
            {
				int times = ret1[i+2]-'0';
//              printf("times=%d\n\r",times);
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
            else if(ret1[i+1]=='[' && ret1[i+2]=='C')
            {
                ant++;
                i+=2;
                continue;
            }
            else if(ret1[i+1]=='[' &&  ret1[i+2]>('0'-1) && ret1[i+2]<('9'+1) && ret1[i+3]>('0'-1) && ret1[i+3]<('9'+1) && ret1[i+4]=='C')
            {
                int times=(ret1[i+2]-'0') * 10 + (ret1[i+3]-'0');
                ant = ant+times;
                i+=4;
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
                memmove(ret2+ant,ret2+ant+times,len-ant-times);
                bzero(tmp_p,times);
                i+=4;
                continue;
            }
            else if(ret1[i+1]=='[' &&  ret1[i+2]>('0'-1) && ret1[i+2]<('9'+1) && ret1[i+3]=='P')
            {
                int times=ret1[i+2]-'0';
                char * tmp_p = ret2+strlen(ret2)-times;
                int len=strlen(ret2);
                memmove(ret2+ant,ret2+ant+times,len-ant-times);
                bzero(tmp_p,times);
                i+=3;
                continue;
            }
            else if(ret1[i+1]=='[' &&  ret1[i+2]>('0'-1) && ret1[i+2]<('9'+1) && ret1[i+3]=='@')
            {
                int len=strlen(ret2);
                memmove(ret2+ant,ret2+ant-1,len-ant+1);
                ret2[ant]=ret1[i+4];
                i+=4;
                ant++;
                //printf("ret2=%s\n",ret2);
                continue;
            }
            else if(ret1[i+1]=='[')
            {
//                ant++;
                i+=2;
                continue;
            }
        }
		
        ret2[ant]=ret1[i];
        ant++;
    }
}

int main(int argc,char **argv)
{
	int fd = open(argv[1],O_RDONLY);
	if(fd<0)
	{
		perror("open err:");
	}

	char * str = malloc(sizeof(char)*string_length);
	char * cache1 = malloc(sizeof(char)*string_length);
	char * cache2 = malloc(sizeof(char)*string_length);
	char * linebuffer = malloc(sizeof(char)*string_length);

	bzero(str,string_length);
	bzero(cache1,string_length);
	bzero(cache2,string_length);
	bzero(linebuffer,string_length);
	
	int ret = 0;
	int i = 0;
	while((ret = read(fd,str,1000)) && ret > 0)
	{
		i=0;
		while(i<ret)
		{
			if(str[i]==0x0a)
			{
				bzero(cache1,string_length);
				bzero(cache2,string_length);
				termfunc(linebuffer,cache1,cache2,1);

				printf("str:\n%s\ni:\n%d\nlinebuffer:\n%s\ncache2:\n%s\n",str,i,linebuffer,cache2);
				bzero(linebuffer,string_length);
			}
			else
			{
				strncpy(linebuffer+strlen(linebuffer),str+i,1);
			}
			i++;
		}
	}
}
