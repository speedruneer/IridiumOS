; =====================================
; idt.s - Interrupt Descriptor Table
; Provides idt_set function to set IDT entries
; Automatically reloads IDT after setting
; =====================================

[BITS 32]

; -----------------------------
; IDT table
; -----------------------------
idt_start: times 256*8 db 0   ; 256 entries, 8 bytes each
idt_end:

idt_descriptor:
    dw idt_end - idt_start - 1    ; limit = size-1
    dd idt_start                  ; base address

; -----------------------------
; Set IDT entry
; Inputs:
;   eax = handler address
;   ecx = index
; -----------------------------
idt_set:
    push edi
    push eax

    ; calculate pointer to entry
    mov edi, idt_start
    mov edx, ecx
    shl edx, 3              ; multiply index by 8
    add edi, edx

    ; fill IDT entry
    mov ax, word [eax]      ; lower 16 bits of handler
    mov [edi], ax
    mov word [edi+2], 0x08  ; code segment selector
    mov byte [edi+4], 0     ; reserved
    mov byte [edi+5], 0x8E  ; type & present
    shr eax, 16
    mov word [edi+6], ax     ; upper 16 bits of handler

    ; reload IDT
    lidt [idt_descriptor]

    pop eax
    pop edi
    ret
