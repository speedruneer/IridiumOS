[BITS 16]
ORG 0x7C00                ; BIOS loads bootloader here

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00         ; stack grows down from here

    ; --------------------------
    ; Load kernel (2 sectors -> 1024 bytes) to 0x0000:0x8900
    ; --------------------------
    mov bx, 0x8900         ; offset into ES segment (which is 0)
    mov ah, 0x02           ; INT 13h: function 02h = read sectors
    mov al, 2              ; number of sectors to read
    mov ch, 0              ; cylinder
    mov cl, 2              ; sector number (start at sector 2)
    mov dh, 0              ; head
    mov dl, 0              ; drive (0 = first floppy, if using hdd use 0x80)
    int 0x13
    jc disk_error          ; if CF set → error

    ; --------------------------
    ; Setup GDT
    ; --------------------------
gdt_start:
    dq 0                   ; Null descriptor

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

    ; Load GDT
    lgdt [gdt_descriptor]

    ; Enable protected mode
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; Far jump into protected mode
    jmp 0x08:pm_entry

; --------------------------
; 32-bit code starts here
; --------------------------
[BITS 32]
pm_entry:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000       ; set up a stack somewhere safe

    ; Jump to loaded kernel at 0x00008900
    jmp 0x08:0x00008900

disk_error:
    hlt

; --------------------------
; Boot sector padding
; --------------------------
times 510-($-$$) db 0
dw 0xAA55
