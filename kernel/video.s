; =====================================
; VGA / screen routines
; =====================================

%define VIDEO_MEMORY 0xb8000
%define SCREEN_WIDTH 80
%define SCREEN_HEIGHT 25

; -------------------------------------
; setCharScreen: write a single char+color at AL=col, AH=row, BL=char, BH=color
; -------------------------------------
setCharScreen:
    pusha

    ; Compute video memory offset using a temp register (EDI)
    movzx edi, ah           ; row -> EDI
    imul edi, SCREEN_WIDTH  ; row * width
    movzx ecx, al           ; column
    add edi, ecx
    shl edi, 1              ; 2 bytes per cell
    add edi, VIDEO_MEMORY   ; final address -> EDI

    ; Build AX = char + color
    mov ax, 0
    mov al, bl              ; character
    mov ah, bh              ; color

    ; Write to video memory
    mov [edi], ax

    popa
    ret


; -------------------------------------
; setChar macro: load registers and call setCharScreen
; -------------------------------------
%macro setChar 4
    push ax
    push bx

    mov al, %1      ; x
    mov ah, %2      ; y
    mov bl, %3      ; character
    mov bh, %4      ; color

    call setCharScreen

    pop bx
    pop ax
%endmacro

; -------------------------------------
; clearScreen function: runtime version
; -------------------------------------
clearScreen:
    pusha
    xor dh, dh       ; row = 0

.clear_row:
    xor dl, dl       ; col = 0

.clear_col:
    setChar dl, dh, ' ', 0x00
    inc dl
    cmp dl, SCREEN_WIDTH
    jb .clear_col

    inc dh
    cmp dh, SCREEN_HEIGHT
    jb .clear_row

    popa
    ret

; -------------------------------------
; error macro: clears screen and prints 2-digit hex error code at (1,1)-(2,1)
; -------------------------------------
errorFunc:
    pusha

    ; Clear the screen
    call clearScreen

    ; Split AL into high and low nibble
    mov ah, al        ; copy error code to AH
    shr al, 4         ; AL = high nibble
    and ah, 0x0F      ; AH = low nibble

    ; Convert high nibble to ASCII
    cmp al, 9
    jbe .high_is_digit
    add al, 'A' - 10
    jmp .high_done
.high_is_digit:
    add al, '0'
.high_done:

    ; Convert low nibble to ASCII
    cmp ah, 9
    jbe .low_is_digit
    add ah, 'A' - 10
    jmp .low_done
.low_is_digit:
    add ah, '0'
.low_done:

    ; Print two characters using setCharScreen
    ; First char at (1,1)
    mov bl, al
    mov bh, 0x04
    mov al, 1          ; x
    mov ah, 1          ; y
    call setCharScreen

    ; Second char at (2,1)
    mov bl, ah
    mov bh, 0x04
    mov al, 2
    mov ah, 1
    call setCharScreen

    popa
    ret