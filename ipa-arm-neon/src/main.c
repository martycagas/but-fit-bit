#include "main.h"

int main()
{
    // initialise a random number generator
    srand(time(NULL));
    
    /* Image emulation
     * 
     * image is stored in consecutive char memory
     * every 3 chars correspond to one pixel
     * pixels are interpreted as BGR, following OpenCV standards
     */
     
    unsigned char input[24];
    unsigned char output[24];
    short int hsb[24];
    
    // creates an array of 8 pixels with randomised RGB values
    for(int i = 0; i < 24; i += 3)
    {
	// red
	input[i + 2] = rand();
	// green
	input[i + 1] = rand();
	// blue
	input[i] = rand();

	// initialisation of an output array
	output[i] = 0;
	output[i + 1] = 0;
	output[i + 2] = 0;
	
	// initialisation of a HSB array
	hsb[i] = 0;
	hsb[i + 1] = 0;
	hsb[i + 2] = 0;
    }
    
    // print out input
    printf("PRINTING OUT INPUT:\n");
    for(int i = 0; i < 24; i += 3)
    {
	    printf("[%u, %u, %u] ", input[i], input[i + 1], input[i + 2]);
    }
    printf("\n");

    asm_rgb2hsb(input, hsb);
    
    // print out hsb
    printf("PRINTING OUT HSB:\n");
    for(int i = 0; i < 24; i += 3)
    {
	    printf("[%hi, %hi, %hi] ", hsb[i], hsb[i + 1], hsb[i + 2]);
    }
    printf("\n");
	
    hsb2rgb(hsb, output);
    
    // print out output
    printf("PRINTING OUT OUTPUT:\n");
    for(int i = 0; i < 24; i += 3)
    {
	    printf("[%u, %u, %u] ", output[i], output[i + 1], output[i + 2]);
    }
    printf("\n");

    return 0;
}
