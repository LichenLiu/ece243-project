########result output########
.equ PIX_ADDR,0x08000000
.data 
PIXEL: .incbin "xiaojiji.bin"

# x starts from zero
# y starts from 239 and decrease to zero
# 2*x + 1024 * y
# for the function has no parameters
# use r4 r5 r6 r7 directly
# use r16 17 18
# use r8 store the pixel buffer
# use r9 as a pointer point to the address of the first pixel information
.section .text
.global draw_result_good

draw_result_good:
addi sp,sp,-12
stw r16,0(sp)
stw r17,4(sp)
stw r18,12(sp)
mov r4, r0  # initial x coordinate
movi r5, 239 # initial y coordinate
movi r6, 320 # end inner loop condition
movia r8, PIX_ADDR # initialize the pixel buffer address
movia r9, PIXEL #initialize the pointer increment by two

Loop:
ldh r10,0(r9) #get pixel info from array
muli r16,r4,2 
muli r17,r5,1024
add r16,r16,r17
add r18,r16,r8
sthio r10,0(r18) # store pixel information into buffer

#increment
addi r9,r9,2   # pixel pointer increment
addi r4,r4,1   # x coordinate increment
blt r4,r6,Loop # inner x loop

mov r4,r0   # reset x to 0
addi r5,r5,-1  # y coordinate decrement
bge r5,r0,Loop # outter y loop

Exit:
ldw r16,0(sp)
ldw r17,4(sp)
ldw r18,12(sp)
addi sp,sp,12
ret
