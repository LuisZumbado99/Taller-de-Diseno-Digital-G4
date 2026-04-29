module top (
    input  logic        CLK100MHZ,
    input  logic        rst_btn,
    input  logic [15:0] sw,
    input  logic        uart_rx,
    output logic        uart_tx,
    output logic [15:0] led
);

    // -------------------------------------------------------------------------
    // Generación de reloj (100 MHz via PLL)
    // -------------------------------------------------------------------------
    
    logic clk_sys, pll_locked;

    clk_wiz_0 pll_inst (
        .clk_in1 (CLK100MHZ),
        .reset   (1'b0),
        .clk_out1(clk_sys),
        .locked  (pll_locked)
    );

    // -------------------------------------------------------------------------
    // Reset sincronizado:
    // -------------------------------------------------------------------------
    
    logic [15:0] rst_reg;
    logic        resetn;

    always_ff @(posedge clk_sys or negedge pll_locked) begin
        if (!pll_locked) begin
            rst_reg <= '0;
            resetn  <= 1'b0;
        end else begin
            if (!rst_btn) begin
                rst_reg <= '0;
                resetn  <= 1'b0;
            end else begin
                if (rst_reg < 16'hFFFF)
                    rst_reg <= rst_reg + 1'b1;
                else
                    resetn <= 1'b1;
            end
        end
    end

    // -------------------------------------------------------------------------
    // Heartbeat - con 100 MHz, bit[25] parpadea a ~1.5 Hz
    // -------------------------------------------------------------------------
    
    logic [25:0] heartbeat;
    always_ff @(posedge clk_sys or negedge resetn) begin
        if (!resetn) heartbeat <= '0;
        else         heartbeat <= heartbeat + 1'b1;
    end

    // -------------------------------------------------------------------------
    // Señales del bus principal (PicoRV32 → bus_interconnect)
    // -------------------------------------------------------------------------
    
    logic        mem_valid, mem_ready;
    logic [31:0] mem_addr,  mem_wdata, mem_rdata;
    logic [3:0]  mem_wstrb;

    // -------------------------------------------------------------------------
    // Señales hacia ROM/GPIO (memory.sv)
    // -------------------------------------------------------------------------
    
    logic        rom_valid, rom_ready;
    logic [31:0] rom_addr,  rom_wdata, rom_rdata;
    logic [3:0]  rom_wstrb;

    // -------------------------------------------------------------------------
    // Señales hacia RAM de datos (data_ram.sv)
    // -------------------------------------------------------------------------
    
    logic        ram_valid, ram_ready;
    logic [31:0] ram_addr,  ram_wdata, ram_rdata;
    logic [3:0]  ram_wstrb;

    // -------------------------------------------------------------------------
    // Señales hacia UART peripheral
    // -------------------------------------------------------------------------
    
    logic        uart_valid, uart_ready;
    logic [31:0] uart_addr,  uart_wdata, uart_rdata;
    logic [3:0]  uart_wstrb;

    // -------------------------------------------------------------------------
    // PicoRV32
    // -------------------------------------------------------------------------
    
    picorv32 #(
        .PROGADDR_RESET (32'h0),
        .STACKADDR      (32'h60000),
        .TWO_STAGE_SHIFT(1)
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

    // -------------------------------------------------------------------------
    // Bus interconnect
    // -------------------------------------------------------------------------
    
    bus_interconnect bus_inst (
        .clk       (clk_sys),
        .mem_valid (mem_valid),
        .mem_ready (mem_ready),
        .mem_addr  (mem_addr),
        .mem_wdata (mem_wdata),
        .mem_wstrb (mem_wstrb),
        .mem_rdata (mem_rdata),

        .rom_valid (rom_valid),
        .rom_ready (rom_ready),
        .rom_addr  (rom_addr),
        .rom_wdata (rom_wdata),
        .rom_wstrb (rom_wstrb),
        .rom_rdata (rom_rdata),

        .ram_valid (ram_valid),
        .ram_ready (ram_ready),
        .ram_addr  (ram_addr),
        .ram_wdata (ram_wdata),
        .ram_wstrb (ram_wstrb),
        .ram_rdata (ram_rdata),

        .uart_valid(uart_valid),
        .uart_ready(uart_ready),
        .uart_addr (uart_addr),
        .uart_wdata(uart_wdata),
        .uart_wstrb(uart_wstrb),
        .uart_rdata(uart_rdata)
    );

    // -------------------------------------------------------------------------
    // ROM + GPIO (memory.sv - maneja 0x0000-0x0FFF y 0x2000-0x200F)
    // -------------------------------------------------------------------------
    
    logic [15:0] mem_leds;

    memory mem_inst (
        .clk       (clk_sys),
        .pll_locked(pll_locked),
        .valid     (rom_valid),
        .ready     (rom_ready),
        .addr      (rom_addr),
        .wdata     (rom_wdata),
        .wstrb     (rom_wstrb),
        .rdata     (rom_rdata),
        .led_out   (mem_leds),
        .sw_in     (sw)
    );

    // -------------------------------------------------------------------------
    // RAM de datos (data_ram.sv - 0x40000-0x7FFFF)
    // -------------------------------------------------------------------------
    
    data_ram ram_inst (
        .clk  (clk_sys),
        .valid(ram_valid),
        .ready(ram_ready),
        .addr (ram_addr),
        .wdata(ram_wdata),
        .wstrb(ram_wstrb),
        .rdata(ram_rdata)
    );

    // -------------------------------------------------------------------------
    // UART peripheral - 100 MHz, 9600 baudios
    // -------------------------------------------------------------------------
    
    logic diag_donerx;
    logic diag_new_rx;
    logic diag_tx_start;
    logic uart_tx_internal;

    uart_peripheral #(
        .CLK_FREQ_HZ(100_000_000),
        .BAUD_RATE  (9600)
    ) u_inst (
        .clk          (clk_sys),
        .resetn       (resetn),
        .mem_valid    (uart_valid),
        .mem_addr     (uart_addr),
        .mem_wdata    (uart_wdata),
        .mem_wstrb    (uart_wstrb),
        .mem_rdata    (uart_rdata),
        .mem_ready    (uart_ready),
        .uart_rx_i    (uart_rx),
        .uart_tx_o    (uart_tx_internal),
        .diag_donerx  (diag_donerx),
        .diag_new_rx  (diag_new_rx),
        .diag_tx_start(diag_tx_start)
    );

    logic donerx_sticky;
    always_ff @(posedge clk_sys or negedge resetn) begin
        if (!resetn)          donerx_sticky <= 1'b0;
        else if (diag_donerx) donerx_sticky <= 1'b1;
    end

    // -------------------------------------------------------------------------
    // TX: idle en '1' durante reset, procesador activo en operación normal
    // -------------------------------------------------------------------------
    
    assign uart_tx = resetn ? uart_tx_internal : 1'b1;

    // -------------------------------------------------------------------------
    // LEDs de diagnóstico
    // -------------------------------------------------------------------------
    
    assign led = {
        pll_locked,      // [15]
        donerx_sticky,   // [14]
        diag_new_rx,     // [13]
        uart_valid,      // [12]
        heartbeat[25],   // [11]
        diag_tx_start,   // [10]
        uart_rx,         // [9]
        resetn,          // [8]
        mem_leds[7:0]    // [7:0]
    };

endmodule
