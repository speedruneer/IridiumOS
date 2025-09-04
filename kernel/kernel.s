[BITS 32]
org 0x8900
; Jump to kernel directly otherwise it causes issues
jmp kernelEntry

KRN_LOADED_STR: db 'krnld success', 0

%include "video.inc"
%include "error.inc"

kernelEntry:

clearScreen 0Fh
printString 0, 0, KRN_LOADED_STR, 0Fh

loop:
    call check_div_zero
    call check_overflow_add
    call check_segments
    call check_stack
    jmp loop