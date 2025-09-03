%include "driver_data.inc"
dd KERNEL_DRIVER_MAGIC_NUMBER

db 11
db "RWFS driver"

db 0 ; Version

db subtype_fs

functions_offset: dd functions - $$

rwfs_ram_address: dd 0

functions:
    dw 3
    dd set_block
    dd read_block
    dd set_fs_location


; ax = block index-1 (first block is FS header)
; bx = block size
; ecx = block data address (source)
set_block:
    push edi              ; preserve edi
    mov edi, [rwfs_ram_address]  ; base FS address
    inc ax                 ; adjust block index if needed
    imul eax, ebx          ; eax = offset = block_index * block_size
    add edi, eax           ; edi = destination address
    mov esi, ecx           ; source address
    mov ecx, ebx           ; number of bytes to copy

.copy_loop:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    dec ecx
    jnz .copy_loop

    pop edi
    ret

dd DRV_FUNC_END

; eax = location
set_fs_location:
    mov dword [rwfs_ram_address], eax
    ret

dd DRV_FUNC_END

; ax = block index-1 (first block is FS header)
; bx = block size
; ecx = destination buffer address
read_block:
    push esi             ; preserve registers
    push edi

    mov edi, ecx         ; destination address
    mov esi, [rwfs_ram_address] ; FS base
    inc ax               ; adjust block index (skip header)
    imul eax, ebx        ; offset = block_index * block_size
    add esi, eax         ; source address

    movzx ecx, bx          ; number of bytes to copy

.copy_loop:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    dec ecx
    jnz .copy_loop

    pop edi
    pop esi
    ret

dd DRV_FUNC_END
