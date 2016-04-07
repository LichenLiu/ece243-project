################
# Caller Saved:
# r8: character address
# r10: x-pos
# r11: y-pos
# r12: inner loop condition
# r13: outer loop condition
# Callee Saved:
# r16: internal computation
# r17: internal computation
################
.section .text

.equ CHAR_ADDR,0x09000000

.global clear_character_buffer

clear_character_buffer:
	addi sp,sp,-8
	stw r16,0(sp)
	stw r17,4(sp)

	movia r8, CHAR_ADDR 			# initialize the pixel buffer address
	mov r10, r0  					# initialize x coordinate
	mov r11, r0 					# initialize y coordinate
	movui r12, 80 					# end inner loop condition
	movui r13,60  					# outter loop condition

Loop:
	muli r16,r11,128
	add r16,r10,r16
	add r17,r16,r8
	stbio r0,0(r17)

	#increment
	addi r10,r10,1   				# x coordinate increment
	blt r10,r12,Loop 				# inner x loop

	mov r10,r0 						# reset x position
	addi r11,r11,1  				# y coordinate decrement
	blt r11,r13,Loop 				# outter y loop

Exit:
	ldw r16,0(sp)
	ldw r17,4(sp)
	addi sp,sp,8
	ret
