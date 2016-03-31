#############################
# Input Argument
# r4: timer period
# r5: timer address
# Caller-saved
# r8: timer period
# r9: timer address
# r10: tmp
#############################
# .equ ADDR_TIMER,0xFF202000

.section .text

.equ TIMER_CTRL,4				# start the timer without cont and interrupt
.global start_timer

start_timer:
	mov r8,r4					# store the timer period
	mov r9,r5					# get the timer address
    
	srli r10,r8,16				# get the upper 16 bits of timeout period
	stwio r10,12(r9)			# set the upper 16 bits of timeout period

	andi r10,r8,0x0ffff			# get the lower 16 bits of timeout period
	stwio r10,8(r9)				# set the lower 16 bits of timeout period

	stwio r0,0(r9)				# clear the status register
	movui r10,TIMER_CTRL		# start the timer without cont and interrupt
	stwio r10,4(r9)

	ret							# return
	