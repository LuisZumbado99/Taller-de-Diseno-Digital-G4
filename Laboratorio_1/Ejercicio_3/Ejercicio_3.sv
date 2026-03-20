module Ejercicio_3 (
    input  logic clk,
    input  logic rst,        // <--- Nombre exacto
    input  logic [3:0] duty_sw, // <--- Nombre exacto
    output logic pwm_out     // <--- Nombre exacto
);

    reg [16:0] counter; // Suficiente para contar hasta 100,000
    
    // Generador de rampa/contador
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
        end else begin
            if (counter >= 99999) // Fin del periodo de 1ms
                counter <= 0;
            else
                counter <= counter + 1;
        end
    end

    // Comparador para generar el ancho de pulso
    // Cada unidad de duty_sw equivale a 6250 ciclos de reloj
    always @(*) begin
        if (counter < (duty_sw * 6250))
            pwm_out = 1'b1;
        else
            pwm_out = 1'b0;
    end

endmodule