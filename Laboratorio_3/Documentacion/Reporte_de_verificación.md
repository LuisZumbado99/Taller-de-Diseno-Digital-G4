# Reporte de Verificación Automatizada - SPI Master

## 1. Objetivo de la Verificación
El propósito de este plan de pruebas es validar el comportamiento funcional del módulo IP `spi_master` diseñado en SystemVerilog, garantizando el cumplimiento de los tiempos, protocolos y control de flujo requeridos para interactuar con dispositivos periféricos reales, específicamente emulando el acelerómetro de tres ejes **Analog Devices ADXL362**.

## 2. Entorno de Pruebas (Testbench)
La verificación se realiza de manera aislada utilizando una metodología *headless* (por consola) con las herramientas de AMD Xilinx Vivado 2024.2.

### Componentes del Entorno:
* **UUT (Unit Under Test):** `spi_master.sv` configurado con un divisor de reloj estático (`CLK_DIV = 4`).
* **Modelo del Esclavo:** Un modelo de comportamiento (BFM) dentro del testbench (`tb_spi_master.sv`) que emula las restricciones de protocolo del chip ADXL362 de forma condicional, respondiendo únicamente en el ciclo correcto.

## 3. Casos de Prueba y Secuencia de Estímulos
La secuencia de simulación consta de una transacción consecutiva de 3 bytes sin liberar el bus (manteniendo `cs_n = 0` mediante la señal `preserve_cs`):
1. **Byte 1 (Escritura):** Envío del comando de lectura de registros (`0x0B`).
2. **Byte 2 (Escritura):** Envío de la dirección del registro de identidad (`0x00`).
3. **Byte 3 (Lectura):** Ciclo de reloj dummy (`0x00`) para recibir la respuesta por la línea `miso`.

## 4. Evidencia de Ejecución (Logs de Simulación en Consola)
A continuación se adjunta la bitácora de ejecución directa extraída dinámicamente de Vivado Simulator (`xsim`):

[VERIFICATION_REPORT.md](https://github.com/user-attachments/files/28653996/VERIFICATION_REPORT.md)
