#include	"network.h"

int main(int argc, char *argv[])
{
	int		err;
	char	*node = "localhost6";
	char	*service = "ssh";
	struct addrinfo	hints, *res;

	bzero(&hints, sizeof(hints));
	hints.ai_flags = AI_CANONNAME;
	hints.ai_family = AF_INET6;

/*
 * 6.1 Protocol-Independent Nodename and Service Name Translation
 * */

	err = getaddrinfo(node, service, &hints, &res);
	if ( err != 0) {
		printf("BROK : getaddrinfo fail, %s\n", gai_strerror(err));
		exit(1);
	} else 
		printf("PASS : getaddrinfo \n");

//	while(res->ai_next != NULL)
	while(1)
	{
		printf("ai_family is %d\n", res->ai_family);
		if (res->ai_next != NULL)
			res = res->ai_next;
		else
			break;
	}

	freeaddrinfo(res);
	printf("PASS : freeaddrinfo");

/*
 * 6.2 Socket Address Structure to Node Name and Service Name
 * */

/* Test getnameinfo */
	struct sockaddr_in6 sa;
	char	host[MAXLINE], serv[MAXLINE];

	bzero(&sa, sizeof(sa));
	sa.sin6_family = AF_INET6;
	sa.sin6_addr = in6addr_loopback;
	sa.sin6_port = htons(443);
	
	err = getnameinfo((struct sockaddr *) &sa, sizeof(sa), host,
			sizeof(host), serv, sizeof(serv), 0);
	if ( err != 0) {
		printf("BROK : getnameinfo fail, %s\n", gai_strerror(err));
		exit(1);
	} else 
		printf("PASS : getnameinfo \n");

	printf("hostname is %s, service is %s\n", host, serv);

	exit(0);
}
