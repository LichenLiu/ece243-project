#############################
# Input Argument
# r4: value to display (only the lower 16bits are displayed)
# r5: address of the 7-seg display
# Caller-saved
# r8: counter
# r9: seven_seg_decoder array pointer/tmp
# r10: settings for 7seg display
# r11: tmp
#############################
# .equ ADDR_HEXDISPLAY30, 0xFF200020
# .equ ADDR_HEXDISPLAY74, 0xFF200030

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
	.byte 0b1011110 					# d
	.byte 0b1111001 					# e
	.byte 0b1110001 					# f

.section .text

.global hexdisplay_7seg

hexdisplay_7seg:
	mov r8,r0 							# clear the counter
	mov r10,r0 							# clear the 7seg display setting

loop:	
	movia r9,seven_seg_decoder

	srl r11,r4,r8 						# shift the input value right by counter bits
	andi r11,r11,0x0f 					# get the four lsb
	add r9,r9,r11 						# adjust the decoder pointer to apprpriate position
	ldbu r11,0(r9) 						# get the setting for 7seg display
	muli r9,r8,2 						# get the position in 7seg setting reg
	sll r11,r11,r9 						# move the 7seg setting to appropriate byte location
	or r10,r10,r11 						# update the setting

	addi r8,r8,4 						# increment the counter

	movui r9,12 						# loop ending condition
	blt r8,r9,loop

	stwio r10,0(r5) 					# update the 7seg display

	ret
