module bus_interconnect (
    input  logic        clk,

    // MASTER (CPU)
    input  logic        mem_valid,
    output logic        mem_ready,
    input  logic [31:0] mem_addr,
    input  logic [31:0] mem_wdata,
    input  logic [3:0]  mem_wstrb,
    output logic [31:0] mem_rdata,

    // ROM
    output logic        rom_valid,
    input  logic        rom_ready,
    output logic [31:0] rom_addr,
    input  logic [31:0] rom_rdata,

    // RAM
    output logic        ram_valid,
    input  logic        ram_ready,
    output logic [31:0] ram_addr,
    output logic [31:0] ram_wdata,
    output logic [3:0]  ram_wstrb,
    input  logic [31:0] ram_rdata,

    // IO (LED + SW)
    output logic        io_valid,
    input  logic        io_ready,
    output logic [31:0] io_addr,
    output logic [31:0] io_wdata,
    output logic [3:0]  io_wstrb,
    input  logic [31:0] io_rdata,

    // UART
    output logic        uart_valid,
    input  logic        uart_ready,
    output logic [31:0] uart_addr,
    output logic [31:0] uart_wdata,
    output logic [3:0]  uart_wstrb,
    input  logic [31:0] uart_rdata
);

 
    // Decodificación
 
    logic sel_rom, sel_ram, sel_io, sel_uart;

    always_comb begin
        sel_rom  = (mem_addr < 32'h00001000);
        sel_ram  = (mem_addr >= 32'h00040000) &&
                   (mem_addr <  32'h00080000);
        sel_io   = (mem_addr >= 32'h00002000) &&
                   (mem_addr <  32'h00002010);
        sel_uart = (mem_addr >= 32'h00002010) &&
                   (mem_addr <  32'h00002020);
    end

 
    // Enrutamiento
 
    assign rom_valid  = mem_valid && sel_rom;
    assign ram_valid  = mem_valid && sel_ram;
    assign io_valid   = mem_valid && sel_io;
    assign uart_valid = mem_valid && sel_uart;

    assign rom_addr = mem_addr;

    assign ram_addr  = mem_addr;
    assign ram_wdata = mem_wdata;
    assign ram_wstrb = mem_wstrb;

    assign io_addr  = mem_addr;
    assign io_wdata = mem_wdata;
    assign io_wstrb = mem_wstrb;

    assign uart_addr  = mem_addr;
    assign uart_wdata = mem_wdata;
    assign uart_wstrb = mem_wstrb;


    // MUX de respuesta
 
    always_comb begin
        mem_ready = 0;
        mem_rdata = 32'hDEADBEEF;

        if (sel_rom) begin
            mem_ready = rom_ready;
            mem_rdata = rom_rdata;
        end
        else if (sel_ram) begin
            mem_ready = ram_ready;
            mem_rdata = ram_rdata;
        end
        else if (sel_io) begin
            mem_ready = io_ready;
            mem_rdata = io_rdata;
        end
        else if (sel_uart) begin
            mem_ready = uart_ready;
            mem_rdata = uart_rdata;
        end
    end

endmodule