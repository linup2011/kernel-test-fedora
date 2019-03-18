#include	"network.h"

int main(int argc, char *argv[])
{
	int	sockfd, hops;
	int	hoplimit = 10;
	socklen_t	len = sizeof(hops);

	if ( (sockfd = socket(AF_INET6, SOCK_STREAM, 0)) == -1) {
		perror("BROK : socket error, ");
		exit(1);
	}

	if (setsockopt(sockfd, IPPROTO_IPV6, IPV6_UNICAST_HOPS,
				(char *) &hoplimit, sizeof(hoplimit)) == -1)
		perror("BROK : setsockopt IPV6_UNICAST_HOPS error");
	else
		printf("PASS : setsockopt IPV6_UNICAST_HOPS.\n");
	
	if (getsockopt(sockfd, IPPROTO_IPV6, IPV6_UNICAST_HOPS,
				(char *) &hops, &len) == -1)
		perror("BROK : getsockopt IPV6_UNICAST_HOPS");
	else
		printf("PASS : Using %d for hop limit.\n", hops);

	exit(0);
}
