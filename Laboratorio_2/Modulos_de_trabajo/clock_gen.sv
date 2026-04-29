module clock_gen (
    input  logic clk_in,
    input  logic rst,
    output logic clk_out,
    output logic locked
);

    wire pll_reset = ~rst; 

    clk_wiz_0 pll_inst (
        .clk_in1(clk_in),
        .reset(pll_reset),
        .clk_out1(clk_out),
        .locked(locked)
    );
endmodule
