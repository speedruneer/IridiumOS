[BITS 16]
ORG 0x7C00       ; BIOS loads bootloader here

start:
    cli                     ; Disable interrupts

    ; --------------------------
    ; Setup GDT
    ; --------------------------
gdt_start:
    dq 0                    ; Null descriptor
    dw 0xFFFF               ; Code segment: limit low
    dw 0x0000               ; base low
    db 0x00                 ; base middle
    db 10011010b            ; access: present, ring0, code
    db 11001111b            ; flags + limit high
    db 0x00                 ; base high

    dw 0xFFFF               ; Data segment: limit low
    dw 0x0000               ; base low
    db 0x00                 ; base middle
    db 10010010b            ; access: present, ring0, data
    db 11001111b            ; flags + limit high
    db 0x00                 ; base high
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

    ; Load GDT
    lgdt [gdt_descriptor]

    ; Enable protected mode
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; Far jump to flush prefetch
    jmp 0x08:pm_entry

[BITS 32]
pm_entry:
    ; Setup data segments
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; --------------------------
    ; Load next 1024 bytes from disk (sectors 2 and 3) into 0x8900
    ; --------------------------
    mov bx, 0x8900       ; ES:BX = target memory
    mov dh, 0            ; head
    mov dl, 0            ; drive number (0 = first floppy)
    mov ch, 0            ; cylinder
    mov cl, 2            ; sector 2 (BIOS counts 1 as first sector)
    mov ax, 0x0201       ; BIOS: AH=02 read, AL=1 sector
    int 0x13
    jc disk_error

    ; Read second sector
    mov cl, 3
    int 0x13
    jc disk_error

    ; Jump to loaded kernel at 0x8900
    jmp 0x0000:0x8900

disk_error:
    hlt

; Fill boot sector to 512 bytes
times 510-($-$$) db 0
dw 0xAA55