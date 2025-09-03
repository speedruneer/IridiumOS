jmp kernel
%include "video.s"
kernel:

mov al, 0x32
call errorFunc