; =============================================
; Minimal bootloader with text, LBA read, PM switch
; =============================================
[BITS 16]
[ORG 0x7C00]

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00           ; temporary stack

    ; ------------------------
    ; Print message
    ; ------------------------
    mov si, msg
.print_char:
    lodsb
    cmp al, 0
    je .done_msg
    mov ah, 0x0E
    mov bh, 0
    mov bl, 0x07
    int 0x10
    jmp .print_char
.done_msg:

    ; ------------------------
    ; Read kernel sectors using LBA
    ; ------------------------
    mov bx, 0x8000           ; destination in memory
    mov si, 0                ; starting LBA
    mov cx, 5                ; number of sectors to load

read_loop:
    push si
    push cx
    push bx
    call read_lba_sector
    pop bx
    pop cx
    pop si
    add bx, 512
    inc si
    dec cx
    jnz read_loop

    ; ------------------------
    ; Setup GDT
    ; ------------------------
    cli
    lgdt [gdt_descriptor]

    ; ------------------------
    ; Enter protected mode
    ; ------------------------
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp 0x08:pm_start        ; flush CS

[BITS 32]
pm_start:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Loaded kernel is at 0x8000
    ; Jump to it if needed:
    ; jmp 0x08:0x8000

halt:
    hlt
    jmp halt

; =============================================
; Print disk error
; =============================================
disk_error:
    mov si, err_msg
.err_loop:
    lodsb
    cmp al, 0
    je .end_err
    mov ah, 0x0E
    mov bh, 0
    mov bl, 0x0C
    int 0x10
    jmp .err_loop
.end_err:
    hlt
    jmp .end_err

; =============================================
; LBA Disk read (INT 13h AH=0x42)
; Inputs:
;   BX = destination
;   SI = LBA
;   DX = drive (0x80)
;   CX = sectors to read (max 127)
; =============================================
read_lba_sector:
    pusha

    ; Disk Address Packet (16 bytes)
    ; Structure:
    ; 0-1: size (16)
    ; 2: 0 (reserved)
    ; 3-4: sectors to read (CX)
    ; 5-8: buffer (ES:BX)
    ; 9-16: LBA (SI)
    lea di, dap
    mov word [di], 16          ; size
    mov byte [di+2], 0
    mov word [di+4], cx        ; sectors
    mov word [di+8], bx       ; buffer offset
    mov word [di+12], 0        ; buffer segment high=0
    mov word [di+4], cx       ; sectors again
    mov word [di+12], si      ; starting LBA

    mov ah, 0x42
    mov dl, 0x80
    mov si, di                 ; DAP address
    int 0x13
    jc disk_error

    popa
    ret

; =============================================
; Disk Address Packet
; =============================================
dap times 16 db 0

; =============================================
; Messages
; =============================================
msg db 'Bootloader: loading kernel...', 0
err_msg db 'Disk read error!', 0

; =============================================
; GDT (flat)
; =============================================
gdt_start:
    dq 0x0000000000000000      ; null descriptor
gdt_code:
    dq 0x00CF9A000000FFFF      ; base=0, limit=4GB, code segment
gdt_data:
    dq 0x00CF92000000FFFF      ; base=0, limit=4GB, data segment
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

; =============================================
; Bootloader signature
; =============================================
times 510-($-$$) db 0
dw 0xAA55
