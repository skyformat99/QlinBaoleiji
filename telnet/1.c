#include<stdio.h>
#include<stdlib.h>
#include <sys/time.h>


struct a
{
    long a;
    long b;
};

int main()
{
    printf("%d\n%d\n",sizeof(struct a),sizeof(struct timeval));
}
