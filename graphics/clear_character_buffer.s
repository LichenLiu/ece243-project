########result output########
.equ CHAR_ADDR,0x09000000
.data 
PIXEL: .incbin "xiaojiji.bin"

# x starts from zero
# y starts from 239 and decrease to zero
# 2*x + 1024 * y
# for the function has no parameters
# use r10 r11 r6 r7 directly
# use r16 17 18
# use r8 store the pixel buffer
# use r9 as a pointer point to the address of the first pixel information
.section .text
.global clear_character_buffer

clear_character_buffer:
	addi sp,sp,-8
	stw r16,0(sp)
	stw r17,4(sp)

	movia r8, CHAR_ADDR # initialize the pixel buffer address
	mov r10, r0  # initialize x coordinate
	movi r11, r0 # initialize y coordinate
	movi r12, 80 # end inner loop condition
	mov r13,60   # outter loop condition
	Loop:
	mov r14,r0
	# x is r10
	muli r16,r11,128
	add r16,r10,r16
	add r17,r16,r8
	#sthio r13,0(r18) # store pixel information into buffer

	stbio r14,0(r17)

	#increment
	addi r10,r10,1   # x coordinate increment
	blt r10,r12,Loop # inner x loop

	addi r11,r11,1  # y coordinate decrement
	blt r11,r13,Loop # outter y loop

Exit:
	ldw r16,0(sp)
	ldw r17,4(sp)
	addi sp,sp,8
	ret