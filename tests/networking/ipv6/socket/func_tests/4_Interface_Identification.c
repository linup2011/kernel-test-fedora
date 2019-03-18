#include	"network.h"

int main(int argc, char *argv[])
{
	int		loi, ifi;
	const char	lo[] = "lo";
	char	iface[MAXLINE];
	int		n = 0;
	char	*ifname = NULL;
	struct if_nameindex	*allif;

/*
 * 4.1 Name-to-Index
 * */

	if ( (loi = if_nametoindex(lo)) == 0) {
		fprintf(stdout, "BROK: if_nametoindex error, no such device");
	}
	printf("PASS : lo index is %d\n", loi);

/*
 * 4.2 Index-to-Name
 * */

	if ( if_indextoname(loi, iface) == NULL) {
		perror("BROK: if_indextoname error, ");
		exit(1);
	}
	printf("PASS : interface name is %s\n", iface);

/*
 * 4.3 Return All Interface Names and Indexes
 * */

	if ( (allif = if_nameindex()) ==NULL){
		perror("BROK : if_nameindex error, ");
		exit(1);
	}
	printf("PASS : get all interface names.\n");
	while ( allif[n].if_index != 0) {
		printf("\tinterface index is %d, name is %s\n", 
				allif[n].if_index, allif[n].if_name);
		n++;
	}

/*
 * 4.4 Free Memory
 * */

	if_freenameindex(allif);
	printf("PASS : free nameindex memory.\n");

	exit(0);
}
