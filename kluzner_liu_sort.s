##############################################################################
	# File: sort.s
	# Skeleton for ECE 154A
	##############################################################################

	.data
student:
	.asciiz "Benjamin Liu, Daniel Kluzner:\n" 	# Place your name in the quotations in place of Student
	.globl	student
nl:		.asciiz "\n"
	.globl nl
sort_print:
	.asciiz "[Info] Sorted values\n"
	.globl sort_print
initial_print:
	.asciiz "[Info] Initial values\n"
	.globl initial_print
read_msg:
	.asciiz "[Info] Reading input data\n"
	.globl read_msg
code_start_msg:
	.asciiz "[Info] Entering your section of code\n"
	.globl code_start_msg

key:		.word 268632064			# Provide the base address of array where input key is stored(Assuming 0x10030000 as base address)
output:		.word 268632144			# Provide the base address of array where sorted output will be stored (Assuming 0x10030050 as base address)
numkeys:		.word 6				# Provide the number of inputs
maxnumber:		.word 10			# Provide the maximum key value


	## Specify your input data-set in any order you like. I'll change the data set to verify
data1:		.word 8
data2:		.word 2
data3:		.word 10
data4:		.word 5
data5:		.word 6
data6:		.word 1

	.text

	.globl main
main:						# main has to be a global label
	addi	$sp, $sp, -4		# Move the stack pointer
	sw 	$ra, 0($sp)		# save the return address

	li	$v0, 4			# print_str (system call 4)
	la	$a0, student		# takes the address of string as an argument
	syscall

	jal process_arguments
	jal read_data			# Read the input data

	j	ready

process_arguments:

	la	$t0, key
	lw	$a0, 0($t0)
	la	$t0, output
	lw	$a1, 0($t0)
	la	$t0, numkeys
	lw	$a2, 0($t0)
	la	$t0, maxnumber
	lw	$a3, 0($t0)
	jr	$ra

	### This instructions will make sure you read the data correctly
read_data:
	move $t1, $a0
	li $v0, 4
	la $a0, read_msg
	syscall
	move $a0, $t1

	la $t0, data1
	lw $t4, 0($t0)
	sw $t4, 0($a0)
	la $t0, data2
	lw $t4, 0($t0)
	sw $t4, 4($a0)
	la $t0, data3
	lw $t4, 0($t0)
	sw $t4, 8($a0)
	la $t0, data4
	lw $t4, 0($t0)
	sw $t4, 12($a0)
	la $t0, data5
	lw $t4, 0($t0)
	sw $t4, 16($a0)
	la $t0, data6
	lw $t4, 0($t0)
	sw $t4, 20($a0)

	jr	$ra


counting_sort:
	#########################

    # a0 = key
    # a1 = output
    # a2 = numkeys
    # a3 = maxnumber
    # t0 = n
    # t9 = count*

# Set base address of count array
lui $t9, 0x1000
ori $t9, $t9, 0x7000

# for loop 1
add $t0, $0, $0
loop1:
    slt $t2, $a3, $t0
    bne $t2, $0, done1

    # t1 = (4*n)
    sll $t1,$t0,2
    # t1 = (4*n) + base address
    add $t1,$t1,$t9
    # store 0 into the new base address
    sw $0,0($t1)

    # increment n
    addi $t0, $t0, 1
    j loop1
done1:


# for loop 2
add $t0, $0, $0
loop2:
    slt $t2, $t0, $a2
    beq $t2, $0, done2

    # t1 = (4*n)
    sll $t1, $t0, 2
    # t1 = (4*n) + base address of keys
    add $t1, $t1, $a0
    # t3 = keys[n]
    lw $t3, 0($t1)

    # t1 = (4 * keys[n])
    sll $t1, $t3, 2
    # t1 = (4 * keys[n]) + count base address
    add $t1, $t1, $t9

    # t3 = count[keys[n]]
    lw $t3, 0($t1)
    # t3++
    addi $t3, $t3, 1
    # store t3 in same address
    sw $t3, 0($t1);

    addi $t0, $t0, 1
    j loop2
done2:

# for loop 3
addi $t0, $0, 1
loop3:
    slt $t2, $a3, $t0
    bne $t2, $0, done3

    # t1 = (4*n)
    sll $t1,$t0,2
    # t1 = (4*n) + base address
    add $t1,$t1,$t9
    
    # load count[n] into t4
    lw $t4,0($t1)
    # load count[n-1] into t5
    lw $t5,-4($t1)
    # t6 = count[n] + count[n-1]
    add $t6,$t4,$t5
    # store count[n] + count[n-1] into memory
    sw,$t6,0($t1)

    addi $t0, $t0, 1
    j loop3
done3:

# for loop 4
add $t0, $0, $0
loop4:
    slt $t2, $t0, $a2
    beq $t2, $0, done4

    # t1 = (4*n)
    sll $t1, $t0, 2
    # t1 = (4*n) + base address of keys
    add $t1, $t1, $a0

    # t3 = keys[n]
    lw $t3, 0($t1)
    # save for later
    add $t5, $t3, $0

    # t3 = keys[n] * 4
    sll $t3, $t3, 2
    # t1 = t3 + count base address
    add $t1, $t3, $t9
    # save for later
    add $t7, $t1, $0

    # t3 = count[keys[n]]
    lw $t3, 0($t1)
    # save for later
    add $t6, $t3, $0

    # s2 = s2 - 1
    addi $t3, $t3, -1
    # t1 = (4*t3)
    sll $t1, $t3, 2
    # t1 + output base address
    add $t1, $t1, $a1
    # output = keys[n]
    sw $t5, 0($t1)
    # count[keys[n]]--
    addi $t6, $t6, -1
    sw $t6, 0($t7)


    addi $t0, $t0, 1
    j loop4
done4:
    


	#########################


	#########################
	jr $ra
	#########################


	##################################
	#Dont modify code below this line
	##################################
ready:
	jal	initial_values		# print operands to the console

	move 	$t2, $a0
	li 	$v0, 4
	la 	$a0, code_start_msg
	syscall
	move 	$a0, $t2

	jal	counting_sort		# call counting sort algorithm

	jal	sorted_list_print


				# Usual stuff at the end of the main
	lw	$ra, 0($sp)		# restore the return address
	addi	$sp, $sp, 4
	jr	$ra			# return to the main program

print_results:
	add $t0, $0, $a2 # No of elements in the list
	add $t1, $0, $a0 # Base address of the array
	move $t2, $a0    # Save a0, which contains base address of the array

loop:
	beq $t0, $0, end_print
	addi, $t0, $t0, -1
	lw $t3, 0($t1)

	li $v0, 1
	move $a0, $t3
	syscall

	li $v0, 4
	la $a0, nl
	syscall

	addi $t1, $t1, 4
	j loop
end_print:
	move $a0, $t2
	jr $ra

initial_values:
	move $t2, $a0
	        addi	$sp, $sp, -4		# Move the stack pointer
	sw 	$ra, 0($sp)		# save the return address

	li $v0,4
	la $a0,initial_print
	syscall

	move $a0, $t2
	jal print_results

	lw	$ra, 0($sp)		# restore the return address
	addi	$sp, $sp, 4

	jr $ra

sorted_list_print:
	move $t2, $a0
	addi	$sp, $sp, -4		# Move the stack pointer
	sw 	$ra, 0($sp)		# save the return address

	li $v0,4
	la $a0,sort_print
	syscall

	move $a0, $t2

	#swap a0,a1
	move $t2, $a0
	move $a0, $a1
	move $a1, $t2

	jal print_results

	    #swap back a1,a0
	move $t2, $a0
	move $a0, $a1
	move $a1, $t2

	lw	$ra, 0($sp)		# restore the return address
	addi	$sp, $sp, 4
	jr $ra
