`timescale 1ns / 1ps

module tb_clk_wiz();
    logic clk_in;
    logic rst_btn;
    logic [15:0] leds; // Ahora recibimos el vector de LEDs

    // Reloj de 100 MHz (periodo 10ns)
    initial begin
        clk_in = 0;
        forever #5 clk_in = ~clk_in;
    end

    // Instancia con los nombres actualizados (Nombres del XDC)
    clk_wiz_wrapper dut (
        .CLK100MHZ (clk_in),
        .rst_btn   (rst_btn),
        .led       (leds)
    );

    initial begin
        rst_btn = 0; // Reset activo (Active Low)
        #100;
        rst_btn = 1; // Liberar reset

        // Ahora verificamos el LED 15 en lugar de la señal 'locked'
        wait(leds[15] == 1'b1);
        $display("Simulacion exitosa: PLL Lock detectado en LED[15] a las %t", $time);
        
        #500;
        $finish;
    end
endmodule