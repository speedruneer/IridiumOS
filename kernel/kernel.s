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

%include "vga.inc"
%include "txtvideo.inc"
%include "error.inc"

kernelEntry:

mov [MODE], al

cmp byte [MODE], 0
jne vga

clearScreen 0Fh
printString 0, 0, KRN_LOADED_STR, 0Fh
printString 0, 1, MODE_TXT, 0Fh

jmp hang

vga:



hang:
    CHECKERR
    jmp hang