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

# speed in cm/sec
.equ ADDR_TIMER,0xFF202000
.equ MAX_PERIOD,0x7FFFFFFF # not causing any signed problem
.equ CYCLE_PER_SEC,100000 # 0.001s # 1 sec -> 100000000
.equ COUNTDOWN_PERIOD,70000000

.equ DISTANCE_BETWEEN_LIGHTSENSOR,  10000 # 10 micrometer

.equ ADDR_LED,0xff200000 				# for testing purpose
.equ ADDR_HEXDISPLAY30, 0xFF200020		# for testing purpose
.equ ADDR_HEXDISPLAY54, 0xFF200030 		# for testing purpose
###############################################################################

.section .data

.global PASSED_FIRST_SENSOR
.global PASSED_SECOND_SENSOR
.global AUDIO_SAMPLE_COUNTER

# load the images
IMAGE_InputScreen: .incbin "Input_Screen.bin"
IMAGE_InputScreenCompleted: .incbin "Input_Screen_Completed.bin"
IMAGE_SpeedNotOK: .incbin "speednotok.bin"
IMAGE_SpeedOK:.incbin "speedok.bin"

IMAGE_CountDown3:.incbin "countdown3.bin"
IMAGE_CountDown2:.incbin "countdown2.bin"
IMAGE_CountDown1:.incbin "countdown1.bin"
IMAGE_CountDownGO:.incbin "countdowngo.bin"


.align 2
PASSED_FIRST_SENSOR: .space 4			# whether the moving object has passed the first sensor
PASSED_SECOND_SENSOR: .space 4 			# whether the moving object has passed the first sensor

SPEED_LIMIT: .space 4					# storing the speed limit
ACTUAL_SPEED: .space 4 					# storing the actual speed

AUDIO_SAMPLE_COUNTER: .space 4 			# tracing the current sample
###############################################################################

.section .text

.global main

main:
init:
	movia sp,VALUE_SP					# initialize the sp

	movia r18, PASSED_FIRST_SENSOR 		# initialize the state boolean
	stw r0,0(r18)

	movia r18,PASSED_SECOND_SENSOR 		# initialize the state boolean
	stw r0,0(r18)

	wrctl ctl3,r0 						# disable all interruptes
	wrctl ctl0,r0 							

init_device:
	movia r18, ADDR_LED 				# get the led address
	stwio r0,0(r18) 					# turn off all LEDS

	movia r18, ADDR_HEXDISPLAY30 		# get the 7seg display address
	stwio r0,0(r18) 					# turn  off the 7seg display

	movia r18, ADDR_HEXDISPLAY54 		# get the 7seg display address
	stwio r0,0(r18) 					# turn  off the 7seg display

	movia r4,ADDR_TIMER 				# pass the address of the timer
	mov r5,r0 							# reset the barrier gate
	call moveBarrierGate

get_input:
	# clear displays
	call clear_pixel_buffer
	call clear_character_buffer

	movia r4,IMAGE_InputScreen 			# pass the image to the subroutine
	call draw_image 					# draw the image

	call get_speedlimit 				# retrieve the speed limit
	movia r18,SPEED_LIMIT 				# store the speed limit into SPEED_LIMIT
	stw r2,0(r18)

	# clear displays
	call clear_pixel_buffer
	call clear_character_buffer

	movia r4,IMAGE_InputScreenCompleted 	# pass the image to the subroutine
	call draw_image

	# create a temp string on stack
	addi sp,sp,-16						# allocate 16 bytes of memory to the string
	stw r0,12(sp)
	stw r0,8(sp)
	stw r0,4(sp)
	stw r0,0(sp)
	mov r5,sp
	movia r18,SPEED_LIMIT 				# get the speed limit
	ldw r4,0(r18)
	call int_to_string 					# convert the integer to string

	mov r4,sp
	movui r5,18
	movui r6,37
	call draw_string 					# draw the speed limit on screen

	addi sp,sp,16 						# deallocate the memory for the temp string from the stack

	# display the speed limit on the 7seg
	movia r18,SPEED_LIMIT 				# get the speed limit
	ldw r4,0(r18)
	movia r5,ADDR_HEXDISPLAY30 			# display the speed limit
	call hexdisplay_7seg

countdown:
	movia r4,150000000 					# delay amount
	movia r5,ADDR_TIMER 				# pass the timer address
	call delay

######
	# clear displays
	call clear_pixel_buffer
	call clear_character_buffer

	movia r4,IMAGE_CountDown3 			# pass the image to the subroutine
	call draw_image

	movia r4,COUNTDOWN_PERIOD 			# delay amount
	movia r5,ADDR_TIMER 				# pass the timer address
	call delay

######
	# clear displays
	call clear_pixel_buffer

	movia r4,IMAGE_CountDown2 			# pass the image to the subroutine
	call draw_image

	movia r4,COUNTDOWN_PERIOD 			# delay amount
	movia r5,ADDR_TIMER 				# pass the timer address
	call delay

######
	# clear displays
	call clear_pixel_buffer

	movia r4,IMAGE_CountDown1 			# pass the image to the subroutine
	call draw_image

	movia r4,COUNTDOWN_PERIOD 			# delay amount
	movia r5,ADDR_TIMER 				# pass the timer address
	call delay

######
	# clear displays
	call clear_pixel_buffer

	movia r4,IMAGE_CountDownGO 			# pass the image to the subroutine
	call draw_image

######################
init_sensors:
	call reset_lego_controller 			# reset the lego controller

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
	call reset_lego_controller 			# reset the lego controller

   	movia r4, ADDR_TIMER           		# pass the address of the timer
	call stop_timer
	mov r19,r2 							# store the result returned from the subroutine

time_difference:
	movia r20,MAX_PERIOD 				# max period
	sub r21,r20,r19 					# MAX_PERIOD - current time

	movia r20,CYCLE_PER_SEC 			# cycle per 0.001 sec
 	divu r21,r21,r20 					# time (in 0.001 second) = time (in cycle) / cycle_per_sec

speed:
	movia r4,DISTANCE_BETWEEN_LIGHTSENSOR
	mov r5,r21
	call calculate_speed 				# calculate the speed
	mov r21,r2 							# retrieve the returned value (measured speed)
	movia r18,ACTUAL_SPEED
	stw r21,0(r18) 						# store the actual speed into the ram

	# display the measured speed on the 7seg
	mov r4,r21
	movia r5,ADDR_HEXDISPLAY54 			# display the actual speed
	call hexdisplay_7seg

check_over_speed:
	movia r20,SPEED_LIMIT 				# get the speed limit
	ldw r20,0(r20)
	bgeu r21,r20,overspeed
	br legalspeed

############################################################################
overspeed:
	movui r4,1 							# enable the audio
	call audio_control

	movia r18, ADDR_LED 				# get the led address
	movia r19,0xffffffff 				# turn on all leds
	stwio r19,0(r18) 					# push the value into leds

	# clear displays
	call clear_pixel_buffer
	call clear_character_buffer

	movia r4,IMAGE_SpeedNotOK 			# draw the image
	call draw_image

	# display the actual speed
	# create a temp string on stack
	addi sp,sp,-16						# allocate 16 bytes of memory to the string
	stw r0,12(sp)
	stw r0,8(sp)
	stw r0,4(sp)
	stw r0,0(sp)
	mov r5,sp
	movia r18,ACTUAL_SPEED 				# get the actual speed
	ldw r4,0(r18)
	call int_to_string 					# convert the integer to string

	mov r4,sp
	movui r5,28
	movui r6,10
	call draw_string 					# draw the actual speed on screen

	addi sp,sp,16 						# deallocate the memory for the temp string from the stack



	movia r4,ADDR_TIMER 				# pass the address of the timer
	movui r5,1 							# pull down the barrier gate
	call moveBarrierGate

	movia r18,AUDIO_SAMPLE_COUNTER 		# pointer to the audio sample counter
	movia r20,240000
loop_audio_playback: 	# 240000>counter, loop
	ldw r19,0(r18) 						# get the counter
	blt r19,r20,loop_audio_playback

	mov r4,r0 							# disable the audio
	call audio_control

	br final

###########################################################################
legalspeed:
	movia r18, ADDR_LED 				# get the led address
	movia r19,0x01 				        # turn on one led
	stwio r19,0(r18) 					# push the value into leds


	# clear displays
	call clear_pixel_buffer
	call clear_character_buffer

	movia r4,IMAGE_SpeedOK 				# draw the image
	call draw_image

	# display the actual speed
	# create a temp string on stack
	addi sp,sp,-16						# allocate 16 bytes of memory to the string
	stw r0,12(sp)
	stw r0,8(sp)
	stw r0,4(sp)
	stw r0,0(sp)
	mov r5,sp
	movia r18,ACTUAL_SPEED 				# get the actual speed
	ldw r4,0(r18)
	call int_to_string 					# convert the integer to string

	mov r4,sp
	movui r5,28
	movui r6,10
	call draw_string 					# draw the actual speed on screen

	addi sp,sp,16 						# deallocate the memory for the temp string from the stack


	br final

###########################################################################
final:
	movia r4,300000000 					# delay amount
	movia r5,ADDR_TIMER 				# pass the timer address
	call delay

#looop:	br looop 						########### DEBUGGING

	br init 							# loop the program
