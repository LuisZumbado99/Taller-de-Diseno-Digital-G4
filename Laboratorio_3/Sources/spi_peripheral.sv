module spi_peripheral #(
    parameter CLK_DIV = 4
)(
    input  logic        clk,
    input  logic        resetn,

    // Interfaz nativa del bus de memoria (PicoRV32)
    input  logic        mem_valid,
    input  logic [31:0] mem_addr,
    input  logic [31:0] mem_wdata,
    input  logic [3:0]  mem_wstrb,
    output logic [31:0] mem_rdata,
    output logic        mem_ready,

    // Pines físicos externos hacia el Acelerómetro
    output logic        sclk,
    output logic        mosi,
    input  logic        miso,
    output logic        cs_n
);

    // -------------------------------------------------------------------------
    // Decodificación de Direcciones Mapeadas en Memoria
    // -------------------------------------------------------------------------
    localparam ADDR_SPI_CTRL = 32'h00002020;
    localparam ADDR_SPI_TX   = 32'h00002024;
    localparam ADDR_SPI_RX   = 32'h00002028;

    wire is_ctrl  = (mem_addr == ADDR_SPI_CTRL);
    wire is_tx    = (mem_addr == ADDR_SPI_TX);
    wire is_rx    = (mem_addr == ADDR_SPI_RX);
    wire is_write = mem_valid && (mem_wstrb != 4'b0);

    // Handshake inmediato original (El que mantenía al CPU corriendo sin trabas)
    assign mem_ready = mem_valid;

    // -------------------------------------------------------------------------
    // Registros Internos
    // -------------------------------------------------------------------------
    logic       spi_start;
    logic       spi_preserve_cs;
    logic [7:0] spi_tx_data;
    logic [7:0] spi_rx_data_raw;
    logic       spi_busy;
    logic       spi_done;
    logic [7:0] rx_capture;

    // -------------------------------------------------------------------------
    // Captura del Dato Recibido
    // -------------------------------------------------------------------------
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            rx_capture <= 8'h00;
        end else if (spi_done) begin
            rx_capture <= spi_rx_data_raw;
        end
    end

    // -------------------------------------------------------------------------
    // Lógica de Escritura del Bus (RESTAURADA AL ORIGINAL)
    // -------------------------------------------------------------------------
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            spi_start       <= 1'b0;
            spi_preserve_cs <= 1'b0;
            spi_tx_data     <= 8'h00;
        end else begin
            // Lógica de apretón de manos original: spi_start se mantiene en alto 
            // hasta que el master core reacciona y levanta spi_busy
            if (spi_busy) begin
                spi_start <= 1'b0;
            end

            if (is_write) begin
                if (is_tx) begin
                    spi_tx_data <= mem_wdata[7:0];
                end
                if (is_ctrl) begin
                    spi_preserve_cs <= mem_wdata[1];
                    if (mem_wdata[0]) begin
                        spi_start <= 1'b1;
                    end
                end
            end
        end
    end

    // -------------------------------------------------------------------------
    // Lógica de Lectura del Bus (RESTAURADA AL ORIGINAL)
    // -------------------------------------------------------------------------
    always_comb begin
        mem_rdata = 32'h0;
        if (mem_valid) begin
            if (is_ctrl) begin
                mem_rdata = {30'b0, spi_preserve_cs, spi_busy};
            end else if (is_tx) begin
                mem_rdata = {24'b0, spi_tx_data};
            end else if (is_rx) begin
                mem_rdata = {24'b0, rx_capture};
            end
        end
    end

    // -------------------------------------------------------------------------
    // Instanciación del Motor Físico SPI (Master Core)
    // -------------------------------------------------------------------------
    spi_master #(.CLK_DIV(CLK_DIV)) master_core (
        .clk        (clk),
        .rst        (~resetn),
        .start      (spi_start),
        .preserve_cs(spi_preserve_cs),
        .tx_data    (spi_tx_data),
        .rx_data    (spi_rx_data_raw),
        .busy       (spi_busy),
        .done       (spi_done),
        .sclk       (sclk),
        .mosi       (mosi),
        .miso       (miso),
        .cs_n       (cs_n)
    );

endmodule