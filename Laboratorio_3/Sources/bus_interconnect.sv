module bus_interconnect (
    input  logic        clk,
    // Conexión al CPU
    input  logic        mem_valid,
    output logic        mem_ready,
    input  logic [31:0] mem_addr,
    input  logic [31:0] mem_wdata,
    input  logic [3:0]  mem_wstrb,
    output logic [31:0] mem_rdata,

    // Periférico 1: ROM / GPIO
    output logic        rom_valid,
    input  logic        rom_ready,
    input  logic [31:0] rom_rdata,

    // Periférico 2: RAM (100 KiB)
    output logic        ram_valid,
    input  logic        ram_ready,
    input  logic [31:0] ram_rdata,

    // Periférico 3: SPI (Acelerómetro)
    output logic        spi_valid,
    input  logic        spi_ready,
    input  logic [31:0] spi_rdata,

    // Periférico 4: UART
    output logic        uart_valid,
    input  logic        uart_ready,
    input  logic [31:0] uart_rdata
);

    // DECODER: Definición de rangos e identificadores de periféricos
    
    // UART: Rango completo desde 0x0000_2010 hasta 0x0000_201F (Cubre 0x2010, 0x2018, 0x201C)
    wire sel_uart = (mem_addr >= 32'h0000_2010 && mem_addr <= 32'h0000_201F);
    
    // SPI Acelerómetro: 0x0000_2020 a 0x0000_202F
    wire sel_spi  = (mem_addr >= 32'h0000_2020 && mem_addr <= 32'h0000_202F);
    
    // RAM de datos: 0x0004_0000 a 0x0007_FFFF
    wire sel_ram  = (mem_addr >= 32'h0004_0000 && mem_addr <= 32'h0007_FFFF);
    
    // ROM y Periféricos básicos: 0x0000_0000 a 0x0000_3FFF (Excluyendo UART y SPI explícitamente)
    wire sel_rom  = (mem_addr >= 32'h0000_0000 && mem_addr <= 32'h0000_3FFF) && !sel_uart && !sel_spi;

    // ROUTING: Activación de señales valid según dirección decodificada
    assign rom_valid  = mem_valid && sel_rom;
    assign ram_valid  = mem_valid && sel_ram;
    assign spi_valid  = mem_valid && sel_spi;
    assign uart_valid = mem_valid && sel_uart;

    // MUX: Selección de Data In y Ready de regreso hacia el CPU
    always_comb begin
        if (sel_ram) begin
            mem_ready = ram_ready;
            mem_rdata = ram_rdata;
        end else if (sel_spi) begin
            mem_ready = spi_ready;
            mem_rdata = spi_rdata;
        end else if (sel_uart) begin
            mem_ready = uart_ready;
            mem_rdata = uart_rdata;
        end else begin
            // Default a ROM/GPIO para evitar latches o estados flotantes
            mem_ready = rom_ready;
            mem_rdata = rom_rdata;
        end
    end

endmodule