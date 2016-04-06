#############################
# Input Argument
# r4: delay count
# r5: timer address
# Caller-saved
# r8: delay count
# r9: timer address
# r10: tmp
#############################
# .equ ADDR_TIMER,0xFF202000

.section .text

.equ TIMER_CTRL,4				# start the timer without cont and interrupt
.global delay

delay:
	addi sp,sp,-4				# allocated the stack
	stw ra,0(sp)				# push ra onto the stack

	mov r8,r4					# store the delay count
	mov r9, r5					# get the timer address

	srli r10,r8,16				# get the upper 16 bits of timeout period
	stwio r10,12(r9)			# set the upper 16 bits of timeout period

	andi r10,r8,0x0ffff			# get the lower 16 bits of timeout period
	stwio r10,8(r9)				# set the lower 16 bits of timeout period

	stwio r0,0(r9)				# clear the status register
	movui r10,TIMER_CTRL		# start the timer without cont and interrupt
	stwio r10,4(r9)

timer_running:
	ldwio r10,0(r9)				# load the status register
	andi r10,r10,0x01			# get the Timeout bit (bit 0)
	beq r10,r0,timer_running	# if not timed out, loop

timed_out:
	stwio r0,0(r9)				# clear the status register
	
	ldw ra,0(sp)				# pop ra from the stack
	addi sp,sp,4				# deallocate the stack

	ret							# return
	