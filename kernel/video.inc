[BITS 32]
org 0x8900
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
    pushad

    ; Compute video memory offset using a temp register (EDI)
    mov edi, 0
    movzx edi, ah           ; row -> EDI
    imul edi, SCREEN_WIDTH  ; row * width
    movzx ecx, al           ; column
    add edi, ecx
    shl edi, 1              ; 2 bytes per cell

    ; Build AX = char + color
    mov ax, 0
    mov al, bl              ; character
    mov ah, bh              ; color

    ; Write to video memory
    mov word [edi+VIDEO_MEMORY], ax

    popad
    ret


; -------------------------------------
; setChar macro: load registers and call setCharScreen
; -------------------------------------
%macro setChar 4
    pushad

    mov al, %2      ; x
    mov ah, %1      ; y
    mov bl, %3      ; character
    mov bh, %4      ; color

    call setCharScreen

    popad
%endmacro