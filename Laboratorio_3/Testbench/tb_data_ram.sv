`timescale 1ns / 1ps

module tb_data_ram();
    logic clk;
    logic valid;
    logic ready;
    logic [31:0] addr;
    logic [31:0] wdata;
    logic [3:0]  wstrb;
    logic [31:0] rdata;

    // Instancia del módulo RAM (100 KiB)
    data_ram dut (
        .clk(clk),
        .valid(valid),
        .ready(ready),
        .addr(addr),
        .wdata(wdata),
        .wstrb(wstrb),
        .rdata(rdata)
    );

    // Generador de reloj (100MHz para la prueba)
    always #5 clk = ~clk;

    initial begin
        // Inicialización
        clk = 0;
        valid = 0;
        addr = 0;
        wdata = 0;
        wstrb = 0;
        
        #20;
        
        $display("--- Iniciando Validación de RAM (Issue #9) ---");

        // --- PRUEBA 1: Escritura Completa (Word) ---
        // Escribimos en la dirección base de la RAM: 0x40000
        @(posedge clk);
        valid = 1;
        addr  = 32'h0004_0000;
        wdata = 32'hDEADBEEF;
        wstrb = 4'b1111; // Escribir los 4 bytes
        
        @(posedge clk);
        valid = 0; // Desactivar valid para ver persistencia
        
        // --- PRUEBA 2: Lectura de la Word escrita ---
        @(posedge clk);
        valid = 1;
        wstrb = 4'b0000; // Modo lectura
        #2; // Pequeño delay para ver el cambio de rdata
        $display("Direccion: %h | Escrito: DEADBEEF | Leido: %h", addr, rdata);

        // --- PRUEBA 3: Escritura de Byte (wstrb parcial) ---
        // Vamos a cambiar solo el byte más bajo de DEADBEEF por 0xAA
        // Resultado esperado: DEADBEAA
        @(posedge clk);
        addr  = 32'h0004_0000;
        wdata = 32'h0000_00AA;
        wstrb = 4'b0001; // Solo el primer byte
        
        @(posedge clk);
        wstrb = 4'b0000; // Volver a lectura
        #2;
        $display("Direccion: %h | Esperado: DEADBEAA | Leido: %h", addr, rdata);

        // --- PRUEBA 4: Verificación de límite superior ---
        // Probar una dirección cercana al final de los 100KiB (0x7FFFF)
        @(posedge clk);
        addr  = 32'h0007_FFFC; // Última palabra alineada
        wdata = 32'h12345678;
        wstrb = 4'b1111;
        
        @(posedge clk);
        wstrb = 4'b0000;
        #2;
        $display("Ultima Direccion: %h | Escrito: 12345678 | Leido: %h", addr, rdata);

        #50;
        $display("--- Validación de RAM Finalizada ---");
        $finish;
    end
endmodule