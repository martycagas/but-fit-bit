# IPA Semester Project

Semester project of the Advanced Assembly Languages course of the Brno University of Technology, Faculty of Informational Technologies.

- Acceleration of an image editing algorithm using a NEON coprocessor on ARM processors

## Description

The project consists of two parts, the algorithm and an example main functions serving the demonstration purposes. The algorithm itself is a GCC inline ARM assembly routine for NEON accelerated transformation of BGR encoded image data to the HSB color system.

The algorithm for transforming data back to HSB could not be effectively vectorized and was written in plain C.

For demonstration purposes, the algorithm operates on an array of 24 8-bit values representing 8 pixels with randomly generated BGR values. Essentially, the algorithm can be called to process any 8 pixels. A possible usage would be to surround the asm statement with a cycle.

As the time constraints didn't allow delving deeper into the algorithm, it's highly unefficient due to manual division of every line back in th FPU of the processor. The next step, if the time allows it, is to extend the algorithm to use the instructions to the numerical division using the taylor polynom that is supported directly in the NEON.

## Project file structure

* doc
    * _doc-cz\_cz.pdf_
* src
    * _algorithm.c_
    * _algorithm.h_
    * _main.c_
    * _main.h_
    * _Makefile_

#### `doc-cz_cz.pdf`

Contains the original project documentation in Czech.

#### `alhorithm.c`

Contains two routines for both-sided conversions between BGR and HSB.

#### `alhorithm.h`

Header definitions for the `algorithm.c`.

#### `main.c`

Essentially a "test class" for the algorithm.

#### `main.h`

Header definitions for the `main.c`.

#### `Makefile`

Contains the project makefile for the GNU program `make`.