#include	"network.h"

int	is_bad_interface_name(char *);
int get_first_interface(void);

int main(int argc, char argv[])
{
	int		sockfd;
	unsigned int	ifi;
	struct ipv6_mreq	mreq6;
	struct in6_addr	maddr6;
	char	*maddr;

	if (argc == 2)
		maddr = &argv[1];
	else
		maddr = MADDR6;

	if ( (ifi = get_first_interface()) == -1){
		perror("BROK : get_first_interface error ");
		exit(1);
	}

	if ( inet_pton(AF_INET6, maddr,  &maddr6) == -1) {
		perror("BROK : inet_pton error ");
		exit(1);
	}

/* Test IPV6_JOIN_GROUP */

	if ( (sockfd = socket(AF_INET6, SOCK_DGRAM, 0)) == -1 ){
		perror("BROK : socket error ");
		exit(1);
	}
	mreq6.ipv6mr_interface = ifi;
	mreq6.ipv6mr_multiaddr = maddr6;
	if(setsockopt(sockfd, IPPROTO_IPV6, IPV6_JOIN_GROUP, 
				&mreq6, sizeof(mreq6)) == -1) {
		perror("BROK : setsockopt IPV6_JOIN_GROUP fail ");
		exit(1);
	}
	
	const char	lo[] = "lo";
	int			loi;
	if ( (loi = if_nametoindex(lo)) == 0) {
		fprintf(stdout, "BROK: if_nametoindex error, no such device");
	}
	if (setsockopt(sockfd, IPPROTO_IPV6, IPV6_MULTICAST_IF,
				(char *) &loi , sizeof(loi)) == -1){
		perror("BROK : setsockopt IPV6_MULTICAST_IF fail ");
		exit(1);
	} else
		printf("PASS : setsockopt IPV6_MULTICAST_IF.\n");

	int		hoplimit = 2;
	int		hops;
	socklen_t	len = sizeof(hops);
	if (setsockopt(sockfd, IPPROTO_IPV6, IPV6_MULTICAST_HOPS, 
				(char *) &hoplimit, sizeof(hoplimit)) == -1)
		perror("BROK : setsockopt IPV6_UNICAST_HOPS error");
	else
		printf("PASS : setsockopt IPV6_UNICAST_HOPS.\n");


	int		enable_loop;
	socklen_t	llen = sizeof(enable_loop);
	if ( getsockopt(sockfd, IPPROTO_IPV6, IPV6_MULTICAST_LOOP,
				(char *) &enable_loop, &llen) == -1) {
		perror("BROK : getsockopt IPV6_MULTICAST_LOOP fail ");
		exit(1);
	}
	printf("PASS : getsockopt IPV6_MULTICAST_LOOP value %d\n", enable_loop);

	exit(0);
}

static char	*bad_interface_name[] = {
	"lo:",
	"lo",
	"stf",	/* pseudo-device 6to4 tunnel interface */
	"gif",	/* psuedo-device generic tunnel interface */
	"dummy",
	"vmnet",
	NULL	/* last entry must be NULL */
};

int	is_bad_interface_name(char *i)
{
	char	**p;
	for ( p = bad_interface_name; *p; ++p)
		if(strncmp(i, *p, strlen(*p)) == 0)
			return 1;
	return 0;
}

//static char	*get_first_interface(void)
int	get_first_interface(void)
{
	struct if_nameindex	*nameindex;
	char	*i = NULL;
	int		 j = 0;
	unsigned int	n;

	nameindex = if_nameindex();
	if(nameindex == NULL) {
		return -1;
	}

	while (nameindex[j].if_index != 0){
		if (strcmp(nameindex[j].if_name, "lo") != 0 && 
				!is_bad_interface_name(nameindex[j].if_name)){
//			i = xstrdup(nameindex[j].if_name);
			n = nameindex[j].if_index;
			break;
		}
		j++;
	}
	if_freenameindex(nameindex);
//	return i;
	return n;
}
