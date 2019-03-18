/* This is a include file for C networking programs */

/* include functions */
/* printf fprintf */
#include	<stdio.h>

/* perror() also need stdio.h */
#include	<errno.h>

/* exit() */
#include	<stdlib.h>

/* bzero() strcmp() */
#include	<string.h>

/* write() read() */
#include	<unistd.h>

/* getaddrinfo() freeaddrinfo() */
#include	<netdb.h>

/* write() read() */
#include	<unistd.h>

/* socket() connect() */
#include	<sys/types.h>
#include	<sys/socket.h>

/* inet_pton() */
#include	<arpa/inet.h>

/* if_nametoindex() if_indextoname() */
#include	<net/if.h>

/* all IPPROTO_IPV6 Options */
#include	<netinet/in.h>

#define	MAXLINE	1024
#define	TCPPORT	9998
#define	UDPPORT	9999
#define	LISTENQ	10
#define	MADDR6	"ff01::123"
