#include	"network.h"

int main(int argc, char *argv[])
{

/* 
 * 3.1 IPv6 Address Family and Protocol Family
 * Defined family name AF_INET6 and PF_INET6 in <sys/socket.h>
 */

#ifndef AF_INET6
	fprintf(stdout, "BROK: We have not defined AF_INET6\n");
	exit(1);
#endif
	fprintf(stdout, "PASS: We have defined AF_INET6\n");

#ifndef PF_INET6
	fprintf(stdout, "BROK: We have not defined PF_INET6\n");
	exit(1);
#endif
	fprintf(stdout, "PASS: We have defined PF_INET6\n");
	
/*
 * 3.2 IPv6 Address Structure
 * Defined struct in6_addr
 * 
 * 3.8 IPv6 Wildcard Address
 * 3.9 IPv6 Loopback Address
 */
 
	char addr[MAXLINE + 1];

	struct in6_addr anyaddr = IN6ADDR_ANY_INIT;
	if (inet_ntop(AF_INET6, &anyaddr, addr, sizeof(addr)) != NULL) {
		fprintf(stdout, "PASS: Our IPv6 any addr is %s\n", addr);
	} else {
		perror("BROK: inet_ntop error: ");
		exit(1);
	}
	
	struct in6_addr loaddr = IN6ADDR_LOOPBACK_INIT;
	if (inet_ntop(AF_INET6, &loaddr, addr, sizeof(addr)) != NULL) {
		fprintf(stdout, "PASS: Our IPv6 loopback addr is %s\n", addr);
	} else {
		perror("BROK: inet_ntop error: ");
		exit(1);
	}
	
/* 3.3 Socket Address Structure
 * Defined struct sockaddr_in6
 * We don't have a sin6_len field in Linux
 * */

/*
	if ( (len = sizeof(servaddr.sin6_len)) != NULL ){
		fprintf(stdout, "size of sockaddr_in6.sin6_len is %d", len);
	} else {
		fprintf(stdout, "We don't have a sin6_len field");
	}
*/

	struct sockaddr_in6 loaddrinfo;	
	
	bzero(&loaddrinfo, sizeof(loaddrinfo));
	loaddrinfo.sin6_family = AF_INET6;
	loaddrinfo.sin6_port = htons(TCPPORT);
	loaddrinfo.sin6_addr = in6addr_loopback;
	
	/* Display the address information */
	fprintf(stdout, 
			"PASS: Address info:\n"
			"	sin6_family	= %d (AF_INET = %d, AF_INET6 = %d)\n"
			"	sin6_port	= %d\n"
			"	sin6_flowinfo	= %d\n"
			"	sin6_addr	= %d\n"
			"	sin6_scope_id	= %d\n",
			loaddrinfo.sin6_family, AF_INET, AF_INET6, loaddrinfo.sin6_port,
			loaddrinfo.sin6_flowinfo, loaddrinfo.sin6_addr, 
			loaddrinfo.sin6_scope_id);
			
	exit(0);
}
