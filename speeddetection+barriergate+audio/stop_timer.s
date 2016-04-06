#############################
# Return
# r2: snapshot from timer
# Input Argument
# r4: timer address
# r5:
# Caller-saved
# r8: timer address
# r9: upper bits
# r10: lower bits
# r11: tmp
#############################
# .equ ADDR_TIMER,0xFF202000

.section .text

.equ STOP,0b00001000
.global stop_timer

stop_timer:
	mov r8,r4				          	# get the timer address

 	stwio r0,16(r8)             # get the snapshot of the timer 
	ldwio r10,16(r8)            # read lower snapshot bits
	ldwio r9,20(r8)            	# read upper snapshot bits
	slli r9,r9,16
 	or r2,r9,r10                # combine the lower and upper bits

 	movia r11,STOP 				      # stop the timer
 	stwio r11,4(r8)

 	stwio r0,0(r8)			       	# clear the status register

	ret							            # return
	