#############################
# testing for moveBarrierGate subroutine
#############################


.section .text

.equ ADDR_JP1,0xFF200060
.equ ADDR_TIMER,0xFF202000

.equ VALUE_SP,0x04000000		# initial sp value


.global _start

_start:
	movia sp,VALUE_SP		# initialize the sp

	movia r4,ADDR_JP1
	movia r5,ADDR_TIMER
	call moveBarrierGate

loop:
	br loop
	