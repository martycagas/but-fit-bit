#ifndef ARPH_H
#define ARPH_H

#include <sys/types.h>

typedef struct arp {
   uint16_t htype;
   uint16_t ptype;
   uint8_t hlen;
   uint8_t plen;
   uint16_t op;
   uint8_t sha[6];
   uint8_t spa[4];
   uint8_t tha[6];
   uint8_t tpa[4];
} __attribute__((packed)) arp_hdr;

#endif
