[BITS 32]
org 0x8900
jmp kernel

KRN_LOADED_STR: db 'krnld success', 0

%include "video.inc"
%include "error.inc"

kernel:

clearScreen 0x0F
printString 0, 0, KRN_LOADED_STR, BLACK*BACKGROUND+RED*FOREGROUND


hang:
    jmp hang