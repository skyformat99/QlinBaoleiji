#ifndef __CI_H__
#define __CI_H__

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <netdb.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <errno.h>
#include <sys/stat.h>
#include <sys/un.h>
#include <unistd.h>
#include <signal.h>
#include <fcntl.h>
#include <time.h>
#include <sys/time.h>
#include "mysql.h"

#define BUFSIZE		80960

struct black_cmds
{
	int level;
	char *cmd;
};

#define BINPATH "/opt/freesvr/audit/gateway/log"
#define SUPER_MAX_PACKET_SIZE   (1024*1024)
/* Transfers packet data between processes */
struct simple_packet
{
	unsigned int type;
	unsigned int len;
	char data[SUPER_MAX_PACKET_SIZE+12];
};

typedef struct _ci_info {
	int sp;
	unsigned int seqno;
	int devices_id;
	int session_id;
	char *monitor_shell_pipe_name_fm;
	char *monitor_shell_pipe_name_tm;
	char *logfilename;
	char *replayfilename;
	char forbidden[256];
	int fd1, fd2;
	//struct black_cmds *black_cmds_list;
	//int black_cmds_nums;
	int sid;
	int black_or_white;
	int g_bytes;
	int invim;
	int insz;
	char *radius_username;
	char *dest_ip;
	char *dest_username;
	MYSQL *sql;
	int encode;
	int get_first_prompt;
	int state;
	int pid;
} CI_INFO;	

typedef struct _ci_ret {
	int pid;
	unsigned int seqno;
	int g_bytes;
	int invim;
	int insz;
	int state;
	int block;
	char echo[2048];
} CI_RET;

/* Extern functions */
int command_inspection_fork(CI_INFO *ci);
int command_inspection_child_loop(int fd, CI_INFO *ci);
int command_inspection_parent_wait_fork(int fd, CI_INFO *ci);
int command_inspection_parent_wait_ci_c2s(CI_INFO *ci, struct simple_packet *spkt);
int command_inspection_parent_wait_ci_s2c(CI_INFO *ci, struct simple_packet *spkt);
CI_INFO *initialize_ci_at_first(int session_id, int devices_id, const char *radius_username, const char *dest_ip, int dest_port, const char *dest_username,
                       const char *client_ip, int client_port, MYSQL *sql, const char *forbidden, int login_commit);
#endif


