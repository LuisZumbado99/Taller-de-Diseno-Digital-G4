# Ejercicio 1

El ejercicio 1 consta de 3 archivos compatibles con Vivado y trabajados con SystemVerilog, el módulo recibe como entradas 4 interruptores (SW0, SW1, SW2 y SW3), las salidas del módulo son 4 LEDs disponibles en la tarjeta de desarrollo (LD0, LD1, LD2 y LD3), el bloque desarrollado convierte el código ingresado por los interruptores por su correspondiente complemento a2 mostrado en los LEDs.

## Archivos presentes:

Desing Source Source: Ejercicio_1.sv <br/>
Testbench Code: Ejercicio_1tb.sv <br/>
Constraints Code: Nexys4_Master_Ejercicio_1.xdc

## Tarjeta utilizada:

Nexys 4 DDR Artix-7 FPGA

## Log report después de síntesis:

Synth Design complete | Checksum: d7fea69d
INFO: [Common 17-83] Releasing license: Synthesis
18 Infos, 2 Warnings, 2 Critical Warnings and 0 Errors encountered.
synth_design completed successfully
synth_design: Time (s): cpu = 00:00:51 ; elapsed = 00:00:58 . Memory (MB): peak = 1606.715 ; gain = 1201.910
INFO: [runtcl-6] Synthesis results are not added to the cache due to CRITICAL_WARNING
Write ShapeDB Complete: Time (s): cpu = 00:00:00 ; elapsed = 00:00:00.002 . Memory (MB): peak = 1606.715 ; gain = 0.000
INFO: [Common 17-1381] The checkpoint 'C:/Users/luisd/Escritorio/Taller de Diseno Digital/Laboratorio_1/Laboratorio_1.runs/synth_1/Ejercicio_1.dcp' has been generated.
INFO: [Vivado 12-24828] Executing command : report_utilization -file Ejercicio_1_utilization_synth.rpt -pb Ejercicio_1_utilization_synth.pb

# Video de funcionamiento:

<https://github.com/user-attachments/assets/b4d7331b-8348-4ec3-92cb-b9d58dc28ac6>
