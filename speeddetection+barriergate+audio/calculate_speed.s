# Input argument: distance in cm, time_cycle_difference in second
# Return: speed in cm/sec
# Note: all input arguments and returned value are of type int */

#############################
# Return
# r2: speed (cm/sec)
# Input Argument
# r4: distance
# r5: time_difference
# Caller-saved
# r8:
# r9:
# r10:
#############################

.section .text

.global calculate_speed

calculate_speed:
	beq r5,r0,div_by_zero
#	bgt r5,r0,div_by_pos

#div_by_neg:
#	sub r5,r0,r5 						# convert r5 back to positive if negative

#div_by_pos:
	divu r2,r4,r5 						# calculate the speed
	br end_func

div_by_zero: 							# guanrantee no divided by zero situation will occur
	mov r2,r0 							# result=0 if divided by zero
	br end_func

end_func:
	ret
	