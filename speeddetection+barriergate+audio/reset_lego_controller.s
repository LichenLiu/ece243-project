# Reset the LEGO control, disable all relavent interruptes
#############################
# Caller-saved
# r8: jp1 address
# r9: tmp
# r10: settings
#############################

.section .text

.equ ADDR_JP1,0xFF200060
.equ DIR_REG,0x07f557ff

.equ INTERRUPTE_MASK,0xFFFFF7FF 			# use and to close interrupte @ IRQ11

.global reset_lego_controller

reset_lego_controller:
	# disable interrupte for JP1
 	rdctl r10,ctl3							# get the current iEnable list
	movia r9,INTERRUPTE_MASK
	and r10,r10,r9 	 						# disable JP1 interrupt
	wrctl ctl3,r10

	movia r8,ADDR_JP1 						# store the jp1 address

 	movia r10,DIR_REG 						# set the direction registor
 	stwio r10,4(r8) 

turn_off_interrupt:
	movia r10,0xFFFFFFFF 					# clear the edge register
	stwio r10,12(r8)
			 				
	stwio r0,8(r8) 							# clear the interruptes for JP1

clear_setting:
 	movia r10,0xffffffff 					# turns everything off
	stwio r10,0(r8)

	ret
