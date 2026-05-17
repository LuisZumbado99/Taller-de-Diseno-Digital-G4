module top (
    input  logic        CLK100MHZ,
    input  logic        rst_btn,
    input  logic [15:0] sw,
    input  logic        uart_rx,
    output logic        uart_tx,
    output logic [15:0] led
);

    // 1. Reloj y Reset Sincronizado
    logic clk_sys, pll_locked, resetn;
    logic [15:0] rst_reg;

    clk_wiz_wrapper clock_inst (
        .clk_in1 (CLK100MHZ),
        .reset   (~rst_btn), 
        .clk_out1(clk_sys),
        .locked  (pll_locked)
    );

    always_ff @(posedge clk_sys or negedge pll_locked) begin
        if (!pll_locked) begin
            rst_reg <= '0;
            resetn  <= 1'b0;
        end else begin
            if (rst_reg < 16'hFFFF) begin
                rst_reg <= rst_reg + 1'b1;
                resetn  <= 1'b0;
            end else begin
                resetn <= 1'b1;
            end
        end
    end

    // --- MODIFICACIÓN ISSUE #12: Sincronización y Anti-rebote ---
    logic [15:0] sw_cleaned;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_debouncers
            debouncer #(
                .CLK_FREQ(10_000_000), // Ajustado a los 10MHz de clk_sys
                .TIMEOUT_MS(10)        // 10ms de tiempo de estabilidad
            ) sw_db_inst (
                .clk(clk_sys),
                .sw_in(sw[i]),
                .sw_out(sw_cleaned[i])
            );
        end
    endgenerate
    // ------------------------------------------------------------

    // 2. Señales del Bus Maestro (CPU)
    logic        mem_valid, mem_ready;
    logic [31:0] mem_addr, mem_wdata, mem_rdata;
    logic [3:0]  mem_wstrb;

    // 3. Señales de Periféricos (Esclavos)
    // Se agregan uart_valid, uart_ready y uart_rdata para Issues #13 y #14
    logic rom_valid, rom_ready, ram_valid, ram_ready, spi_valid, spi_ready;
    logic uart_valid, uart_ready;
    logic [31:0] rom_rdata, ram_rdata, spi_rdata, uart_rdata;

    // 4. Instancia del Core PicoRV32
    picorv32 #(
        .ENABLE_COUNTERS(1),
        .ENABLE_REGS_16_31(1),
        .ENABLE_REGS_DUALPORT(1),
        .STACKADDR(32'h0007_FFFF) 
    ) cpu (
        .clk      (clk_sys),
        .resetn   (resetn),
        .mem_valid(mem_valid),
        .mem_ready(mem_ready),
        .mem_addr (mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata)
    );

    // 5. Instancia del Interconector (Modificado para incluir la UART)
    bus_interconnect bus_inst (
        .clk      (clk_sys),
        .mem_valid(mem_valid),
        .mem_ready(mem_ready),
        .mem_addr (mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata),
        // Conexiones de esclavos de memoria y SPI
        .rom_valid(rom_valid), .rom_ready(rom_ready), .rom_rdata(rom_rdata),
        .ram_valid(ram_valid), .ram_ready(ram_ready), .ram_rdata(ram_rdata),
        .spi_valid(spi_valid), .spi_ready(spi_ready), .spi_rdata(spi_rdata),
        // Conexiones del nuevo esclavo UART
        .uart_valid(uart_valid), .uart_ready(uart_ready), .uart_rdata(uart_rdata)
    );

    // 6. Instancias de Memorias y Periféricos
    memory mem_inst (
        .clk(clk_sys), 
        .pll_locked(pll_locked),
        .valid(rom_valid), 
        .ready(rom_ready),
        .addr(mem_addr), 
        .wdata(mem_wdata), 
        .wstrb(mem_wstrb), 
        .rdata(rom_rdata),
        .led_out(led), 
        .sw_in(sw_cleaned) 
    );

    data_ram ram_inst (
        .clk(clk_sys), .valid(ram_valid), .ready(ram_ready),
        .addr(mem_addr), .wdata(mem_wdata), .wstrb(mem_wstrb), .rdata(ram_rdata)
    );

    uart_peripheral #(
        .CLK_FREQ_HZ(10_000_000), // Sobreescritura crítica: Forzamos los 10MHz del clk_sys
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
        
        // Conexión externa a los pines de la Nexys 4
        .uart_rx_i (uart_rx),
        .uart_tx_o (uart_tx),
        
        // Señales de diagnóstico (puedes dejarlas desconectadas si no las usas)
        .diag_donerx(),
        .diag_new_rx(),
        .diag_tx_start()
    );

    // 7. Dummy SPI (Se mantiene hasta el desarrollo del acelerómetro)
    assign spi_ready = spi_valid;
    assign spi_rdata = 32'hADAB362;

endmodule