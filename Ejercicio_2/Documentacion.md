# Ejercicio 2

El módulo 2 emula el funcionamiento de un multiplexor de cuatro entradas, parametrizado, para un ancho de datos (bus width) de entrada y salida variable. Para este 
se usa la totalidad de los switches de la FPGA (Desde el S0 hasta el S15) como entradas del multiplexor (I1, I2, I3 y I4) y se usan 2 botones (P17 y M17) como el selector
de 2 bits, completando así el funcionamiento del multiplexor.


## Archivos presentes:

Desing Source Source: Ejercicio_2.sv <br/>
Testbench Code: Ejercicio_2tb.sv <br/>
Constraints Code: Nexys4_Master_Ejercicio_2.xdc

## Tarjeta utilizada:

Nexys 4 DDR Artix-7 FPGA

## Log report después de síntesis:

Synth Design complete | Checksum: 55b9c3d
INFO: [Common 17-83] Releasing license: Synthesis
19 Infos, 1 Warnings, 1 Critical Warnings and 0 Errors encountered.
synth_design completed successfully
synth_design: Time (s): cpu = 00:00:57 ; elapsed = 00:01:24 . Memory (MB): peak = 1594.105 ; gain = 1188.324
INFO: [runtcl-6] Synthesis results are not added to the cache due to CRITICAL_WARNING
Write ShapeDB Complete: Time (s): cpu = 00:00:00 ; elapsed = 00:00:00.002 . Memory (MB): peak = 1594.105 ; gain = 0.000
INFO: [Common 17-1381] The checkpoint 'C:/Users/luisd/Escritorio/Taller de Diseno Digital/Laboratorio_1/Laboratorio_1.runs/synth_1/Ejercicio_2.dcp' has been generated.
INFO: [Vivado 12-24828] Executing command : report_utilization -file Ejercicio_2_utilization_synth.rpt -pb Ejercicio_2_utilization_synth.pb



# Video de funcionamiento:



