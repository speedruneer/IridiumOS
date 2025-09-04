; =====================================
; Copyright (C) 2025 Speedruneer/SpeedruneerOff
; All rights reserved
; Distributed for hobby purposes only
; =====================================

[BITS 32]
org 0x8900

VGA_WIDTH equ 320
VGA_HEIGHT equ 200
VGA_FB    equ 0xA0000   ; linear framebuffer for mode 13h

; ============================
; Set pixel at (x, y) in color
; Usage: setPixel x, y, color
; ============================
%macro setPixel 3
    mov eax, %2            ; y
    imul eax, VGA_WIDTH    ; y * 320
    add eax, %1            ; + x
    mov edx, VGA_FB        ; framebuffer base
    add edx, eax
    mov al, %3
    mov [edx], al
%endmacro

; ============================
; Set pixel with custom framebuffer
; Usage: setPixelCustomFB framebuffer_ptr, x, y, color
; ============================
%macro setPixelCustomFB 4
    mov eax, %3            ; y
    imul eax, VGA_WIDTH    ; y * 320
    add eax, %2            ; + x
    add eax, %1            ; framebuffer ptr
    mov al, %4
    mov [eax], al
%endmacro
