# Input argument: distance in m, time_cycle_difference in second
# Return: speed in m/sec
# Note: all input arguments and returned value are of type int */

#############################
# Return
# r2: speed (m/sec)
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
	div r2,r4,r5 						# calculate the speed
	ret
	