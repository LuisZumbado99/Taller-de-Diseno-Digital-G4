`timescale 1ns / 1ps

module tb_leds();
    logic clk = 0;
    logic valid, ready;
    logic [31:0] addr, wdata, rdata;
    logic [3:0] wstrb;
    logic [15:0] led_out;

    // Instancia del módulo de memoria/periféricos
    memory dut (
        .clk(clk),
        .pll_locked(1'b1),
        .valid(valid),
        .ready(ready),
        .addr(addr),
        .wdata(wdata),
        .wstrb(wstrb),
        .rdata(rdata),
        .led_out(led_out),
        .sw_in(16'h0)
    );

    always #5 clk = ~clk;

    initial begin
        // Inicialización
        valid = 0; addr = 0; wdata = 0; wstrb = 0;
        #20;

        // --- PRUEBA: Escritura en Registro de LEDs (0x2004) ---
        @(posedge clk);
        valid = 1;
        addr  = 32'h0000_2004;
        wdata = 32'h0000_0A5A; // Patrón de prueba
        wstrb = 4'b1111;       // Escribir todos los bytes
        
        @(posedge clk);
        valid = 0;
        wstrb = 0;

        #10;
        if (led_out[11:0] == 12'hA5A) 
            $display("TEST PASSED: LEDs muestran el valor correcto: %h", led_out[11:0]);
        else 
            $display("TEST FAILED: Valor esperado A5A, obtenido %h", led_out[11:0]);

        #50;
        $finish;
    end
endmodule