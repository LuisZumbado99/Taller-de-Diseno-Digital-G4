module memory (
    input  logic        clk,
    input  logic        mem_valid,
    output logic        mem_ready,

    input  logic [31:0] mem_addr,
    input  logic [31:0] mem_wdata,
    input  logic [3:0]  mem_wstrb,
    output logic [31:0] mem_rdata,
    output logic [15:0] led_out,

    input  logic [15:0] sw_in,
    input  logic uart_rx,
    output logic uart_tx
);


    // Registro de LEDs

    logic [15:0] led_reg;
    assign led_out = led_reg;

    initial led_reg = 16'h0000;


    // Parámetros

    localparam ROM_SIZE = 512;
    localparam RAM_SIZE = 1024;


    // Memorias

    logic [31:0] rom [0:ROM_SIZE-1];
    logic [31:0] ram [0:RAM_SIZE-1];

    initial begin
        $readmemh("firmware.hex", rom);
    end

 
    // Sincronizador de switches
 
    logic [15:0] sw_sync_0, sw_sync_1;

    always_ff @(posedge clk) begin
        sw_sync_0 <= sw_in;
        sw_sync_1 <= sw_sync_0;
    end

 
    // UART interno
 
    logic [31:0] uart_rdata;
    logic        uart_ready;

 
    // Decodificación de dirección
 
    logic is_rom, is_ram, is_led, is_sw, is_uart;

    always_comb begin
        is_rom  = (mem_addr < 32'h00001000);
        is_ram  = (mem_addr >= 32'h00040000) &&
                  (mem_addr <  32'h00080000);
        is_led  = (mem_addr == 32'h00002004);
        is_sw   = (mem_addr == 32'h00002000);

        is_uart = (mem_addr >= 32'h00002010) &&
                  (mem_addr <= 32'h00002018);
    end

 
    // Instancia UART
 
    uart_peripheral uart0 (
        .clk        (clk),
        .resetn     (1'b1),
        .mem_valid  (mem_valid && is_uart),
        .mem_addr   (mem_addr),
        .mem_wdata  (mem_wdata),
        .mem_wstrb  (mem_wstrb),
        .mem_rdata  (uart_rdata),
        .mem_ready  (uart_ready),

        .uart_rx_i  (uart_rx),
        .uart_tx_o  (uart_tx)
    );

 
    // Lógica de acceso

    always_ff @(posedge clk) begin
        mem_ready <= 0;

        if (mem_valid && !mem_ready) begin

            if (is_uart) begin
                mem_ready <= uart_ready;
                mem_rdata <= uart_rdata;
            end

            else begin
                mem_ready <= 1;

                // ROM
                if (is_rom) begin
                    mem_rdata <= rom[mem_addr[11:2]];
                end

                // RAM
                else if (is_ram) begin
                    if (mem_wstrb != 0)
                        ram[mem_addr[11:2]] <= mem_wdata;

                    mem_rdata <= ram[mem_addr[11:2]];
                end

                // LEDs
                else if (is_led) begin
                    if (mem_wstrb != 0)
                        led_reg <= mem_wdata[15:0];

                    mem_rdata <= {16'b0, led_reg};
                end

                // SWITCHES
                else if (is_sw) begin
                    mem_rdata <= {16'b0, sw_sync_1};
                end

                // Default
                else begin
                    mem_rdata <= 32'hDEADBEEF;
                end
            end
        end
    end

endmodule
