[BITS 32]

%define VGA_VIDEO_MEMORY 0xA0000
%define SCREEN_WIDTH 320
%define SCREEN_HEIGHT 200

; ==========================
; Clear screen (320x200x256)
; Input: CL = color
; ==========================
VGA_ClearScreen:
    pushad
    mov edi, VGA_VIDEO_MEMORY
    mov al, cl
    mov ecx, SCREEN_WIDTH * SCREEN_HEIGHT
    rep stosb
    popad
    ret

; ==========================
; Plot a pixel safely
; Input: AX = X, BX = Y, CL = color
; ==========================
VGA_PLOT_PIXEL:
    ; bounds check
    cmp ax, SCREEN_WIDTH
    jae .skip
    cmp bx, SCREEN_HEIGHT
    jae .skip

    mov edi, VGA_VIDEO_MEMORY
    movzx eax, ax
    movzx ebx, bx
    imul ebx, SCREEN_WIDTH
    add eax, ebx
    add edi, eax
    mov [edi], cl
.skip:
    ret

; ==========================
; Switch to VGA or Text mode
; Input: AL = mode (0x03 text, 0x13 320x200x256)
; ==========================
switchRenderingMode:
    cli
    pushad
    pushfd

    ; temporary real-mode stack at 0x9000
    mov ax, 0x0000
    mov ss, ax
    mov esp, 0x90000

    ; leave protected mode
    mov eax, cr0
    and eax, 0xFFFFFFFE
    mov cr0, eax

    ; far jump to 16-bit code
    jmp 0x0000:real_mode_entry

[BITS 16]
real_mode_entry:
    ; BIOS call to set mode
    mov ah, 0x00
    int 0x10             ; AL already has desired mode

    ; --- setup GDT to return to protected mode ---
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

    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp 0x08:pm_resume

[BITS 32]
pm_resume:
    popfd
    popad
    mov esp, 0x90000
    sti
    ret
