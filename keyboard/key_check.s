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
#######################
#######################
# r5 temp register used to store the scancode 
# r6 state register
# r7 number of digits 
# r8 PS/2 base address
# r9 temp register
#######################
.equ PS2addr, 0xFF200100
.global KeyboardHandler
KeyboardHandler:
movi r6, 0x0 # initialize the state bit 
mov r7, r0 # number counter
movia r8, PS2addr
#ldwio r9, 0(r8)
#srli r10,r9,16
#bgt r10,r0,keyboard_poll
#else 
#br KeyboardHandler
# will appear in every poll loop

keyboard_poll:
ldwio r9, 0(r8) ###############
andi r4,r9,0x00008000 #musk the valid bit
beq r4,r0,keyboard_poll
andi  r9,r9,0xff # data value in r9

#check key0
movi r5, 0x45
beq r9,r5,key0
# check key1
movi r5, 0x16
beq r9,r5,key1
# check key2
movi r5, 0x1E
beq r9,r5,key2
#check key3
movi r5, 0x26
beq r9,r5,key3
#check key4
movi r5, 0x25
beq r9,r5,key4
#check key 5
movi r5, 0x2E
beq r9,r5,key5
#check key 6
movi r5, 0x36
beq r9,r5,key6
#check key 7
movi r5, 0x3D
beq r9,r5,key7
#check key 8
movi r5, 0x3E
beq r9,r5,key8
#check key 9
movi r5, 0x46
beq r9,r5,key9
#check enter key
movi r5, 0x5A
beq r9,r5,keyEnter

movi r5,0x0F
beq r9, r5, breakSig

# use r6 as state flag
# use r7 as number counter
breakSig:
movi r6,0x1
br keyboard_poll

key0:
# check state bit it it is 0 flip the bit break state bit = 1
# which means it is the last byte of the break signal
beq r6,r0,key0_press
#clear the state bit
mov r6,r0
#################
br keyboard_poll
key0_press:
addi r7,r7,1
subi sp,sp,0x4
movi r9,0x0
stw r9,0(sp)
br keyboard_poll

key1:
# check state bit it it is 0 flip the bit break state bit = 1
# which means it is the last byte of the break signal
beq r6,r0,key1_press
#clear the state bit
mov r6,r0
#################
br keyboard_poll
key1_press:
addi r7,r7,1
subi sp,sp,0x4
movi r9,0x1
stw r9,0(sp)
br keyboard_poll

key2:
# check state bit it it is 0 flip the bit break state bit = 1
# which means it is the last byte of the break signal
beq r6,r0,key2_press
#clear the state bit
mov r6,r0
#################
br keyboard_poll
key2_press:
addi r7,r7,1
subi sp,sp,0x4
movi r9,0x2
stw r9,0(sp)
br keyboard_poll

key3:
# check state bit it it is 0 flip the bit break state bit = 1
# which means it is the last byte of the break signal
beq r6,r0,key3_press
#clear the state bit
mov r6,r0
#################
br keyboard_poll
key3_press:
addi r7,r7,1
subi sp,sp,0x4
movi r9,0x3
stw r9,0(sp)
br keyboard_poll

key4:
# check state bit it it is 0 flip the bit break state bit = 1
# which means it is the last byte of the break signal
beq r6,r0,key4_press
#clear the state bit
mov r6,r0
#################
br keyboard_poll
key4_press:
addi r7,r7,1
subi sp,sp,0x4
movi r9,0x4
stw r9,0(sp)
br keyboard_poll

key5:
# check state bit it it is 0 flip the bit break state bit = 1
# which means it is the last byte of the break signal
beq r6,r0,key5_press
#clear the state bit
mov r6,r0
#################
br keyboard_poll
key5_press:
addi r7,r7,1
subi sp,sp,0x4
movi r9,0x5
stw r9,0(sp)
br keyboard_poll

key6:
# check state bit it it is 0 flip the bit break state bit = 1
# which means it is the last byte of the break signal
beq r6,r0,key6_press
#clear the state bit
mov r6,r0
#################
br keyboard_poll
key6_press:
addi r7,r7,1
subi sp,sp,0x4
movi r9,0x6
stw r9,0(sp)
br keyboard_poll

key7:
# check state bit it it is 0 flip the bit break state bit = 1
# which means it is the last byte of the break signal
beq r6,r0,key7_press
#clear the state bit
mov r6,r0
#################
br keyboard_poll
key7_press:
addi r7,r7,1
subi sp,sp,0x4
movi r9,0x7
stw r9,0(sp)
br keyboard_poll

key8:
# check state bit it it is 0 flip the bit break state bit = 1
# which means it is the last byte of the break signal
beq r6,r0,key8_press
#clear the state bit
mov r6,r0
#################
br keyboard_poll
key8_press:
addi r7,r7,1
subi sp,sp,0x4
movi r9,0x8
stw r9,0(sp)
br keyboard_poll

key9:
# check state bit it it is 0 flip the bit break state bit = 1
# which means it is the last byte of the break signal
beq r6,r0,key9_press
#clear the state bit
mov r6,r0
#################
br keyboard_poll
key9_press:
addi r7,r7,1
subi sp,sp,0x4
movi r9,0x9
stw r9,0(sp)
br keyboard_poll
#calculate the number value and return it in r2
#discard the left break signal 
#recover the stack 
#here use r5 store the order of the each
#r2 as the final result


keyEnter:
beq r7,r0,keyboard_poll #if there hasn't a input yet
#else 
movi r5,0x1;
loop:
beq r7,r0,RET
ldw r4, 0(sp) #use r4 store the single digit
mul r4,r4,r5
add r2,r2,r4
muli r5,r5,0xa

subi r7,r7,1
addi sp,sp,4

br loop

RET:
	ret