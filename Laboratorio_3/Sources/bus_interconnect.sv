module bus_interconnect (
    input  logic        clk,
    input  logic        mem_valid,
    output logic        mem_ready,
    input  logic [31:0] mem_addr,
    input  logic [31:0] mem_wdata,
    input  logic [3:0]  mem_wstrb,
    output logic [31:0] mem_rdata,

    output logic        rom_valid,
    input  logic        rom_ready,
    input  logic [31:0] rom_rdata,

    output logic        ram_valid,
    input  logic        ram_ready,
    input  logic [31:0] ram_rdata,

    output logic        spi_valid,
    input  logic        spi_ready,
    input  logic [31:0] spi_rdata,

    output logic        uart_valid,
    input  logic        uart_ready,
    input  logic [31:0] uart_rdata
);

    wire sel_uart = (mem_addr >= 32'h0000_2010 && mem_addr <= 32'h0000_201F);
    wire sel_spi  = (mem_addr >= 32'h0000_2020 && mem_addr <= 32'h0000_202F);
    wire sel_ram  = (mem_addr >= 32'h0004_0000 && mem_addr <= 32'h0007_FFFF);
    wire sel_rom  = (mem_addr >= 32'h0000_0000 && mem_addr <= 32'h0000_3FFF) && !sel_uart && !sel_spi;

    assign rom_valid  = mem_valid && sel_rom;
    assign ram_valid  = mem_valid && sel_ram;
    assign spi_valid  = mem_valid && sel_spi;
    assign uart_valid = mem_valid && sel_uart;

    always_comb begin
        if (sel_ram) begin
            mem_ready = ram_ready;
            mem_rdata = ram_rdata;
        end else if (sel_spi) begin
            mem_ready = spi_ready;
            mem_rdata = spi_rdata;          // línea de diagnóstico 0x55 eliminada
        end else if (sel_uart) begin
            mem_ready = uart_ready;
            mem_rdata = uart_rdata;
        end else begin
            mem_ready = rom_ready;
            mem_rdata = rom_rdata;
        end
    end

endmodule