module Ejercicio_4 (
    input  logic clk,           // 100MHz
    input  logic rst_n,         // Reset activo bajo
    input  logic btn_send,      // Botón N17
    input  logic rx_pin,        // Pin C4
    output logic tx_pin,        // Pin D4
    output logic [7:0] leds     // LEDs
);

    // Señales internas ajustadas a los módulos disponibles
    logic tx_ready;
    logic tx_start;
    logic [7:0] tx_data;
    logic rx_done;
    logic [7:0] rx_data_out;
    logic btn_pressed;

    // Parámetros para los módulos del repositorio
    localparam CLK_FREQ = 100_000_000; // 100 MHz para Nexys 4
    localparam BAUD = 9600;

    // 1. Detector de flanco para el botón
    logic btn_reg;
    always_ff @(posedge clk) begin
        btn_reg <= btn_send;
        btn_pressed <= btn_send & ~btn_reg;
    end

    // 2. Instancia del Transmisor UART (Ajustado a los nombres del repo)
    uart_tx #(CLK_FREQ, BAUD) transmitter (
        .clk(clk),
        .rst(~rst_n),
        .newd(tx_start),      // 'newd' inicia la transmisión
        .tx_data(tx_data),    // 'tx_data' es el bus de entrada
        .tx(tx_pin),
        .donetx(tx_ready)     // 'donetx' indica que terminó
    );

    // 3. Instancia del Receptor UART (Ajustado a los nombres del repo)
    uart_rx #(CLK_FREQ, BAUD) receiver (
        .clk(clk),
        .rst(~rst_n),
        .rx(rx_pin),
        .donerx(rx_done),
        .doutrx(rx_data_out)
    );

    // 4. FSM de envío de "Hola mundo"
    message_sender fsm_inst (
        .clk(clk),
        .rst(~rst_n),
        .btn_send(btn_pressed),
        .tx_ready(tx_ready),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .done()
    );

    // 5. Registro para mantener el dato en los LEDs
    always_ff @(posedge clk) begin
        if (~rst_n)
            leds <= 8'b0;
        else if (rx_done)
            leds <= rx_data_out;
    end

endmodule

module message_sender (
    input  logic clk,
    input  logic rst,
    input  logic btn_send,
    input  logic tx_ready,
    output logic tx_start,
    output logic [7:0] tx_data,
    output logic done
);

    typedef enum logic [1:0] {IDLE, SEND, WAIT} state_t;
    state_t state;
    
    logic [3:0] char_ptr;

    // ROM del mensaje
    always_comb begin
        case(char_ptr)
            4'd0: tx_data = 8'h48; // H
            4'd1: tx_data = 8'h6F; // o
            4'd2: tx_data = 8'h6C; // l
            4'd3: tx_data = 8'h61; // a
            4'd4: tx_data = 8'h20; // space
            4'd5: tx_data = 8'h6D; // m
            4'd6: tx_data = 8'h75; // u
            4'd7: tx_data = 8'h6E; // n
            4'd8: tx_data = 8'h64; // d
            4'd9: tx_data = 8'h6F; // o
            default: tx_data = 8'h00;
        endcase
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            char_ptr <= 0;
            tx_start <= 0;
            done <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx_start <= 0;
                    done <= 0;
                    char_ptr <= 0;
                    if (btn_send) state <= SEND;
                end
                SEND: begin
                    tx_start <= 1;
                    state <= WAIT;
                end
                WAIT: begin
                    tx_start <= 0;
                    if (tx_ready) begin
                        if (char_ptr == 4'd9) begin
                            state <= IDLE;
                            done <= 1;
                        end else begin
                            char_ptr <= char_ptr + 1;
                            state <= SEND;
                        end
                    end
                end
            endcase
        end
    end
endmodule

module uart_top
  #(parameter clk_freq = 1000000,
    parameter baud_rate = 9600
   )
  (input clk,
   input rst,
   input rx,
   input newd,
   input [7:0] dintx,
   output donerx,
   output donetx,
   output tx,
   output [7:0] doutrx
);
  
  
  uart_tx #(clk_freq, baud_rate) utx(clk,rst,newd,dintx,tx,donetx);
  uart_rx #(clk_freq, baud_rate) urx(clk,rst,rx,donerx,doutrx);
  
  

  
  endmodule
  
module uart_rx #(
    parameter clk_freq  = 100_000_000,
    parameter baud_rate = 9600
)(
    input  logic clk,
    input  logic rst,
    input  logic rx,
    output logic donerx,
    output logic [7:0] doutrx
);

    localparam CLKS_PER_BIT = clk_freq / baud_rate;

    typedef enum logic [2:0] {
        IDLE,
        START_BIT,
        DATA_BITS,
        STOP_BIT,
        CLEANUP
    } state_t;

    state_t state;

    logic [15:0] clk_count;
    logic [2:0]  bit_index;
    logic [7:0]  rx_shift;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            clk_count <= 0;
            bit_index <= 0;
            doutrx <= 0;
            donerx <= 0;
        end else begin

            case(state)

                IDLE: begin
                    donerx <= 0;
                    clk_count <= 0;
                    bit_index <= 0;

                    if (rx == 0)
                        state <= START_BIT;
                end

                START_BIT: begin
                    if (clk_count == (CLKS_PER_BIT/2)) begin
                        if (rx == 0) begin
                            clk_count <= 0;
                            state <= DATA_BITS;
                        end else
                            state <= IDLE;
                    end else
                        clk_count <= clk_count + 1;
                end

                DATA_BITS: begin
                    if (clk_count < CLKS_PER_BIT-1)
                        clk_count <= clk_count + 1;
                    else begin
                        clk_count <= 0;
                        rx_shift[bit_index] <= rx;

                        if (bit_index < 7)
                            bit_index <= bit_index + 1;
                        else begin
                            bit_index <= 0;
                            state <= STOP_BIT;
                        end
                    end
                end

                STOP_BIT: begin
                    if (clk_count < CLKS_PER_BIT-1)
                        clk_count <= clk_count + 1;
                    else begin
                        doutrx <= rx_shift;
                        donerx <= 1'b1;
                        clk_count <= 0;
                        state <= CLEANUP;
                    end
                end

                CLEANUP: begin
                    state <= IDLE;
                    donerx <= 0;
                end

            endcase
        end
    end

endmodule
    
module uart_tx #(
    parameter clk_freq  = 100_000_000,
    parameter baud_rate = 9600
)(
    input  logic clk,
    input  logic rst,
    input  logic newd,
    input  logic [7:0] tx_data,
    output logic tx,
    output logic donetx
);

    localparam CLKS_PER_BIT = clk_freq / baud_rate;

    typedef enum logic [2:0] {
        IDLE,
        START_BIT,
        DATA_BITS,
        STOP_BIT,
        CLEANUP
    } state_t;

    state_t state;

    logic [15:0] clk_count;
    logic [2:0]  bit_index;
    logic [7:0]  tx_shift;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state      <= IDLE;
            tx         <= 1'b1;
            clk_count  <= 0;
            bit_index  <= 0;
            donetx     <= 0;
        end else begin

            case (state)

                IDLE: begin
                    tx        <= 1'b1;
                    donetx    <= 1'b0;
                    clk_count <= 0;
                    bit_index <= 0;

                    if (newd) begin
                        tx_shift <= tx_data;
                        state    <= START_BIT;
                    end
                end

                START_BIT: begin
                    tx <= 1'b0;

                    if (clk_count < CLKS_PER_BIT-1)
                        clk_count <= clk_count + 1;
                    else begin
                        clk_count <= 0;
                        state <= DATA_BITS;
                    end
                end

                DATA_BITS: begin
                    tx <= tx_shift[bit_index];

                    if (clk_count < CLKS_PER_BIT-1)
                        clk_count <= clk_count + 1;
                    else begin
                        clk_count <= 0;

                        if (bit_index < 7)
                            bit_index <= bit_index + 1;
                        else begin
                            bit_index <= 0;
                            state <= STOP_BIT;
                        end
                    end
                end

                STOP_BIT: begin
                    tx <= 1'b1;

                    if (clk_count < CLKS_PER_BIT-1)
                        clk_count <= clk_count + 1;
                    else begin
                        clk_count <= 0;
                        donetx <= 1'b1;
                        state <= CLEANUP;
                    end
                end

                CLEANUP: begin
                    donetx <= 1'b0;
                    state <= IDLE;
                end

            endcase
        end
    end

endmodule