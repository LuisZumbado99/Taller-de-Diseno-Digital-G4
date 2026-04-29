module bus_interconnect (
    input  logic        clk,

    // --- Interfaz con PicoRV32 ---
    input  logic        mem_valid,
    output logic        mem_ready,
    input  logic [31:0] mem_addr,
    input  logic [31:0] mem_wdata,
    input  logic [3:0]  mem_wstrb,
    output logic [31:0] mem_rdata,

    // --- ROM + GPIO (memory.sv) ---
    output logic        rom_valid,
    input  logic        rom_ready,
    output logic [31:0] rom_addr,
    output logic [31:0] rom_wdata,
    output logic [3:0]  rom_wstrb,
    input  logic [31:0] rom_rdata,

    // --- RAM de datos ---
    output logic        ram_valid,
    input  logic        ram_ready,
    output logic [31:0] ram_addr,
    output logic [31:0] ram_wdata,
    output logic [3:0]  ram_wstrb,
    input  logic [31:0] ram_rdata,

    // --- UART peripheral ---
    output logic        uart_valid,
    input  logic        uart_ready,
    output logic [31:0] uart_addr,
    output logic [31:0] uart_wdata,
    output logic [3:0]  uart_wstrb,
    input  logic [31:0] uart_rdata
);

    // -------------------------------------------------------------------------
    // Decodificación de regiones
    // -------------------------------------------------------------------------
    
    logic sel_rom;   // ROM (0x0000-0x0FFF) + GPIO (0x2000-0x200F)
    logic sel_uart;  // UART (0x2010-0x201F)
    logic sel_ram;   // RAM  (0x40000-0x7FFFF)

    always_comb begin
        sel_uart = (mem_addr >= 32'h00002010) && (mem_addr <= 32'h0000201F);
        sel_ram  = (mem_addr >= 32'h00040000) && (mem_addr <= 32'h0007FFFF);
        sel_rom  = !sel_uart && !sel_ram;
    end

    // -------------------------------------------------------------------------
    // Señales válidas hacia cada periférico
    // -------------------------------------------------------------------------
    
    assign rom_valid  = mem_valid && sel_rom;
    assign ram_valid  = mem_valid && sel_ram;
    assign uart_valid = mem_valid && sel_uart;

    // -------------------------------------------------------------------------
    // Bus de direcciones/datos hacia cada periférico (broadcast)
    // -------------------------------------------------------------------------
    
    assign rom_addr   = mem_addr;
    assign rom_wdata  = mem_wdata;
    assign rom_wstrb  = mem_wstrb;

    assign ram_addr   = mem_addr;
    assign ram_wdata  = mem_wdata;
    assign ram_wstrb  = mem_wstrb;

    assign uart_addr  = mem_addr;
    assign uart_wdata = mem_wdata;
    assign uart_wstrb = mem_wstrb;

    // -------------------------------------------------------------------------
    // Multiplexor de respuesta hacia el CPU
    // -------------------------------------------------------------------------
    
    always_comb begin
        if (sel_uart) begin
            mem_ready = uart_ready;
            mem_rdata = uart_rdata;
        end else if (sel_ram) begin
            mem_ready = ram_ready;
            mem_rdata = ram_rdata;
        end else begin
            mem_ready = rom_ready;
            mem_rdata = rom_rdata;
        end
    end

endmodule
