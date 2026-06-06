## Documentación final

### Explicación de Módulos (Jerarquía de Hardware)

  1. spi_master.sv (Unit Under Test - UUT): Es el núcleo del hardware periférico, mapeado en el espacio de memoria del procesador RISC-V. Su función es traducir
  comandos paralelos de la CPU en ráfagas seriales síncronas.

  2. tb_spi_master.sv (Entorno de Verificación - Testbench Top): Es el módulo de jerarquía superior que no se sintetiza en la FPGA; su único propósito es orquestar
  la simulación y emular el comportamiento del entorno.

  3. Modelo del Esclavo BFM (Bus Functional Model): Ubicado de manera interna o adyacente en el testbench, es un modelo de comportamiento diseñado específicamente
  para simular la lógica interna del acelerómetro Analog Devices ADXL362. No procesa ecuaciones físicas complejas, sino que valida la semántica del protocolo SPI.

### Máquina de Estados Finitos (FSM) del spi_master

<img width="600" height="550" alt="mermaid-diagram-2026-06-05-180016" src="https://github.com/user-attachments/assets/34cb808b-5778-40c1-bf76-8d56620623a0" />

#### Descripción de Estados:

  1. ST_IDLE: El bus está libre. Las líneas se mantienen en reposo: cs_n = 1, sclk = 0, mosi = 0.
  2. ST_LOAD: Captura el byte de entrada de la CPU en el registro interno de desplazamiento y limpia los contadores de bits.
  3. ST_SHIFT: Estado de transmisión/recepción activa. El reloj sclk oscila. En cada flanco de bajada se desplaza un bit a mosi; en cada flanco de subida se muestrea miso.
  4. ST_CHECK: Evalúa la señal de control preserve_cs. Si la CPU requiere enviar más bytes consecutivos (como la secuencia de comando + dirección), la FSM regresa a ST_LOAD manteniendo cs_n = 0 para evitar romper la transacción. Si terminó, retorna a ST_IDLE llevando cs_n = 1.

### Diagrama de Tiempos (Timing Diagram)

 <img width="820" height="312" alt="wavedrom" src="https://github.com/user-attachments/assets/98c8c79a-0d8f-4799-ba00-c365b49850d1" />

El diagrama muestra el comportamiento temporal verificado de las señales físicas durante el último byte de la transacción (Lectura del ID 0xAD).

### Arquitectura del Software de Telemetría (Python Parser)

La arquitectura del software de telemetría para ambos scripts está diseñada bajo el principio de Procesamiento Asíncrono Orientado a Eventos mediante un esquema de 
sondeo (polling) no bloqueante. La meta principal de esta arquitectura es desacoplar la recepción de datos seriales por hardware (que ocurre a una tasa de refresco 
externa) del hilo de renderizado de la interfaz gráfica (UI), evitando que la ventana de Windows se congele o se vuelva inestable.


