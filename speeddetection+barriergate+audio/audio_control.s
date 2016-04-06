# Enables and disables the audio by turnning the interrupts of audio core on and off
#############################
# Input Argument
# r4: 0 - off; 1 - on
# Caller-saved
# r8: Audio Core address/ audio sample counter address
# r9: settings 
# r10: tmp
#############################

.section .text

.equ INTERUPT_ON_MASK,0x00000040 			# IRQ: 6. use or to mask on
.equ INTERUPT_OFF_MASK,0xFFFFFFBF 			# use and to cover off
.equ ADDR_AUDIO_CORE,0xFF203040

.global audio_control

audio_control:
	movia r8, AUDIO_SAMPLE_COUNTER
	stw r0,0(r8) 							# clear the audio sample counter

	movia r8,ADDR_AUDIO_CORE 				# get the address to the audio core
	beq r0,r4,off 							# if turn off the audio
	br on 

on:
	movia r9,0b0010  						# clear the write FIFOs and enables Write Interrupt
	stwio r9,0(r8) 							# store the setting

	rdctl r9,ctl3							# get the current iEnable list
	movia r10,INTERUPT_ON_MASK 				# mask on
	or r9,r9,r10
	wrctl ctl3,r9

	movia r9,1
	wrctl ctl0,r9 							# enable global interrupts

	br subroutine_end

off:
	rdctl r9,ctl3							# get the current iEnable list
	movia r10,INTERUPT_OFF_MASK 			# mask off
	and r9,r9,r10
	wrctl ctl3,r9
					
	stwio r0,0(r8) 							# disables Write Interrupt

	br subroutine_end

subroutine_end:
	ret
