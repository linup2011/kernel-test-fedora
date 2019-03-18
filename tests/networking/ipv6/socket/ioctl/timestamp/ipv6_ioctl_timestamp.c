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
#include <netinet/sctp.h>
#include <sys/uio.h>
#include <linux/in6.h>
#include <linux/socket.h>
#include <linux/ipv6.h>
#include <netdb.h>


#define MY_PORT_NUM 51111 /* This can be changed to suit the need and should be same in server and client */
#define TRUE 1
#define FALSE 0


int main ()
{

  int listenSock, connectSock, ret, retime, flags;
  int  rc, new_sd;
  struct timeval valbefore, valafter;
  struct timespec specbefore, specafter;
  struct sockaddr_in6 servaddrs;
  struct sockaddr_in6 servaddrc;
  struct sctp_initmsg initmsg;
  struct sctp_sndrcvinfo sndrcvinfo; 

  flags = 0;

  /* Create listen socket */
  listenSock = socket( AF_INET6, SOCK_STREAM, IPPROTO_SCTP );

  bzero( (void *)&servaddrs, sizeof(servaddrs) );
  servaddrs.sin6_family = AF_INET6;
  inet_pton(AF_INET6, "0::1", &(servaddrs.sin6_addr));
  servaddrs.sin6_port = htons(51111);
  ret = bind( listenSock, (struct sockaddr *)&servaddrs, sizeof(servaddrs) );


  /* Specify that a maximum of 5 streams will be available per socket */
  memset( &initmsg, 0, sizeof(initmsg) );
  initmsg.sinit_num_ostreams = 5;
  initmsg.sinit_max_instreams = 5;
  initmsg.sinit_max_attempts = 4;
  ret = setsockopt( listenSock, IPPROTO_SCTP, SCTP_INITMSG,
                    &initmsg, sizeof(initmsg) );

  listen( listenSock, 5 );

  /* Create connect socket */
  connectSock = socket( AF_INET6, SOCK_STREAM, IPPROTO_SCTP );

  bzero( (void *)&servaddrc, sizeof(servaddrc) );
  servaddrc.sin6_family = AF_INET6;
  servaddrc.sin6_port = htons(51111);
  inet_pton(AF_INET6, "0::1", &(servaddrc.sin6_addr));

  ret = connect( connectSock, (struct sockaddr *)&servaddrc, sizeof(servaddrc) );

  /* Accept connection */
  new_sd = accept(listenSock, NULL, NULL);
  if (new_sd < 0)
  {
     
     perror("accept() failed");
     close ( connectSock );
     close ( listenSock );
     exit (1);
      
  }
  else
  {
   
     printf("  New incoming connection - %d\n", new_sd);
     printf("  Accept new connection OK.\n " );

  }
 

  char out[20480];
  char in[20480];
  int i = 0;
  int n = 2;
  int len = 0;
  bzero ( out, 20480 );
  bzero ( in, 20480 );
  strcpy( out, "Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,\
          Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,\
          Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,\
          Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,\
          Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,\
          Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,\
          Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,\
          Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,\
          Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,\
          Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,\
          Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,\
          Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,\
          Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,\
          Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,\
          Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,\
          Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,\
          Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,\
          Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,\
          Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,\
          Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,\
          Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,\
          Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,\
          Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,\
          Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th,Zara ali a DPS student in class 10th" );

  for ( i = 0; i < 2; i++ )
  {
  
      rc = sctp_sendmsg( connectSock, out, (size_t)strlen(out), NULL,0,0,0,0,0,0 );
      if (rc < 0)
      {
      
         perror("  send() failed");
         close ( connectSock );
         close ( new_sd );
         close ( listenSock );
         exit (1);
   
      }
  
      printf("send OK.\n");   
  
      rc = sctp_recvmsg( new_sd, in, sizeof(in),
                     (struct sockaddr *)NULL, 0, &sndrcvinfo, &flags );
      if (rc <= 0)
      {
     
         perror("  recv() failed");
         close ( connectSock );
         close ( listenSock );
         close ( new_sd );
         exit (1);
   
      }

      len = rc;
      printf("  %d bytes received\n", len);

      n = n - 1;    
      if ( n == 0 )
      {

         /* Get timestamp of struct timeval before 2nd receiving message */
         retime = ioctl ( new_sd, SIOCGSTAMP, &valbefore );
         if ( retime < 0 )
            perror ( "inet6_ioctl failed.");
         else
            printf ( "timestamp before receiving: %ld s, %ld us \n", valbefore.tv_sec, valbefore.tv_usec ); 

         /* Get timestamp of struct timespec before 2nd receiving message */
         retime = ioctl ( new_sd, SIOCGSTAMPNS, &specbefore );
         if ( retime < 0 )
            perror ( "iinet6_ioctl failed.");
         else
            printf ( "timestamp before receiving: %ld s, %ld ns \n", specbefore.tv_sec, specbefore.tv_nsec );
      
      }
  }

 
  /* Get timestamp of struct timeval after 2nd receiving message */
  retime = ioctl ( new_sd, SIOCGSTAMP, &valafter );
  if ( retime < 0 )
     perror ( "inet6_ioctl failed after.");
  else
     printf ( "timestamp after receiving: %ld s, %ld us \n", valafter.tv_sec, valafter.tv_usec );


  /* Get timestamp of struct timespec after 2nd receiving message */
  retime = ioctl ( new_sd, SIOCGSTAMPNS, &specafter );
  if ( retime < 0 )
     perror ( "iinet6_ioctl failed after.");
  else
     printf ( "timestamp after receiving: %ld s, %ld ns \n", specafter.tv_sec, specafter.tv_nsec );

   
  printf ( "Exiting normally. \n");     
  exit (0);

}
