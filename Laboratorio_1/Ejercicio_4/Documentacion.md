# Ejercicio 4

Se implementó una interfaz UART hacien uso de un código encontrado en un repositorio de licencia libre. La integración y funcionamiento de dicho módulo corre
por su cuenta se elaboró un set de pruebas para asegurar que dicho módulo UART funciona correctamente. La interfaz UART desarrollada es capaz de manejar 
el protocolo serial bidireccional a una velocidad de 9600 baudios. El diseñoo permite enviar a una computadora personal un ”Hola mundo” al presionar un botón de la FPGA
(N17). Adicionalmente, el diseño muestra en los LEDs los datos recibidos desde dicha computadora (LEDs desde el L0 hasta el L15). Para emular la terminal y lograr la
comunicación bidireccional se utilizó la herramienta PuTTY.


## Archivos presentes:

Desing Source Source: Ejercicio_4.sv <br/>
Testbench Code: Ejercicio_4tb.sv <br/>
Constraints Code: Nexys4_Master_Ejercicio_4.xdc

## Tarjeta utilizada:

Nexys 4 DDR Artix-7 FPGA

## Log report después de síntesis:

Synth Design complete | Checksum: d68b312d
INFO: [Common 17-83] Releasing license: Synthesis
35 Infos, 3 Warnings, 1 Critical Warnings and 0 Errors encountered.
synth_design completed successfully
synth_design: Time (s): cpu = 00:00:55 ; elapsed = 00:01:03 . Memory (MB): peak = 1625.637 ; gain = 1219.707
INFO: [runtcl-6] Synthesis results are not added to the cache due to CRITICAL_WARNING
Write ShapeDB Complete: Time (s): cpu = 00:00:00 ; elapsed = 00:00:00.002 . Memory (MB): peak = 1625.637 ; gain = 0.000
INFO: [Common 17-1381] The checkpoint 'C:/Users/luisd/Escritorio/Taller de Diseno Digital/Laboratorio_1/Laboratorio_1.runs/synth_1/Ejercicio_4.dcp' has been generated.
INFO: [Vivado 12-24828] Executing command : report_utilization -file Ejercicio_4_utilization_synth.rpt -pb Ejercicio_4_utilization_synth.pb

## Repositorio utilizado para la interfar UART: 

SV-uart-with-tb creado por Adnan259

Link: github.com/Adnan259/SV-uart-with-tb/
