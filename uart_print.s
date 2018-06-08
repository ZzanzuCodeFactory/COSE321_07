#include "uart_regs.h"

.data
string:
	.ascii "00"
	.ascii ":"
	.ascii "00"
	.ascii ":"
	.ascii "00"
	.byte 0x0D
	.byte 0x00
.text

.macro uart_print

	bl uart_trans

.endm

uart_trans:

	ldr 	r0, =UART1_BASE
	ldr 	r1, =string

	ldrb	    r2, [r1], #1 // hour 10'
	ldrb		r3, [r1], #1 // hour 1'
	ldrb		r4, [r1], #1 // ":"
	ldrb		r5, [r1], #1 // minute 10'
	ldrb		r6, [r1], #1 // minute 1'
	ldrb		r7, [r1], #1 // ":"
	ldrb		r8, [r1], #1 // second 10'
	ldrb		r9,[r1], #1 // second 1'

	add r9, #1 // add 1 second

	// second
	cmp r9, #58
	moveq r9, #48
	addeq r8, #1

	cmp r8, #54
	moveq r8, #48
	addeq r6, #1

	// minute
	cmp r6, #58
	moveq r6, #48
	addeq r5, #1

	cmp r5, #54
	moveq r5, #48
	addeq r3, #1

	cmp r3, #58
	moveq r3, #48
	addeq r2, #1 // increment hour number by 1

	ldr 	r1, =string

	strb	    r2, [r1], #1 // hour 10'
	strb		r3, [r1], #1 // hour 1'
	strb		r4, [r1], #1 // :
	strb		r5, [r1], #1 // minute 10'
	strb		r6, [r1], #1 // minute 1'
	strb		r7, [r1], #1 // :
	strb		r8, [r1], #1 // second 10'
	strb		r9,	[r1], #1 // second 1'

	ldr 	r1, =string

TRANSMIT_loop:

	// ---------  Check to see if the Tx FIFO is empty ------------------------------
	ldr 	r2, [r0, #0x2C]	// get Channel Status Register
	and	r2, r2, #0x8		// get Transmit Buffer Empty bit(bit[3:3])
	cmp	r2, #0x8			// check if TxFIFO is empty and ready to receive new data
	bne	TRANSMIT_loop		// if TxFIFO is NOT empty, keep checking until it is empty
	//------------------------------------------------------------------------------

	ldrb     r3, [r1], #1
	streqb	r3, [r0, #0x30]	// fill the TxFIFO with 0x48
	cmp      r3, #0x00
	bne		TRANSMIT_loop

	mov		pc, lr				//    return to the caller
