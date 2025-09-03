[BITS 32]
; =====================================
; error.inc — IridiumOS kernel errors (string-based)
; =====================================

; -------------------------
; Error messages (labels)
; -------------------------

ERR_UNKNOWN:            db "Unknown error", 0
ERR_DISK_FAIL:          db "Disk failure", 0
ERR_DISK_TIMEOUT:       db "Disk timeout", 0
ERR_DISK_READ:          db "Disk read error", 0
ERR_DISK_WRITE:         db "Disk write error", 0

ERR_KEYBOARD_FAIL:      db "Keyboard failure", 0
ERR_UNSUPPORTED_DEVICE: db "Unsupported device", 0
ERR_KERNEL_DIED:        db "Kernel died, idk why", 0

ERR_VGA_FAIL:           db "VGA failure", 0
ERR_UNSUPPORTED_MODE:   db "Unsupported video mode", 0

ERR_STACK_OVERFLOW:     db "Stack overflow", 0
ERR_MEM_CORRUPT:        db "Memory corruption", 0

ERR_PROG_RETURNED:      db "Program returned unexpectedly", 0
ERR_PROG_ILLEGAL_INSTR: db "Illegal instruction in program", 0
ERR_PROG_ACCESS_VIOLATION: db "Program access violation", 0

; -------------------------
; kernel_panic
; IN: ESI = pointer to error string
; -------------------------
kernel_panic:
    pushad

    ; clear screen (white on red)
    clearScreen BLACK*BACKGROUND + RED*FOREGROUND

    ; print crash header
    printString 0, 0, panic_msg, BLACK*BACKGROUND + RED*FOREGROUND

    ; print reason string
    printString 0, 1, esi, BLACK*BACKGROUND + RED*FOREGROUND

    ; hang forever
.halt:
    jmp .halt

    popad
    ret

panic_msg: db "IridiumOS crashed! Reason:", 0

; -------------------------
; ERR macro (takes string label)
; -------------------------
%macro ERR 1
    mov esi, %1          ; load pointer to string into ESI
    call kernel_panic
%endmacro
