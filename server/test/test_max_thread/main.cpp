#include <stdio.h>  
#include <string.h>  
#include <stdlib.h>  
#include <unistd.h>  
#include <pthread.h>  
#include <string>
using namespace std;

struct guozhi
{
    int a = 10;
    string b= "liliwang";
};

void * thread_null(void*);  

int main(int argc, char *argv[])  
{  
    unsigned int    i;  
    int             rc;  
    pthread_t       pool_id[65536];
    sleep(1);  
    for(i = 0; i < 65536; i++) {  
        rc = pthread_create(pool_id + i, 0, thread_null, NULL);  
        if (0 != rc) {  
            fprintf(stderr, "pthread_create() failure\r\nMax pthread num is %d\r\n", i);  
            exit(-1);  
        }  
    }  
    fprintf(stdout, "Max pthread num is 65536\r\nYour system is power_full\r\n");  
    exit(0);  
}  
void * thread_null(void*)  
{  
    pthread_detach(pthread_self());  
    sleep(60);  
    pthread_exit(NULL);  
}
