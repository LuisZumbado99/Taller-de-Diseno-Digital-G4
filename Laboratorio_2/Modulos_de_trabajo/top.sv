module top (
    input  logic CLK100MHZ,
    input  logic rst_btn,
    input  logic [15:0] sw,
    output logic [15:0] led
);

 
    // Señales de reloj
 
    logic clk_sys;
    logic pll_locked;

 
    // PLL

    clock_gen clk_inst (
        .clk_in(CLK100MHZ),
        .rst(rst_btn),
        .clk_out(clk_sys),
        .locked(pll_locked)
    );

 
    // Reset activo en bajo
 
    logic resetn;
    assign resetn = pll_locked;

 
    // Señales de memoria (CPU)
 
    logic        mem_valid;
    logic        mem_ready;
    logic [31:0] mem_addr;
    logic [31:0] mem_wdata;
    logic [3:0]  mem_wstrb;
    logic [31:0] mem_rdata;

 
    // Señal interna de LEDs
 
    logic [15:0] led_internal;

 
    // CPU PicoRV32
 
    picorv32 cpu (
        .clk         (clk_sys),
        .resetn      (resetn),

        .mem_valid   (mem_valid),
        .mem_ready   (mem_ready),
        .mem_addr    (mem_addr),
        .mem_wdata   (mem_wdata),
        .mem_wstrb   (mem_wstrb),
        .mem_rdata   (mem_rdata)
    );

 
    // Memoria + periféricos
 
    memory mem_inst (
        .clk        (clk_sys),
        .mem_valid  (mem_valid),
        .mem_ready  (mem_ready),
        .mem_addr   (mem_addr),
        .mem_wdata  (mem_wdata),
        .mem_wstrb  (mem_wstrb),
        .mem_rdata  (mem_rdata),
        .led_out    (led_internal),
        .sw_in      (sw)
    );

 
    // Salida a LEDs físicos
 
    assign led = led_internal;

endmodule
