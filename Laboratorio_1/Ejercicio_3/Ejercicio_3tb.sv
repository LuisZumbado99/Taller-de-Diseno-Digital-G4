module Ejercicio_3tb();
    // Senales de prueba
    logic clk;
    logic rst;
    logic [3:0] duty_sw;
    logic pwm_out;

    // Instancia del modulo PWM (Unit Under Test)
    Ejercicio_3 uut (
        .clk(clk),
        .rst(rst),
        .duty_sw(duty_sw),
        .pwm_out(pwm_out)
    );

    // Generacion de reloj de 100MHz (10ns de periodo)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Reset inicial
        rst = 1;
        duty_sw = 4'b0000;
        #100;
        rst = 0;
        $display("Iniciando validacion exhaustiva de PWM...");

        // Caso 1: 0% Duty Cycle (LED apagado)
        duty_sw = 4'd0;
        #(1000000); // Esperar 1ms (un periodo completo)
        
        // Caso 2: 25% Duty Cycle (duty_sw = 4 de 16 niveles)
        duty_sw = 4'd4;
        #(2000000); // Esperar 2ms para observar dos ciclos
        
        // Caso 3: 50% Duty Cycle (duty_sw = 8)
        duty_sw = 4'd8;
        #(2000000);
        
        // Caso 4: 100% Duty Cycle (duty_sw = 15 aprox. maximo)
        duty_sw = 4'd15;
        #(2000000);

        $display("Prueba finalizada. Revise las formas de onda para confirmar los anchos de pulso.");
        $finish;
    end
endmodule