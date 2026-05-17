`timescale 1ns / 1ps

module tb_bus_driver();
    logic clk = 0;
    logic [31:0] m_addr, m_rdata;
    logic m_valid, m_ready;

    // Señales de periféricos dummy
    logic rom_v, ram_v, spi_v;

    bus_interconnect dut (
        .clk(clk),
        .mem_valid(m_valid), .mem_ready(m_ready),
        .mem_addr(m_addr),   .mem_rdata(m_rdata),
        .mem_wdata(32'h0),   .mem_wstrb(4'h0),
        
        .rom_valid(rom_v), .rom_ready(1'b1), .rom_rdata(32'hA1A1A1A1),
        .ram_valid(ram_v), .ram_ready(1'b1), .ram_rdata(32'hB2B2B2B2),
        .spi_valid(spi_v), .spi_ready(1'b1), .spi_rdata(32'hC3C3C3C3)
    );

    always #5 clk = ~clk;

    initial begin
        m_valid = 1;
        
        // Probar acceso a ROM (0x0000)
        m_addr = 32'h0000_0000; #10;
        $display("Acceso ROM: valid=%b, rdata=%h", rom_v, m_rdata);

        // Probar acceso a RAM (0x40000)
        m_addr = 32'h0004_0000; #10;
        $display("Acceso RAM: valid=%b, rdata=%h", ram_v, m_rdata);

        // Probar acceso a SPI (0x2020)
        m_addr = 32'h0000_2020; #10;
        $display("Acceso SPI: valid=%b, rdata=%h", spi_v, m_rdata);

        $finish;
    end
endmodule