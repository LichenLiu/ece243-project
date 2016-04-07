#############################
# testing for moveBarrierGate subroutine
#############################
.section .data 
IMAGE_InputScreen: .incbin "Input_Screen.bin"


.section .text

.equ VALUE_SP,0x04000000		# initial sp value

.global main

main:
	#addi sp,sp,-8
	#stw ra,4(sp)
	#stw r18,0(sp)

	movia sp,VALUE_SP			# initialize the sp

	call clear_pixel_buffer
	call clear_character_buffer
	
	call get_speedlimit
	mov r18,r2
	#movui r18,12345

	call clear_pixel_buffer
	call clear_character_buffer

	movia r4,IMAGE_InputScreen
	call draw_image

	mov r4,r18
	addi sp,sp,-16				# allocate 16 bytes of memory to the string


	stw r0,12(sp)
	stw r0,8(sp)
	stw r0,4(sp)
	stw r0,0(sp)

	mov r5,sp
	call int_to_string

	mov r4,sp
	movui r5,15
	movui r6,10
	call draw_string

	addi sp,sp,16 				# deallocate the memory


loop:
	br loop

#	ldw ra,4(sp)
#	ldw r18,0(sp)

#	addi sp,sp,8

#	ret
