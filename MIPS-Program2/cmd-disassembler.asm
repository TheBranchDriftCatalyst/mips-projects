.data

inputfile:	.asciiz		"input.txt" # relative file

##### input.txt CONTENTS #######
# AD090018
# 01835025
# 08000010
# 00AF8020
# 03E00008
# 8D090018
# 34820258
# 0C000FDC
# 062000A
# 3062000A
# 11D60464
# 00AF8021
# FFFFFFFF
################################


readBuffer:		.word		0:250
writeBuffer:	.word		0:250

# this statements array will be used to hold the cleaned up read buffer.
# we want to remove all the extraneuos characters such as /n and /0 /r
# and convert the characters to binary.  Once this
# is done we will have each statement in binary in the statement array taking up one word of space
OBJCODE:		.word		0:100
OPERATION:	.word		0:100
INST_TYPE:	.word		0:100
REGISTERS:	.word		0:32 # 0 - 31, sequential order


# R-TYPE; I-TYPE; J-TYPE
NUM_TYPES:	.word		0:3
NUM_LEGAL:	.word		0:1
NUM_ILLEGAL:.word		0:1
TOTAL:			.word		0:1


# Strings for construction of output
add_ascii:	.asciiz		"add"
addi_ascii:	.asciiz		"addi"
or_ascii:		.asciiz		"or"
ori_ascii:	.asciiz 	"ori"
j_ascii:		.asciiz 	"j"
beq_ascii:	.asciiz		"beq"
lw_ascii:		.asciiz 	"lw"
sw_ascii:		.asciiz 	"sw"
jr_ascii:		.asciiz		"jr"
jal_ascii:	.asciiz 	"jal"
# Invalid ASCII Message
inv_ascii:	.asciiz		"Instruction not Recognized"


registers:		.asciiz 	"$0", "$1", "$2", "$3", "$4", "$5", "$6", "$7", "$8", "$9", "$10", "$11", "$12", "$13", "$14", "$15", "$16", "$17", "$18", "$19", "$20", "$21", "$22", "$23", "$24", "$25", "$26", "$27", "$28", "$29", "$30", "$31"
cntSection:		.asciiz		"\n----------------\n Instruction Counts\n----------------\n"
totalOut:			.asciiz		"Number of Instructions: "
legalOut:			.asciiz		"Number of legal instructions: "
illegalOut:		.asciiz		"Number of Unrecognizable instructions: "
frmtSection:	.asciiz		"----------------\n Instruction Formats\n----------------\n"
r_Out:				.asciiz		"Number of R-Format Instructions: "
i_Out:				.asciiz		"Number of I-Format Instructions: "
j_Out:				.asciiz		"Number of J-Format Instructions: "
analysisStr:	.asciiz		"\n******** Basic Code Analysis ********\n"
newLine:			.asciiz		"\n"
tabChar:			.asciiz		"\t"
commaChar:		.asciiz		", "


.text

# s0 is the input file descriptor
main:

 	##############################################
 	# OPEN OUTPUT FILE AND DUMP CONTENTS TO BUFFER

	# address of the variable containing source file name
	la	$a0, inputfile
	li	$a1, 0 # flag = 0 for read
	li	$a2, 0


	li	$v0, 13	# syscall code for open file mode = 0, doesn't matter, ignored anyway
	syscall
	move	$s0, $v0
	li	$a0, 0  # address of the variable containing source file name
	li	$a1, 0	# flag = 0 for read
	li	$a2, 0	# s0 = file descriptor


	# Read entire input file and insert into buffer
	li	$v0, 14 		# syscall code for read file
	move	$a0, $s0	# file descriptor
	# address of buffer in memory in which we want to store the content of source file
	la	$a1, readBuffer
	li	$a2, 1000   # maximum number of bytes to read
	syscall

	li	$v0, 16	    # syscall code for close file
	move	$a0, $s0	# file descriptor
	syscall
 	##############################################
 	# DONE READING FILE INTO THE BUFFER

	jal 	CONVERT
	jal 	DISASSEMBLE

	############# TEST OUTPUT #############

	la		$a0, cntSection  	# Load output message
	li		$v0, 4			# Load print string syscode 4 into register
	syscall					# System call to print welcome string

	la		$a0, totalOut  		# Load output message
	li		$v0, 4			# Load print string syscode 4 into register
	syscall

	lw		$a0, TOTAL  		# Load output message
	li		$v0, 1			# Load print string syscode 4 into register
	syscall

	la		$a0, newLine  		# Load output message
	li		$v0, 4			# Load print string syscode 4 into register
	syscall

	la		$a0, legalOut  		# Load output message
	li		$v0, 4			# Load print string syscode 4 into register
	syscall

	lw		$a0, NUM_LEGAL  		# Load output message
	li		$v0, 1			# Load print string syscode 4 into register
	syscall

	la		$a0, newLine  		# Load output message
	li		$v0, 4			# Load print string syscode 4 into register
	syscall

	la		$a0, illegalOut 	# Load output message
	li		$v0, 4			# Load print string syscode 4 into register
	syscall

	lw		$a0, NUM_ILLEGAL	# Load output message
	li		$v0, 1			# Load print string syscode 4 into register
	syscall

	la		$a0, newLine  		# Load output message
	li		$v0, 4			# Load print string syscode 4 into register
	syscall

	la		$a0, analysisStr 	# Load output message
	li		$v0, 4			# Load print string syscode 4 into register
	syscall

	la		$a0, frmtSection  	# Load output message
	li		$v0, 4			# Load print string syscode 4 into register
	syscall


	la		$a0, i_Out  	# Load output message
	li		$v0, 4			# Load print string syscode 4 into register
	syscall

	lw		$a0, NUM_TYPES+4	# Load output message
	li		$v0, 1			# Load print string syscode 4 into register
	syscall

	la		$a0, newLine  		# Load output message
	li		$v0, 4			# Load print string syscode 4 into register
	syscall

	la		$a0, r_Out  		# Load output message
	li		$v0, 4			# Load print string syscode 4 into register
	syscall

	lw		$a0, NUM_TYPES+0	# Load output message
	li		$v0, 1			# Load print string syscode 4 into register
	syscall

	la		$a0, newLine  		# Load output message
	li		$v0, 4			# Load print string syscode 4 into register
	syscall

	la		$a0, j_Out  		# Load output message
	li		$v0, 4			# Load print string syscode 4 into register
	syscall

	lw		$a0, NUM_TYPES+8	# Load output message
	li		$v0, 1			# Load print string syscode 4 into register
	syscall

	la		$a0, newLine  		# Load output message
	li		$v0, 4			# Load print string syscode 4 into register
	syscall
	############# END TEST OUTPUTS ############

	# end program

	li	$a0, 0
	li	$v0, 10
	syscall

#######################################
##############Functions################
#######################################

CONVERT:

	la	$t0, readBuffer
	la	$t6, OBJCODE
	li	$t1, 0  # \0 is what we are looking for and will exit the loop
	li	$t2, 13	# \r ignore goto next
	li	$t3, 10	# \n ignore goto next
	li	$t4, 0x41 # A
	li	$t5, 0x39 # 9
	li 	$t7, 28

	# Convert loop is here
	LOOP1:
		lbu $a0, ($t0)
		add	$t0, $t0, 1

		beq $a0, $t2, LOOP1		# current char = \r ignore and goto next
		beq	$a0, $t3, LOOP1 	# current char = \n ignore and goto next
		beq	$a0, $t1, L1_DONE 	# current char = \0 DONE

		# Character is a non delimiter now we need to verify if the
		# character is within the hex range 0-9 and A, B, C, D, E, F

		# branch to char loop if curchar is a character ABCDEF A = 41hex, F = 46hex
		bleu	$a0, $t5, digitLoop
		# branch to digit loop is curchar is a digit 0-9 0 = 30hex 9 = 39 hex
		bgeu 	$a0, $t4, charLoop

		charLoop:
			# Mask we apply to a ascii character in the ABCDEF range
			#to convert directly to hex equaivilant.
			add	$a0, $a0, 0xffffffc9
			j 	charDone

		digitLoop:
			# We might be able to use 0x0xffffffcf
			# mask we apply to ascii 0-9 digit to get raw hex value
			add	$a0, $a0, -0x30
			j 	charDone

	charDone:

		sllv 	$a0, $a0, $t7
		add 	$s1, $s1, $a0

		add 	$t7, $t7, -4
		blt 	$t7, 0, resetANDstore

		# our digit is now in a0 and its the raw hex value to the 0th degree.

		j 	LOOP1

		resetANDstore:
			sw	$s1, ($t6)
			addi 	$t6, $t6, 4
			li	$s1, 0
			li 	$t7, 28
			j	LOOP1

L1_DONE:
	li	$t0, 0
	li	$t6, 0
	li	$t1, 0
	li	$t2, 0
	li	$t3, 0
	li	$t4, 0
	li	$t5, 0
	li 	$t7, 0
 	jr 	$ra

########################################
########################################

# s1 = r count instructions
# s2 = i count instructions
# s3 = j count instructions
# s4 = illegal commands
# s0 = Current OBJCODE Array Address
# s5 = operation array which holds the corresponding operation mnemonic
# t0, full objcode of current instruction
# t1, opcode or funct code
DISASSEMBLE:

	# we are going to take one instruction at a time from the OBJCODE array
	# S0 will hold the address of the object code array
	la $s0, OBJCODE
	la $s5, OPERATION
	add $sp, $sp, -4
	sw $ra, 4($sp)
	li $s1, 0 # r type count
	li $s2, 0 # i type count
	li $s3, 0 # j type count
	li $s4, 0 # illegal instruction count

	DIS_LOOP1:

		lw $t0, ($s0)

		beq $t0, 0xFFFFFFFF, DIS_DONE # if the OBJCODE is 0xFFFFFFFF we are at the end of the array

		# Instruction is not end instruction so we, first we need to find the opcode
		# t0 holds the FULL OBJECT CODe

		srl $t1, $t0, 26
		#t1 now holds the OPCODE

		beq $t1, 0x00000000, R_TYPE
		bge $t1, 4, I_TYPE
		beq $t1, 0x2, J_TYPE
		beq $t1, 0x3, J_TYPE

		j INVALID_CODE

		R_TYPE:

			sll $t1, $t0, 26
			srl $t1, $t1, 26
			# t1 now holds the FUNCT CODE

			# we need to retrieve the rs, rd, rt registers from this and store them into t2, t3, t4
			# rs=t2 rt=t3 rd=t4

			# to get the rs register
			sll $t2, $t0, 6
			srl $t2, $t2, 27

			# to get the rt register
			sll $t3, $t0, 11
			srl $t3, $t3, 27

			# to get the rd register
			sll $t4, $t0, 16
			srl $t4, $t4, 27

			beq $t1, 0x20, add_Instruction
			beq $t1, 0x25, or_Instruction
			beq $t1, 0x08, jr_Instruction

			j INVALID_CODE

			add_Instruction:
				add $s1, $s1, 1		# update instruction count

				la		$a0, add_ascii		# Load output message
				li		$v0, 4			# Load print string syscode 4 into register
				syscall

				jal registerCount

				j NEXT_INSTRUCTION

			or_Instruction:
				add $s1, $s1, 1 	# update instruction count

				la		$a0, or_ascii	# Load output message
				li		$v0, 4		# Load print string syscode 4 into register
				syscall

				jal registerCount

				j NEXT_INSTRUCTION

			jr_Instruction:
				add $s1, $s1, 1		# update instruction count

				la		$a0, jr_ascii	# Load output message
				li		$v0, 4			# Load print string syscode 4 into register
				syscall

				la		$a0, tabChar 	# Load output message
				li		$v0, 4			# Load print string syscode 4 into register
				syscall


				move		$a0, $t2	# Load output message
				li		$v0, 1	        # Load print string syscode 4 into register
				syscall

				j NEXT_INSTRUCTION

		I_TYPE:

			beq $t1, 0x8, addi_Instruction
			beq $t1, 0xd, ori_Instruction
			beq $t1, 0x4, beq_Instruction
			beq $t1, 0x23, lw_Instruction
			beq $t1, 0x2b, sw_Instruction

			j INVALID_CODE


			addi_Instruction:
				add $s2, $s2, 1
				la		$a0, addi_ascii 	# Load output message
				li		$v0, 4			# Load print string syscode 4 into register
				syscall


				j NEXT_INSTRUCTION

			ori_Instruction:
				add $s2, $s2, 1

				la		$a0, ori_ascii 	# Load output message
				li		$v0, 4			# Load print string syscode 4 into register
				syscall


				j NEXT_INSTRUCTION

			beq_Instruction:
				add $s2, $s2, 1

				la		$a0, beq_ascii 	# Load output message
				li		$v0, 4			# Load print string syscode 4 into register
				syscall

				j NEXT_INSTRUCTION

			lw_Instruction:
				add $s2, $s2, 1
				la		$a0, lw_ascii 	# Load output message
				li		$v0, 4			# Load print string syscode 4 into register
				syscall


				j NEXT_INSTRUCTION

			sw_Instruction:
				add $s2, $s2, 1
				la		$a0, sw_ascii 	# Load output message
				li		$v0, 4			# Load print string syscode 4 into register
				syscall


				j NEXT_INSTRUCTION
		J_TYPE:

			beq $t1, 0x2, j_Instruction
			beq $t1, 0x3, jal_Instruction

			j INVALID_CODE

			j_Instruction:
				add $s3, $s3, 1

				la		$a0, j_ascii 	# Load output message
				li		$v0, 4		# Load print string syscode 4 into register
				syscall


				j NEXT_INSTRUCTION

			jal_Instruction:
				add $s3, $s3, 1

				la		$a0, jal_ascii 	# Load output message
				li		$v0, 4			# Load print string syscode 4 into register
				syscall


				j NEXT_INSTRUCTION

	NEXT_INSTRUCTION:

		add 	$s0, $s0, 4 # INCREMENT TO THE NEXT OBJCODE INSTRUCTION

		la	$a0, newLine 	# Load output message
		li	$v0, 4			# Load print string syscode 4 into register
		syscall


		j	DIS_LOOP1

	INVALID_CODE:
		addi 	$s4, $s4, 1
		# la	$a0, invalid_ascii 	# Load output message
		# li	$v0, 4			# Load print string syscode 4 into register
		# syscall


		j 	NEXT_INSTRUCTION

DIS_DONE:

	sw 	$s1, NUM_TYPES
	sw 	$s2, NUM_TYPES+4
	sw 	$s3, NUM_TYPES+8
	sw 	$s4, NUM_ILLEGAL

	add 	$s1, $s1, $s2
	add 	$s1, $s1, $s3

	sw 	$s1, NUM_LEGAL

	add $s1, $s1, $s4
	sw 	$s1, TOTAL

	lw $ra, 4($sp)
	add $sp, $sp, 4
	jr $ra

########## FUNCTION TO COUNT REGISTERS ###############

# t2 = r2, t3 = rt, t4 = rd
registerCount:

	jr $ra
