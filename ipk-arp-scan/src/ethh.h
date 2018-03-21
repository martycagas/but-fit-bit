#ifndef IPV4H_H
#define IPV4H_H

#include <sys/types.h>

typedef struct eth {
  uint8_t dest[6];
  uint8_t source[6];
  uint8_t eth_type[2];
}__attribute__((packed)) eth_hdr;

#endif
