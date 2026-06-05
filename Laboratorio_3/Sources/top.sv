module top (
    input  logic        CLK100MHZ,
    input  logic        rst_btn,
    input  logic [15:0] sw,
    input  logic        uart_rx,
    output logic        uart_tx,
    output logic [15:0] led,

    // --- Pines físicos para el Acelerómetro SPI de la Nexys 4 DDR ---
    output logic        ACL_SCLK,
    output logic        ACL_MOSI,
    input  logic        ACL_MISO,
    output logic        ACL_CSN
);

    // -------------------------------------------------------------------------
    // 1. Reloj y Reset Sincronizado Robustecido
    // -------------------------------------------------------------------------
    logic clk_sys, pll_locked, resetn;
    logic [15:0] rst_reg;

    clk_wiz_wrapper clock_inst (
        .clk_in1 (CLK100MHZ),
        .reset   (~rst_btn), 
        .clk_out1(clk_sys),
        .locked  (pll_locked)
    );

    // Si el botón de reset externo es presionado (0) o el PLL pierde seguro,
    // se fuerza la bajada de la señal global resetn inmediatamente para limpiar registros.
    always_ff @(posedge clk_sys or negedge pll_locked) begin
        if (!pll_locked || !rst_btn) begin
            rst_reg <= '0;
            resetn  <= 1'b0;
        end else begin
            if (rst_reg < 16'hFFFF) begin
                rst_reg <= rst_reg + 1'b1;
                resetn  <= 1'b0;
            end else begin
                resetn  <= 1'b1; // Sale del reset tras 65535 ciclos estables de clk_sys
            end
        end
    end

    // -------------------------------------------------------------------------
    // 2. Sincronización y Filtrado de Switches (GPIO)
    // -------------------------------------------------------------------------
    logic [15:0] sw_sync_0, sw_sync_1, sw_cleaned;
    always_ff @(posedge clk_sys) begin
        sw_sync_0   <= sw;
        sw_sync_1   <= sw_sync_0;
        sw_cleaned  <= sw_sync_1;
    end

    // -------------------------------------------------------------------------
    // 3. Interconexión de Buses de Memoria
    // -------------------------------------------------------------------------
    wire        mem_valid;
    wire        mem_ready;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0]  mem_wstrb;
    wire [31:0] mem_rdata;

    wire        rom_valid, rom_ready;
    wire [31:0] rom_rdata;
    wire        ram_valid, ram_ready;
    wire [31:0] ram_rdata;
    wire        spi_valid, spi_ready;
    wire [31:0] spi_rdata;
    wire        uart_valid, uart_ready;
    wire [31:0] uart_rdata;

    bus_interconnect bus_inst (
        .clk       (clk_sys),
        .mem_valid (mem_valid),
        .mem_ready (mem_ready),
        .mem_addr  (mem_addr),
        .mem_wdata (mem_wdata),
        .mem_wstrb (mem_wstrb),
        .mem_rdata (mem_rdata),

        .rom_valid (rom_valid), .rom_ready (rom_ready), .rom_rdata (rom_rdata),
        .ram_valid (ram_valid), .ram_ready (ram_ready), .ram_rdata (ram_rdata),
        .spi_valid (spi_valid), .spi_ready (spi_ready), .spi_rdata (spi_rdata),
        .uart_valid(uart_valid),.uart_ready(uart_ready),.uart_rdata(uart_rdata)
    );

    // -------------------------------------------------------------------------
    // 4. Instanciación del Procesador PicoRV32 Core
    // -------------------------------------------------------------------------
    picorv32 cpu_core (
        .clk      (clk_sys),
        .resetn   (resetn),
        .trap     (), 
        .mem_valid(mem_valid),
        .mem_instr(),
        .mem_ready(mem_ready),
        .mem_addr (mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata)
    );

    // -------------------------------------------------------------------------
    // 5. Registro espejo directo para los LEDs bajos (led[7:0])
    // -------------------------------------------------------------------------
    // Captura escrituras a la dirección 0x00002004 de forma global en el bus común
    logic [7:0] led_bajos_reg;

    always_ff @(posedge clk_sys) begin
        if (!resetn) begin
            led_bajos_reg <= 8'h00;
        end else begin
            if (mem_valid && mem_ready && (mem_addr == 32'h00002004) && mem_wstrb[0]) begin
                led_bajos_reg <= mem_wdata[7:0];
            end
        end
    end

    // -------------------------------------------------------------------------
    // 6. Instanciación de Periféricos del Sistema y Telemetría del Bus
    // -------------------------------------------------------------------------
    
    // CONTADOR GLOBAL DE ACTIVIDAD PARA EL LED 12
    // Este contador mira el bus general de la CPU (mem_valid && mem_ready).
    // Sumará CADA VEZ que el procesador ejecute exitosamente cualquier instrucción,
    // ya sea en la ROM, RAM o SPI, evitando que el LED 12 se congele en los bucles wait.
    logic [23:0] global_cpu_activity = 24'd0;
    always_ff @(posedge clk_sys) begin
        if (!resetn) begin
            global_cpu_activity <= '0;
        end else if (mem_valid && mem_ready) begin
            global_cpu_activity <= global_cpu_activity + 1'b1;
        end
    end

    logic [15:0] led_rom_wire; // Señal intermedia para capturar diagnóstico de la memoria

    memory rom_gpio_inst (
        .clk(clk_sys), 
        .pll_locked(pll_locked), 
        .valid(rom_valid), 
        .ready(rom_ready),
        .addr(mem_addr), 
        .wdata(mem_wdata), 
        .wstrb(mem_wstrb), 
        .rdata(rom_rdata),
        .led_out(led_rom_wire), // Redirigido a la señal intermedia
        .sw_in(sw_cleaned) 
    );

    // Asignación unificada de la barra externa final (CORREGIDA):
    // led[15:13] = Diagnóstico de estados directos de la memoria (Locked, Valid, Ready)
    // led[12]    = Conectado a la telemetría real del bus completo (¡Ya nunca se quedará fijo!)
    // led[11:8]  = Datos altos de la barra original de la ROM
    // led[7:0]   = El registro espejo libre de colisiones por decodificación
    assign led[15:13] = led_rom_wire[15:13];
    assign led[12]    = global_cpu_activity[23]; // Reemplazo por la telemetría del bus global
    assign led[11:8]  = led_rom_wire[11:8];
    assign led[7:0]   = led_bajos_reg;

    data_ram ram_inst (
        .clk(clk_sys), .valid(ram_valid), .ready(ram_ready),
        .addr(mem_addr), .wdata(mem_wdata), .wstrb(mem_wstrb), .rdata(ram_rdata)
    );

    uart_peripheral #(
        .CLK_FREQ_HZ(10_000_000), 
        .BAUD_RATE(9600)
    ) uart_inst (
        .clk       (clk_sys),
        .resetn    (resetn),
        .mem_valid (uart_valid),
        .mem_ready (uart_ready),
        .mem_addr  (mem_addr),
        .mem_wdata (mem_wdata),
        .mem_wstrb (mem_wstrb),
        .mem_rdata (uart_rdata),
        
        .uart_rx_i (uart_rx),
        .uart_tx_o (uart_tx),
        
        .diag_donerx(),
        .diag_new_rx(),
        .diag_tx_start()
    );

    spi_peripheral #(
        .CLK_DIV(4) // Genera SCLK a 2.5 MHz (10MHz / 4)
    ) spi_inst (
        .clk       (clk_sys),
        .resetn    (resetn),
        .mem_valid (spi_valid),
        .mem_ready (spi_ready),
        .mem_addr  (mem_addr),
        .mem_wdata (mem_wdata),
        .mem_wstrb (mem_wstrb),
        .mem_rdata (spi_rdata),
        
        // Conexiones a los pines de la placa
        .sclk      (ACL_SCLK),
        .mosi      (ACL_MOSI),
        .miso      (ACL_MISO),
        .cs_n      (ACL_CSN)
    );

endmodule