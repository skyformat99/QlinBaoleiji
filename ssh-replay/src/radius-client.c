/*
 * radclient.c	General radius packet debug tool.
 *
 * Version:	$Id$
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; either version 2 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program; if not, write to the Free Software
 *   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * Copyright 2000  The FreeRADIUS server project
 * Copyright 2000  Miquel van Smoorenburg <miquels@cistron.nl>
 * Copyright 2000  Alan DeKok <aland@ox.org>
 */
static const char rcsid[] = "$Id$";
//#define SERVER_PORT 1812
//#define SERVER_IPADDR "124.160.111.60"
//#define SECRET "freesvr"

#include "autoconf.h"

#include <stdio.h>
#include <stdlib.h>
#include <termios.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif

#include <string.h>
#include <ctype.h>
#include <netdb.h>
#include <sys/socket.h>

#ifdef HAVE_NETINET_IN_H
#include <netinet/in.h>
#endif

#ifdef HAVE_SYS_SELECT_H
#include <sys/select.h>
#endif

#ifdef HAVE_GETOPT_H
#include <getopt.h>
#endif

#include <assert.h>
#include <arpa/telnet.h>
#include "conf.h"
#include "radpaths.h"
#include "missing.h"
#include "libradius.h"

static int retries = 10;
static float timeout = 3;
static const char *secret = NULL;
static int do_output = 1;
static int totalapp = 0;
static int totaldeny = 0;
static int totallost = 0;

static int server_port = 0;
static int packet_code = 0;
static uint32_t server_ipaddr = 0;
static int resend_count = 1;
static int done = 1;

static int sockfd;
static int radius_id[256];
static int last_used_id = -1;

static rbtree_t *filename_tree = NULL;
static rbtree_t *request_tree = NULL;

static int sleep_time = -1;

char radius_server_ip_address[32];
char radius_server_secret[64];
unsigned short int radius_server_port;

