 module uart_tx
    #(parameter clk_freq = 1000000,
      parameter baud_rate = 9600
     )
    (input clk,
     input rst,
     input newd,
     input [7:0] tx_data,
     output reg tx,
     output reg donetx
  );
    
    localparam countclk = clk_freq/baud_rate;
    integer count = 0;
    integer countd = 0;
    
    reg uclk = 0;
    
    
    always @(posedge clk) begin 
      if(count < countclk/2) begin 
        count <= count +1;
      end
        else begin
          count <= 0;
          uclk <= ~uclk;
        end
      end
      
      enum bit[1:0] {idle = 2'b00, start = 2'b01, transfer = 2'b10, done = 2'b11} state;
      
      reg [7:0] din;
      
      always @(posedge uclk) begin
        if (rst) begin
          state <= idle;
        end
        else begin
          
          case(state) 
            idle: begin
              countd <= 0;
              tx <= 1'b1;
              donetx <= 1'b0;
              
              if(newd) begin
                state <= transfer;
                tx <= 1'b0;
                din <= tx_data;
              end
              else state<= idle;
            end//idle
            
            
            transfer: begin 
              if(countd <= 7) begin
                countd <= countd + 1;
                tx <= din[countd];
                state <= transfer;
              end
              else begin
                countd <=0;
                donetx <= 1'b1;
                state <= idle;
                donetx <= 1'b1;
              end
            end
            
            default: state<=idle;
          endcase
        end
      end
  endmodule