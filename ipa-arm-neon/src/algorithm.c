#include "algorithm.h"

void asm_rgb2hsb(unsigned char * input_data, short int * hsb_data)
{

    __asm volatile(
        // r7 is a pointer to the output image arra
        // r8 is a pointer to the input image array
        "ldr r7, %0\n"
        "ldr r8, %1\n"

        // d20 8 pixels of the blue channel
        // d21 8 pixels of the green channel
        // d22 8 pixels of the red channel
        "vld3.8 {d28, d29, d30}, [r7]!\n"

        // extends registers to 16 bits per value - results in registers going as follows:
        // q0 8 pixels of the blue channel on 16 bits
        // q1 8 pixels of the green channel on 16 bits
        // q2 8 pixels of the red channel on 16 bits
        "vmovl.u8 q0, d28\n" // blue
        "vmovl.u8 q1, d29\n" // green
        "vmovl.u8 q2, d30\n" // red

        // q3 holds max values
        // q4 holds min values

        /// compute max
        // store the bigger of red and green into max
        "vmax.s16 q3, q2, q1\n"
        // store the bigger of max and blue into max
        "vmax.s16 q3, q3, q0\n"

        /// compute brightness
        // q3 now holds max value => q3 now holds BRIGHTNESS

        /// compute min
        // store the smaller of red and green into max
        "vmin.s16 q4, q2, q1\n"
        // store the smaller of max and blue into max
        "vmin.s16 q4, q4, q0\n"

        /// compute saturation
        // q5 holds saturation
        // q6 holds vector of 1s where MAX == 0
        "vcle.s16 q6, q3, #0\n"
        // prepare a vetor of #1s
        "mov r4, #1\n"
        "vdup.16 q7, r4\n"
        // erase where MAX != 0
        // q8 is a vector like MAX without zeroes
        "vmax.s16 q8, q7, q3\n"
        // q9 holds Ma - Mi
        "vqsub.s16 q9, q3, q4\n"

        /// switching to unsigned arithmetics!!

        // multiply q9 by 256 by shifting it by 8 to the left
        "vqshl.u16 q9, #8\n"
        // divide every scalar of q9 by corresponding scalar of q8 and store it to q10
        // done in ARM because NEON is unable to perform division
        // scalar 0
        "vmov.u16 r4, d18[0]\n"
        "vmov.u16 r5, d16[0]\n"
        "udiv r6, r4, r5\n"
        "vmov.16 d20[0], r6\n"
        //scalar 1
        "vmov.u16 r4, d18[1]\n"
        "vmov.u16 r5, d16[1]\n"
        "udiv r6, r4, r5\n"
        "vmov.16 d20[1], r6\n"
        //scalar 2
        "vmov.u16 r4, d18[2]\n"
        "vmov.u16 r5, d16[2]\n"
        "udiv r6, r4, r5\n"
        "vmov.16 d20[2], r6\n"
        //scalar 3
        "vmov.u16 r4, d18[3]\n"
        "vmov.u16 r5, d16[3]\n"
        "udiv r6, r4, r5\n"
        "vmov.16 d20[3], r6\n"
        //scalar 4
        "vmov.u16 r4, d19[0]\n"
        "vmov.u16 r5, d17[0]\n"
        "udiv r6, r4, r5\n"
        "vmov.16 d21[0], r6\n"
        //scalar 5
        "vmov.u16 r4, d19[1]\n"
        "vmov.u16 r5, d17[1]\n"
        "udiv r6, r4, r5\n"
        "vmov.16 d21[1], r6\n"
        //scalar 6
        "vmov.u16 r4, d19[2]\n"
        "vmov.u16 r5, d17[2]\n"
        "udiv r6, r4, r5\n"
        "vmov.16 d21[2], r6\n"
        //scalar 7
        "vmov.u16 r4, d19[3]\n"
        "vmov.u16 r5, d17[3]\n"
        "udiv r6, r4, r5\n"
        "vmov.16 d21[3], r6\n"
        // now q10 is filled with division results
        // invert vector of 1s where MAX == 0
        "vorn q7, q7\n"
        "veor q6, q7\n"
        // AND complemented comparation vector with q10 and store it to q5
        "vand q5, q6, q10\n"

        /// switching to signed arithmetics!!

        // set values that are greater than 255 to 255
        "mov r4, #0xff\n"
        "vdup.16 q7, r4\n"
        "vmin.s16 q5, q5, q7\n"
        // q5 now holds SATURATION

        /// compute hue
        // q6 holds hue
        // q8-q10 now cointains comparsions of MAX with all color channels
        "vceq.i16 q8, q2, q3\n"
        "vceq.i16 q9, q1, q3\n"
        "vceq.i16 q10, q0, q3\n"
        // negate first and second and AND them with second and third, respectively
        "vorn q11, q11\n"
        "veor q12, q8, q11\n"
        "vand q9, q12\n"
        "veor q12, q9, q11\n"
        "vand q10, q12\n"
        // calculate subtractions of respecive colors and store them to three separate vectors
        "vqsub.s16 q11, q1, q0\n"
        "vqsub.s16 q12, q0, q2\n"
        "vqsub.s16 q13, q2, q1\n"
        // now AND the vectors q11-q13 with vectors q8-q10
        "vand q11, q8\n"
        "vand q12, q9\n"
        "vand q13, q10\n"
        // add those vectors together to q6
        "vbic q6, q6\n"
        "vqadd.s16 q6, q11\n"
        "vqadd.s16 q6, q12\n"
        "vqadd.s16 q6, q13\n"
        // multiply q6 by 60
        "mov r4, #0x3c\n"
        "vdup.16 d22, r4\n"
        "vmull.s16 q7, d12, d22\n"
        "vmull.s16 q8, d13, d22\n"
        "vqmovn.s32 d12, q7\n"
        "vqmovn.s32 d13, q8\n"
        // q7 holds Delta = Ma - Mi
        "vqsub.s16 q7, q3, q4\n"
        // divide all separately by DELTA
        // scalar 0
        "vmov.s16 r4, d12[0]\n"
        "vmov.s16 r5, d14[0]\n"
        "sdiv r6, r4, r5\n"
        "vmov.16 d12[0], r6\n"
        // scalar 1
        "vmov.s16 r4, d12[1]\n"
        "vmov.s16 r5, d14[1]\n"
        "sdiv r6, r4, r5\n"
        "vmov.16 d12[1], r6\n"
        // scalar 2
        "vmov.s16 r4, d12[2]\n"
        "vmov.s16 r5, d14[2]\n"
        "sdiv r6, r4, r5\n"
        "vmov.16 d12[2], r6\n"
        // scalar 3
        "vmov.s16 r4, d12[3]\n"
        "vmov.s16 r5, d14[3]\n"
        "sdiv r6, r4, r5\n"
        "vmov.16 d12[3], r6\n"
        // scalar 4
        "vmov.s16 r4, d13[0]\n"
        "vmov.s16 r5, d15[0]\n"
        "sdiv r6, r4, r5\n"
        "vmov.16 d13[0], r6\n"
        // scalar 5
        "vmov.s16 r4, d13[1]\n"
        "vmov.s16 r5, d15[1]\n"
        "sdiv r6, r4, r5\n"
        "vmov.16 d13[1], r6\n"
        // scalar 6
        "vmov.s16 r4, d13[2]\n"
        "vmov.s16 r5, d15[2]\n"
        "sdiv r6, r4, r5\n"
        "vmov.16 d13[2], r6\n"
        // scalar 7
        "vmov.s16 r4, d13[3]\n"
        "vmov.s16 r5, d15[3]\n"
        "sdiv r6, r4, r5\n"
        "vmov.16 d13[3], r6\n"
        // add 120 to green elements of q6(hue) and 240 to blue elements
        "mov r4, #0x78\n"
        "vdup.16 q12, r4\n"
        "vand q12, q9\n"
        "vqadd.s16 q6, q6, q12\n"
        "mov r4, #0xf0\n"
        "vdup.16 q12, r4\n"
        "vand q12, q10\n"
        "vqadd.s16 q6, q6, q12\n"
        // add 360 to elements lower than 0
        "mov r4, #0x168\n"
        "vdup.16 q12, r4\n"
        "vclt.s16 q13, q6, #0\n"
        "vand q12, q13\n"
        "vqadd.s16 q6, q6, q12\n"
        // erase all where saturations equals 0
        "vceq.i16 q7, q5, #0\n"
        "vorn q8, q8\n"
        "veor q7, q8\n"
        "vand q6, q7\n"
        // q6 now holds hue

        /// perform any operation

        // excahnge registers to prepare them for storing
        "vswp q3, q4\n"
        "vswp q4, q6\n"

        // store it, interleaving
        "vst3.16 {d8, d10, d12}, [r8]!\n"
        "vst3.16 {d9, d11, d13}, [r8]!\n"

        : "=m" (input_data)
        : "m" (hsb_data)
        : "memory"
    );

}

void hsb2rgb(short int * hsb_data, unsigned char * output_data)
{
    short int hue;
    short int sat;
    short int bri;

    unsigned char r;
    unsigned char g;
    unsigned char b;

    unsigned int i;
    unsigned int f;
    unsigned int p;
    unsigned int q;
    unsigned int t;

    for(int j = 0; j < 24; j += 3)
    {
        hue = hsb_data[j];
        sat = hsb_data[j + 1];
        bri = hsb_data[j + 2];

        i = hue / 60;
        f = hue % 60;
        p = bri * (255 - sat) / 256;
        q = bri * (255 - sat * f / 60) / 256;
        t = bri * (255 - sat * (60 - f) / 60) / 256;

        switch(i)
        {
            case 0:
            {
                r = bri;
                g = t;
                b = p;
            } break;

            case 1:
            {
                r = q;
                g = bri;
                b = p;
            } break;

            case 2:
            {
                r = p;
                g = bri;
                b = t;
            } break;

            case 3:
            {
                r = p;
                g = q;
                b = bri;
            } break;

            case 4:
            {
                r = t;
                g = p;
                b = bri;
            } break;

            case 5:
            {
                r = bri;
                g = p;
                b = q;
            } break;
        }

        output_data[j] = b;
        output_data[j + 1] = g;
        output_data[j + 2] = r;
    }
}
