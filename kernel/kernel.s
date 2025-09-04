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

%include "video.inc"
%include "error.inc"

kernelEntry:

clearScreen 0Fh
printString 0, 0, KRN_LOADED_STR, 0Fh

loop:
    CHECKERR
    jmp loop