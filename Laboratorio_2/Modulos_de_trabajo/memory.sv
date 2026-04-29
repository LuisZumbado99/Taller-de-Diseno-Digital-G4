module memory (
    input  logic        clk,
    input  logic        pll_locked, 
    input  logic        valid,
    output logic        ready,
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    input  logic [3:0]  wstrb,
    output logic [31:0] rdata,
    output logic [15:0] led_out,
    input  logic [15:0] sw_in
);

    assign ready = valid;
    logic [15:0] led_reg = 16'h0000;
    assign led_out[15]    = pll_locked;
    assign led_out[14]    = valid;
    assign led_out[13]    = ready;
    assign led_out[12]    = (addr == 0) && valid;
    assign led_out[11:0]  = led_reg[11:0];
    logic [31:0] rom [0:1023]; 
    
    initial begin
        for (int i=0; i<1024; i++) rom[i] = 32'h00000013;
        $readmemh("firmware.hex", rom);
    end

    // Decodificación de registros internos
    wire is_led = (addr == 32'h00002004);
    wire is_sw  = (addr == 32'h00002000);

    always_comb begin
        if (is_led)      rdata = {16'b0, led_reg};
        else if (is_sw)  rdata = {16'b0, sw_in};
        else if (addr[31:12] == 0) rdata = rom[addr[11:2]];
        else             rdata = 32'h00000013; // NOP por seguridad
    end

    always_ff @(posedge clk) begin
        if (valid && wstrb != 0 && is_led) begin
            led_reg <= wdata[15:0];
        end
    end
endmodule
