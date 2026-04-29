module uart_tx #(
    parameter CLK_FREQ_HZ = 100_000_000,
    parameter BAUD_RATE   = 9600
)(
    input  logic       clk,
    input  logic       rst,
    input  logic       newd,
    input  logic [7:0] tx_data,
    output logic       tx,
    output logic       donetx
);

    localparam integer BAUD_DIV = CLK_FREQ_HZ / BAUD_RATE;
    localparam integer CNT_W    = $clog2(BAUD_DIV) + 1;

    typedef enum logic [1:0] {
        IDLE,
        START,
        DATA,
        STOP
    } state_t;

    state_t           state;
    logic [CNT_W-1:0] baud_cnt;
    logic [2:0]       bit_cnt;
    logic [7:0]       shift_reg;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state    <= IDLE;
            tx       <= 1'b1;
            donetx   <= 1'b0;
            baud_cnt <= '0;
            bit_cnt  <= '0;
            shift_reg <= '0;
        end else begin
            donetx <= 1'b0;  // pulso de 1 ciclo por defecto

            case (state)

                IDLE: begin
                    tx <= 1'b1;
                    if (newd) begin
                        shift_reg <= tx_data;
                        baud_cnt  <= '0;
                        bit_cnt   <= '0;
                        state     <= START;
                    end
                end

                START: begin
                    tx <= 1'b0;  // start bit
                    if (baud_cnt == CNT_W'(BAUD_DIV - 1)) begin
                        baud_cnt <= '0;
                        state    <= DATA;
                    end else begin
                        baud_cnt <= baud_cnt + 1'b1;
                    end
                end

                DATA: begin
                    tx <= shift_reg[0];  // LSB primero
                    if (baud_cnt == CNT_W'(BAUD_DIV - 1)) begin
                        baud_cnt  <= '0;
                        shift_reg <= {1'b0, shift_reg[7:1]};
                        if (bit_cnt == 3'd7) begin
                            bit_cnt <= '0;
                            state   <= STOP;
                        end else begin
                            bit_cnt <= bit_cnt + 1'b1;
                        end
                    end else begin
                        baud_cnt <= baud_cnt + 1'b1;
                    end
                end

                STOP: begin
                    tx <= 1'b1;  // stop bit
                    if (baud_cnt == CNT_W'(BAUD_DIV - 1)) begin
                        baud_cnt <= '0;
                        donetx   <= 1'b1;
                        state    <= IDLE;
                    end else begin
                        baud_cnt <= baud_cnt + 1'b1;
                    end
                end

                default: state <= IDLE;

            endcase
        end
    end

endmodule
