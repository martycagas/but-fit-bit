# INP Project 2

Second project of the Computer Systems Design course of the Brno University of Technology, Faculty of Informational Technologies.

- VHDL Brainlove Interpreter

## Description

Please note that
> This product includes software developed by the University of Technology, Faculty of Information Technology, Brno and its contributors.

### Brainlove Interpreter

Project was derived from Zdenek Vasicek's template controlling the peripheral features of the FITkit development kit containing the XC3S50 family FPGA on board.

It is uploaded in form that was submitted for grading.

The ```login.b``` and ```login-long.b``` both contain code (the latter with comments) in the language Brainlove, that the processor described in ```cpu.vhd``` is capable of interpreting. Brainlove is extension to the [Brainfuck](https://en.wikipedia.org/wiki/Brainfuck) language featuring five new commands. Of those, the processor is capable of interpreting ```$``` and ```!``` commands that store and load the value of the current cell to and from ```TMP``` memory cell, respectively, in addition to all standard Brainfuck commands.

**The processor does not support following Brainlove commands as it was not specified in the assignement:**

```
(    while(!*ptr) { /* loop while *ptr == 0 */
)    }
~    break; /* break from the most inner loop */
```

The project was graded with following notes from Zdenek Vasicek:

```
Verification of the processor's functionality:

    0. test program (BF)         result
    1. ++++++++++                    ok
    2. ----------                    ok
    3. +>++>+++                      ok
    4. <+<++<+++                     ok
    5. .+.+.+.                       ok
    6. ,+,+,+,                       ok
    7. +$+++++++++++!                ok
    8. +$>++++!                      ok
    9. [........]test[.........]     ok
    10. +++[.-]                      ok
    11. +++++[>++[>+.<-]<-]          ok

    Support of basic cycles: yes
    Support of nested cycles: yes

Notes regarding implementation:

    Processor does not respond to the signal EN
    Incomplete sensitivity list; missing signals: DATA_RDATA, IN_DATA, tmp_signal
    Possible problematic control of following signals: DATA_RDWR, wdata_selector
```

**Total points for CPU implementation: 16 (out of 17)**