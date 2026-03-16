// Modulo para calcular el complemento a2 de 4 bits //

module Ejercicio_1 (
    input  wire [3:0] sw,  // Entrada de los 4 Interruptores de la Nexys 4
    output wire [3:0] led  // Salida de los 4 LEDs de la Nexys 4
);

    assign led = -sw; // El operador '-' en Verilog implementa el complemento a 2

endmodule