## Documentación de fuentes de diseño

top.sv (Módulo Raíz) \
 ├── clk_wiz_wrapper (Mapeo de Reloj y Reset Sincronizado)        \
 ├── debouncer (Filtros de anti-rebote para interruptores)        \
 ├── bus_interconnect.sv (Decodificación y Enrutamiento del Bus)  \
 ├── memory.sv (ROM de Instrucciones + Diagnóstico GPIO por LEDs) \
 ├── data_ram.sv (Memoria Volátil de Datos - 100 KiB)             \
 └── uart_peripheral.sv (Subsistema UART Completo)                \
      ├── uart_tx.sv (FSM de Transmisión Serial)                  \
      └── uart_rx.sv (FSM de Recepción Serial)                
