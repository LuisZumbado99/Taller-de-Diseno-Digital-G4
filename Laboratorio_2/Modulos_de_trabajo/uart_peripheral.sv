module uart_peripheral #(
    parameter CLK_FREQ_HZ = 100_000_000,
    parameter BAUD_RATE   = 9600
)(
    input  logic        clk,
    input  logic        resetn,

    input  logic        mem_valid,
    input  logic [31:0] mem_addr,
    input  logic [31:0] mem_wdata,
    input  logic [3:0]  mem_wstrb,
    output logic [31:0] mem_rdata,
    output logic        mem_ready,
    input  logic        uart_rx_i,
    output logic        uart_tx_o,
    output logic        diag_donerx,
    output logic        diag_new_rx,
    output logic        diag_tx_start
);

    // -------------------------------------------------------------------------
    // Decodificación de direcciones
    // -------------------------------------------------------------------------
    
    localparam ADDR_CTRL    = 32'h00002010;
    localparam ADDR_DATA_TX = 32'h00002018;
    localparam ADDR_DATA_RX = 32'h0000201C;

    wire is_ctrl    = (mem_addr == ADDR_CTRL);
    wire is_data_tx = (mem_addr == ADDR_DATA_TX);
    wire is_data_rx = (mem_addr == ADDR_DATA_RX);
    wire is_write   = mem_valid && (mem_wstrb != 4'b0);
    wire is_read    = mem_valid && (mem_wstrb == 4'b0);

    // -------------------------------------------------------------------------
    // Bus handshake
    // -------------------------------------------------------------------------
    
    assign mem_ready = mem_valid;

    // -------------------------------------------------------------------------
    // Registros internos TX
    // -------------------------------------------------------------------------
    
    logic [7:0] tx_data_reg;
    logic       tx_start;
    logic       tx_busy;
    logic       tx_done;

    // -------------------------------------------------------------------------
    // Registros internos RX
    // -------------------------------------------------------------------------
    
    logic [7:0] rx_data_reg;
    logic [7:0] rx_data_wire;
    logic       rx_done;
    logic       new_rx;

    // -------------------------------------------------------------------------
    // Lectura combinacional
    // -------------------------------------------------------------------------
    
    always_comb begin
        if (is_ctrl)         mem_rdata = {30'b0, new_rx, tx_busy};
        else if (is_data_tx) mem_rdata = {24'b0, tx_data_reg};
        else if (is_data_rx) mem_rdata = {24'b0, rx_data_reg};
        else                 mem_rdata = 32'h0;
    end

    // -------------------------------------------------------------------------
    // Lógica TX
    // -------------------------------------------------------------------------
    
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            tx_data_reg <= 8'h0;
            tx_start    <= 1'b0;
            tx_busy     <= 1'b0;
        end else begin
            tx_start <= 1'b0;  // default: pulso apagado

            // Escritura del dato TX
            if (is_write && is_data_tx)
                tx_data_reg <= mem_wdata[7:0];

            // Disparo de TX
            if (is_write && is_ctrl && mem_wdata[0] && !tx_busy) begin
                tx_start <= 1'b1;
                tx_busy  <= 1'b1;
            end

            // Limpieza de tx_busy al finalizar transmisión
            if (tx_done)
                tx_busy <= 1'b0;
        end
    end

    // -------------------------------------------------------------------------
    // Lógica RX
    // -------------------------------------------------------------------------
    
    wire clear_new_rx = is_read && is_data_rx;

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            new_rx      <= 1'b0;
            rx_data_reg <= 8'h0;
        end else begin
            if (rx_done) begin
                rx_data_reg <= rx_data_wire;
                new_rx      <= 1'b1;
            end else if (clear_new_rx) begin
                new_rx <= 1'b0;
            end
        end
    end

    // -------------------------------------------------------------------------
    // Diagnóstico
    // -------------------------------------------------------------------------
    
    assign diag_donerx   = rx_done;
    assign diag_new_rx   = new_rx;
    assign diag_tx_start = tx_busy;

    // -------------------------------------------------------------------------
    // Instancias UART TX / RX
    // -------------------------------------------------------------------------
    
    uart_tx #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE  (BAUD_RATE)
    ) tx_i (
        .clk    (clk),
        .rst    (~resetn),
        .newd   (tx_start),
        .tx_data(tx_data_reg),
        .tx     (uart_tx_o),
        .donetx (tx_done)
    );

    uart_rx #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE  (BAUD_RATE)
    ) rx_i (
        .clk   (clk),
        .rst   (~resetn),
        .rx    (uart_rx_i),
        .donerx(rx_done),
        .doutrx(rx_data_wire)
    );

endmodule
