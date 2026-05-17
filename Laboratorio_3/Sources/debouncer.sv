`timescale 1ns / 1ps

module debouncer #(
    parameter CLK_FREQ = 10_000_000, // 10 MHz
    parameter TIMEOUT_MS = 10        // 10 ms para estabilidad
)(
    input  logic clk,
    input  logic sw_in,
    output logic sw_out
);
    // 1. Sincronizador de 2 etapas (Elimina metaestabilidad)
    logic sync_0, sync_1;
    always_ff @(posedge clk) begin
        sync_0 <= sw_in;
        sync_1 <= sync_0;
    end

    // 2. Contador para Anti-rebote
    localparam COUNT_MAX = CLK_FREQ / 1000 * TIMEOUT_MS;
    integer count = 0;
    logic stable_sw = 0;

    always_ff @(posedge clk) begin
        if (sync_1 != stable_sw) begin
            if (count < COUNT_MAX)
                count <= count + 1;
            else begin
                stable_sw <= sync_1;
                count <= 0;
            end
        end else begin
            count <= 0;
        end
    end

    assign sw_out = stable_sw;
endmodule