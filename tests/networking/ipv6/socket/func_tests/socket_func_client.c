#include	"network.h"

/*
 * 3.5 The Socket Functions
 * Usage: a.out [ IPv6 address ]
 * */

 
int main(int argc, char *argv[])
{
	
	int		tcpsockfd, udpsockfd;
	struct	sockaddr_in6	tcpservaddr, udpservaddr;
	char	line[] = "Hello World!" ;
	struct in6_addr servaddr = in6addr_any;
	
	if (argc == 2) {
		if( inet_pton(AF_INET6, argv[1], &servaddr) < 0) {
			perror("BORK: inet_pton ");
			exit(1);
		}
	}

	bzero(&tcpservaddr, sizeof(tcpservaddr));
	bzero(&udpservaddr, sizeof(udpservaddr));

	tcpservaddr.sin6_family = AF_INET6;
	tcpservaddr.sin6_addr = servaddr;
	tcpservaddr.sin6_port = htons(TCPPORT);

	udpservaddr.sin6_family = AF_INET6;
	udpservaddr.sin6_addr = servaddr;
	udpservaddr.sin6_port = htons(UDPPORT);
	
	if ( (tcpsockfd = socket(AF_INET6, SOCK_STREAM, 0)) < 0 ) {
		perror("socket error: ");
		exit(1);
	}
	if ( (udpsockfd = socket(AF_INET6, SOCK_DGRAM, 0)) < 0 ) {
		perror("socket error: ");
		exit(1);
	}
	
	if ( connect(tcpsockfd, (struct sockaddr *) &tcpservaddr, sizeof(tcpservaddr)) < 0){
		perror("connect error:");
		exit(1);
	}
	if ( write(tcpsockfd, line, strlen(line)) < 0) {
		perror("wirte error: ");
		exit(1);
	}
	
	if ( sendto(udpsockfd, line, strlen(line), 0, (struct sockaddr *) &udpservaddr, sizeof(udpservaddr)) < 0){
		perror("BROK: sendto ");
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
