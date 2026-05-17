`timescale 1ns / 1ps

module tb_top_integration();
    logic clk100 = 0;
    logic rst_n = 0;
    logic [15:0] leds;

    // Instancia del Top
    top dut (
        .CLK100MHZ(clk100),
        .rst_btn(rst_n),
        .sw(16'h1234), // Valor fijo de prueba para switches
        .uart_rx(1'b1),
        .uart_tx(),
        .led(leds)
    );

    always #5 clk100 = ~clk100;

    initial begin
        $display("Iniciando simulación larga...");
        clk100 = 0;
        rst_n = 0; 
        #100;
        rst_n = 1; 
        #800000;
        $display("Valor de los LEDs al final: %b", leds);
        $finish;
end
endmodule