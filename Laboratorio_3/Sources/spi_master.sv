module spi_master #(
    parameter CLK_DIV = 4
)(
    input  logic        clk,
    input  logic        rst,
    input  logic        start,
    input  logic        preserve_cs,
    input  logic [7:0]  tx_data,
    output logic [7:0]  rx_data,
    output logic        busy,
    output logic        done,

    output logic        sclk,
    output logic        mosi,
    input  logic        miso,
    output logic        cs_n
);

    typedef enum logic [1:0] {
        IDLE,
        GEN_CLK,
        END_BYTE
    } state_t;

    state_t     state;
    logic [3:0] clk_cnt;
    logic [2:0] bit_cnt;
    logic [7:0] shifter_tx;
    logic [7:0] shifter_rx;
    logic       internal_cs;

    assign cs_n = ~internal_cs;

    // FIX P3: busy es un registro FF controlado por la máquina de estados.
    // La versión anterior usaba "assign busy = (state != IDLE) || start",
    // que es combinacional. Cuando spi_peripheral registraba spi_start=1,
    // busy subía inmediatamente (mismo ciclo), antes de que IDLE procesara
    // el start. spi_peripheral veía busy=1 y bajaba spi_start en el mismo
    // ciclo, por lo que en el siguiente ciclo IDLE veía start=0 y no arrancaba.
    // Ahora busy es un FF que solo sube cuando IDLE acepta el start.

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state       <= IDLE;
            clk_cnt     <= 0;
            bit_cnt     <= 0;
            shifter_tx  <= 8'h00;
            shifter_rx  <= 8'h00;
            sclk        <= 1'b0;
            mosi        <= 1'b0;
            busy        <= 1'b0;
            done        <= 1'b0;
            internal_cs <= 1'b0;
            rx_data     <= 8'h00;
        end else begin
            done <= 1'b0;

            case (state)

                IDLE: begin
                    sclk    <= 1'b0;
                    mosi    <= 1'b0;
                    busy    <= 1'b0;
                    clk_cnt <= 0;
                    if (start) begin
                        shifter_tx  <= tx_data;
                        bit_cnt     <= 7;
                        busy        <= 1'b1;        // Sube solo cuando se acepta start
                        internal_cs <= 1'b1;
                        mosi        <= tx_data[7];
                        state       <= GEN_CLK;
                    end else if (!preserve_cs) begin
                        internal_cs <= 1'b0;
                    end
                end

                GEN_CLK: begin
                    if (clk_cnt == (CLK_DIV / 2) - 1) begin
                        // Flanco de SUBIDA: muestrear MISO (SPI Mode 0)
                        sclk       <= 1'b1;
                        shifter_rx <= {shifter_rx[6:0], miso};
                        clk_cnt    <= clk_cnt + 1'b1;
                    end
                    else if (clk_cnt == CLK_DIV - 1) begin
                        // Flanco de BAJADA: avanzar shifter y preparar siguiente bit
                        sclk       <= 1'b0;
                        clk_cnt    <= 0;
                        shifter_tx <= {shifter_tx[6:0], 1'b0};
                        if (bit_cnt == 0) begin
                            state <= END_BYTE;
                        end else begin
                            bit_cnt <= bit_cnt - 1'b1;
                            mosi    <= shifter_tx[6]; // siguiente bit tras el shift
                        end
                    end
                    else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end

                END_BYTE: begin
                    sclk    <= 1'b0;
                    mosi    <= 1'b0;
                    done    <= 1'b1;
                    rx_data <= shifter_rx;
                    busy    <= 1'b0;
                    if (!preserve_cs) begin
                        internal_cs <= 1'b0;
                    end
                    state <= IDLE;
                end

                default: state <= IDLE;

            endcase
        end
    end

endmodule