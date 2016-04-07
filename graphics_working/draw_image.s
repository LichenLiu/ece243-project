################
# Input Argument:
# r4: pointer to image to display
# Caller Saved:
# r8: pixel address
# r9: pixel pointer
# r10: x-pos
# r11: y-pos
# r12: x loop condition
# r13: pixel data
# Callee Saved:
# r16: internal computation
# r17: internal computation
# r18: internal computation
################
# x starts from zero
# y starts from 239 and decrease to zero
# 2*x + 1024 * y

.section .text

.equ PIX_ADDR,0x08000000

.global draw_image

draw_image:
	addi sp,sp,-12
	stw r16,0(sp)
	stw r17,4(sp)
	stw r18,8(sp)

	movia r8, PIX_ADDR 			# initialize the pixel buffer address
	mov r9, r4 					# initialize the pixel pointer
	mov r10, r0  				# initial x coordinate
	movui r11, 239 				# initial y coordinate
	movui r12, 320 				# end inner loop condition

Loop:
	ldh r13,0(r9) 				#get pixel info from array
	muli r16,r10,2 
	muli r17,r11,1024
	add r16,r16,r17
	add r18,r16,r8
	sthio r13,0(r18) 			# store pixel information into buffer

	#increment
	addi r9,r9,2   				# pixel pointer increment
	addi r10,r10,1   			# x coordinate increment
	blt r10,r12,Loop 			# inner x loop

	mov r10,r0   				# reset x to 0
	addi r11,r11,-1  			# y coordinate decrement
	bge r11,r0,Loop 			# outter y loop

Exit:
	ldw r16,0(sp)
	ldw r17,4(sp)
	ldw r18,8(sp)
	addi sp,sp,12
	ret
