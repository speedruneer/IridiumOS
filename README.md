# IridiumOS

IridiumOS is a hobby OS

## Specs

Singletasking OS
Can only boot from UEFI CSM or BIOS, I recommend using a VM (qemu specifically)
Status at this time: W.I.P

## Minimum specs

CPU: 486DX
USB: 2.0
Disk: USB/ATA/SATA 16MB
RAM: 512MB

## Qemu boot command

`qemu-system-x86_64 -cpu 486 -m 4G -drive file=iridiumos.img,if=ide,media=disk`

For installing programs add at the beginning:

`-fda program.fdd`
