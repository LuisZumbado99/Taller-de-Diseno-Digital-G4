module top (
    input  logic CLK100MHZ,
    input  logic rst_btn,
    output logic [15:0] led
);

    logic clk_sys;
    logic pll_locked;


    // PLL

   clock_gen clk_inst (
        .clk_in(CLK100MHZ),
        .rst(rst_btn),
        .clk_out(clk_sys),
        .locked(pll_locked)
    );


    // Reset activo en bajo para PicoRV32

   logic resetn;
    assign resetn = pll_locked;
 
 
    // Señales de memoria

    logic        mem_valid;
    logic        mem_ready;
    logic [31:0] mem_addr;
    logic [31:0] mem_wdata;
    logic [3:0]  mem_wstrb;
    logic [31:0] mem_rdata;


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


    // Memoria (ROM + RAM)

    memory mem_inst (
        .clk        (clk_sys),
        .mem_valid  (mem_valid),
        .mem_ready  (mem_ready),
        .mem_addr   (mem_addr),
        .mem_wdata  (mem_wdata),
        .mem_wstrb  (mem_wstrb),
        .mem_rdata  (mem_rdata)
    );

    // Debug (opcional)

    assign led[0] = pll_locked;

endmodule
