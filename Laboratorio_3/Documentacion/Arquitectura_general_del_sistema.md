## Arquitectura general del sistema.

Diagrama de bloques de la arquitectura de implementación real que se planea para la FPGA, se plantea con el fin de organizar el desarrollo por módulos,definir interfaces, facilitar integración y usarlo como base para el desarrollo del proyecto. 

<img width="500" height="700" alt="Diagrama sin título drawio (1)" src="https://github.com/user-attachments/assets/f4e496b6-ddf7-4799-b949-229a3d4930a4" />

Arquitectura sugerida para la implementación del clock y del reset:

<img width="400" height="250" alt="Diagrama sin título drawio (2)" src="https://github.com/user-attachments/assets/d467ce92-daca-449a-9662-259ffa403b9d" />

Para el reset se implementará un reset compuesto por 2 partes, la parte física que es la señal resultante de presionar el botón físico asignado en la FPGA y uno interno sincronizado para evitar metastabilidad. Para el clock no se va a generar un clock manualmente con contadores, sino que, se obtará por un único clock global y usar enable pulses/dividers.

Interfaces principales:

| Modulo | Entrada | Salida |
| --- | --- | --- |
| PLL | clk_100MHz | clk_sys |
| Reset Sync | reset_btn | rst_sys |
| RISC-V | ProgIn/DataIn | Address/DataOut/we |
| ROM | ProgAddress | ProgIn |
| RAM | Address/DataOut/we | DataIn |
| UART | TX Data | RX Data |
| SPI | TX command | RX data |
| LED Driver | Data bus | LEDs |
| SW / BTN | BTN/SW | Data bus |

Bus de instrucciones:

| Señal | Tamaño |
| --- | --- |
| ProgAddress_o | 32 bits |
| ProgIn_i | 32 bits |

Bus de data:

| Señal | Tamaño |
| --- | --- |
| DataAddress_o | 32 bits |
| DataOut_o | 32 bits |
| DataIn_i | 32 bits |
| we_o | 1 bit |

Señales:

| Señal | Descripción | Dirección | Tipo |
| --- | --- | --- | --- |
| clk_sys | Clock principal sistema | - | Global |
| rst_sys | Reset sincronizado | - | Global |
| clk_100MHz | Clock físico Nexys4 | - | Global |
| we_o | Write enable global | - | Global |
| spi_sclk | - | FPGA → ADXL362 | SPI |
| spi_mosi | - | FPGA → ADXL362 | SPI |
| spi_miso | - | ADXL362 → FPGA | SPI |
| spi_cs | - | FPGA → ADXL362 | SPI |
| uart_tx | - | FPGA → PC | UART |
| uart_rx | - | FPGA → PC | UART |


