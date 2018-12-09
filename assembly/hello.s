# PURPOSE: Print "Hello, World!", then exit.
# INPUT: None.
# OUTPUT:    Prints a string to stdout.
#           Returns a status code of 0.
# VARIABLES:
#           %rax holds the system call number
#           %rbx holds the return status
.section .data
hw:
        .ascii "Hello, World!!!"

.section .text
        .globl _start

_exit:
        mov $1, %rax # System call number for exit.
        mov $0, %rbx # Exit code.
        int $0x80    # Call the kernel.

_start:
        mov $4, %rax  # System call number for write.
        mov $1, %rbx  # stdout.
        mov $hw, %rcx # Address of the buffer.
        mov $15, %rdx # Number of bytes to write.
        int $0x80     # Call the kernel.

call _exit # Call the _exit macro.
