 
## CLOCK
 
set_property PACKAGE_PIN E3 [get_ports CLK100MHZ]
set_property IOSTANDARD LVCMOS33 [get_ports CLK100MHZ]

 
## RESET
 
set_property PACKAGE_PIN C12 [get_ports rst_btn]
set_property IOSTANDARD LVCMOS33 [get_ports rst_btn]

 
## LEDS
 
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

 
## SWITCHES

set_property PACKAGE_PIN A8  [get_ports {sw[0]}]
set_property PACKAGE_PIN C11 [get_ports {sw[1]}]
set_property PACKAGE_PIN C10 [get_ports {sw[2]}]
set_property PACKAGE_PIN A10 [get_ports {sw[3]}]
set_property PACKAGE_PIN B9  [get_ports {sw[4]}]
set_property PACKAGE_PIN B8  [get_ports {sw[5]}]
set_property PACKAGE_PIN A9  [get_ports {sw[6]}]
set_property PACKAGE_PIN D9  [get_ports {sw[7]}]
set_property PACKAGE_PIN C7  [get_ports {sw[8]}]
set_property PACKAGE_PIN C6  [get_ports {sw[9]}]
set_property PACKAGE_PIN B6  [get_ports {sw[10]}]
set_property PACKAGE_PIN D8  [get_ports {sw[11]}]
set_property PACKAGE_PIN A5  [get_ports {sw[12]}]
set_property PACKAGE_PIN A4  [get_ports {sw[13]}]
set_property PACKAGE_PIN B4  [get_ports {sw[14]}]
set_property PACKAGE_PIN A3  [get_ports {sw[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[*]}]

 
## UART
 
set_property PACKAGE_PIN D10 [get_ports uart_rx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_rx]

set_property PACKAGE_PIN C4 [get_ports uart_tx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_tx]
