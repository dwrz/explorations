# PURPOSE: Print "fizz" if a number is divisible by three.
# INPUT: None.
# OUTPUT:    Prints a string to stdout.
#           Returns a status code of 0.
# VARIABLES:
#           %rax holds the system call number
#           %rbx holds the return status
.section .data
fizz:
        .ascii "fizz\n"
buzz:
        .ascii "buzz\n"
fizzbuzz:
        .ascii "fizzbuzz\n"
number_string:
        .zero 4
print_case:
        # print_case tracks what should be printed for the current number.
        # 0: print the counter.
        # 1: print "fizz".
        # 2: print "buzz".
        # 3: print "fizzbuzz".
        .zero 1

.section .text
        .globl _start

_test_fizz:
        mov %rcx, %rax # Use the loop counter as the dividend.
        movq $3, %rbx # Use 3 as the divisor for "fizz" test.
        cdq # Convert double-word to quad-word, necessary for 32 and 64-bit division.
        div %rbx
        cmp $0, %rdx # Was the remainder 0?
        jne return_test_fizz
        add $1, print_case # Store the print case.
return_test_fizz:
        ret

_test_buzz:
        mov %rcx, %rax # Use the loop counter as the dividend.
        movq $5, %rbx # Use 3 as the divisor for "buzz" test.
        cdq # Convert double-word to quad-word, necessary for 32 and 64-bit division.
        div %rbx
        cmp $0, %rdx # Was the remainder 0?
        jne return_test_buzz
        add $2, print_case # Store the print case.
return_test_buzz:
        ret

_itoa:
        push %rbp
        mov %rsp, %rbp
        add $48, %rax
        mov %rax, number_string
        movl $10, number_string+1
        mov %rbp, %rsp
        pop %rbp
        ret

_print:
        push %rbp
        mov %rsp, %rbp

        # Print the buffer.
        mov $4, %rax             # System call number for write.
        mov $1, %rbx             # stdout.

        # Switch on the print_case:
        cmp $0, print_case
        je print_counter
        cmp $1, print_case
        je print_fizz
        cmp $2, print_case
        je print_buzz
        cmp $3, print_case
        je print_fizzbuzz

        # Set %rcx to hold the address of the buffer.
        # Set %rdx to hold the number of bytes to write.
print_counter:
        mov %rcx, %rax           # Store the loop counter in rax.
        call _itoa               # Convert the counter to ascii, store in buffer.
        mov $4, %rax             # Reset rax to hold the system call number for write.
        mov $number_string, %rcx
        mov $2, %rdx
        jmp print_and_return
print_fizz:
        mov $fizz, %rcx
        mov $5, %rdx
        jmp print_and_return
print_buzz:
        mov $buzz, %rcx
        mov $5, %rdx
        jmp print_and_return
print_fizzbuzz:
        mov $fizzbuzz, %rcx
        mov $8, %rdx
        jmp print_and_return
print_and_return:
        int $0x80 # Call the kernel.

        mov %rbp, %rsp
        pop %rbp
        ret

_exit_normal:
        mov $1, %rax # System call number for exit.
        mov $0, %rbx # Exit code.
        int $0x80    # Call the kernel.

_start:
        # Initialize the loop counter as 1.
        mov $1, %rcx

loop:
        # Determine the print case.
        call _test_fizz
        call _test_buzz

        # Save the loop counter on the stack.
        push %rcx

        call _print

        # Restore the loop counter, then increment it.
        pop %rcx
        inc %rcx

        # Reset the print case.
        movl $0, print_case

        # Have we iterated 15 times? If not, loop again.
        cmp $16, %rcx
        jl loop

call _exit_normal
