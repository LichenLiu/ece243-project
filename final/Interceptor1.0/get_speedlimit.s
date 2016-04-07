########################
#0 	45
#1 	16
#2 	1E
#3 	26
#4 	25
#5	2E
#6 	36
#7 	3D
#8 	3E
#9 	46
#Enter 5A
#. 	49
#BKSP 66
#######################
#######################
# Return
# r2 the integer value of the input
# Caller Saved:
# r8 PS/2 base address
# r9 temp register stores the 1 byte data in FIFO
# r10 temp register stores the 1 byte scancode 
# Callee Saved:
# r16 state register
# r17 number of digits
# r18 tmp


#######################
.section .text

.equ PS2addr, 0xFF200100
.equ TEXT_POSITION_X,18
.equ TEXT_POSITION_Y,37

.global get_speedlimit
get_speedlimit:

# save return address

#######prelogue#######
	addi sp,sp,-16

	stw r16,0(sp)
	stw r17,4(sp)
	stw r18,8(sp)
	stw ra,12(sp)
	#stw r19,16(sp)

	mov r16, r0 # initialize the state bit 
	mov r17, r0 # number counter
	mov r18, r0
	mov r19, r0
################################
keyboard_poll:
	movia r8, PS2addr
	ldwio r9, 0(r8) ###############
	andi r10,r9,0x00008000 #musk the valid bit
	beq r10,r0,keyboard_poll
	andi  r9,r9,0xff # data value in r9

	#check BKSP key
	movi r10, 0x66
	beq r9,r10,keyBKSP
	
	#check enter key
	movi r10, 0x5A
	beq r9,r10,keyEnter

	#check key0
	movi r10, 0x45
	beq r9,r10,key0
	# check key1
	movi r10, 0x16
	beq r9,r10,key1
	# check key2
	movi r10, 0x1E
	beq r9,r10,key2
	#check key3
	movi r10, 0x26
	beq r9,r10,key3
	#check key4
	movi r10, 0x25
	beq r9,r10,key4
	#check key 5
	movi r10, 0x2E
	beq r9,r10,key5
	#check key 6
	movi r10, 0x36
	beq r9,r10,key6
	#check key 7
	movi r10, 0x3D
	beq r9,r10,key7
	#check key 8
	movi r10, 0x3E
	beq r9,r10,key8
	#check key 9
	movi r10, 0x46
	beq r9,r10,key9

	movi r10,0x0F
	beq r9, r10, breakSig

# use r16 as state flag
# use r17 as number counter
breakSig:
	movi r16,0x1
	br keyboard_poll

key0:
# check state bit it it is 0 flip the bit break state bit = 1
# which means it is the last byte of the break signal
	beq r16,r0,key0_press
	#clear the state bit
	mov r16,r0
#################
	br keyboard_poll
key0_press:
	movui r12,0x9 # max size of the input 9 digit 
	bge r17,r12,keyboard_poll # 
	addi r17,r17,1
	subi sp,sp,0x4
	movi r9,0x0
	stw r9,0(sp)
# assume I have a pointer
	movi r9,0x30 # move ascii code of '0' into r4
	subi sp,sp,4
	stb r9,0(sp)
	stb r0,1(sp)
	sth r0,2(sp)
	mov r4,sp
	addi r5,r17,TEXT_POSITION_X
	movui r6,TEXT_POSITION_Y
	call draw_string
	addi sp,sp,4
##############################
	br keyboard_poll

key1:
# check state bit it it is 0 flip the bit break state bit = 1
# which means it is the last byte of the break signal
	beq r16,r0,key1_press
#clear the state bit
	mov r16,r0
#################
br keyboard_poll
	key1_press:
	movui r12,0x9 # max size of the input 9 digit 
	bge r17,r12,keyboard_poll # 
	addi r17,r17,1
	subi sp,sp,0x4
	movi r9,0x1
	stw r9,0(sp)
# assume I have a pointer
	movi r9,0x31 # move ascii code of '0' into r4
	subi sp,sp,4
	stb r9,0(sp)
	stb r0,1(sp)
	sth r0,2(sp)
	mov r4,sp
	addi r5,r17,TEXT_POSITION_X
	movui r6,TEXT_POSITION_Y
	call draw_string
	addi sp,sp,4
##############################
br keyboard_poll

key2:
# check state bit it it is 0 flip the bit break state bit = 1
# which means it is the last byte of the break signal
	beq r16,r0,key2_press
#clear the state bit
	mov r16,r0
#################
	br keyboard_poll
	key2_press:
	movui r12,0x9 # max size of the input 9 digit 
	bge r17,r12,keyboard_poll # 
	addi r17,r17,1
	subi sp,sp,0x4
	movi r9,0x2
	stw r9,0(sp)
# assume I have a pointer
	movi r9,0x32 # move ascii code of '0' into r4
	subi sp,sp,4
	stb r9,0(sp)
	stb r0,1(sp)
	sth r0,2(sp)
	mov r4,sp
	addi r5,r17,TEXT_POSITION_X
	movui r6,TEXT_POSITION_Y
	call draw_string
	addi sp,sp,4
##############################
br keyboard_poll

key3:
# check state bit it it is 0 flip the bit break state bit = 1
# which means it is the last byte of the break signal
	beq r16,r0,key3_press
#clear the state bit
	mov r16,r0
#################
	br keyboard_poll
	key3_press:
	movui r12,0x9 # max size of the input 9 digit 
	bge r17,r12,keyboard_poll # 
	addi r17,r17,1
	subi sp,sp,0x4
	movi r9,0x3
	stw r9,0(sp)
# assume I have a pointer
	movi r9,0x33 # move ascii code of '0' into r4
	subi sp,sp,4
	stb r9,0(sp)
	stb r0,1(sp)
	sth r0,2(sp)
	mov r4,sp
	addi r5,r17,TEXT_POSITION_X
	movui r6,TEXT_POSITION_Y
	call draw_string
	addi sp,sp,4
##############################
	br keyboard_poll

key4:
# check state bit it it is 0 flip the bit break state bit = 1
# which means it is the last byte of the break signal
	beq r16,r0,key4_press
#clear the state bit
	mov r16,r0
#################
	br keyboard_poll
	key4_press:
	movui r12,0x9 # max size of the input 9 digit 
	bge r17,r12,keyboard_poll # 
	addi r17,r17,1
	subi sp,sp,0x4
	movi r9,0x4
	stw r9,0(sp)
# assume I have a pointer
	movi r9,0x34 # move ascii code of '0' into r4
	subi sp,sp,4
	stb r9,0(sp)
	stb r0,1(sp)
	sth r0,2(sp)
	mov r4,sp
	addi r5,r17,TEXT_POSITION_X
	movui r6,TEXT_POSITION_Y
	call draw_string
	addi sp,sp,4
##############################
	br keyboard_poll

key5:
# check state bit it it is 0 flip the bit break state bit = 1
# which means it is the last byte of the break signal
	beq r16,r0,key5_press
#clear the state bit
	mov r16,r0
#################
	br keyboard_poll
	key5_press:
	movui r12,0x9 # max size of the input 9 digit 
	bge r17,r12,keyboard_poll # 
	addi r17,r17,1
	subi sp,sp,0x4
	movi r9,0x5
	stw r9,0(sp)
# assume I have a pointer
	movi r9,0x35 # move ascii code of '0' into r4
	subi sp,sp,4
	stb r9,0(sp)
	stb r0,1(sp)
	sth r0,2(sp)
	mov r4,sp
	addi r5,r17,TEXT_POSITION_X
	movui r6,TEXT_POSITION_Y
	call draw_string
	addi sp,sp,4
##############################
	br keyboard_poll

key6:
# check state bit it it is 0 flip the bit break state bit = 1
# which means it is the last byte of the break signal
	beq r16,r0,key6_press
#clear the state bit
	mov r16,r0
#################
	br keyboard_poll
	key6_press:
	movui r12,0x9 # max size of the input 9 digit 
	bge r17,r12,keyboard_poll # 
	addi r17,r17,1
	subi sp,sp,0x4
	movi r9,0x6
	stw r9,0(sp)
# assume I have a pointer
	movi r9,0x36 # move ascii code of '0' into r4
	subi sp,sp,4
	stb r9,0(sp)
	stb r0,1(sp)
	sth r0,2(sp)
	mov r4,sp
	addi r5,r17,TEXT_POSITION_X
	movui r6,TEXT_POSITION_Y
	call draw_string
	addi sp,sp,4
##############################
	br keyboard_poll

key7:
# check state bit it it is 0 flip the bit break state bit = 1
# which means it is the last byte of the break signal
	beq r16,r0,key7_press
#clear the state bit
	mov r16,r0
#################
	br keyboard_poll
	key7_press:
	movui r12,0x9 # max size of the input 9 digit 
	bge r17,r12,keyboard_poll # 
	addi r17,r17,1
	subi sp,sp,0x4
	movi r9,0x7
	stw r9,0(sp)
# assume I have a pointer
	movi r9,0x37 # move ascii code of '0' into r4
	subi sp,sp,4
	stb r9,0(sp)
	stb r0,1(sp)
	sth r0,2(sp)
	mov r4,sp
	addi r5,r17,TEXT_POSITION_X
	movui r6,TEXT_POSITION_Y
	call draw_string
	addi sp,sp,4
##############################
	br keyboard_poll

key8:
# check state bit it it is 0 flip the bit break state bit = 1
# which means it is the last byte of the break signal
	beq r16,r0,key8_press
#clear the state bit
	mov r16,r0
#################
	br keyboard_poll
key8_press:
	movui r12,0x9 # max size of the input 9 digit 
	bge r17,r12,keyboard_poll # 
	addi r17,r17,1
	subi sp,sp,0x4
	movi r9,0x8
	stw r9,0(sp)
# assume I have a pointer
	movi r9,0x38 # move ascii code of '0' into r4
	subi sp,sp,4
	stb r9,0(sp)
	stb r0,1(sp)
	sth r0,2(sp)
	mov r4,sp
	addi r5,r17,TEXT_POSITION_X
	movui r6,TEXT_POSITION_Y
	call draw_string
	addi sp,sp,4
##############################
	br keyboard_poll

key9:
# check state bit it it is 0 flip the bit break state bit = 1
# which means it is the last byte of the break signal
	beq r16,r0,key9_press
#clear the state bit
	mov r16,r0
#################
	br keyboard_poll
	key9_press:
	movui r12,0x9 # max size of the input 9 digit 
	bge r17,r12,keyboard_poll # 
	addi r17,r17,1
	subi sp,sp,0x4
	movi r9,0x9
	stw r9,0(sp)
# assume I have a pointer
	movi r9,0x39 # move ascii code of '0' into r4
	subi sp,sp,4
	stb r9,0(sp)
	stb r0,1(sp)
	sth r0,2(sp)
	mov r4,sp
	addi r5,r17,TEXT_POSITION_X
	movui r6,TEXT_POSITION_Y
	call draw_string
	addi sp,sp,4
##############################
	br keyboard_poll

keyBKSP:
# check state bit it it is 0 flip the bit break state bit = 1
# which means it is the last byte of the break signal
	beq r16,r0,keyBKSP_press
#clear the state bit
	mov r16,r0
	br keyboard_poll
keyBKSP_press:
	ble r17,r0,keyboard_poll # 
#addi r17,r17,-1 //r17 should stay the same
	stw r0,0(sp)
	addi sp,sp,4
# assume I have a pointer
	movi r9,0x7F # move ascii code of '0' into r4
	subi sp,sp,4
	stb r9,0(sp)
	stb r0,1(sp)
	sth r0,2(sp)
	mov r4,sp
	addi r5,r17,TEXT_POSITION_X
	movui r6,TEXT_POSITION_Y
	call draw_string
	addi sp,sp,4
##############################
	addi r17,r17,-1
	br keyboard_poll

keyEnter:
# check state bit it it is 0 flip the bit break state bit = 1
# which means it is the last byte of the break signal
	beq r16,r0,keyboard_poll
	beq r17,r0,keyboard_poll #if there hasn't a input yet
#else 
	movi r10,1;
	mov r2,r0
loop: # reconstruct number
	ble r17,r0,RET
######################
	ldw r18, 0(sp) #use r18 store the single digit
	mul r18,r18,r10
	add r2,r2,r18
	muli r10,r10,10
######################
	subi r17,r17,1
	addi sp,sp,4
	br loop

	
RET:
	ldw r16,0(sp)
	ldw r17,4(sp)
	ldw r18,8(sp)
	ldw ra,12(sp)
	addi sp,sp,16

	ret
	