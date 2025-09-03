; ============================
; Program template - x86 32-bit
; ============================

; headers
%include "header.s"
; code entry point (loader will jump here)
; Using relative jump, position-independent
jmp start

; data area



; Required area, do not touch

start: