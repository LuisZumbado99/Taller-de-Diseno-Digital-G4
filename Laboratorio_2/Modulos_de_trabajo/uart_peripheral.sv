module uart_peripheral (
    input  logic        clk,
    input  logic        resetn,

    // interfaz tipo memory-mapped
    input  logic        mem_valid,
    input  logic [31:0] mem_addr,
    input  logic [31:0] mem_wdata,
    input  logic [3:0]  mem_wstrb,
    output logic [31:0] mem_rdata,
    output logic        mem_ready,

    // pines físicos
    input  logic        uart_rx_i,
    output logic        uart_tx_o
);

 
    // Direcciones
 
    localparam ADDR_TX     = 32'h00002010;
    localparam ADDR_RX     = 32'h00002014;
    localparam ADDR_STATUS = 32'h00002018;

    logic is_tx, is_rx, is_status;

    always_comb begin
        is_tx     = (mem_addr == ADDR_TX);
        is_rx     = (mem_addr == ADDR_RX);
        is_status = (mem_addr == ADDR_STATUS);
    end

 
    // Registros
 
    logic [7:0] tx_data;
    logic       tx_start;
    logic       tx_done;

    logic [7:0] rx_data;
    logic       rx_done;

 
    // TX control
 
    always_ff @(posedge clk) begin
        tx_start <= 0;

        if (mem_valid && mem_wstrb != 0 && is_tx) begin
            tx_data  <= mem_wdata[7:0];
            tx_start <= 1;
        end
    end

 
    // STATUS
 
    logic tx_busy;
    assign tx_busy = ~tx_done;    

    logic rx_ready;
    assign rx_ready = rx_done;    

 
    // Lectura CPU
 
    always_ff @(posedge clk) begin
        mem_ready <= 0;

        if (mem_valid && !mem_ready) begin
            mem_ready <= 1;

            if (is_rx)
                mem_rdata <= {24'b0, rx_data};

            else if (is_status)
                mem_rdata <= {30'b0, rx_ready, tx_busy};

            else
                mem_rdata <= 32'h00000000;
        end
    end

 
    // UART TX
 
    uart_tx tx_inst (
        .clk     (clk),
        .rst     (~resetn),
        .newd    (tx_start),
        .tx_data (tx_data),
        .tx      (uart_tx_o),
        .donetx  (tx_done)
    );

 
    // UART RX  
 
    uart_rx rx_inst (
        .clk    (clk),
        .rst    (~resetn),
        .rx     (uart_rx_i),
        .donerx (rx_done),    
        .doutrx (rx_data)
    );

endmodule
