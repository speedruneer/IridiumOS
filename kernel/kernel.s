; =====================================
; Copyright (C) 2025 Speedruneer/SpeedruneerOff
; All rights reserved
; Distributed for hobby purposes only
; =====================================

[BITS 32]
org 0x8900
; Jump to kernel directly otherwise it causes issues
jmp kernelEntry

KRN_LOADED_STR: db 'krnld success', 0
MODE_VGA:       db 'mode: vga graphics', 0
MODE_TXT:       db 'mode: text graphics', 0
MODE: db 0

%include "txtvideo.inc"
%include "vga.inc"
%include "error.inc"

kernelEntry:
mov [MODE], al

cmp byte [MODE], 0
jne vga

clearScreen 0Fh
printString 0, 0, KRN_LOADED_STR, 0Fh
printString 0, 1, MODE_TXT, 0Fh
jmp loop

vga:

setPixel 10, 10, 0x66
setPixel 11, 10, 0x66
setPixel 11, 11, 0x66
setPixel 10, 11, 0x66

loop:
    CHECKERR
    jmp loop