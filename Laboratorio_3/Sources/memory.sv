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
    
    // Registro para detectar actividad en la dirección 0 (Fetch)
    logic led12_toggle = 1'b0;

    // Diagnóstico visual en los LEDs superiores
    assign led_out[15]    = pll_locked;
    assign led_out[14]    = valid;
    assign led_out[13]    = ready;
    assign led_out[12]    = led12_toggle;
    assign led_out[11:0]  = led_reg[11:0];

    // --- Memoria ROM (512 palabras de 32 bits) ---
    logic [31:0] rom [0:511]; 
    
    initial begin
        // Inicializar con NOPs (addi x0, x0, 0)
        for (int i=0; i<512; i++) rom[i] = 32'h00000013;
        $readmemh("firmware.hex", rom);
    end

    // --- Lógica de Decodificación Estricta ---
    wire is_rom = (addr >= 32'h0000_0000 && addr <= 32'h0000_07FF);
    wire is_sw  = (addr == 32'h0000_2000);
    wire is_led = (addr == 32'h0000_2004);

    always_comb begin
        // Valor por defecto si no hay una dirección válida o valid es 0
        rdata = 32'h0000_0013; 
        
        if (valid) begin
            if (is_sw)          rdata = {16'b0, sw_in};
            else if (is_led)    rdata = {16'b0, led_reg};
            else if (is_rom)    rdata = rom[addr[10:2]];
            else                rdata = 32'h0000_0013; // NOP de seguridad
        end
    end

    always_ff @(posedge clk) begin
        // Detectar ejecución en dirección 0 (Toggle LED 12)
        if (valid && addr == 32'h0 && ready) begin
            led12_toggle <= ~led12_toggle;
        end

        // Lógica de Escritura en LEDs (Solo si wstrb no es 0)
        if (valid && (wstrb != 4'b0000) && is_led) begin
            if (wstrb[0]) led_reg[7:0]  <= wdata[7:0];
            if (wstrb[1]) led_reg[15:8] <= wdata[15:8];
        end
    end

endmodule