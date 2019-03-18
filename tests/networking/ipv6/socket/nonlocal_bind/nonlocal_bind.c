#include <errno.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>
#include <netdb.h>

int main(int argc, char **argv)
{
	struct addrinfo *spoof_info;
	char family_vec[16] = "AF_INET6";
	char type_vec[16] = "SOCK_STREAM";
	char proto_vec[16] = "0";
	int fd, ret = 0, i = 0;
	int type = SOCK_STREAM;
	int protocol = 0;

	if (argc < 4 ) {
		printf("Usage: %s spoof_ip6_addr spoof_port type [protocol]\n", argv[0]);
		printf("\t type - stream, dgram, seqpacket, raw\n");
		printf("\t protocol - default 0, tcp, udp, sctp, icmp\n");
		return -1;
	}

	if (getaddrinfo(argv[1], argv[2], NULL, &spoof_info) != 0) {
		perror("getaddrinfo");
		return -1;
	}

	if (spoof_info->ai_family == AF_INET) {
		strcpy(family_vec, "AF_INET");
	}

	if (!strcasecmp(argv[3], "stream")) {
		type = SOCK_STREAM;
		strcpy(type_vec, "SOCK_STREAM");
	} else if (!strcasecmp(argv[3], "dgram")) {
		type = SOCK_DGRAM;
		strcpy(type_vec, "SOCK_DGRAM");
	} else if (!strcasecmp(argv[3], "seqpacket")) {
		type = SOCK_SEQPACKET;
		strcpy(type_vec, "SOCK_SEQPACKET");
	} else if (!strcasecmp(argv[3], "raw")) {
		type = SOCK_RAW;
		strcpy(type_vec, "SOCK_RAW");
	} else {
		printf("%s, not support yet!\n", type);
		return -1;
	}

	if (argc == 5) {
		if (!strcasecmp(argv[4], "tcp")) {
			protocol = IPPROTO_TCP;
			strcpy(proto_vec, "IPPROTO_TCP");
		} else if (!strcasecmp(argv[4], "udp")) {
			protocol = IPPROTO_UDP;
			strcpy(proto_vec, "IPPROTO_UDP");
		} else if (!strcasecmp(argv[4], "sctp")) {
			protocol = IPPROTO_SCTP;
			strcpy(proto_vec, "IPPROTO_SCTP");
		} else if (!strcasecmp(argv[4], "icmp")) {
			protocol = IPPROTO_ICMP;
			strcpy(proto_vec, "IPPROTO_ICMP");
		} else {
			printf("%s, not support yet!\n", protocol);
			return -1;
		}
	}

	fd = socket(spoof_info->ai_family, type, protocol);
	if (fd == -1) {
		perror("socket");
		return -1;
	}

	if (spoof_info->ai_family == AF_INET6) {
		struct sockaddr_in6 *addr6 = (struct sockaddr_in6 *)spoof_info->ai_addr;
		addr6->sin6_scope_id = 1;
	}

	ret = bind(fd, spoof_info->ai_addr, spoof_info->ai_addrlen);
	if (ret != 0) {
		printf("bind failed: [%d] - %s\n", errno, strerror(errno));
		printf("===== Test Item:(%s, %s, %s) Fail ===\n", family_vec, type_vec, proto_vec);
		ret = errno;
	} else {
		printf("===== Test Item:(%s, %s, %s) Pass ===\n", family_vec, type_vec, proto_vec);
	}

	free(spoof_info);
	close(fd);
	return ret;
}

