module Ejercicio_1tb();
    // Senales de prueba
    logic [3:0] sw;
    logic [3:0] led;
    logic [3:0] expected_led;
    int errors = 0;

    // Instancia del modulo (Unit Under Test)
    Ejercicio_1 uut (
        .sw(sw),
        .led(led)
    );

    initial begin
        $display("Iniciando testbench auto-comprobado...");
        
        // Probar todas las combinaciones posibles (0 a 15)
        for (int i = 0; i < 16; i++) begin
            sw = i;
            expected_led = -i; // Calculo de referencia
            #10; // Esperar retardo de propagacion simulado

            if (led !== expected_led) begin
                $display("ERROR: Entrada %b | Salida %b | Esperado %b", sw, led, expected_led);
                errors++;
            end else begin
                $display("OK: Entrada %b | Salida %b", sw, led);
            end
        end

        if (errors == 0)
            $display("TEST EXITOSO: Todas las combinaciones son correctas.");
        else
            $display("TEST FALLIDO: Se encontraron %d errores.", errors);
            
        $finish;
    end
endmodule