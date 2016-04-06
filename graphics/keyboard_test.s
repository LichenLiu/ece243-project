#############################
# testing for moveBarrierGate subroutine
#############################


.section .text



.equ VALUE_SP,0x04000000		# initial sp value


.global _start

_start:
	movia sp,VALUE_SP		# initialize the sp

	call KeyboardHandler
	call draw_result_good

loop:
	br loop
	