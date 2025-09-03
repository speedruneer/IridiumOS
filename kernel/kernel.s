[BITS 32]
org 0x8900
jmp kernel

%include "vga.inc"

kernel:

;clearScreen 0x0F
;setChar 0, 0, 'E', 0x0F
mov al, 13h
call switchVgaOrTxt
mov cl, 0x15
call VGA_ClearScreen
mov ax, 30
mov bx, 30
mov cl, 0Fh
call VGA_PLOT_PIXEL
hang:
jmp hang