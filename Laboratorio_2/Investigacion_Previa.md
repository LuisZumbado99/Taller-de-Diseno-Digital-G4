# Investigación Previa

### Arquitectura RISC-V (RV32I)

RISC-V es una arquitectura de conjunto de instrucciones (ISA) abierta basada en principios RISC (Reduced Instruction Set Computer). El subconjunto RV32I corresponde a la base de instrucciones enteras de 32 bits.

#### Características:
  - Arquitectura load/store (solo acceso a memoria mediante lw, sw).
  - 32 registros de propósito general (x0–x31).
  - x0 siempre vale 0.
  - Instrucciones de tamaño fijo (32 bits).
  - Pipeline simple en implementaciones básicas.

#### Instrucciones clave para el laboratorio:
  - Aritmética → add, sub, addi
  - Memoria → lw, sw
  - Control → beq, bne, jal, jalr
  - Manejo de constantes → lui, auipc

### Toolchain RISC-V

Un toolchain es el conjunto de herramientas necesarias para transformar código fuente en un ejecutable.

#### Flujo básico:
Código ensamblador → Assembler (riscv32) → Código objeto → Linker → Ejecutable → Conversión a binario/hex → Memoria ROM en FPGA

### Protocolo AXI-Lite

AXI-Lite es una versión simplificada del protocolo AXI utilizada para comunicación entre procesador y periféricos. En el laboratorio se utiliza para interconectar el CPU con periféricos.

#### Características:
  - Comunicación memoria mapeada.
  - Sin burst (transacciones simples).
  - Baja complejidad → ideal para FPGA.

#### Señales clave:
  - valid → indica datos válidos
  - ready → receptor listo
  - addr → dirección
  - data → datos

### Memorias en FPGA

En FPGA, las memorias se implementan típicamente usando bloques internos (BRAM). Dividido en 2, la memoria ROM (Read Only Memory) la cual contiene el programa, es inicializada con archivo .hex o .bin, se caracteriza por ser de solo lectura y la memoria RAM (Random Access Memory) la cual almacena datos en ejecución, permite lectura y escritura.

#### Mapa de memoria para el laboratorio:

  - 0x0000 – 0x0FFF   → ROM (programa)
  - 0x02000           → Switches/Botones
  - 0x02004           → LEDs
  - 0x02010–0x0201C   → UART
  - 0x40000 – 0x7FFFF → RAM

### Fuentes

#### Arquitectura RISC-V (RV32I)
- RISC-V Foundation. *The RISC-V Instruction Set Manual, Volume I: Unprivileged ISA*  
  https://riscv.org/technical/specifications/

- Patterson, D. A., & Waterman, A. (2017). *The RISC-V Reader: An Open Architecture Atlas*  
  https://riscv.org/

#### Toolchain RISC-V
- GNU Toolchain for RISC-V  
  https://github.com/riscv-collab/riscv-gnu-toolchain

- SiFive Documentation – RISC-V Toolchain Guide  
  https://www.sifive.com/documentation

### Protocolo AXI-Lite
- ARM. *AMBA AXI and ACE Protocol Specification (AXI4)*  
  https://developer.arm.com/documentation/ihi0022/latest

- Xilinx. *AXI Reference Guide (UG1037)*  
  https://www.xilinx.com/support/documentation/ip_documentation/axi_ref_guide/latest/ug1037-axi-reference-guide.pdf

### Memorias en FPGA
- Xilinx. *Block Memory Generator (PG058)*  
  https://www.xilinx.com/support/documentation/ip_documentation/blk_mem_gen/latest/pg058-blk-mem-gen.pdf

- Xilinx. *Vivado Design Suite User Guide: Memory Resources (UG473)*  
  https://www.xilinx.com/support/documentation/user_guides/ug473_7Series_Memory_Resources.pdf

### Implementaciones RISC-V de referencia
- PicoRV32 (core RISC-V minimalista)  
  https://github.com/YosysHQ/picorv32

- UltraEmbedded RISC-V Core  
  https://github.com/ultraembedded/riscv
