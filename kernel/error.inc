; =====================================
; Copyright (C) 2025 Speedruneer/SpeedruneerOff
; All rights reserved
; Distributed for hobby purposes only
; =====================================


[BITS 32]
; =====================================
; error.inc — IridiumOS kernel errors (string-based)
; =====================================

%define STACK_TOP    0x90000       ; where you start the stack (grows down)
%define STACK_BOTTOM 0x8F000       ; arbitrary lower bound for stack safety

; -------------------------
; Error messages (labels)
; -------------------------

ERR_UNKNOWN:            db "Unknown error", 0
ERR_DISK_FAIL:          db "Disk failure", 0
ERR_DISK_TIMEOUT:       db "Disk timeout", 0
ERR_DISK_READ:          db "Disk read error", 0
ERR_DISK_WRITE:         db "Disk write error", 0

ERR_KEYBOARD_FAIL:      db "Keyboard failure", 0
ERR_UNSUPPORTED_DEVICE: db "Unsupported device", 0
ERR_KERNEL_DIED:        db "Kernel died, idk why", 0

ERR_VGA_FAIL:           db "VGA failure", 0
ERR_UNSUPPORTED_MODE:   db "Unsupported video mode", 0

ERR_STACK_OVERFLOW:     db "Stack overflow", 0
ERR_MEM_CORRUPT:        db "Memory corruption", 0

ERR_PROG_RETURNED:      db "Program returned unexpectedly", 0
ERR_PROG_ILLEGAL_INSTR: db "Illegal instruction in program", 0
ERR_PROG_ACCESS_VIOLATION: db "Program access violation", 0

ERR_PROG_OLD:           db "This program is an invalid/older version", 0
ERR_PROG_NEW:           db "This program is an invalid/newer version", 0
ERR_PROG_BRK:           db "This program has broken headers or isn't prgm", 0
; -------------------------
; kernel_panic
; IN: ESI = pointer to error string
; -------------------------
kernel_panic:
    pushad

    ; clear screen (white on red)
    clearScreen BLACK*BACKGROUND + RED*FOREGROUND

    ; print crash header
    printString 0, 0, panic_msg, BLACK*BACKGROUND + RED*FOREGROUND

    ; print reason string
    printString 0, 1, esi, BLACK*BACKGROUND + RED*FOREGROUND

    ; hang forever
.halt:
    jmp .halt

panic_msg: db "IridiumOS crashed! Reason:", 0

; -------------------------
; ERR macro (takes string label)
; -------------------------
%macro ERR 1
    mov esi, %1          ; load pointer to string into ESI
    call kernel_panic
%endmacro

check_stack:
    cmp esp, STACK_BOTTOM
    jb .overflow
    cmp esp, STACK_TOP
    ja .overflow
    ret
.overflow:
    ERR ERR_STACK_OVERFLOW

; Example: check that DS, ES, FS, GS are valid GDT selectors
check_segments:
    mov ax, ds
    test ax, 0xFFFC      ; mask low 2 bits
    jz .bad
    mov ax, es
    test ax, 0xFFFC
    jz .bad
    mov ax, fs
    test ax, 0xFFFC
    jz .bad
    mov ax, gs
    test ax, 0xFFFC
    jz .bad
    ret
.bad:
    ERR ERR_MEM_CORRUPT   ; use a generic memory error

; IN: EAX = numerator, EBX = denominator
check_div_zero:
    test ebx, ebx
    jz .div_zero
    ret
.div_zero:
    ERR ERR_PROG_ILLEGAL_INSTR

; Example: add two signed values in EAX, EBX
check_overflow_add:
    add eax, ebx
    jo .overflow
    ret
.overflow:
    ERR ERR_KERNEL_DIED

%macro CHECKERR 0
    call check_div_zero
    call check_overflow_add
    call check_segments
    call check_stack
%endmacro