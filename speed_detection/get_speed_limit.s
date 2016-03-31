# Return: speed limit (0-256) via switches(SW [7:0]) in m/sec
# Also prints the speed limit to the 7seg display(HEX1 HEX0) for debugging purpose
# Note: the returned value is of type int */

#############################
# Return
# r2: speed limit entered by the user (m/sec)
# Caller-saved
# r8: slide switches address/speed limit upper and lower hex bits/pushbutton address
# r9: seven_seg_decoder array pointer/7seg address/pushbutton reg
# r10: settings for 7seg display
#############################

.section .data
seven_seg_decoder:
	.byte 0b0111111 					# 0
	.byte 0b0000110 					# 1
	.byte 0b1011011						# 2
	.byte 0b1001111						# 3
	.byte 0b1100110						# 4
	.byte 0b1101101						# 5
	.byte 0b1111101						# 6
	.byte 0b0000111						# 7
	.byte 0b1111111						# 8
	.byte 0b1101111 					# 9
	.byte 0b1110111 					# a
	.byte 0b1111100 					# b
	.byte 0b0111001  					# c
	.byte 0b0100001 					# d
	.byte 0b1111001 					# e
	.byte 0b1110001 					# f
	

.section .text

.equ ADDR_SLIDESWITCHES, 0xFF200040
.equ ADDR_HEXDISPLAY30, 0xFF200020
.equ ADDR_PUSHBUTTON, 0xFF200050

.global get_speed_limit

get_speed_limit:
	movia r8,ADDR_PUSHBUTTON 			# get the address of pushbuttons
POLL:
	ldwio r9,0(r8) 						# get the value of pushbutton
	beq r0,r9,POLL 						# loop if no pushbutton is pressed

	movia r8,ADDR_SLIDESWITCHES 		# get the address of switches
  	ldwio r2,0(r8)                		# read switches
  	andi r2,r2,0x0ff 					# retrieves only the bit 0-7
	
	# display the input on the 7seg
	movia r9,seven_seg_decoder 			# get the address of the seven_seg_decoder array
	srli r8,r2,4 						# get the upper four bits of the speed limit
	add r9,r9,r8 						# adjust the pointer to point to the corresponding
										# 7seg config of the upper four bits of the speed limit
	ldbu r10,0(r9) 						# get the 7seg config for the upper four bits
	slli r10,r10,8

	movia r9,seven_seg_decoder 			# get the address of the seven_seg_decoder array
	andi r8,r2,0x0f 					# get the lower four bits of the speed limit
	add r9,r9,r8 						# adhyst the pointer of the seven_seg_decoder array

	ldbu r8,0(r9) 						# get the 7seg config for the lower four bits

	or r10,r10,r8 						# combine the 7seg conif for both upper and lower 4 btis

	movia r9,ADDR_HEXDISPLAY30 			# get the address of 7seg displays
	stwio r10,0(r9) 					# set the 7seg display

	ret
