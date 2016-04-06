# Return: speed limit (0-256) via switches(SW [7:0]) in cm/sec
# Also prints the speed limit to the 7seg display(HEX1 HEX0) for debugging purpose
# Note: the returned value is of type int */

#############################
# Return
# r2: speed limit entered by the user (cm/sec)
# Caller-saved
# r8: slide switches address/pushbutton address
# r9: pushbutton reg
#############################
.section .text

.equ ADDR_SLIDESWITCHES, 0xFF200040
.equ ADDR_HEXDISPLAY30, 0xFF200020
.equ ADDR_PUSHBUTTON, 0xFF200050

.global get_speed_limit

get_speed_limit:
	addi sp,sp,-4
	stw ra,0(sp) 						# push the return address

	movia r8,ADDR_PUSHBUTTON 			# get the address of pushbuttons
POLL:
	ldwio r9,0(r8) 						# get the value of pushbutton
	beq r0,r9,POLL 						# loop if no pushbutton is pressed

	movia r8,ADDR_SLIDESWITCHES 		# get the address of switches
  	ldwio r2,0(r8)                		# read switches
  	andi r2,r2,0x0ff 					# retrieves only the bit 0-7
	
	# display the input on the 7seg
	addi sp,sp,-4
	stw r2,0(sp)

	mov r4,r2
	movia r5,ADDR_HEXDISPLAY30 			# display the input
	call hexdisplay_7seg

	ldw r2,0(sp)
	addi sp,sp,4


	ldw ra,0(sp) 						# pop the return address
	addi sp,sp,4

	ret
