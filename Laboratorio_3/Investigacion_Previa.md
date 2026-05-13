**1. Investigar el protocolo SPI y cómo configuraría los registros de control para usarlo.**

El protocolo SPI (Serial Peripheral Interface) es un protocolo de comunicación serial síncrono utilizado para comunicar un dispositivo maestro con uno o varios esclavos. Fue diseñado originalmente por Motorola y es ampliamente usado en sensores, memorias y periféricos embebidos. SPI utiliza típicamente cuatro señales:

| Señal | Descripción |
| --- | --- |
| SLCK | Clock generado por el maestro |
| MOSI | Master Out Slave In |
| MISO | Master In Slave Out |
| CS/SS | Chip Select |

Funcionamiento general:
- El maestro activa CS en bajo.
- El maestro genera el reloj SCLK.
- Los datos se transmiten bit a bit entre MOSI y MISO.
- Al finalizar la transacción, CS vuelve a alto.

Si el protocolo utilizado es full duplex, significa que la transmisión y recepción ocurren simultáneamente. El protocólo SPI posee cuatro modos de operación definidos por CPOL → polaridad del clock y por CPHA → fase de muestreo.

| Modo SPI | CPOL | CPHA |
| ---         |     ---      |          --- |
| Mode 0  |  0   |  0  |
| Mode 1  |  0   |  1  |
| Mode 2  |  1   |  0  |
| Mode 3  |  1   |  1  |

CPOL define el estado IDLE del clock (0 reloj en bajo, 1 reloj en alto) mientras que CPHA define en que flanco se captura el dato (0 primer flanco, 1 segundo flanco). Ahora bien, para implementar el periférico SPI memory-mapped del laboratorio, normalmente se utilizan:

| Registro | Función |
| --- | --- |
| Control Register | Configurar CPOL, CPHA, enable, clock divider |
| Status Register | Busy, TX ready, RX valid |
| Tx Register | Dato a transmitir |
| Rx Register | Dato recibido |

Basado en el mapa de memoria dado por el instructivo, se plantea las siguientes propuestas para el laboratorio a desarrollar:

Propuesta de registros para el laboratorio:
| Dirección | Registro |
| --- | --- |
| 0x02020 | SPI Control |
| 0x02028 | SPI Tx |
| 0x0202C | SPI Rx |

Propuesta de bits del registro de control:
| Bit | Función |
| --- | --- |
| 0 | SPI Enable |
| 1 | Start Transaction |
| 2 | Busy |
| 3 | Rx Valid |
| 4 | CPOL |
| 5 | CPHA |
| 15:8 | Clock Divider |

Rerefencias: \
[1. Tutorial del protocolo SPI](https://next.gr/tutorials/digital-communication/spi-protocol-tutorial?utm_source=chatgpt.com) \
[2. SPI CPOL/CPHA Tutorial](https://chatgpt.com/c/6a04e1ba-2138-83e8-9544-a6f9feb539ce#:~:text=SPI%20CPOL/CPHA%20Tutorial)
