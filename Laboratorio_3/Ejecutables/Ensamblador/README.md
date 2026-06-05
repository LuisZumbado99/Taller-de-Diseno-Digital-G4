## Implementación del programa en ensamblador

Para el desarrollo del programa requerido, se sugirió el uso de un intérprete del ensamblador de RISC-V, particularmente para el subconjunto de instrucciones RV32I. 
Se usó Ubutu para el interprete de ensambrador.

### Paso a paso para generación e implementación del programa en ensamblador.

  1. Actualizar la lista de paquetes disponibles: `sudo apt update`
  2. Instalar herramientas esenciales de compilación: `sudo apt install build-essential -y`
  3. Instalar el toolchain de GCC para RISC-V (versión embebida/bare-metal): `sudo apt install gcc-riscv64-unknown-elf -y`
  4. Cambiar al directorio correspondiente (ajusta la ruta según la estructura).
  5. Agregar los archivos main.S, linker.ld y Makefile al directorio creado.
  6. Ejecutar la regla de limpieza del Makefile: `make clean`
  7. Ejecutar el Makefile para procesar el main.S y aplicar las reglas del Linker script: `make`

Siguiendo este paso a paso el intérprete del ensamblador generará un archivo llamado firmware que estará en formato hexadecimal, ese archivo debe ser copiado y pegado
en la carpeta del proyecto junto a las Design sources de Vivado.
