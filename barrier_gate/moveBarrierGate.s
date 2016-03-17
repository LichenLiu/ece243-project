#############################
# Input Argument
# r4: GPIO address (JP1/JP2)
# r5: timer address

# Callee-saved
# r16: JP address
# r17: MOTOR OFF
# r18: temporary
# r20: motor direction
# r21: sensor to check (0: #0/ 1: #1)
# r22: timer address
#############################
# Important
# use sensor 0 and 1 for touch sensors
# use motor 0 for barrier gate motor


.section .text

.equ DIR_REG, 0x07f557ff
.equ INIT_CTL, 0xffffffff			# set all things off

.equ MOTOROFF,0xffffffff			# sensor off, motor0 off
.equ MOTORCW,0xfffffffc				# sensor off, motor0 forward, on
.equ MOTORCCW,0xfffffffe			# sensor off, motor0 reverse, on

.equ ON_CYCLE,0x0003003a			# delay for motor on, 196666
.equ OFF_CYCLE,0x0003003a			# delay for motor off, 196666
	
.global moveBarrierGate

moveBarrierGate:
	subi sp,sp,28				# push onto the stack
	stw ra,24(sp)
	stw r22,20(sp)
	stw r21,16(sp)
	stw r20,12(sp)
	stw r18,8(sp)
	stw r17,4(sp)
	stw r16,0(sp)

	mov r22,r5 					# store the timer address
	mov r16,r4					# store JP address
	movia r17,MOTOROFF			# get the motor off setting

	movia r18,DIR_REG			# get the direction register setting
	stwio r18,4(r16)			# set the direction register

	movia r18,INIT_CTL			# get the initial control setting
	stwio r18,0(r16)			# initialize motor and sensor

	# r4 is the same
	mov r5,r0 					# check the value of touch sensor 0
	call getTouchSensorValue

	movui r18,0x000f 			# if the touch sensor 0 is fully off (not touched)
	beq r18,r2,towards_sensor0  # move towards touch sensor 0
	br towards_sensor1

towards_sensor0: # assume CW motor direction
	movia r20,MOTORCW
	movui r21,0
	br motor_move

towards_sensor1: # assume CCW motor direction
	movia r20,MOTORCCW
	movui r21,1
	br motor_move

motor_move:
	stwio r20,0(r16) 			# set the motor to move

	movia r4,ON_CYCLE
	mov r5,r22
	call delay					# call subroutine to delay
		
	stwio r17,0(r16) 			# set the motor to off

	movia r4,OFF_CYCLE
	mov r5,r22
	call delay					# call subroutine to delay

	mov r4,r16
	mov r5,r21 					# check the value of target touch sensor
	call getTouchSensorValue

	movui r18,0x000f 			# if the target touch sensor is fully off (not touched)
	beq r18,r2,motor_move  		# continue
	
	# end subroutine
	ldw ra,24(sp)
	ldw r22,20(sp)
	ldw r21,16(sp)
	ldw r20,12(sp)
	ldw r18,8(sp)
	ldw r17,4(sp)
	ldw r16,0(sp)
	addi sp,sp,28				# pop from the stack

	ret
