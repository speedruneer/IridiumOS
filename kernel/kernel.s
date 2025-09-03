[BITS 32]
org 0x8900
jmp kernel

%include "vga.inc"

kernel:

;clearScreen 0x0F
;setChar 0, 0, 'E', 0x0F
mov al, 13h
call switchRenderingMode
mov cl, 0x1
call VGA_ClearScreen

hang:
    jmp hang