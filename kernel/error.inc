[BITS 32]
org 0x8900
[extern printString]
unknown_crash:
    clearScreen
    printString 0, 0, line, BLACK*BACKGROUND+RED*FOREGROUND
    printString 0, 1, reason.unknown, BLACK*BACKGROUND+RED*FOREGROUND
@:
    jmp @

line: db 'IridiumOS crashed', 0
reason:
    .unknown: db 'Unknown reason for crash', 0
    .cant_read: db 'Cant read something, likely RAM, unlikely registers', 0