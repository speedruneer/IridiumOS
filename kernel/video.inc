[BITS 32]
[org 0x8900]
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

    ; Compute offset in characters
    mov edi, VIDEO_MEMORY        ; start of VGA
    movzx ecx, ah                ; row
    imul ecx, SCREEN_WIDTH
    movzx eax, al
    add ecx, eax                 ; column
    shl ecx, 1                   ; 2 bytes per char
    add edi, ecx

    mov ax, 0
    mov al, bl
    mov ah, bh
    mov word [edi], ax

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

; =====================================
; clearScreen: fill VGA memory directly
; %1 = color attribute (8-bit)
; =====================================
%macro clearScreen 1
    pushad                     ; save registers

    mov edi, VIDEO_MEMORY       ; start of VGA memory
    mov ecx, 2000  ; total characters
    mov al, ' '                 ; space character
    mov ah, %1                  ; color
    movzx eax, ax                 ; combine char+color in EAX for 32-bit writes

.clear_loop:
    mov [edi], ax               ; write char+color
    add edi, 2                   ; next cell
    loop .clear_loop

    popad
%endmacro

; -------------------------------------
; printString macro
; Inputs:
;   %1 = column (x)
;   %2 = row (y)
;   %3 = pointer to null-terminated string
;   %4 = color (8-bit)
; -------------------------------------
%macro printString 4
    pushad                  ; save registers

    mov cl, %1              ; column
    mov ah, %2              ; row
    mov si, %3              ; pointer to string

.next_char:
    lodsb                   ; load next byte from string into AL temporarily
    cmp al, 0
    je .done
    mov bl, al              ; character for setCharScreen
    mov al, cl
    mov bh, %4              ; color for setCharScreen
    call setCharScreen
    inc cl                  ; move to next column
    jmp .next_char

.done:
    popad
%endmacro
