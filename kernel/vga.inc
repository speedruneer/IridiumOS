[BITS 32]
%define VGA_VIDEO_MEMORY 0xA0000
%define TXT_VIDEO_MEMORY 0xB8000
%define SCREEN_HEIGHT    480
%define SCREEN_WIDTH     640

vgapixelbytecount: db 1

; ax = X
; bx = Y
; cl = color
VGA_PLOT_PIXEL:
    mov edi, VGA_VIDEO_MEMORY
    movzx eax, ax
    movzx ebx, bx
    imul ebx, SCREEN_WIDTH
    imul ebx, vgapixelbytecount
    add ebx, eax
    add edi, ebx
    mov [edi], cl
    ret

; ==============================
; Switch to real mode, call BIOS, back to PM
; ==============================

; ax = mode to set (e.g., 0x13 = 320x200x256, 0x03 = 80x25 text)
switchVgaOrTxt:
    cli
    ; --- save registers ---
    pushad
    pushfd

    ; --- disable interrupts ---
    mov ebx, eax
    mov eax, cr0
    and eax, 0xFFFFFFFE  ; clear PE bit to switch to real mode
    mov cr0, eax
    mov eax, ebx

    ; --- far jump to real mode code ---
    jmp 0x0000:real_mode_entry

[BITS 16]
real_mode_entry:
    mov bx, ax
    mov ax, 0x0000
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    mov ax, bx

    ; call BIOS to set video mode
    mov ah, 0x00
    int 0x10             ; mode in AL already set by caller

    ; --- switch back to protected mode ---
    cli
gdt_start:
    dq 0                    ; null descriptor

    ; Code segment: base=0, limit=4GB
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00

    ; Data segment: base=0, limit=4GB
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

    lgdt [gdt_descriptor] ; reload GDT
    mov eax, cr0
    or eax, 1             ; set PE bit
    mov cr0, eax

    ; far jump into protected mode
    jmp 0x08:pm_resume

[BITS 32]
pm_resume:
    ; --- restore registers ---
    popfd
    popad
    sti
    ret

; ======================================
; VGA Clear Screen (320x200, 256 colors)
; Input: CL = color (0-255)
; ======================================
VGA_ClearScreen:
    pushad                   ; save all general-purpose registers

    mov edi, 0xA0000         ; VGA framebuffer
    mov al, cl               ; color to fill
    mov ecx, 320*200         ; number of pixels
    rep stosb                ; fill entire screen

    popad                    ; restore registers
    ret
