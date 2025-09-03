; ============================
; Disk driver with BIOS access
; ============================

%include "driver_data.inc"

dd KERNEL_DRIVER_MAGIC_NUMBER

db 11
db "disk driver"
db 0        ; Version
db subtype_device

dd functions

functions:
    dw 2
    dd read_sector
    dd write_sector

; ============================
; Protected mode → real mode
; ============================
switch_to_real_mode:
    cli
    mov eax, cr0
    and eax, 0xFFFFFFFE
    mov cr0, eax

    ; Far jump to flush CS
    jmp 0x0000:real_mode_entry

; ============================
; Real mode code
; ============================
[BITS 16]
real_mode_entry:
    ; setup stack
    mov ax, 0x9000
    mov ss, ax
    mov sp, 0xFFFF
    mov ds, ax
    mov es, ax

    ; AL already holds 0=read,1=write
    push dx
    push cx
    push bx
    call bios_rw_sectors
    pop bx
    pop cx
    pop dx

    jmp protected_mode_entry

; ----------------------------
; BIOS read/write sectors (CHS)
; ----------------------------
; DX = linear sector
; CX = count
; BX = buffer address (<1MB)
; AL = 0 read, 1 write
bios_rw_sectors:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov si, dx            ; linear sector
    mov di, cx            ; sector count
    mov bp, bx            ; buffer pointer

rw_loop:
    ; --- CHS calculation ---
    mov ax, si
    xor dx, dx
    mov bx, 63            ; sectors per track
    div bx                ; AX = cylinder*heads? DX = sector in track
    mov cl, dl
    inc cl                 ; 1-based
    xor dx, dx
    mov bx, 16            ; heads
    div bx                 ; AX = cylinder, DX = head
    mov ch, al
    mov dh, dl

    mov dl, 0x80           ; drive 0

    ; BIOS call
    cmp al, 0
    je do_read
    jne do_write

do_read:
    mov ah, 0x02
    int 0x13
    jc error_handler
    jmp rw_done

do_write:
    mov ah, 0x03
    int 0x13
    jc error_handler

rw_done:
    add bp, 512
    inc si
    dec di
    jnz rw_loop

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

error_handler:
    stc
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ============================
; Switch back to protected mode
; ============================
[BITS 32]
protected_mode_entry:
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; far jump to flush CS
    jmp 0x08:pm_continue

pm_continue:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    sti
    ret

; ----------------------------
; Function wrappers
; ----------------------------
read_sector:
    mov al, 0
    call switch_to_real_mode
    ret

dd DRV_FUNC_END

write_sector:
    mov al, 1
    call switch_to_real_mode
    ret

dd DRV_FUNC_END