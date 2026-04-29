module uart_rx #(
    parameter CLK_FREQ_HZ = 10_000_000,
    parameter BAUD_RATE   = 9600
)(
    input  logic       clk,
    input  logic       rst,
    input  logic       rx,
    output logic       donerx,
    output logic [7:0] doutrx
);

    localparam integer BAUD_DIV      = CLK_FREQ_HZ / BAUD_RATE;
    localparam integer HALF_BAUD_DIV = BAUD_DIV / 2;
    localparam integer CNT_W         = $clog2(BAUD_DIV) + 1;

    // -------------------------------------------------------------------------
    // Sincronizador de 2 etapas para rx asíncrono
    // -------------------------------------------------------------------------
    
    logic rx_meta, rx_sync, rx_prev;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            rx_meta <= 1'b1;
            rx_sync <= 1'b1;
            rx_prev <= 1'b1;
        end else begin
            rx_meta <= rx;
            rx_sync <= rx_meta;
            rx_prev <= rx_sync;
        end
    end

    wire start_edge = (rx_prev == 1'b1) && (rx_sync == 1'b0);

    // -------------------------------------------------------------------------
    // FSM + contador interno - todo en un solo bloque
    // -------------------------------------------------------------------------
    
    typedef enum logic [1:0] {
        IDLE,
        START,
        DATA,
        STOP
    } state_t;

    state_t           state;
    logic [CNT_W-1:0] cnt;       // contador de ciclos dentro del bit actual
    logic [2:0]       bit_cnt;   // contador de bits de datos recibidos
    logic [7:0]       shift_reg;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= IDLE;
            cnt       <= '0;
            bit_cnt   <= '0;
            shift_reg <= '0;
            donerx    <= 1'b0;
            doutrx    <= '0;
        end else begin
            donerx <= 1'b0;  // pulso de un ciclo por defecto

            case (state)

                // -------------------------------------------------------------
                // IDLE: esperar flanco de bajada del start bit
                // -------------------------------------------------------------
                IDLE: begin
                    if (start_edge) begin
                        cnt   <= '0;
                        state <= START;
                    end
                end

                // -------------------------------------------------------------
                // START: esperar hasta el centro del start bit y verificar
                // -------------------------------------------------------------
                START: begin
                    if (cnt == CNT_W'(HALF_BAUD_DIV - 1)) begin
                        if (rx_sync == 1'b0) begin
                            // Start bit válido - preparar recepción de datos
                            cnt     <= '0;
                            bit_cnt <= '0;
                            state   <= DATA;
                        end else begin
                            // Glitch - volver a esperar
                            state <= IDLE;
                        end
                    end else begin
                        cnt <= cnt + 1'b1;
                    end
                end

                // -------------------------------------------------------------
                // DATA: muestrear cada bit en su centro (cada BAUD_DIV ciclos)
                // El contador ya está alineado al centro desde el estado START
                // -------------------------------------------------------------
                DATA: begin
                    if (cnt == CNT_W'(BAUD_DIV - 1)) begin
                        cnt       <= '0;
                        shift_reg <= {rx_sync, shift_reg[7:1]}; // LSB primero
                        if (bit_cnt == 3'd7) begin
                            state <= STOP;
                        end else begin
                            bit_cnt <= bit_cnt + 1'b1;
                        end
                    end else begin
                        cnt <= cnt + 1'b1;
                    end
                end

                // -------------------------------------------------------------
                // STOP: verificar stop bit y entregar byte
                // -------------------------------------------------------------
                STOP: begin
                    if (cnt == CNT_W'(BAUD_DIV - 1)) begin
                        cnt   <= '0;
                        state <= IDLE;
                        if (rx_sync == 1'b1) begin
                            doutrx <= shift_reg;
                            donerx <= 1'b1;
                        end
                        // Stop inválido: byte descartado silenciosamente
                    end else begin
                        cnt <= cnt + 1'b1;
                    end
                end

                default: state <= IDLE;

            endcase
        end
    end

endmodule
