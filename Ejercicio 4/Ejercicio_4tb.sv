`timescale 1ns/1ps

module Ejercicio_4tb();
    logic clk;
    logic rst_n;
    logic btn_send;
    logic rx_pin;
    logic tx_pin;
    logic [7:0] leds;

    Ejercicio_4 uut (.*);

    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Reloj de 100MHz
    end

    // Tiempo de bit exacto para 9600 baudios: 100MHz / 9600 = 10416 ciclos
    localparam BIT_PERIOD = 10416; 

    initial begin
        // --- Secuencia de Reset ---
        rst_n = 0;
        btn_send = 0;
        rx_pin = 1; 
        #100;
        rst_n = 1;
        #100;

        $display("--- Iniciando Simulación ---");

        // --- PRUEBA 1: Disparo forzado (Para ver tx_pin moverse) ---
        $display("Pulsando botón...");
        btn_send = 1;
        #200; // Mantenemos el botón un poco más para asegurar detección
        btn_send = 0;

        // Esperar a que la transmisión empiece (tx_pin baja a 0)
        // Usamos una guarda de tiempo para no quedar en espera infinita
        fork
            begin
                wait(tx_pin == 1'b0);
                $display("Start bit detectado en tx_pin!");
            end
            begin
                #1000000;
                $display("ERROR: Tiempo de espera agotado, no hay transmisión.");
            end
        join_any

        // --- PRUEBA 2: Recepción 'A' (0x41) ---
        // 0x41 binario: 01000001. LSB primero: 1-0-0-0-0-0-1-0
        $display("Simulando recepción de 'A'...");
        
        rx_pin = 0; #(BIT_PERIOD); // Start
        rx_pin = 1; #(BIT_PERIOD); // Bit 0 (LSB)
        rx_pin = 0; #(BIT_PERIOD); // Bit 1
        rx_pin = 0; #(BIT_PERIOD); // Bit 2
        rx_pin = 0; #(BIT_PERIOD); // Bit 3
        rx_pin = 0; #(BIT_PERIOD); // Bit 4
        rx_pin = 0; #(BIT_PERIOD); // Bit 5
        rx_pin = 1; #(BIT_PERIOD); // Bit 6
        rx_pin = 0; #(BIT_PERIOD); // Bit 7 (MSB)
        rx_pin = 1; #(BIT_PERIOD); // Stop
        
        #5000;
        $display("Simulación finalizada.");
        $finish;
    end
endmodule