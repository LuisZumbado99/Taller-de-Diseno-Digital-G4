`timescale 1ns / 1ps

module tb_top();
    logic clk100;
    logic btn_rst;
    logic [15:0] sw;
    logic [15:0] leds;
    logic uart_tx;

    // Reloj de 100MHz
    initial begin
        clk100 = 0;
        forever #5 clk100 = ~clk100;
    end

    // Instancia del Top
    top dut (
        .CLK100MHZ(clk100),
        .rst_btn(btn_rst),
        .sw(sw),
        .uart_rx(1'b1),
        .uart_tx(uart_tx),
        .led(leds)
    );

    initial begin
        btn_rst = 0; // Pulsado (Reset activo)
        sw = 16'hAAAA;
        #200;
        btn_rst = 1; // Soltamos botón
        
        // Esperamos a que el PLL enganche y el reset sincronizado termine
        wait(leds[15] == 1'b1);
        wait(leds[14] == 1'b1);
        
        $display("Integracion Top-Level exitosa a las %t", $time);
        #1000;
        $finish;
    end
endmodule