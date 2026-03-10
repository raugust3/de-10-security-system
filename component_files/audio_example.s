.global _start
_start:
    mov  r8, #40            // r8 = half-period duration, adjust this to change the pitch/frequency
    ldr  r6, =0xff203040    // r6 = base address of the audio peripheral
    ldr  r4, =0x10000000    // r4 = amplitude/volume. 0x10000000 is a high positive value
    mov  r5, r8             // r5 = loop counter for the current half-period

WaitForWriteSpace:
    ldr  r2, [r6, #4]       // read the FIFO Space Register (offset 4)
    
    tst  r2, #0xff000000    // check WSRC (Write Space Right Channel) - bits [31:24]
    beq  WaitForWriteSpace  // if 0, the right FIFO is full.. wait
    
    tst  r2, #0x00ff0000    // check WSLC (Write Space Left Channel) - bits [23:16]
    beq  WaitForWriteSpace  // if 0, the left FIFO is full.. wait

WriteTwoSamples:
    str  r4, [r6, #8]       // write sample to left data register (offset 8)
    str  r4, [r6, #12]      // write sample to right data register (offset 12)
    
    /* manage the duration of the current wave state */
    subs r5, r5, #1         // decrement the half-period counter
    bne  WaitForWriteSpace  // if counter > 0, keep sending the same amplitude

HalfPeriodInvertWaveform:
    /* square wave toggle */
    mov  r5, r8             // reset the half-period counter
    neg  r4, r4             // flip the amplitude (e.g., +0x10000000 becomes -0x10000000)
    b    WaitForWriteSpace  // repeat forever to create a continuous tone

