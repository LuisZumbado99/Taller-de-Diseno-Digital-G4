`timescale 1ns / 1ps

module tb_rom();
    logic clk;
    logic valid;
    logic ready;
    logic [31:0] addr;
    logic [31:0] rdata;
    logic [15:0] leds;

    // Instancia del módulo memory (fijando entradas que no usaremos en '0')
    memory dut (
        .clk(clk),
        .pll_locked(1'b1),
        .valid(valid),
        .ready(ready),
        .addr(addr),
        .wdata(32'h0),
        .wstrb(4'h0),
        .rdata(rdata),
        .led_out(leds),
        .sw_in(16'h0)
    );

    // Generador de reloj
    always #5 clk = ~clk;

    initial begin
        // Inicialización
        clk = 0;
        valid = 0;
        addr = 0;
        
        #20;
        
        // --- PRUEBA 1: Lectura de Dirección 0x0000 ---
        $display("--- Iniciando lectura de ROM ---");
        valid = 1;
        addr = 32'h0000_0000;
        #10;
        $display("Direccion: %h | Dato: %h", addr, rdata);
        
        // --- PRUEBA 2: Lectura de Dirección 0x0004 ---
        addr = 32'h0000_0004;
        #10;
        $display("Direccion: %h | Dato: %h", addr, rdata);

        // --- PRUEBA 3: Lectura fuera de rango (debe dar NOP: 00000013) ---
        addr = 32'h0000_0900;
        #10;
        $display("Direccion Fuera de Rango: %h | Dato: %h", addr, rdata);

        #50;
        $display("--- Testbench ROM Finalizado ---");
        $finish;
    end
endmodule