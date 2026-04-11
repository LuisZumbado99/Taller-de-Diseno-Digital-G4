module memory (
    input  logic        clk,
    input  logic        mem_valid,
    output logic        mem_ready,

    input  logic [31:0] mem_addr,
    input  logic [31:0] mem_wdata,
    input  logic [3:0]  mem_wstrb,
    output logic [31:0] mem_rdata
);

    // Parámetros de memoria

    localparam ROM_SIZE = 512;        // 512 palabras (2 KB)
    localparam RAM_SIZE = 1024;       // ajustable


    // Memorias

    logic [31:0] rom [0:ROM_SIZE-1];
    logic [31:0] ram [0:RAM_SIZE-1];


    // Inicialización ROM

    initial begin
        $readmemh("firmware.hex", rom);
    end


    // Decodificación de dirección

    logic is_rom, is_ram;

    always_comb begin
        is_rom = (mem_addr < 32'h00001000);              // 0x0000-0x0FFF
        is_ram = (mem_addr >= 32'h00040000) &&
                 (mem_addr <  32'h00080000);             // 0x40000-0x7FFFF
    end


    // Lógica de acceso

    always_ff @(posedge clk) begin
        mem_ready <= 0;

        if (mem_valid && !mem_ready) begin
            mem_ready <= 1;


            // ROM (solo lectura)

            if (is_rom) begin
                mem_rdata <= rom[mem_addr[11:2]]; // palabra alineada
            end


            // RAM (lectura/escritura)

            else if (is_ram) begin
                if (mem_wstrb != 0) begin
                    // escritura
                    ram[mem_addr[11:2]] <= mem_wdata;
                end
                mem_rdata <= ram[mem_addr[11:2]];
            end


            // Default (no implementado)

            else begin
                mem_rdata <= 32'hDEADBEEF;
            end
        end
    end

endmodule