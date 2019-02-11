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

_print_counter:
        push %rbp
        mov %rsp, %rbp
        mov %rcx, %rax           # Store the loop counter in rax.
        call _itoa               # Convert the counter to ascii, store in buffer.

        # Print the buffer.
        mov $4, %rax             # System call number for write.
        mov $1, %rbx             # stdout.
        mov $number_string, %rcx # Address of the buffer.
        mov $2, %rdx             # Number of bytes to write.
        int $0x80                # Call the kernel.

        mov %rbp, %rsp
        pop %rbp
        ret

_print_fizz:
        push %rbp
        mov %rsp, %rbp

        mov $4, %rax    # System call number for write.
        mov $1, %rbx    # stdout.
        mov $fizz, %rcx # Address of the buffer.
        mov $4, %rdx    # Number of bytes to write.
        int $0x80       # Call the kernel.

        mov %rbp, %rsp
        pop %rbp
        ret

_print_buzz:
        push %rbp
        mov %rsp, %rbp

        mov $4, %rax    # System call number for write.
        mov $1, %rbx    # stdout.
        mov $buzz, %rcx # Address of the buffer.
        mov $4, %rdx    # Number of bytes to write.
        int $0x80       # Call the kernel.

        mov %rbp, %rsp
        pop %rbp
        ret

_print_fizzbuzz:
        push %rbp
        mov %rsp, %rbp

        mov $4, %rax    # System call number for write.
        mov $1, %rbx    # stdout.
        mov $fizzbuzz, %rcx # Address of the buffer.
        mov $8, %rdx    # Number of bytes to write.
        int $0x80       # Call the kernel.

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

        # If the print case is 0, print the counter.
        cmp $0, print_case
        je print_counter
        # If the print case is 1, print fizz.
        cmp $1, print_case
        je print_fizz
        # If the print case is 2, print buzz.
        cmp $2, print_case
        je print_buzz
        # If the print case is 3, print fizzbuzz.
        cmp $3, print_case
        je print_fizzbuzz

print_counter:
        call _print_counter
        jmp continue
print_fizz:
        call _print_fizz
        jmp continue
print_buzz:
        call _print_buzz
        jmp continue
print_fizzbuzz:
        call _print_fizzbuzz
        jmp continue
continue:
        # Restore the loop counter, then increment it.
        pop %rcx
        inc %rcx
        # Reset the print case.
        movl $0, print_case
        # Have we iterated 5 times? If not, loop again.
        cmp $6, %rcx
        jl loop

call _exit_normal
