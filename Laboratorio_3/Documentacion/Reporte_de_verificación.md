# Reporte de Verificación Automatizada - SPI Master

## 1. Objetivo de la Verificación
El propósito de este plan de pruebas es validar el comportamiento funcional del módulo IP `spi_master` diseñado en SystemVerilog, garantizando el cumplimiento de los tiempos, protocolos y control de flujo requeridos para interactuar con dispositivos periféricos reales, específicamente emulando el acelerómetro de tres ejes **Analog Devices ADXL362**.

## 2. Entorno de Pruebas (Testbench)
La verificación se realiza de manera aislada utilizando una metodología *headless* (por consola) con las herramientas de AMD Xilinx Vivado 2024.2. 

### Componentes del Entorno:
* **UUT (Unit Under Test):** `spi_master.sv` configurado con un divisor de reloj estático (`CLK_DIV = 4`).
* **Modelo del Esclavo:** Un modelo de comportamiento (BFM) dentro del testbench (`tb_spi_master.sv`) que emula las restricciones de protocolo del chip ADXL362.



### Restricción del Protocolo ADXL362 implementada:
El esclavo virtual mantiene la línea `miso` en alta impedancia (`z`) o en bajo (`0`) de forma condicional durante las fases de Comando y Dirección. Solo inyecta el identificador de fabricante `0xAD` durante la transferencia del tercer byte (Byte Dummy de lectura).

## 3. Casos de Prueba y Secuencia de Estímulos
La secuencia de simulación consta de una transacción consecutiva de 3 bytes sin liberar el bus (manteniendo `cs_n = 0` mediante la señal `preserve_cs`):
1. **Byte 1 (Escritura):** Envío del comando de lectura de registros (`0x0B`).
2. **Byte 2 (Escritura):** Envío de la dirección del registro de identidad (`0x00`).
3. **Byte 3 (Lectura):** Ciclo de reloj dummy (`0x00`) para recibir la respuesta por la línea `miso`.

## 4. Evidencia de Ejecución (Logs de Simulación)
La simulación se ejecuta de forma automática en modo batch mediante el script de automatización (`run_spi_sim.bat`). A continuación se adjunta la bitácora de éxito directo de Vivado Simulator (`xsim`):

```text
[START] Iniciando simulacion de lectura ADXL362...
[DIAGNOSTICO] Estado final de lineas físicas:
              -> cs_n = 1, sclk = 0, mosi = 0, miso = z
              -> rx_data (Leido por Maestro) = 8'had (8'b10101101)
[SUCCESS] DoD Cumplido! Transaccion SPI Completa exitosa. ID Leido: 0xad
$finish called at time : 11300 ns
INFO: [Common 17-206] Exiting xsim at Fri Jun  5 13:50:59 2026...
