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
        .zero 4

.section .text
        .globl _start

_test_fizzbuzz:
        # _test_fizzbuzz expects a 64-bit integer on the stack.
        # It returns a "print case" at %rax, also a 64-bit int.
        # The return value tracks what should be printed for the input number.
        # The possible return values are:
        # 0, i.e., print the counter.
        # 1, i.e., print "fizz".
        # 2, i.e., print "buzz".
        # 3, i.e., print "fizzbuzz".
        push %rbp
        mov %rsp, %rbp
        sub $8, %rsp # Local stack variable to track print case.
        movq $0, 8(%rsp)
test_fizz:
        # Retrieve the loop counter to use as the dividend.
        # It's now 24 bytes up from the stack pointer:
        # 8 bytes were just set aside for the print case.
        # 8 bytes were set aside for the base pointer.
        # 8 bytes were set aside for the counter, preceding the call.
        # We really only need a single byte for the counter and print case.
        # As is, the code is not space efficient.
        mov 24(%rsp), %rax
        movq $3, %rbx  # Use 3 as the divisor for "fizz" test.
        # Convert double-word to quad-word.
        # Necessary for 32 and 64-bit division.
        cdq
        div %rbx
        cmp $0, %rdx    # Was the remainder 0?
        jne test_buzz   # If not, test division by 5.
        add $1, 8(%rsp) # Otherwise, increment the print case.
test_buzz:
        mov 24(%rsp), %rax # Retrieve the counter again.
        movq $5, %rbx      # Use 5 as the divisor for "buzz" test.
        cdq
        div %rbx
        cmp $0, %rdx          # Was the remainder 0?
        jne return_print_case # If not, return.
        add $2, 8(%rsp)       # Otherwise, increment the print case by two.
return_print_case:
        mov 8(%rsp), %rax # Put the print case in %rax.
        mov %rbp, %rsp
        pop %rbp
        ret

_itoa:
        # _itoa expects a 64-bit integer on the stack.
        # It converts an integer into its ascii multi-byte representation.
        # The conversion is stored on the number_string buffer.
        # We get the digits in reverse order by dividing by 10:
        # 1234 / 10 yields a remainder of 4, then, 3, 2, 1.
        # We push these onto the stack, then pop off the stack to get the
        # correct order (pop 1 yields 1, pop 2 yields 2, etcetera).
        push %rbp
        mov %rsp, %rbp
        mov 16(%rsp), %rax # Place the integer param in %rax.
        # Uuse %rcx to keep track of how many digits we have processed.
        # We need this to know when to stop popping off the stack.
        mov $0, %rcx
        # Use 10 as the divisor. The remainder will give us the last digit.
        movq $10, %rbx
conversion_loop:
        inc %rcx # Keep track of the digit we're processing.
        cdq      # Setup for division.
        div %rbx
        # Convert to ASCII by adding 48.
        # ASCII "0" is 48, "1" is 49, etc.
        # By adding 48, we can get the ASCII integer that represents our digit.
        add $48, %rdx
        push %rdx # Push the converted remainder onto the stack.
        cmp $0, %rax # Are we done, i.e., is the quotient 0?
        jne conversion_loop # If not, repeat.
        # Otherwise, it's time to store the converted digits in our buffer.
        # Load the effective address of the buffer in %rdx.
        lea number_string, %rdx
save_to_buffer_loop:
        # Remember how we kept track of our digits with %rcx?
        # We now pop the stack to get each digit back.
        pop %rax
        # The ASCII character is only one byte long.
        # Move that byte into the buffer, by using the address in %rdx.
        movb %al, (%rdx)
        # We've processed this digit, decrement %rcx.
        dec %rcx
        # Increment %rdx so that it points to the buffer's next byte address.
        inc %rdx
        cmp $0, %rcx            # Have we processed all digits?
        jne save_to_buffer_loop # If not, loop again.
        # We're done moving data from the stack to the buffer.
        # Let's add a newline to the end of our digits.
        # The ASCII integer representation of "\n" is 10.
        movb $10, number_string + 3
        mov %rbp, %rsp
        pop %rbp
        ret

_print:
        # print expects a print case and counter, both 64-bit integers,
        # on the stack.
        # The former should be passed at 16 bytes above the stack pointer,
        # the latter at 24 bytes above, i.e.:
        # var print_case = 16(%rsp)
        # var counter = 24(%rsp)
        # Depending on the print case, _print either:
        # 1. Prints the counter, by using _itoa to convert it to ASCII.
        # 2. Prints "fizz", "buzz", or "fizzbuzz".
        # The printing itself is done by asking the kernel to write to stdout.
        push %rbp
        mov %rsp, %rbp
        # Setup the registers for the kernel request.
        mov $4, %rax             # System call number for write.
        mov $1, %rbx             # stdout.
        # %rcx will hold the address of the buffer to be printed.
        # %rdx will hold the number of bytes to write.
        # How these are set depends on the print case:
        cmp $0, 16(%rsp)
        je print_counter
        cmp $1, 16(%rsp)
        je print_fizz
        cmp $2, 16(%rsp)
        je print_buzz
        cmp $3, 16(%rsp)
        je print_fizzbuzz
print_counter:
        # We need to convert the counter to ASCII.
        # _itoa does this for us.
        # _itoa has a side-effect on the number_string buffer.
        # Push the counter again on the stack, for convenience.
        push 24(%rsp)
        # We could access the parameter to print from _itoa, with a larger byte
        # offset. But it's probably a little cleaner to just use another
        # location on the stack.
        call _itoa
        # _itoa also changes the values in the registers, so we'll need to
        # reset them for the request to the kernel.
        mov $4, %rax
        mov $1, %rbx
        mov $number_string, %rcx # Set the buffer the kernel should use.
        # Print 3 digits + 1 newline = 4 bytes.
        mov $4, %rdx
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
        push %rcx # Store the counter.
        call _test_fizzbuzz
        # _test_fizzbuzz returns the print case with %rax.
        # Place the return value on the stack, so that it can be used by _print.
        push %rax
        call _print
        pop %rax # Remove %rax from the stack, so that we can
        # restore the loop counter, then increment it.
        pop %rcx
        inc %rcx
        # Check: have we iterated enough times? If not, loop again.
        cmp $101, %rcx
        jl loop
        # Otherwise, we're done.
call _exit_normal
