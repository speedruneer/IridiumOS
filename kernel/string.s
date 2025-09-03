; ===============================
; NASM macros for length-prefixed strings
; ===============================

; eax = string address
; returns value in bl
%macro strlen 1
    mov bl, [%1]
%endmacro

; eax = source string address (length-prefixed)
; ebx = destination string address
%macro movstr 2
    push esi               ; preserve registers
    push edi

    mov cl, [%1]           ; load length of string
    lea esi, [%1 + 1]      ; source start (after length byte)
    mov edi, %2            ; destination start

.copy_loop_%=:
    cmp cl, 0
    je .done_%=
    mov al, [esi]          ; load byte from source
    mov [edi], al          ; store byte to destination
    inc esi
    inc edi
    dec cl
    jmp .copy_loop_%=

.done_%=:
    pop edi
    pop esi
%endmacro

; eax = string address
; bl = string index
; bh = output
%macro substr 3
    mov cl, [%1]           ; string length
    cmp %2, cl
    jae .err_%=
    mov %3, [%1 + %2 + 1] ; get character
    jmp .stop_%=

.err_%=:
    mov %3, 0

.stop_%=:
%endmacro