#include<stdio.h>
#include<stdlib.h>
#include <ctype.h>



int main()
{
    char *a = "Š";
    unsigned char b = 0x8a;
    
    if(str_isprint(a))
    {
        printf("OK\n");
    }
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
