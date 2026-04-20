module top (
    input  logic CLK100MHZ,
    input  logic rst_btn,
    input  logic [15:0] sw,
    input  logic uart_rx,     
    output logic uart_tx,     
    output logic [15:0] led
);


    // Reloj

    logic clk_sys;
    logic pll_locked;

    clock_gen clk_inst (
        .clk_in(CLK100MHZ),
        .rst(rst_btn),
        .clk_out(clk_sys),
        .locked(pll_locked)
    );


    // Reset

    logic resetn;
    assign resetn = pll_locked;


    // Señales CPU

    logic        mem_valid;
    logic        mem_ready;
    logic [31:0] mem_addr;
    logic [31:0] mem_wdata;
    logic [3:0]  mem_wstrb;
    logic [31:0] mem_rdata;

 
    // LEDs internos
 
    logic [15:0] led_internal;

 
    // CPU
 
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
        .sw_in      (sw),

        // UART conectado
        .uart_rx    (uart_rx),
        .uart_tx    (uart_tx)
    );

 
    // Salida LEDs
 
    assign led = led_internal;

endmodule
