module top (
    input  logic CLK100MHZ,
    input  logic rst_btn,
    output logic [15:0] led
);

    logic clk_sys;
    logic pll_locked;

    // Instancia del PLL
    clock_gen clk_inst (
        .clk_in(CLK100MHZ),
        .rst(rst_btn),
        .clk_out(clk_sys),
        .locked(pll_locked)
    );

    // Reset sincronizado (MUY recomendado)
    logic rst_sync;

    assign rst_sync = ~pll_locked;

    // Aquí conectas tu CPU
    // Ejemplo:
    /*
    picorv32 cpu (
        .clk(clk_sys),
        .resetn(~rst_sync),
        ...
    );
    */

endmodule