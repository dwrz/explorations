#PURPOSE:   Simple program that exits and returns a
#           status code back to the Linux kernel

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
#           %eax holds the system call number
#           %ebx holds the return status
#
.section .data

.section .text
.globl _start

_start:
movl $1, %eax       # this is the linux kernel command
                    # number (system call) for exiting
                    # $ means immediate mode addressing,
                    # without $ it defaults to direct
                    # mode, looking up a number in
                    # address 1

movl $2, %ebx       # this is the status number we will
                    # return to the OS

int $0x80           # this wakes up the kernel to run the
                    # exit command
