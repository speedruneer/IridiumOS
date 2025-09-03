[BITS 16]
[ORG 0x7C00]                ; BIOS loads bootloader here

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00          ; stack grows down from here

    ; --------------------------
    ; Load kernel (2 sectors) to 0x0000:0x8900
    ; --------------------------
    mov bx, 0x8900          ; offset into ES
    mov ah, 0x02            ; INT 13h function 02h = read sectors
    mov al, 2               ; number of sectors
    mov ch, 0               ; cylinder
    mov cl, 2               ; sector 2
    mov dh, 0               ; head
    mov dl, 0x80            ; first HDD
    int 0x13
    jc disk_error           ; jump if CF set
    mov ah, 01h
    mov ch, 3Fh
    int 10h
    jmp e

    ; --------------------------
    ; Setup GDT
    ; --------------------------
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

e:
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
    mov esp, 0x90000         ; stack somewhere safe

    ; Jump to loaded kernel
    jmp 0x08:0x00008900

; --------------------------
; Disk error handler
; --------------------------
[BITS 16]
disk_error:
    ; Print "Error "
    mov si, error_msg
.print_loop:
    lodsb                  ; load byte from DS:SI into AL
    cmp al, 0
    je .print_code          ; end of string
    mov ah, 0x0E
    int 0x10
    jmp .print_loop

.print_code:
    ; Print AH error code as hex (two characters)
    mov al, ah              ; error code in AH from INT 13h
    call print_hex_byte
    hlt

; --------------------------
; Helper: print 1 byte in hex
; --------------------------
print_hex_byte:
    push ax
    mov ah, 0
    mov bl, al
    shr al, 4
    call print_hex_nibble
    mov al, bl
    and al, 0x0F
    call print_hex_nibble
    pop ax
    ret

print_hex_nibble:
    cmp al, 0x0A
    jl .digit
    add al, 'A' - 10
    jmp .done
.digit:
    add al, '0'
.done:
    mov ah, 0x0E
    int 0x10
    ret

error_msg db 'Error ', 0

; --------------------------
; Boot sector padding
; --------------------------
times 510-($-$$) db 0
dw 0xAA55
