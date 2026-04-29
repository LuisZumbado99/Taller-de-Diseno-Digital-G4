module data_ram (
    input  logic        clk,
    input  logic        valid,
    output logic        ready,
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    input  logic [3:0]  wstrb,
    output logic [31:0] rdata
);

    // 100 KiB = 102400 bytes = 25600 palabras de 32 bits
    localparam RAM_DEPTH = 25600;

    logic [31:0] mem [0:RAM_DEPTH-1];

    // Índice de palabra: restamos base 0x40000 y dividimos entre 4
    // addr[17:2] cubre exactamente los 25600 elementos (2^15 = 32768 > 25600)
    wire [14:0] word_idx = addr[16:2];  // bits suficientes para 25600 entradas

    // Respuesta en 1 ciclo
    assign ready = valid;

    always_ff @(posedge clk) begin
        if (valid) begin
            // Escritura con byte-enable (wstrb)
            if (wstrb[0]) mem[word_idx][ 7: 0] <= wdata[ 7: 0];
            if (wstrb[1]) mem[word_idx][15: 8] <= wdata[15: 8];
            if (wstrb[2]) mem[word_idx][23:16] <= wdata[23:16];
            if (wstrb[3]) mem[word_idx][31:24] <= wdata[31:24];

            // Lectura (read-first: devuelve dato antes de escribir)
            rdata <= mem[word_idx];
        end
    end

endmodule