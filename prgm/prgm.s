%define CURRENT_VERSION 1
; eax = address of file in ram
; Error code in bl, 0 = older version, 1 = newer version, 2 = broken header FF = fine
checkHeader:
    cmp dword [eax], "PRGM"
    jne .brokenheader
    cmp byte [eax + 4], CURRENT_VERSION
    ja .newer
    jb .older
    mov bl, 0xFF
    ret
    .brokenheader:
        mov bl, 0x02
        ret
    .newer:
        mov bl, 0x01
        ret
    .older:
        mov bl, 0x00
        ret