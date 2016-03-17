#############################
# Return Value
# r2: value of the sensor
# Input Argument
# r4: GPIO address (JP1/JP2)
# r5: select touch sensor (0: #0/ 1: #1)

# Caller-saved
# r8 temporary
# r9 sensor setting masks (sensor0/sensor1)
# r10 sensor ready bit (sensor0/sensor1)
# r11 LEGO Controller setting
#############################
# Important
# uses sensor 0 and 1 for touch sensors, in value mode
# this subroutine modifies the sensor control bits


.section .text

.equ DIR_REG, 0x07f557ff
# .equ INIT_CTL, 0xffffffff			# set all things off

.equ SENSOR_OFF_MASK, 0x00055400	# use OR to turn all sensors off

.equ SENSOR0_ON_MASK, 0xFFFFFBFF	# use AND to turn sensor0 on
.equ SENSOR1_ON_MASK, 0xFFFFEFFF	# use AND to turn sensor1 on

# .equ SENSOR0_OFF_MASK, 0x00000400	# use OR to turn sensor0 off
# .equ SENSOR1_OFF_MASK, 0x00001000	# use OR to turn sensor1 off

	
.global getTouchSensorValue

getTouchSensorValue:
	# init
	movia r8,DIR_REG			# get the direction register setting
	stwio r8,4(r4)				# set the direction register
	movia r8,SENSOR_OFF_MASK 	# turn off all sensors
	ldwio r11,0(r4) 			# get the LEGO Controller settings
	or r11,r11,r8 				# mask off all sensors

	beq r5,r0,sensor0_check_init
	br sensor1_check_init
	# check whether to check sensor 0 or sensor 1

sensor0_check_init:
	movia r9,SENSOR0_ON_MASK
	movui r10,11
	br init_sensor

sensor1_check_init:
	movia r9,SENSOR1_ON_MASK
	movui r10,13
	br init_sensor

init_sensor:
	and r11,r11,r9 				# turn on corresponding sensor
	stwio r11,0(r4)

poll_sensor:
	ldwio r11,0(r4) 			# get the data register

	srl r8,r11,r10
	andi r8,r8,0x01 			# get the sensor ready bit
	bne r8,r0,poll_sensor 

retrieve_sensor_value:
	srli r8,r11,27
	andi r2,r8,0x0f

	ret
