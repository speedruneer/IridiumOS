[BITS 32]
org 0x8900
jmp kernel
%define STACK_TOP    0x90000       ; where you start the stack (grows down)
%define STACK_BOTTOM 0x8F000       ; arbitrary lower bound for stack safety

KRN_LOADED_STR: db 'krnld success', 0

%include "video.inc"
%include "error.inc"

check_stack:
    cmp esp, STACK_BOTTOM
    jb .overflow
    cmp esp, STACK_TOP
    ja .overflow
    ret
.overflow:
    ERR ERR_STACK_OVERFLOW
    ret

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
    ret

; IN: EAX = numerator, EBX = denominator
check_div_zero:
    test ebx, ebx
    jz .div_zero
    ret
.div_zero:
    ERR ERR_PROG_ILLEGAL_INSTR
    ret

; Example: add two signed values in EAX, EBX
check_overflow_add:
    add eax, ebx
    jo .overflow
    ret
.overflow:
    ERR ERR_KERNEL_DIED
    ret


kernel:



loop:
    call check_div_zero
    call check_overflow_add
    call check_segments
    call check_stack
    clearScreen 0x0F
    jmp loop