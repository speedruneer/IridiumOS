[BITS 32]
org 0x8900
jmp kernel

KRN_LOADED_STR: db 'krnld success', 0
ERROR: db 'err: idk', 0


%include "video.inc"

kernel:

clearScreen 0x0F
printString 0, 0, KRN_LOADED_STR, 0x0F

hang:
    jmp hang