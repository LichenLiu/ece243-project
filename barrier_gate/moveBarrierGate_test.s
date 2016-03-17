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

loop:
	movia r4,100000000
	movia r5,ADDR_TIMER
	call delay					# call subroutine to delay

	movia r4,ADDR_JP1
	movia r5,ADDR_TIMER
	movui r6,0
	call moveBarrierGate

	movia r4,100000000
	movia r5,ADDR_TIMER
	call delay					# call subroutine to delay

	movia r4,ADDR_JP1
	movia r5,ADDR_TIMER
	movui r6,1
	call moveBarrierGate

	br loop
	