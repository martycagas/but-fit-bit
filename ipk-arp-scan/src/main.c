#include "main.h"

int main(int argc, char * argv[])
{
	pid_t reciever;

	char interface[BUFF_SIZE];
	char filepath[BUFF_SIZE];
	int if_set = 0;
	int fp_set = 0;

	for (int i = 1; i < argc; i++) {
		if (strcmp(argv[i], "-i") == 0) {
			strcpy(interface, argv[++i]);
			if_set = 1;
		} else if (strcmp(argv[i], "-f") == 0) {
			strcpy(filepath, argv[++i]);
			fp_set = 1;
		} else {
			fprintf(stderr, "Incorrect parameter format!\n");
			exit(1);
		}
	}
	if (if_set != 1 || fp_set != 1) {
		exit(1);
	}

	uint8_t src_mac[6];
	uint8_t src_ip[4];
	uint8_t net_mask[4];
	uint8_t * ether_frame;
	uint8_t * recv_ether_frame;

	arp_hdr arphdr;
	eth_hdr ethhdr;

	struct ifreq ifr;
	struct sockaddr_ll device;

	recv_ether_frame = calloc(IP_MAXPACKET, sizeof(uint8_t));
	ether_frame = calloc(IP_MAXPACKET, sizeof(uint8_t));

	int info_socket = socket(AF_INET, SOCK_RAW, IPPROTO_RAW);
	if (info_socket < 0) {
		perror("socket() failed to get socket descriptor for using ioctl() ");
		close(info_socket);
		free(recv_ether_frame);
		free(ether_frame);
		exit (3);
	}

	snprintf (ifr.ifr_name, sizeof(ifr.ifr_name), "%s", interface);
	if (ioctl(info_socket, SIOCGIFHWADDR, &ifr) < 0) {
		perror("ioctl() failed to get source MAC address ");
		close(info_socket);
		free(recv_ether_frame);
		free(ether_frame);
		return(3);
	}
	memcpy(src_mac, ifr.ifr_hwaddr.sa_data, 6 * sizeof (uint8_t));
	if (ioctl(info_socket, SIOCGIFADDR, &ifr) < 0) {
		perror("ioctl() failed to get source IP address ");
		close(info_socket);
		free(recv_ether_frame);
		free(ether_frame);
		return(3);
	}
	memcpy(src_ip, ifr.ifr_addr.sa_data + 2, 4 * sizeof (uint8_t));
	if (ioctl(info_socket, SIOCGIFNETMASK, &ifr) < 0) {
		perror("ioctl() failed to get source IP address ");
		close(info_socket);
		free(recv_ether_frame);
		free(ether_frame);
		return(3);
	}
	memcpy(net_mask, ifr.ifr_netmask.sa_data + 2, 4 * sizeof (uint8_t));
	close(info_socket);

	uint32_t mask;
	uint32_t ip;
	uint32_t count;
	ip = (uint32_t) src_ip[3] + (((uint32_t) src_ip[2]) << 8) + (((uint32_t) src_ip[1]) << 16) + (((uint32_t) src_ip[0]) << 24);
	mask = (uint32_t) net_mask[3] + (((uint32_t) net_mask[2]) << 8) + (((uint32_t) net_mask[1]) << 16) + (((uint32_t) net_mask[0]) << 24);
	uint32_t network_addr = ip & mask;
	count = ~mask;

	device.sll_ifindex = if_nametoindex(interface);
	if (device.sll_ifindex == 0) {
		perror("if_nametoindex() failed to obtain interface index ");
		free(recv_ether_frame);
		free(ether_frame);
		exit(3);
	}
	device.sll_family = AF_PACKET;
	memcpy(device.sll_addr, src_mac, 6 * sizeof (uint8_t));
	device.sll_halen = 6;

	// ETHER header
	memset(&ethhdr.dest, 0xff, 6 * sizeof (uint8_t));
	memcpy(&ethhdr.source, src_mac, 6 * sizeof (uint8_t));
	ethhdr.eth_type[0] = ETH_P_ARP / 256;
	ethhdr.eth_type[1] = ETH_P_ARP % 256;

	// ARP header
	arphdr.htype = htons(1);
	arphdr.ptype = htons(2048);
	arphdr.hlen = 6;
	arphdr.plen = 4;
	arphdr.op = htons(1);
	memcpy(&arphdr.sha, src_mac, 6 * sizeof (uint8_t));
	memcpy(&arphdr.spa, src_ip, 4 * sizeof (uint8_t));
	memset(&arphdr.tha, 0x00, 6 * sizeof (uint8_t));

	int comm_socket = socket(PF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
	if (comm_socket < 0) {
		perror("socket() failed ");
		free(recv_ether_frame);
		free(ether_frame);
		exit(3);
	}

	int recv_socket = socket(PF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
	if (recv_socket < 0) {
		perror("socket() failed ");
		close(comm_socket);
		free(recv_ether_frame);
		free(ether_frame);
		exit(3);
	}

	struct timespec parent_wait;
	parent_wait.tv_sec = 0;
	parent_wait.tv_nsec = 10000000;

	struct timeval socket_timeout;
	socket_timeout.tv_sec = 0;
	socket_timeout.tv_usec = 50000;

	if (setsockopt(recv_socket, SOL_SOCKET, SO_RCVTIMEO, (char *)&socket_timeout, sizeof(socket_timeout)) < 0) {
        perror("setsockopt");
        close(comm_socket);
        close(recv_socket);
		    free(recv_ether_frame);
		    free(ether_frame);
        exit(1);
    }

	arp_hdr * recv_arphdr = (arp_hdr *) (recv_ether_frame + ETH_HDR_LEN);

	// prepare outpt file
	FILE * output;
	output = fopen(filepath, "w");
	fprintf(output, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
	fprintf(output, "<devices>\n");
	fclose(output);

	// send to all devices on the network
	for (uint32_t i = 1; i < count; i++) {
		ip = network_addr | i;
		arphdr.tpa[0] = ip >> 24;
		arphdr.tpa[1] = (ip >> 16) & 0xff;
		arphdr.tpa[2] = (ip >> 8) & 0xff;
		arphdr.tpa[3] = ip & 0xff;

		reciever = fork();
		if (reciever < 0) {
			fprintf(stderr, "Failed to create reciever process.\nTerminating...\n");
			close(comm_socket);
			close(recv_socket);
			free(recv_ether_frame);
			free(ether_frame);
			exit(2);
		} else if (reciever == 0) {
			while (1) {
				signal(SIGINT, SIG_IGN);
				int recieve = recv(recv_socket, recv_ether_frame, IP_MAXPACKET, 0);
				if (recieve < 0) {
					if (errno == EINTR) {
						memset(recv_ether_frame, 0, IP_MAXPACKET * sizeof (uint8_t));
						continue;
					} else {
						exit(0);
					}
				}
				if (recieve == 60 && recv_arphdr->op == htons(2) && recv_ether_frame[12] == (ETH_P_ARP / 256) && recv_ether_frame[13] == (ETH_P_ARP % 256)) {
					output = fopen(filepath, "a");
					fprintf(output, "\t<host mac=\"%02x:%02x:%02x:%02x:%02x:%02x\">\n", recv_arphdr->sha[0], recv_arphdr->sha[1], recv_arphdr->sha[2], recv_arphdr->sha[3], recv_arphdr->sha[4], recv_arphdr->sha[5]);
					fprintf(output, "\t\t<ipv4>%u.%u.%u.%u</ipv4>\n", recv_arphdr->spa[0], recv_arphdr->spa[1], recv_arphdr->spa[2], recv_arphdr->spa[3]);
					fprintf(output, "\t</host>\n");
					fclose(output);
					break;
				}
			}
			exit(0);
		} else {
			memcpy(ether_frame, &ethhdr, ETH_HDR_LEN * sizeof(uint8_t));
			memcpy(ether_frame + ETH_HDR_LEN, &arphdr, ARP_HDR_LEN * sizeof(uint8_t));

			nanosleep(&parent_wait, NULL);
			int bytes = sendto(comm_socket, ether_frame, ETH_HDR_LEN + ARP_HDR_LEN, 0, (struct sockaddr *) &device, sizeof (device));
			if (bytes <= 0) {
				perror ("sendto() failed");
				exit(4);
			}
			wait(NULL);
		}
	}

	output = fopen(filepath, "a");
	fprintf(output, "</devices>\n");
	fclose(output);

	close(comm_socket);
	close(recv_socket);
	free(ether_frame);
	free(recv_ether_frame);

	return (0);
}
