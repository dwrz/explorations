# PURPOSE:
        # Loop from numbers 1 to 100.
        # Print "fizz" if a number is divisible by 3.
        # Print "buzz" if a number is divisible by 5.
        # Print "fizzbuzz" if a number is divisible by 3 and 5.
        # Print the number in all other cases.
# INPUT: None.
# OUTPUT:
        # Print newline separated strings to stdout.
        # Return a status code of 0.
# VARIABLES:
.section .data
fizz:
        .ascii "fizz\n"
buzz:
        .ascii "buzz\n"
fizzbuzz:
        .ascii "fizzbuzz\n"
number_string: # Used to store the ascii representation of a number.
        .zero 5
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
        movq $3, %rbx  # Use 3 as the divisor for "fizz" test.
        cdq # Convert double-word to quad-word, necessary for 32 and 64-bit division.
        div %rbx
        cmp $0, %rdx         # Was the remainder 0?
        jne return_test_fizz # If not, return early.
        add $1, print_case   # Otherwise, increment the print case.
return_test_fizz:
        ret

_test_buzz:
        mov %rcx, %rax # Use the loop counter as the dividend.
        movq $5, %rbx  # Use 5 as the divisor for "buzz" test.
        cdq # Convert double-word to quad-word, necessary for 32 and 64-bit division.
        div %rbx
        cmp $0, %rdx         # Was the remainder 0?
        jne return_test_buzz # If not, return early.
        add $2, print_case   # Otherwise, increment the print case.
return_test_buzz:
        ret

_itoa: # Expects an integer at %rax.
        push %rbp
        mov %rsp, %rbp

        # We use %rcx to keep track of how many digits we have processed.
        # We need this to know when to stop popping off the stack.
        mov $0, %rcx

        # We divide by ten, then use the remainder to get the digit.
        movq $10, %rbx
        cdq # Convert double-word to quad-word, necessary for 32 and 64-bit division.

conversion_loop:
        inc %rcx
        mov $0, %rdx # Reset rdx.
        div %rbx
        add $48, %rdx
        push %rdx
        cmp $0, %rax
        jne conversion_loop

        lea number_string, %rdx

save_to_buffer_loop:
        pop %rax
        movb %al, (%rdx)
        dec %rcx
        inc %rdx
        cmp $0, %rcx
        jne save_to_buffer_loop

        movb $10, number_string + 3
        mov %rbp, %rsp
        pop %rbp
        ret

_print:
        push %rbp
        mov %rsp, %rbp

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

        mov $1, %rbx             # stdout.
        mov $4, %rax             # Reset rax to hold the system call number for write.
        mov $number_string, %rcx
        mov $5, %rdx
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
        mov $9, %rdx
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
        # Determine the print case (which was initialized as 0).
        # Both calls have a side-effect on the print_case buffer.
        # If the counter is divisible by 3, increment print_case by 1.
        # If divisible by 5, increment print_case by 2.
        # A number divisible by 3 and 5 thus results in a print_case of 3.
        # A number that isn't divisible by either leaves print_case at 0.
        call _test_fizz
        call _test_buzz

        # Save the loop counter on the stack,
        # since the call to print will modify %rcx.
        push %rcx

        call _print

        # Restore the loop counter, then increment it.
        pop %rcx
        inc %rcx

        # Reset the print case.
        movb $0, print_case

        # Have we iterated enough times? If not, loop again.
        cmp $101, %rcx
        jl loop

call _exit_normal
