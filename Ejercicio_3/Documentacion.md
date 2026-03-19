# Ejercicio 3

Se diseñó un módulo que reciba como entrada un código de 4 bits por medio de interruptores (S0, S1, S2 y S3). Dicha entrada se usa como código de nivel para una 
modulación PWM(Pulse With Modulation) que se envía como salida a un pin de la FPGA, el ancho del pulso es de alrededor de 1ms. La salida de carga será en un LED
de la tarjeta(L0). (Aumentando de 25% en 25% hasta alcanzar el 100%).


## Archivos presentes:

Desing Source Source: Ejercicio_3.sv <br/>
Testbench Code: Ejercicio_3tb.sv <br/>
Constraints Code: Nexys4_Master_Ejercicio_3.xdc

## Tarjeta utilizada:

Nexys 4 DDR Artix-7 FPGA

## Log report después de síntesis:

Synth Design complete | Checksum: 5a2407a4
INFO: [Common 17-83] Releasing license: Synthesis
20 Infos, 1 Warnings, 1 Critical Warnings and 0 Errors encountered.
synth_design completed successfully
synth_design: Time (s): cpu = 00:00:55 ; elapsed = 00:01:04 . Memory (MB): peak = 1618.023 ; gain = 1211.770
INFO: [runtcl-6] Synthesis results are not added to the cache due to CRITICAL_WARNING
Write ShapeDB Complete: Time (s): cpu = 00:00:00 ; elapsed = 00:00:00.002 . Memory (MB): peak = 1618.023 ; gain = 0.000
INFO: [Common 17-1381] The checkpoint 'C:/Users/luisd/Escritorio/Taller de Diseno Digital/Laboratorio_1/Laboratorio_1.runs/synth_1/Ejercicio_3.dcp' has been generated.
INFO: [Vivado 12-24828] Executing command : report_utilization -file Ejercicio_3_utilization_synth.rpt -pb Ejercicio_3_utilization_synth.pb


# Video de funcionamiento:


<https://github.com/user-attachments/assets/e1af765e-4cce-4231-ba4f-8e502fa0320a>


