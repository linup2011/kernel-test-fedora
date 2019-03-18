#include	"network.h"

/*
 * 3.5 The Socket Functions
 * */

int main(int argc, char *argv[])
{
	int		tcplen, udplen, n;
	int		tcpsockfd, udpsockfd, tcpclifd;
	struct	sockaddr_in6	tcpservaddr, udpservaddr;
	struct	sockaddr_in6	tcpcliaddr, udpcliaddr;
	char	buff[MAXLINE + 1];
	char	addr[MAXLINE + 1];

	bzero(&tcpservaddr, sizeof(tcpservaddr));
	bzero(&udpservaddr, sizeof(udpservaddr));

	tcpservaddr.sin6_family = AF_INET6;
	tcpservaddr.sin6_addr = in6addr_any;
	tcpservaddr.sin6_port = htons(TCPPORT);

	udpservaddr.sin6_family = AF_INET6;
	udpservaddr.sin6_addr = in6addr_any;
	udpservaddr.sin6_port = htons(UDPPORT);

	if ( (tcpsockfd = socket(AF_INET6, SOCK_STREAM, 0)) < 0 ) {
		perror("socket error: ");
		exit(1);
	}
	if ( (udpsockfd = socket(AF_INET6, SOCK_DGRAM, 0)) < 0 ) {
		perror("socket error: ");
		exit(1);
	}
	
	if( bind(tcpsockfd, (struct sockaddr *) &tcpservaddr, sizeof(tcpservaddr)) < 0) {
		perror("bind error: ");
		exit(1);
	}
	if ( listen(tcpsockfd, LISTENQ) < 0) {
		perror("listen error: ");
		exit(1);
	}
	if( bind(udpsockfd, (struct sockaddr *) &udpservaddr, sizeof(udpservaddr)) < 0) {
		perror("bind error: ");
		exit(1);
	}
	
	/* Test getsockname(), not understand why use this function */
	udplen = sizeof(udpservaddr);
	if ( getsockname(udpsockfd, (struct sockaddr *) &udpservaddr, &udplen) < 0) {
		perror("BROK: getpeername error: ");
		exit(1);
	}
	if ( inet_ntop(AF_INET6, &udpservaddr.sin6_addr, addr, sizeof(addr)) != NULL) {
		printf("PASS : Connection from %s, port %d\n", addr, ntohs(udpservaddr.sin6_port));
	} else 
	{
		perror("inet_ntop error: ");
		exit(1);
	}


	tcplen = sizeof(tcpcliaddr);
//	if ( (tcpclifd = accept(tcplistenfd, (struct sockaddr *) &tcpcliaddr, &tcplen)) < 0) {
	if ( (tcpclifd = accept(tcpsockfd, NULL , NULL)) < 0) {
		perror("accept error: ");
		exit(1);
	}
	
		/* Test getpeername() */
	if ( getpeername(tcpclifd, (struct sockaddr *) &tcpcliaddr, &tcplen) < 0) {
		perror("BROK: getpeername error: ");
		exit(1);
	}
	if ( inet_ntop(AF_INET6, &tcpcliaddr.sin6_addr, addr, sizeof(addr)) != NULL) {
		printf("PASS : Connection from %s, port %d\n", addr, ntohs(tcpcliaddr.sin6_port));
	} else 
	{
		perror("inet_ntop error: ");
		exit(1);
	}

	/* Receive TCP message */
	while( (n = recvfrom(tcpclifd, buff, MAXLINE, 0, NULL , NULL)) > 0){
		buff[n] = 0;
		printf("PASS : Got a message '%s' from tcpclient\n", buff);
		break;
	}
	if ( n < 0 ){
		perror("recvfrom error: ");
		exit(1);
	}
	
	/* Receive UDP message */
	while( (n = recvfrom(udpsockfd, buff, MAXLINE, 0, NULL , NULL)) > 0){
		buff[n] = 0;
		printf("PASS : Got a message '%s' from udpclient\n", buff);
		break;
	}
	if ( n < 0 ){
		perror("recvfrom error: ");
		exit(1);
	}
	
	if ( close(tcpsockfd) < 0) {
		perror("close error: ");
		exit(1);
	}	
	if ( close(udpsockfd) < 0) {
		perror("close error: ");
		exit(1);
	}

}
