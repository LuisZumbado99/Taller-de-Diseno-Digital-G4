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
  - Aritmética: add, sub, addi
  - Memoria: lw, sw
  - Control: beq, bne, jal, jalr
  - Manejo de constantes: lui, auipc

###
