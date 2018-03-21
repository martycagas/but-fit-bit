// accelerating algorithm using a neon FPU

#ifndef algorithm_h
#define algorithm_h

#include <stdio.h>
#include <stdlib.h>

#define WIDTH 8
#define HEIGHT 8

void asm_rgb2hsb(unsigned char *, short int *);
void hsb2rgb(short int *, unsigned char *);

#endif

