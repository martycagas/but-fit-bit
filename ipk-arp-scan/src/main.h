#ifndef MAIN_H
#define MAIN_H

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>           // strcpy, memset(), and memcpy()

#define __USE_POSIX
#include <netdb.h>            // struct addrinfo
#include <sys/types.h>        // needed for socket(), uint8_t, uint16_t
#include <sys/socket.h>       // needed for socket()
#include <sys/wait.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <sys/time.h>
#include <fcntl.h>
#define __USE_POSIX199309
#include <time.h>
#include <signal.h>
#include <arpa/inet.h>        // inet_pton() and inet_ntop()
#include <sys/ioctl.h>        // macro ioctl is defined
#include <bits/ioctls.h>      // defines values for argument "request" of ioctl.
#define __USE_MISC
#include <net/if.h>           // struct ifreq
#include <linux/if_packet.h>  // struct sockaddr_ll (see man 7 packet)
#include <linux/if_ether.h>   // ETH_P_ARP = 0x0806, ETH_P_ALL = 0x0003
#include <net/ethernet.h>

#include <errno.h>            // errno, perror()

#include "arph.h"
#include "ethh.h"

#define IP_MAXPACKET 65535 
#define ETH_P_ARP 0x0806

#define ETH_HDR_LEN 14
#define ARP_HDR_LEN 28
#define BUFF_SIZE 256

// function prototypes
int main(int argc, char ** argv);

#endif
