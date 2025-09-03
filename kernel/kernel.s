[BITS 32]
org 0x8900
jmp kernel

%include "video.inc"

kernel:

clearScreen 0x0F
setChar 0, 0, 'E', 0x0F

hang:
    jmp hang