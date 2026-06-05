# Configuración de herramientas
AS = riscv64-unknown-elf-as
LD = riscv64-unknown-elf-ld
OBJCOPY = riscv64-unknown-elf-objcopy

# Parámetros de arquitectura (PicoRV32 usa RV32I)
ASFLAGS = -march=rv32i -mabi=ilp32
LDFLAGS = -m elf32lriscv -T linker.ld

all: firmware.hex

main.o: main.S
	$(AS) $(ASFLAGS) main.S -o main.o

firmware.elf: main.o linker.ld
	$(LD) $(LDFLAGS) main.o -o firmware.elf

firmware.bin: firmware.elf
	$(OBJCOPY) -O binary firmware.elf firmware.bin

firmware.hex: firmware.bin
	@# Script en Python en una sola línea para evitar errores de indentación en el Makefile
	python3 -c "bin_data=open('firmware.bin','rb').read(); padded=bin_data+b'\x00'*((4-len(bin_data)%4)%4); words=[padded[i:i+4] for i in range(0,len(padded),4)]; hex_lines=[f'{w[3]:02x}{w[2]:02x}{w[1]:02x}{w[0]:02x}' for w in words]; open('firmware.hex','w').write('\n'.join(hex_lines)+'\n')"
	@echo "===================================================="
	@echo "¡Éxito! Archivo 'firmware.hex' generado listo para Vivado."
	@echo "===================================================="

clean:
	rm -f main.o firmware.elf firmware.bin firmware.hex

.PHONY: all clean
