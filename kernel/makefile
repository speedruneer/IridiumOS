.PHONY: clean build

build:
	nasm kernel.s -o kernel.bin -f bin
	nasm bootloader.s -o bootloader.bin -f bin
	cat kernel.bin >> bootloader.bin

clean:
	rm -f *.bin