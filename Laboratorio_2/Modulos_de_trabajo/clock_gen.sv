module clock_gen (
    input  logic clk_in,     // 100 MHz (Nexys4)
    input  logic rst,        // reset externo
    output logic clk_out,    // reloj generado
    output logic locked      // indica estabilidad
);

    // Señal interna de reset para el PLL
    logic resetn;

    assign resetn = ~rst;

    // Instancia del Clock Wizard (PLL/MMCM)
    clk_wiz_0 pll_inst (
        .clk_in1(clk_in),
        .reset(rst),
        .clk_out1(clk_out),
        .locked(locked)
    );

endmodule