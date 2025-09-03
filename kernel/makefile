# List of source files
BOOTLOADER := bootloader.s
KERNEL := kernel.s

# Output binaries
BOOTLOADER_BIN := bootloader.bin
KERNEL_BIN := kernel.bin
OS_IMAGE := os.img

.PHONY: build clean

build: clean $(BOOTLOADER_BIN) $(KERNEL_BIN) merge

# Assemble .s -> .bin
%.bin: %.s
	nasm $< -f bin -o $@

# Merge bootloader + kernel into single image
merge:
	# Pad bootloader to 512 bytes
	cat $(KERNEL_BIN) >> $(BOOTLOADER_BIN)
	dd if=/dev/zero bs=512 count=3 >> $(BOOTLOADER_BIN)
	# Concatenate bootloader + kernel into OS image

# Clean binaries
clean:
	rm -f $(BOOTLOADER_BIN) $(KERNEL_BIN) $(OS_IMAGE)
