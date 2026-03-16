// Modulo de Multiplexor 4 a 1 parametrizado //

module Ejercicio_2 #(
    parameter WIDTH = 4  // Valor por defecto
)(
    input  wire [WIDTH-1:0] d0, d1, d2, d3, // Entradas de datos
    input  wire [1:0] sel,                  // Selector de 2 bits
    output reg  [WIDTH-1:0] y               // Salida usando reg para usar en el always
);

    // El modelado de comportamiento //
    always @(*) begin
        case (sel)
            2'b00: y = d0;
            2'b01: y = d1;
            2'b10: y = d2;
            2'b11: y = d3;
            default: y = {WIDTH{1'b0}}; // Evita la creacion de latches
        endcase
    end

endmodule