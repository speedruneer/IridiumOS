; ============================
; Program template - x86 32-bit
; ============================

; headers
%include "header.s"
; code entry point (loader will jump here)
; Using relative jump, position-independent
jmp start

; data area
process_ram_address: dd 0   ; placeholder variable


; Required area, do not touch

start:
    ; ----------------------------
    ; Compute the runtime address of process_ram_address
    ; ----------------------------
    call get_eip             ; Push address of next instruction
get_eip:
    pop eax                  ; EAX = current instruction address
    add eax, process_ram_address - get_eip  ; EAX = absolute RAM address of process_ram_address

    ; Example: store a value
    mov dword [eax], 0x12345678

; Code

; put whatever code for the program