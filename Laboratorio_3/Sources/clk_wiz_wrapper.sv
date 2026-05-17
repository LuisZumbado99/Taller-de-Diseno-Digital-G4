module clk_wiz_wrapper (
    input  logic clk_in1,  // Reloj 100MHz
    input  logic reset,    // Reset (Active High para el IP)
    output logic clk_out1, // Reloj 10MHz
    output logic locked    // Señal de estabilidad
);

    // Instancia del IP generado por Vivado
    // Asegúrate de que el nombre clk_wiz_0 coincida con tu IP Catalog
    clk_wiz_0 pll_inst (
        .clk_out1(clk_out1),
        .reset(reset),
        .locked(locked),
        .clk_in1(clk_in1)
    );

endmodule