module top (
    input  logic CLK100MHZ,
    input  logic rst_btn,
    input  logic [15:0] sw,
    input  logic uart_rx,
    output logic uart_tx,
    output logic [15:0] led
);

 
    // Clock
 
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
 
    (* KEEP = "TRUE" *) logic [15:0] sw_keep;
    assign sw_keep = sw;

 
    // CPU signals
 
    logic        mem_valid;
    logic        mem_ready;
    logic [31:0] mem_addr;
    logic [31:0] mem_wdata;
    logic [3:0]  mem_wstrb;
    logic [31:0] mem_rdata;


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

 
    // BUS signals → MEMORY
 
    logic        mem_s_valid;
    logic        mem_s_ready;
    logic [31:0] mem_s_addr;
    logic [31:0] mem_s_wdata;
    logic [3:0]  mem_s_wstrb;
    logic [31:0] mem_s_rdata;

 
    // BUS signals → UART
 
    logic        uart_valid;
    logic        uart_ready;
    logic [31:0] uart_addr;
    logic [31:0] uart_wdata;
    logic [3:0]  uart_wstrb;
    logic [31:0] uart_rdata;

 
    // BUS (INTERCONNECT)
 
    bus_interconnect bus (
        .clk(clk_sys),

        // MASTER (CPU)
        .mem_valid(mem_valid),
        .mem_ready(mem_ready),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata),

        // MEMORY
        .ram_valid(mem_s_valid),
        .ram_ready(mem_s_ready),
        .ram_addr(mem_s_addr),
        .ram_wdata(mem_s_wdata),
        .ram_wstrb(mem_s_wstrb),
        .ram_rdata(mem_s_rdata),

        // No usados
        .rom_valid(),
        .rom_ready(1'b0),
        .rom_addr(),
        .rom_rdata(32'b0),

        .io_valid(),
        .io_ready(1'b0),
        .io_addr(),
        .io_wdata(),
        .io_wstrb(),
        .io_rdata(),

        // UART
        .uart_valid(uart_valid),
        .uart_ready(uart_ready),
        .uart_addr(uart_addr),
        .uart_wdata(uart_wdata),
        .uart_wstrb(uart_wstrb),
        .uart_rdata(uart_rdata)
    );

 
    // MEMORY (ROM + RAM + GPIO)
 
    memory mem_inst (
        .clk   (clk_sys),

        .valid (mem_s_valid),
        .ready (mem_s_ready),
        .addr  (mem_s_addr),
        .wdata (mem_s_wdata),
        .wstrb (mem_s_wstrb),
        .rdata (mem_s_rdata),

        .led_out (led),
        .sw_in   (sw_keep) 
    );

 
    // UART
 
    uart_peripheral uart0 (
        .clk        (clk_sys),
        .resetn     (resetn),

        .mem_valid  (uart_valid),
        .mem_addr   (uart_addr),
        .mem_wdata  (uart_wdata),
        .mem_wstrb  (uart_wstrb),
        .mem_rdata  (uart_rdata),
        .mem_ready  (uart_ready),

        .uart_rx_i  (uart_rx),
        .uart_tx_o  (uart_tx)
    );

endmodule
