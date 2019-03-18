#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <sys/syscall.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <errno.h>
#include <netinet/in.h>
#include <sys/uio.h>
#include <linux/in6.h>
#include <linux/udp.h>
#include <linux/socket.h>
#include <linux/ipv6.h>
#include <linux/icmpv6.h>
#include <netdb.h>

#define MY_PORT_NUM 51111 /* This can be changed to suit the need and should be same in server and client */
#define TRUE 1
#define FALSE 0
#define __BIG_ENDIAN_BITFIELD 1


int main ( int argc, char *argv[] )  
{

  int rawSock1, rawSock2, ret, flags, rc, on;
  struct sockaddr_in6 servaddrs;
  struct sockaddr_in6 servaddrc;
  bzero( (void *)&servaddrs, sizeof(servaddrs) );
  bzero( (void *)&servaddrc, sizeof(servaddrc) );
  flags = 0;
  on = 1;
  struct msghdr msg;
  struct iovec iov[1];
  bzero( (void *)iov, sizeof(iov[1]) );
  bzero( (void *)&msg, sizeof(msg) );

  char * datagram;
  datagram = malloc(4096);
  memset(datagram, 0, 4096);
  struct ipv6hdr * ipv6_hdr_str = (struct ipv6hdr * ) datagram;  
  struct icmp6hdr * icmpv6_hdr_str = (struct icmp6hdr * ) ( datagram + sizeof (struct ipv6hdr) );
  char * data = (char *) ( datagram + sizeof(struct ipv6hdr) + sizeof(struct icmp6hdr) );
  strcpy( data, "Zara ali a DPS student in class 10th.\0");
  int datalen = strlen( data );

  rawSock1 = socket( AF_INET6, SOCK_RAW, IPPROTO_ICMPV6 );
  if (rawSock1 < 0)
  {
        perror("Failed to get raw socket 1\n");
        return -1;
  }
  else

  	printf("New raw socket 1: %d .\n", rawSock1);


  rawSock2 = socket( AF_INET6, SOCK_RAW, IPPROTO_RAW );
  if (rawSock2 < 0)
  {
  	perror("Failed to get raw socket 2\n");
        return -1;
  }
  else
  	printf("New raw socket 2: %d .\n", rawSock2);


  servaddrs.sin6_family = AF_INET6;
  inet_pton(AF_INET6, "::1", &(servaddrs.sin6_addr));
  servaddrs.sin6_port = htons(0);
 
  servaddrc.sin6_family = AF_INET6;
  servaddrc.sin6_port = htons(0);
  servaddrc.sin6_flowinfo = 0;
  servaddrc.sin6_scope_id = 1;
  inet_pton(AF_INET6, "2012::78", &(servaddrc.sin6_addr));
 
  // Message Type (8 bits): echo request
  icmpv6_hdr_str -> icmp6_type = ICMPV6_ECHO_REQUEST;
  // Message Code (8 bits): echo request
  icmpv6_hdr_str -> icmp6_code = 0;
  // Identifier (16 bits): usually pid of sending process - pick a number
  icmpv6_hdr_str -> icmp6_identifier = htons (1000);
  // Sequence Number (16 bits): starts at 0
  icmpv6_hdr_str -> icmp6_sequence = htons (0);
  // ICMP header checksum (16 bits): set to 0 when calculating checksum
  icmpv6_hdr_str -> icmp6_cksum = 0;
  //icmpv6_hdr_str.icmp6_cksum = icmp6_checksum (ipv6_hdr_str, icmpv6_hdr_str, data, datalen);

 
  /* Fill out IPv6 header */
  ipv6_hdr_str->version = 6;
  ipv6_hdr_str->priority = 1;
  ipv6_hdr_str->flow_lbl[0] = 0;
  ipv6_hdr_str->flow_lbl[1] = 0;
  ipv6_hdr_str->flow_lbl[2] = 0;
  ipv6_hdr_str->payload_len = htons(8 + strlen(data));
  ipv6_hdr_str->nexthdr = IPPROTO_ICMPV6;
  ipv6_hdr_str->hop_limit = 64;
  inet_pton(AF_INET6, "2012::78", &(ipv6_hdr_str->daddr)); // IPv6 
  inet_pton(AF_INET6, "::1", &(ipv6_hdr_str->saddr)); // IPv6
 
 
  msg.msg_name = (struct sockaddr_in6 *)&servaddrc;
  msg.msg_namelen = sizeof(struct sockaddr_in6);
  iov[0].iov_base = datagram;
  iov[0].iov_len = sizeof(struct ipv6hdr) + sizeof(struct udphdr) + strlen(data);
  msg.msg_iov = iov;
  msg.msg_iovlen = 1;
  msg.msg_control = NULL;
  msg.msg_controllen = 0;
  msg.msg_flags = 0;

  ret = setsockopt ( rawSock1, IPPROTO_IPV6, IP_HDRINCL, &on, sizeof(on) );
  if (ret < 0)
  {
  	perror("Failed to setsockopt 1\n");
        return -1;
  }
  ret = setsockopt ( rawSock2, IPPROTO_IPV6, IP_HDRINCL, &on, sizeof(on) );  
  if (ret < 0)
  {
  	perror("Failed to setsockopt 2\n");
  	return -1;
  }

  rc = sendmsg( rawSock1, &msg, flags );
  if (rc < 0)
  {
      
  	perror("send() failed 1");
        close ( rawSock1 );
        return -1;
  }
  else
  {
        printf("send OK 1.\n"); 
  }

  rc = sendmsg( rawSock2, &msg, flags );
  if (rc < 0)
  {

        perror("send() failed 2");
        close ( rawSock2 );
        return -1;
  }
  else
  {
        printf("send OK 2.\n");
  }

 
  struct icmp6_filter icmpv6filcon;
  bzero( (void *)&icmpv6filcon, sizeof(struct icmp6_filter) );
  int icmpv6fillen = sizeof( struct icmp6_filter);
  ret = getsockopt ( rawSock1, IPPROTO_ICMPV6, ICMPV6_FILTER, &icmpv6filcon, &icmpv6fillen );
  if ( ret < 0 )
  	perror("Failed to getsockopt 1\n");
  else
  	printf("ICMPv6 filter content 1: %d \n", icmpv6filcon.data);


  bzero( (void *)&icmpv6filcon, sizeof(struct icmp6_filter) );
  ret = getsockopt ( rawSock2, IPPROTO_ICMPV6, ICMPV6_FILTER, &icmpv6filcon, &icmpv6fillen );
  if ( ret < 0 )
        perror("Failed to getsockopt 2\n");
  else
        printf("ICMPv6 filter content 2: %d \n", icmpv6filcon.data);


  free ( datagram );

  close (rawSock1);
  close (rawSock2); 
  printf ( "Exiting normally. \n");     
  return 0;
 
}
