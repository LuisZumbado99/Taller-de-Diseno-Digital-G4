module memory (
    input  logic        clk,

    // interfaz desde BUS
    input  logic        valid,
    output logic        ready,

    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    input  logic [3:0]  wstrb,
    output logic [31:0] rdata,

    // GPIO
    output logic [15:0] led_out,
    input  logic [15:0] sw_in
);

 
    // LEDs
 
    logic [15:0] led_reg;
    assign led_out = led_reg;

    initial led_reg = 16'h0000;

 
    // Memorias
 
    localparam ROM_SIZE = 512;
    localparam RAM_SIZE = 1024;

    logic [31:0] rom [0:ROM_SIZE-1];
    logic [31:0] ram [0:RAM_SIZE-1];

    initial begin
        $readmemh("firmware.hex", rom);
    end
 
 
    // Switch sync
 
    logic [15:0] sw_sync_0, sw_sync_1;

    always_ff @(posedge clk) begin
        sw_sync_0 <= sw_in;
        sw_sync_1 <= sw_sync_0;
    end

 
    // Decodificación LOCAL
 
    logic is_rom, is_ram, is_led, is_sw;

    always_comb begin
        is_rom = (addr < 32'h00001000);
        is_ram = (addr >= 32'h00040000) &&
                 (addr <  32'h00080000);
        is_led = (addr == 32'h00002004);
        is_sw  = (addr == 32'h00002000);
    end

 
    // Lógica
 
    always_ff @(posedge clk) begin
        ready <= 0;

        if (valid && !ready) begin
            ready <= 1;

            if (is_rom) begin
                rdata <= rom[addr[11:2]];
            end

            else if (is_ram) begin
                if (wstrb != 0)
                    ram[addr[11:2]] <= wdata;

                rdata <= ram[addr[11:2]];
            end

            else if (is_led) begin
                if (wstrb != 0)
                    led_reg <= wdata[15:0];

                rdata <= {16'b0, led_reg};
            end

            else if (is_sw) begin
                rdata <= {16'b0, sw_sync_1};
            end

            else begin
                rdata <= 32'hDEADBEEF;
            end
        end
    end

endmodule
