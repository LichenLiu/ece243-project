#############################
# r8: ipending/address/audio sample counter
# r9: masked ipending/value
# r10: tmp
# r11: tmp
#############################
.equ ADDR_JP1_IRQ,0x0800 					# IRQ: 11
.equ ADDR_JP1,0xFF200060

.equ ADDR_AUDIO_CORE_IRQ,0x00000040 		# IRQ: 6
.equ ADDR_AUDIO_CORE,0xFF203040

.equ SENSOR2_STATE_BIT,0x20000000 			# bit 29
.equ SENSOR3_STATE_BIT,0x40000000  			# bit 30

.equ AUDIO_AMPLITUDE_POSITIVE,  0x00e0000
.equ AUDIO_AMPLITUDE_NEGATIVE,  -0x00e0000

#.equ ADDR_TIMER,0xFF202000
# .equ TIMER_CTRL,0b0101					# timer without cont

.section .exceptions, "ax"

IHandler:
	# PROLOGUE
	addi sp,sp,-16							# allocate the stack
	stw r11,12(sp) 							# save the register
	stw r10,8(sp)							
	stw r9,4(sp)
	stw r8,0(sp)

	rdctl r8,ctl4							# read the ipending control register
	

	#andi r9,r8,0x01						# check whether the source of interrupt is timer
	#bne r0,r9,TimerServerRoutine			# if timer is causing the interrupt,
											# go to timer routine

	andi r9,r8,ADDR_AUDIO_CORE_IRQ 			# check whether the source of interrupt is from the audio core
	bne r0,r9,AUDIOCORERoutine

	andi r9,r8,ADDR_JP1_IRQ 				# check whether the source of interrupt is JP1
	bne r0,r9,LEGOCTLRoutine				# if JP1 is causing the interrupt,
											# go to JP1 (lego control) routine

	br EPILOGUE

#############################################################################

AUDIOCORERoutine:
	movia r8,AUDIO_SAMPLE_COUNTER 			# get the value inside the audio sample counter
	ldw r8,0(r8) 
	
	# 240000<=counter, return
	movia r10,240000
	bge r8,r10,EPILOGUE

	# 48000<=counter<96000, goto zero
	movia r11,48000
	cmpgeu r10,r8,r11
	movia r11,96000
	cmpltu r9,r8,r11
	and r10,r9,r10
	bne r0,r10,AudioSampleZero

	# 144000<=counter<192000, goto zero
	movia r11,144000
	cmpgeu r10,r8,r11
	movia r11,192000
	cmpltu r9,r8,r11
	and r10,r9,r10
	bne r0,r10,AudioSampleZero

	# counter mod 48
	movui r11,48
	divu r9, r8, r11
	mul r10, r9, r11
	sub r10, r8, r10 # r10=remainder

	# if remainder < 24, goto positive
	# else (remainder >=24), goto negative
	movui r9,24
	bltu r10,r9,AudioSamplePositive
	br AudioSampleNegative

AudioSamplePositive:
	movia r10, AUDIO_AMPLITUDE_POSITIVE
	br AudioSampleSendFIFO

AudioSampleNegative:
	movia r10, AUDIO_AMPLITUDE_NEGATIVE
	br AudioSampleSendFIFO

AudioSampleZero:
	mov r10, r0
	br AudioSampleSendFIFO

AudioSampleSendFIFO:
	movia r8,ADDR_AUDIO_CORE
	stwio r10,8(r8) 						# write to the LINEOUT FIFO left
	stwio r10,12(r8) 						# write to the LINEOUT FIFO right

	movia r8,AUDIO_SAMPLE_COUNTER 			# get the value inside the audio sample counter
	ldw r9,0(r8) 
	addi r9,r9,1 							# increment by 1
	stw r9, 0(r8) 							# store the value

	br EPILOGUE

#############################################################################

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


#############################################################################

EPILOGUE:
	ldw r11,12(sp) 						# restore the register
	ldw r10,8(sp)						
	ldw r9,4(sp)
	ldw r8,0(sp)
	addi sp,sp,16						# deallocate the stack

	subi ea,ea,4						# execute the aborted instruction
	eret
	