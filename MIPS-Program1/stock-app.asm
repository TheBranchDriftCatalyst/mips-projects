.data

stocks: 	.word 		0:20
price:		.word 		0:20

nameBuffer:	.word		1
priceBuffer:	.word		1

welString: 	.asciiz 	"Welcome!\nEnter how many stocks you have: "
enterString: 	.asciiz 	"Enter the four digit NASQDAQ Abbreviation and Price for Each Stock\n: "
buyString:	.asciiz		"How Many Stocks Would You Like to Buy: \n"
sellString:	.asciiz		"How Many Stocks Would You Like To Sell: \n"
entered_1:	.asciiz		"You have entered "
entered_2:	.asciiz		" stock abbreviations and prices\n"
error1String:	.asciiz		"You entered more stocks to buy than you have! Retry!\n"
error2String:	.asciiz		"You entered more stocks to sell than you have! Retry!\n"
portfolio:	.asciiz		"Your portfolio includes: \n"
newLine:	.asciiz 	"\n"
space:		.asciiz		" "


.text

main:
	la		$a0, welString  	# Load output message
	li		$v0, 4			# Load print string syscode 4 into register
	syscall					# System call to print welcome string

	li		$v0, 5 			# Load syscode for user int input
	syscall
	move 		$s0, $v0		# User input is now stored in $s0

						### s0 will now be used to store the loop conditional
	li 		$t0, 0			### t0 will be our loop counter

	la		$s1, stocks		### s1 holds the start of the stock list array
	la		$s2, price		### s2 holds the list of the stock price array

	la		$a0, enterString 	# Load output message
	li		$v0, 4			# print code into v0
	syscall

	li 		$a1, 6			# number of bytes to read
INLOOP:
	beq 		$s0, $t0, INDONE

	move 		$a0, $s1 		# $s1 = address of names space
	li 		$v0, 8 			# read a string
	syscall

	li		$v0, 5 			# Load syscode for user int input
	syscall
	sw 		$v0, ($s2)

	addi		$s2, $s2, 4		# Increment stock name memory location
	addi 		$s1, $s1, 4		# Increment stock price memory location
	addi		$t0, $t0, 1		# Increment loop conditional
	j		INLOOP
INDONE:
	# Input is now done so we can sort
	jal 		Buble_Sort

	la		$a0, entered_1  	# Load output message
	li		$v0, 4			# Load print string syscode 4 into register
	syscall					# System call to print string

	add		$a0, $zero, $s0
	li		$v0, 1
	syscall

	la		$a0, entered_2  	# Load output message
	li		$v0, 4			# Load print string syscode 4 into register
	syscall					# System call to print string
	j		buyIn
Error1:
	la		$a0, error1String  	# Load output message
	li		$v0, 4			# Load print string syscode 4 into register
	syscall

buyIn:
	la		$a0, buyString  	# Load output message
	li		$v0, 4			# Load print string syscode 4 into register
	syscall					# System call to print string

	li		$v0, 5 			# Load syscode for user int input
	syscall
	move 		$s4, $v0		# s4 = ammount to buy

	bgt 		$s4, $s0, Error1
	j		sellIn
Error2:
	la		$a0, error2String  	# Load output message
	li		$v0, 4			# Load print string syscode 4 into register
	syscall

sellIn:
	la		$a0, sellString  	# Load output message
	li		$v0, 4			# Load print string syscode 4 into register
	syscall					# System call to print string

	li		$v0, 5 			# Load syscode for user int input
	syscall
	move 		$s5, $v0		# s5 = ammount to sell

	bgt 		$s5, $s0, Error2

buySellEnd:

	# Reinitialize array pointers
	la		$s1, stocks		### s1 holds the start of the stock list array
	la		$s2, price		### s2 holds the list of the stock price array

	li		$t0, 0			# Initialize loop counter to 0


	# Printed "Your Portfolio Contains: \n"
	la		$a0, portfolio  	# Load output message
	li		$v0, 4			# Load print string syscode 4 into register
	syscall					# System call to print string
print:
	beq 		$s0, $t0, printDone

	# Print names[i]

	lw  	 	$a0, ($s2)
	li		$v0, 1
	syscall

	# Having trouble here becuase mips syscall code 4 requires a NULL TERMINATED
	# string.  when inputing them into the array i create a non null terminated string.
	#  I'm going to have to send these to a buffer that has one word 4 chars and another word with just null
	# two words <abreviation> <null + newline>
	lw		$a0, ($s1)
	li		$v0, 4
	syscall

	la		$a0, newLine
	li		$v0, 4
	syscall


	addi		$s2, $s2, 4		# Increment stock name memory location
	addi 		$s1, $s1, 4
	add		$t0, $t0, 1
	j		print

printDone:

	# End program
	li 		$v0, 10
	syscall

###########################################
############# PROCEDURE CALLS #############
###########################################

########### BEGIN BUBBLE SORT #############

# We are wanting to manipulate memory directly
# therefore it is unecessary to pass the values as a0 and a1.
Buble_Sort:
	li 		$t0, 1		   	# t0 = 1, this is our counter
OuterSort:

	# We want to reintialize the array values because when we filled the arrays
	# we changed the pointers to do so
        la   		$s2, price         	# reintialize our pointer to the price array
        la   		$s1, stocks             # reintialize our pointer to the stock names array

        move 		$t1, $t0
        beq  		$s0, $t0, return        # if t0 = length of array then we exit
        addi 		$t0, $t0,1              # it t0 != length of array increment array by one and go to innersort loop
InnerSort:
	beq  		$t1, $s0, OuterSort     # jump to outerloop

        lw   		$t6,0($s2)              # t6 = value[i]
        lw   		$t5,4($s2)              # t5 = value[i+1]
        bgt  		$t6, $t5 swap           # if (temp1 > temp2) then-> jump to swap values; else continue and increment to next values to compare

        # Increment Memory and Counters
        addi 		$s2,$s2, 4              # increment the memory pointer by one word for price array
        addi 		$s1,$s1, 4              # increment the memory pointer by one word for names array
        addi 		$t1, $t1, 1             # increment counter by 1, counter++
        j    		InnerSort
swap:
        sw   		$t6 , 4($s2)            # t6 = price[i+1]
        sw   		$t5,  0($s2)            # t5 = price[i]
        addi 		$s2,$s2,4               # increment the memory pointer by one word for price array
        #Perform actual swap precodude
	lw  		$t6, 0($s1)             # t6 = name[i]
	lw  	 	$t7, 4($s1)             # t7 = name[i + 1]
	sw  	 	$t7 ,0($s1)             # name[j] = temp2
	sw  	 	$t6, 4($s1)             # name[j+1] = temp

	#Increment Memory and Counters
	addi		$s1,$s1,4               # increment counter++
	addi		$t1, $t1, 1             # increment counter++
	j   		InnerSort
return:
	jr 		$ra			# Return to caller

########### END BUBBLE SORT ##############
