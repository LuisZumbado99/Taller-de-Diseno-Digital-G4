module Ejercicio_2tb();
    // Parámetro para cambiar el ancho de datos en cada corrida
    parameter W = 16; 
    
    // Señales de interconexión
    logic [W-1:0] d0, d1, d2, d3;
    logic [1:0] sel;
    logic [W-1:0] y;
    logic [W-1:0] expected_y;
    
    int errors = 0;
    int i;

    // Instancia del multiplexor con el parámetro actual
    Ejercicio_2 #(.WIDTH(W)) uut (
        .d0(d0), .d1(d1), .d2(d2), .d3(d3),
        .sel(sel),
        .y(y)
    );

    // Tarea para verificar el resultado automáticamente
    task check_result;
        begin
            case(sel)
                2'b00: expected_y = d0;
                2'b01: expected_y = d1;
                2'b10: expected_y = d2;
                2'b11: expected_y = d3;
            endcase
            #1; // Pequeño retraso para dejar que la lógica combinacional se estabilice
            if (y !== expected_y) begin
                $display("ERROR en iteración %0d: sel=%b | y=%h | esperado=%h", i, sel, y, expected_y);
                errors++;
            end
        end
    endtask

    initial begin
        $display("--- Iniciando prueba para WIDTH = %0d ---", W);
        
        // Generar 50 casos de prueba aleatorios
        for (i = 0; i < 50; i++) begin
            // Generación de datos aleatorios
            d0 = $urandom;
            d1 = $urandom;
            d2 = $urandom;
            d3 = $urandom;
            sel = $urandom_range(0, 3);
            
            #10; // Esperar tiempo entre estímulos
            check_result();
        end

        if (errors == 0)
            $display("--- PRUEBA EXITOSA: 50/50 casos correctos para WIDTH %0d ---", W);
        else
            $display("--- PRUEBA FALLIDA: %0d errores detectados ---", errors);

        $stop; // Detener la simulación para revisar las ondas
    end
endmodule