# Set the threshold for light sensor, and then switch the lego controller to statemode
# Light Sensor:
# first one: sensor #2
# second one: sensor #3
#############################
# Caller-saved
# r8: jp1 address
# r9: threshold value
# r10: settings
#############################

.section .text

.equ ADDR_JP1_IRQ,0x0800 					# IRQ: 11
.equ ADDR_JP1,0xFF200060
.equ DIR_REG,0x07f557ff

.equ LIGHT_THRESHOLD,0x0c					# Light sensor THRESHOLD VALUE (TBD)
.equ LIGHTSENSOR1_SET_THRESHOLD,0xF83FBFFF	# Light sensor 1 (sensor#2) template
.equ LIGHTSENSOR2_SET_THRESHOLD,0xF83EFFFF	# Light sensor 2 (sensor#3) template
.equ DISABLE_ALL_VALUE,0xF87FFFFF 			# Disable all sensor with load to off, value mode
.equ DISABLE_ALL_STATE,0xF85FFFFF 			# Disable all sensor with load to off, state mode
.equ INTERRUPT_MASk, 0x60000000 			# Enable sensor2 and sensor3 for interrupt

.global set_sensor_statemode

set_sensor_statemode:
	movia r8,ADDR_JP1 						# store the jp1 address
 	movui r9,LIGHT_THRESHOLD 				# store the threshold value for light sensor
 	slli r9,r9,23 							# shift the threshold bits to appropriate positions

 	movia r10,DIR_REG 						# set the direction registor
 	stwio r10,4(r8) 

set_lightsensor1: # sensor#2
	movia r10,LIGHTSENSOR1_SET_THRESHOLD   	# set the threshold for lightsensor1
	or r10,r10,r9
	stwio r10,0(r8)
	
	movia r10,DISABLE_ALL_VALUE 			# tell the controller the threshold has been loaded
	or r10,r10,r9
	stwio r10,0(r8)

set_lightsensor2: # sensor#3
	movia r10,LIGHTSENSOR2_SET_THRESHOLD 	# set the threshold for lightsensor2
	or r10,r10,r9
	stwio r10,0(r8)

	movia r10,DISABLE_ALL_VALUE 			# tell the controller the threshold has been loaded
	or r10,r10,r9
	stwio r10,0(r8)

switch_state_mode:
	movia r10,DISABLE_ALL_STATE 			# set the mode to state mode
	stwio r10,0(r8)

turn_on_interrupt:
	movia r10,0xFFFFFFFF 					# clear the edge register
	stwio r10,12(r8)

	movia r10,INTERRUPT_MASk 				# set the interrupt mask
	stwio r10,8(r8)

	rdctl r10,ctl3							# get the current iEnable list
	ori r10,r10,ADDR_JP1_IRQ 				# enable JP1 interrupt
	wrctl ctl3,r10

	movia r10,1
	wrctl ctl0,r10 							# enable global interrupts

	ret
