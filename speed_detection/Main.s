#############################
# Callee-saved
# r16:
# r17:
# r18: address
# r19: value
# r20: tmp/predefined speed limit
# r21: time passed/speed detected
# r22:
# r23:
#############################

.equ VALUE_SP,0x04000000				# initial sp value


.equ ADDR_TIMER,0xFF202000
.equ MAX_PERIOD,0xFFFFFFFF
.equ CYCLE_PER_SEC,100000000

.equ DISTANCE_BETWEEN_LIGHTSENSOR,  50

.equ ADDR_LED,0xff200000 				# for testing purpose
.equ ADDR_HEXDISPLAY30, 0xFF200020		# for testing purpose
###############################################################################

.section .data

.global PASSED_FIRST_SENSOR
.global PASSED_SECOND_SENSOR

.align 2
PASSED_FIRST_SENSOR: .space 4			# whether the moving object has passed the first sensor
PASSED_SECOND_SENSOR: .space 4 			# whether the moving object has passed the first sensor

SPEED_LIMIT: .space 4					# storing the speed limit
###############################################################################

.section .text

.global _start

_start:
init:
	movia sp,VALUE_SP					# initialize the sp

	movia r18, PASSED_FIRST_SENSOR 		# initialize the state boolean
	stw r0,0(r18)

	movia r18,PASSED_SECOND_SENSOR 		# initialize the state boolean
	stw r0,0(r18)

init_device:
	movia r18, ADDR_LED 				# get the led address
	stwio r0,0(r18) 					# turn off all LEDS

	movia r18, ADDR_HEXDISPLAY30 		# get the 7seg display address
	stwio r0,0(r18) 					# turn  off the 7seg display

	call get_speed_limit 				# retrieve the speed limit
	movia r18,SPEED_LIMIT 				# store the speed limit into SPEED_LIMIT
	stw r2,0(r18)

	call set_sensor_statemode 			# setup the light sensor
										# interrpt enabled here

###############################################################################

	movia r18, PASSED_FIRST_SENSOR 		# get the address of passed_first_sensor
wait_for_lightsensor1:
	ldw r19,0(r18) 						# get the value of passed_first_sensor
	beq r0,r19,wait_for_lightsensor1 	# loop, if the value of passed_first_sensor is false

	# start the timer
timer_init:
	movia r5, ADDR_TIMER 				# pass the address of the timer
	movia r4, MAX_PERIOD 				# pass the max period
	call start_timer

   	movia r18, PASSED_SECOND_SENSOR 	# get the address of passed_second_sensor
wait_for_lightsensor2:
  	ldw r19,0(r18) 						# get the value of passed_second_sensor
  	beq r0,r19,wait_for_lightsensor2 	# loop, if the value of passed_second_sensor is false

check_timer_value:
   	movia r4, ADDR_TIMER           		# pass the address of the timer
	call stop_timer
	mov r19,r2 							# store the result returned from the subroutine

time_difference:
	movia r20,MAX_PERIOD 				# max period
	sub r21,r20,r19 					# MAX_PERIOD - current time
	movia r20,CYCLE_PER_SEC 			# cycle per sec
 	divu r21,r21,r20 					# time (in second) = time (in cycle) / cycle_per_sec

speed:
	movia r4,DISTANCE_BETWEEN_LIGHTSENSOR
	mov r5,r21
	call calculate_speed 				# calculate the speed
	mov r21,r2 							# retrieve the returned value (measured speed)

check_over_speed:
	movia r20,SPEED_LIMIT 				# get the speed limit
	ldw r20,0(r20)
	bge r21,r20,overspeed
	br legalspeed

overspeed:
	movia r18, ADDR_LED 				# get the led address
	movia r19,0xffffffff 				# turn on all leds
	stwio r19,0(r18) 					# push the value into leds
	br end_loop

legalspeed:
	movia r18, ADDR_LED 				# get the led address
	movia r19,0x01 				        # turn on one led
	stwio r19,0(r18) 					# push the value into leds
	br end_loop

end_loop: 								# infinite loop
	br end_loop
