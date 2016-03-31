#############################
# r8: ipending/address/other
# r9: masked ipending/value
# r10: tmp
#############################
.equ ADDR_JP1_IRQ,0x0800 					# IRQ: 11
.equ ADDR_JP1,0xFF200060

.equ SENSOR2_STATE_BIT,0x20000000 			# bit 29
.equ SENSOR3_STATE_BIT,0x40000000  			# bit 30

#.equ ADDR_TIMER,0xFF202000
# .equ TIMER_CTRL,0b0101					# timer without cont

.section .exceptions, "ax"

IHandler:
	# PROLOGUE
	addi sp,sp,-12							# allocate the stack
	stw r10,8(sp)							# save the register
	stw r9,4(sp)
	stw r8,0(sp)

	rdctl r8,ctl4							# read the ipending control register
	

	#andi r9,r8,0x01						# check whether the source of interrupt is timer
	#bne r0,r9,TimerServerRoutine			# if timer is causing the interrupt,
											# go to timer routine


	andi r9,r8,ADDR_JP1_IRQ 				# check whether the source of interrupt is JP1
	bne r0,r9,LEGOCTLRoutine				# if JP1 is causing the interrupt,
											# go to JP1 (lego control) routine

	br EPILOGUE


LEGOCTLRoutine:
	movia r8,ADDR_JP1
	ldwio r9,12(r8) 						# load the edge capture register
	
	movia r10,0xFFFFFFFF
	stwio r10,12(r8) 						# Clear the Edge Capture Register 

	movia r10,SENSOR2_STATE_BIT 			# check whether sensor 2 (light sensor1)
    and r10,r10,r9 							# causes the interrupt
    bne r0,r10,Sensor2ServiceRoutine

    movia r10,SENSOR3_STATE_BIT 			# check whether sensor 3 (light sensor2)
    and r10,r10,r9 							# causes the interrupt
    bne r0,r10,Sensor3ServiceRoutine

	br EPILOGUE


Sensor2ServiceRoutine: # first light sensor to pass
	# need to check passed_first_sensor
	movia r8, PASSED_FIRST_SENSOR 			# look up the state
	ldw r9,0(r8)
	bne r0,r9,EPILOGUE 						# exit if passed_first_sensor is true
	#bne r0,r9,Sensor3ServiceRoutine 		# exit if passed_first_sensor is true

	# need to check passed_second_sensor
	movia r8, PASSED_SECOND_SENSOR 			# look up the state
	ldw r9,0(r8)
	bne r0,r9,EPILOGUE 						# exit if passed_second_sensor is true
	#bne r0,r9,Sensor3ServiceRoutine 		# exit if passed_second_sensor is true

	# start the timer
	movia r8, PASSED_FIRST_SENSOR 			# change the state
	movia r9,1 								# set passed_first_sensor to true
	stw r9,0(r8)
	br EPILOGUE
	
Sensor3ServiceRoutine: # second light sensor to pass
	# need to check passed_first_sensor first
	movia r8, PASSED_FIRST_SENSOR 			# look up the state
	ldw r9,0(r8)
	beq r0,r9,EPILOGUE 						# exit if passed_first_sensor is false
	
	# need to check passed_second_sensor
	movia r8, PASSED_SECOND_SENSOR 			# look up the state
	ldw r9,0(r8)
	bne r0,r9,EPILOGUE 						# exit if passed_second_sensor is true

	# stop the timer
	movia r8, PASSED_SECOND_SENSOR 			# change the state
	movia r9,1 								# set passed_second_sensor to true
	stw r9,0(r8)
	br EPILOGUE
	

#TimerServerRoutine:
#	movia r8,ISTIMEOUT					# get the address of the timeout flag
#	movui r9, 0x01						# set the timeout flag to true
#	stb r9,0(r8)

#	movia r8,ADDR_TIMER					# get the address of timer
#	stwio r0,0(r8)						# clear the status register (acknowledge)
#	movui r9,TIMER_CTRL					# start the timer without cont
#	stwio r9,4(r8)

#	br EPILOGUE



#	movia r8,ADDR_JTAG_UART_2			# get the address of JTAG UART
#	ldwio r9,0(r8)						# acknowledge and read the data
#	andi r9,r9,0x0ff					# mask other bits

#	movui r8,CHAR_S						# check whether the input is 's'
#	beq r8,r9,JTAGUART_INPUT_VALID

#	movui r8,CHAR_R						# check whether the input is 'r'
#	beq r8,r9,JTAGUART_INPUT_VALID

#	br EPILOGUE							# do nothing if the input is invlid


#JTAGUART_INPUT_VALID:
#	movia r8,TYPE 						# get the address of TYPE
#	stb r9,0(r8)						# store the value read

#	br EPILOGUE


EPILOGUE:
	ldw r10,8(sp)						# restore the register
	ldw r9,4(sp)
	ldw r8,0(sp)
	addi sp,sp,12						# deallocate the stack

	subi ea,ea,4						# execute the aborted instruction
	eret
	