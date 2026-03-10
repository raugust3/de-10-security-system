.global _start
_start:
	/* initialize addresses */
    ldr r12, MPCORE_PRIV_TIMER 
    ldr r11, LED_BASE 
    
    /* initialize timer registers */
    mov r0, #0          		// hundredths
    mov r1, #0          		// seconds
    mov r2, #0x3FF      		// LED starting pattern
	mov r3, #0x1FF				// LED update pattern
	
	str r2, [r11]
    
    /* setup hardware timer */
    ldr r4, TIMEOUT 
    str r4, [r12]       		// load value
    mov r4, #0b01
    str r4, [r12, #0xC] 		// clear interrupt bit
    mov r4, #0b011      		// enable, auto-reload, no interrupt
    str r4, [r12, #0x08]

_main_loop:
	bl _start_timer
	
	// reset the timer if one second has passed
	cmp r1, #1
	moveq r1, #0
	moveq r0, #0
	bleq _stop_timer
	
	b _main_loop
	
_start_timer:
	// reuse registers for start_timer subroutine
	push {r9, r10, r11, r12}
	// DONT OVERWRITE r12 THIS IS THE TIMER

	// check if the 0.01s timer has expired
	ldr r11, [r12, #0xC]	
	cmp r11, #1
	
	// increment r0 if 0.01s has passed
	addeq r0, r0, #1
	
	// calculate seconds
	ldr r10, =100
	cmp r0, r10					// if 0.01s >= 100
	addge r1, r1, #1 			// increment the number of seconds
	movge r0, #0 				// reset the number of 0.01 seconds that have passed
	
	// reset timer flag bit
	mov r9, #0b01 				// write 1 to reset/clear
	str r9, [r12, #0xC]
	
	pop {r9, r10, r11, r12}		// bring back original values for registers
	bx lr 						// back to main loop
	
_stop_timer:
	// decrement an LED
	and r3, r2
	str r3, [r11]
	cmp r3, #0					// if no LEDs are lit, end the program
	beq _end
	lsr r3, #1
	bx lr 						// back to main loop

_end:
	str r2, [r11]				// placeholder ending
	b _end

@@ CONSTANTS & ADDRESSES
KEY_BASE: 			.word 0xFF200050
LED_BASE: 			.word 0xFF200000
PIX_BASE:			.word 0xC8000000
AUDIO_BASE:			.word 0xFF203040
SW_BASE: 			.word 0xFF200040
SEG_BASE0: 			.word 0xFF200020
SEG_BASE1: 			.word 0xFF200030
MPCORE_PRIV_TIMER:  .word 0xFFFEC600
TIMEOUT: 			.word 1999999
WIDTH:				.word 320
HEIGHT:				.word 240
BYTES_PER_ROW:		.word 10
BYTES_PER_PIXEL:	.word 1