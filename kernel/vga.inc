; =====================================
; Copyright (C) 2025 Speedruneer/SpeedruneerOff
; All rights reserved
; Distributed for hobby purposes only
; =====================================

[BITS 32]
org 0x8900

VGA_WIDTH  equ 320
VGA_HEIGHT equ 200
VGA_FB     equ 0xA0000   ; linear framebuffer for mode 13h

; ============================
; Pixel plotter
; IN: ecx = x, edx = y, al = color
; ============================
setPixelFunc:
    cmp ecx, VGA_WIDTH
    jae .ret
    cmp edx, VGA_HEIGHT
    jae .ret

    imul edx, VGA_WIDTH    ; y * width
    add edx, ecx           ; + x
    mov edi, VGA_FB
    add edi, edx           ; address = VGA_FB + y*width + x
    mov [edi], al
.ret:
    ret

%macro setPixel 3
    pushad
    mov ecx, %1
    mov edx, %2
    mov al, %3
    call setPixelFunc
    popad
%endmacro