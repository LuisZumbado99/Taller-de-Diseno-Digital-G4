### Módulos de trabajo detallados en la división del laboratorio en sub-issues.
#### Archivos presentes en la carpeta:
  - PicoRV32.sv →  Microcontrolador de 32 bits (Extraído de PicoRV32 - RISC-V CPU Core)
  - picorv32_tb.sv → Testbench para prueba de simulación del microcontrolador de 32 bits (Extraído de PicoRV32 - RISC-V CPU Core)
  - clock_gen.sv → Wrapper del PLL (El PLL se debe configurar desde el ClockWizard de Vivado)
  - top.sv → Módulo Top
  - memory.sv → Módulo de memoria RAM y ROM
  - peripherals.sv → Múdulo de transmisión tipo UART (Adaptación de repositorio SystemVerilog UART and Testbench)
  - uart_rx.sv → Módulo para recepción de transmisión tipo UART (Extraído de repositorio SystemVerilog UART and Testbench)
  - uart_tx.sv → Módulo para emisión de transmisión tipo UART (Extraído de repositorio SystemVerilog UART and Testbench)
  - data_ram.sv → RAM de datos nueva para 0x40000–0x7FFFF (Espacio de memoria de escritura/lectura donde almacenar variables temporales)
  - firmware_app → Código en ensamblador para efectuar sumas y restas de 2 números enteros.

#### Estructura del proyecto:
rtl/ \
├── src                             \
│    ├── top.sv                      \
│    ├── bus_interconnect.sv         \
│    ├── data_ram.sv                 \
│    ├── memory.sv                   \
│    ├── uart_peripheral.sv          \
│    ├── uart_rx.sv                  \
│    ├── uart_tx.sv                  \
│    ├── clock_gen.sv                \
│    ├── PicoRV32.sv                 \
│    └── constraints/                \
│        └── nexys4_ddr.xdc          \
└── firmware                        \
     ├── firmware_calculator.s       \
     ├── firmware_calculator.hex     \
     └── link.ld                     \
              

#### Repositorios externos utilizados:

1. [SystemVerilog UART and Testbench](https://github.com/Adnan259/SV-uart-with-tb/) 
2. [PicoRV32 - RISC-V CPU Core](https://github.com/YosysHQ/picorv32)

