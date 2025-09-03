[BITS 32]
org 0x8900
jmp kernel

%include "video.inc"

kernel:

setChar 2, 2, 'E', 0x0F