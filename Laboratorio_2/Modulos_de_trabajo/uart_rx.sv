 module uart_rx
      #(parameter clk_freq = 1000000,
      parameter baud_rate = 9600
     )
      (input clk,
       input rst,
       input rx,
       output reg donerx,
       output reg [7:0] doutrx
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
      
      
      enum bit[1:0] {idle = 2'b00, start = 2'b01} state;
      
      always @(posedge uclk) begin
        if(rst) begin
          countd<=0;
          doutrx<=0;
          donerx<=0;
        end
        else begin
          case(state) 
            idle: begin
              doutrx <= 8'd0;
              donerx <= 1'b0;
              countd <= 0;
              if(rx==1'b0) state<= start;
              else 
                state<=idle;
            end
            
            start: begin
              if (countd <= 7) begin
                countd <= countd + 1;
                doutrx <= {rx,doutrx[7:1]};
               // state <= start;
              end
              else begin 
                countd <=0;
                donerx <= 1'b1;
                state <= idle;
                
              end  
            end
         
            default: state<= idle;
          endcase
        end
      end
      
    endmodule