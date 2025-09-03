build:
	nasm kernel.s -o kernel.bin
	nasm bootloader.s -o bootloader.bin
	cat kernel.bin >> bootloader.bin

clean:
	rm -f *.bin