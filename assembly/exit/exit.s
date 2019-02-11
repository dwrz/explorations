#PURPOSE:   Simple program that exits and returns a
#           status code back to the Linux kernel
#

#INPUT:     none
#

#OUTPUT:    returns a status code  This can be viewed
#           by typing
#
#           echo $?
#
#           after running the program
#

#VARIABLES:
#           %rax holds the system call number
#           %rbx holds the return status
#
.section .data

.section .text
.globl _start

_start:
mov $1, %rax       # this is the linux kernel command
                    # number (system call) for exiting
                    # $ means immediate mode addressing,
                    # without $ it defaults to direct
                    # mode, looking up a number in
                    # address 1

mov $0, %rbx       # this is the status number we will
                    # return to the OS

int $0x80           # this wakes up the kernel to run the
                    # exit command
