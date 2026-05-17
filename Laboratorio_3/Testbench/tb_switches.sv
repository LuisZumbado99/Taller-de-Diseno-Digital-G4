`timescale 1ns / 1ps
module tb_switches();
    logic clk = 0;
    logic sw_raw;
    logic sw_clean;

    debouncer #(.CLK_FREQ(1000), .TIMEOUT_MS(5)) dut (
        .clk(clk), .sw_in(sw_raw), .sw_out(sw_clean)
    );

    always #5 clk = ~clk;

    initial begin
        sw_raw = 0; #50;
        
        // Simular rebotes
        sw_raw = 1; #10; sw_raw = 0; #10;
        sw_raw = 1; #10; sw_raw = 0; #10;
        sw_raw = 1; // Se mantiene estable
        
        #200; // Esperar tiempo de estabilidad
        if (sw_clean) $display("Éxito: Señal estabilizada.");
        $finish;
    end
endmodule