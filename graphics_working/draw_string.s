#######################
# Input Argument
# r4: pointer to string
# r5: starting x
# r6: starting y
# Caller Saved:
# r8: address of character buffer
# r9: 0x7f hard coded
# Callee Saved:
# r16: x coord
# r17: y coord
# r18: address offset
# r19: character retrieved from the input string
# r19: tmp
# r20: final character buffer address
#######################
.section .text

.equ ADDR_CHAR, 0x09000000

.global draw_string

draw_string:
	addi sp,sp,-24		 	# allocated the stack 
	stw r16,0(sp) 		 	# push r16 onto the stack
	stw r17,4(sp) 		 	# push r17 onto the stack
	stw r18,8(sp) 			# push r18 onto the stack
	stw r19,12(sp)
	stw r20,16(sp)
	stw ra,20(sp) 			# push ra onto the stack

	movia r8, ADDR_CHAR
	movui r9,0x7f
	mov r16, r5 			# initialize x coordinate
	muli r17, r6,128 		# calculate address offset

Loop: # r4 stores the pointer a list of ascii code
	ldbu r19,0(r4)
	beq r19,r0,RET
	beq r19,r9,DEL
	###############
CAL:
	# update x coordinates based on current number size
	add r18,r16,r17 
	add r20,r18,r8 
	stbio r19,0(r20) # draw the character
	addi r16,r16,1
	addi r4,r4,1 
	br Loop

DEL:
	mov r19,r0
	br CAL

RET:
	ldw r16,0(sp) # push r16 onto the stack
	ldw r17,4(sp) # push r17 onto the stack
	ldw r18,8(sp) # push r18 onto the stack
	ldw r19,12(sp)
	ldw r20,16(sp)
	ldw ra,20(sp) # push ra onto the stack
	addi sp,sp,24 # deallocated the stack 
	ret
