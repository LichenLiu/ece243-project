#######################
#0  30
#1  31
#2  32
#3  33
#4  34
#5	35
#6 	36
#7 	37
#8 	38
#9 	49
############################################################
# r4 is the input argument which is the character ascii code
# r8 store the character buffer address
# r9 current size of number
# r16 initial x coordinate
# r17 initial y coordinate
# r18 address offset
# 80 60

# mov r9 r7
.section .text
.equ ADDR_CHAR, 0x09000000
.global drawcharacter

drawcharacter:

addi sp,sp,-16				# allocated the stack 
stw ra,0(sp)				# push ra onto the stack
stw r16,4(sp)				# push r16 onto the stack
stw r17,8(sp)				# push r17 onto the stack
stw r18,12(sp)				# push r18 onto the stack

movia r8, ADDR_CHAR

movi r16, 37				# initialize x coordinate
movi r17, 29				# initialize y coordinate

subi r9,r9,1
add r17,r17,r9				# update y coordinates based on current number size
muli r17, r17,128			# calculate address offset
addi r18,r16,r17			
stbio r4,r18(r8)			# draw the character

ldw r18,12(sp)
ldw r17,8(sp)
ldw r16,4(sp)
ldw ra,0(sp)
addi sp,sp,16				#deallocate data on the stack
ret

