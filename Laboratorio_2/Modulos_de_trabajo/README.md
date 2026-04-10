### Módulos de trabajo detallados en la división del laboratorio en sub-issues.
#### Archivos presentes en la carpeta:
  - PicoRV32.sv →  Microcontrolador de 32 bits
  - picorv32_tb.sv → Testbench para prueba de simulación del microcontrolador de 32 bits
  - clock_gen.sv → Wrapper del PLL (El PLL se debe configurar desde el ClockWizard de Vivado)
  - top.sv → Modulo Top

#### Estructura del proyecto:
rtl/ \
├── picorv32.v          # (original, NO tocar) \
├── clock_gen.sv        # tu PLL \
├── top.sv              # top-level del sistema \
├── memory.sv           # ROM/RAM \
├── peripherals.sv      # UART, LEDs, etc. \
└── bus.sv              # interconexión 
