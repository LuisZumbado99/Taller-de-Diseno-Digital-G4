## 1. CLOCK (Reloj del Sistema - 100MHz Base)
set_property PACKAGE_PIN E3 [get_ports CLK100MHZ]
set_property IOSTANDARD LVCMOS33 [get_ports CLK100MHZ]
create_clock -name sys_clk -period 10.000 [get_ports CLK100MHZ]

## 2. RESET (CPU_RESET - Compartido Físicamente en Pin C12 - Activo en Bajo)
set_property PACKAGE_PIN C12 [get_ports rst_btn]
set_property IOSTANDARD LVCMOS33 [get_ports rst_btn]
set_property PULLUP true [get_ports rst_btn]

## 3. LEDS DE DIAGNÓSTICO Y GPIO
set_property PACKAGE_PIN H17 [get_ports {led[0]}]
set_property PACKAGE_PIN K15 [get_ports {led[1]}]
set_property PACKAGE_PIN J13 [get_ports {led[2]}]
set_property PACKAGE_PIN N14 [get_ports {led[3]}]
set_property PACKAGE_PIN R18 [get_ports {led[4]}]
set_property PACKAGE_PIN V17 [get_ports {led[5]}]
set_property PACKAGE_PIN U17 [get_ports {led[6]}]
set_property PACKAGE_PIN U16 [get_ports {led[7]}]
set_property PACKAGE_PIN V16 [get_ports {led[8]}]
set_property PACKAGE_PIN T15 [get_ports {led[9]}]
set_property PACKAGE_PIN U14 [get_ports {led[10]}]
set_property PACKAGE_PIN T16 [get_ports {led[11]}]
set_property PACKAGE_PIN V15 [get_ports {led[12]}]
set_property PACKAGE_PIN V14 [get_ports {led[13]}]
set_property PACKAGE_PIN V12 [get_ports {led[14]}]
set_property PACKAGE_PIN V11 [get_ports {led[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]

## 4. SWITCHES (Entradas GPIO Sincronizadas)
set_property PACKAGE_PIN J15 [get_ports {sw[0]}]
set_property PACKAGE_PIN L16 [get_ports {sw[1]}]
set_property PACKAGE_PIN M13 [get_ports {sw[2]}]
set_property PACKAGE_PIN R15 [get_ports {sw[3]}]
set_property PACKAGE_PIN R17 [get_ports {sw[4]}]
set_property PACKAGE_PIN T18 [get_ports {sw[5]}]
set_property PACKAGE_PIN U18 [get_ports {sw[6]}]
set_property PACKAGE_PIN R13 [get_ports {sw[7]}]
set_property PACKAGE_PIN T8  [get_ports {sw[8]}]
set_property PACKAGE_PIN U8  [get_ports {sw[9]}]
set_property PACKAGE_PIN R16 [get_ports {sw[10]}]
set_property PACKAGE_PIN T13 [get_ports {sw[11]}]
set_property PACKAGE_PIN H6  [get_ports {sw[12]}]
set_property PACKAGE_PIN U12 [get_ports {sw[13]}]
set_property PACKAGE_PIN U11 [get_ports {sw[14]}]
set_property PACKAGE_PIN V10 [get_ports {sw[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[*]}]

## 5. UART (USB-UART Bridge Terminal PuTTY)
set_property PACKAGE_PIN C4 [get_ports uart_rx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_rx]
set_property PACKAGE_PIN D4 [get_ports uart_tx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_tx]

## 7. ACCELEROMETER (ADXL362) - ASIGNACIÓN FÍSICA OFICIAL NEXYS 4 DDR
set_property PACKAGE_PIN E15 [get_ports ACL_MISO]
set_property IOSTANDARD LVCMOS33 [get_ports ACL_MISO]

set_property PACKAGE_PIN F14 [get_ports ACL_MOSI]
set_property IOSTANDARD LVCMOS33 [get_ports ACL_MOSI]

set_property PACKAGE_PIN F15 [get_ports ACL_SCLK]
set_property IOSTANDARD LVCMOS33 [get_ports ACL_SCLK]

set_property PACKAGE_PIN D15 [get_ports ACL_CSN]
set_property IOSTANDARD LVCMOS33 [get_ports ACL_CSN]