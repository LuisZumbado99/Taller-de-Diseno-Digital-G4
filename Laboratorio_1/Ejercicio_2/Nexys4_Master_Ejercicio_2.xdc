## Configuración para MUX 4-a-1 (WIDTH = 4)

## Entrada d0 (Switches 0 al 3)
set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { d0[0] }];
set_property -dict { PACKAGE_PIN L16   IOSTANDARD LVCMOS33 } [get_ports { d0[1] }];
set_property -dict { PACKAGE_PIN M13   IOSTANDARD LVCMOS33 } [get_ports { d0[2] }];
set_property -dict { PACKAGE_PIN R15   IOSTANDARD LVCMOS33 } [get_ports { d0[3] }];

## Entrada d1 (Switches 4 al 7)
set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports { d1[0] }];
set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports { d1[1] }];
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports { d1[2] }];
set_property -dict { PACKAGE_PIN R13   IOSTANDARD LVCMOS33 } [get_ports { d1[3] }];

## Entrada d2 (Switches 8 al 11)
set_property -dict { PACKAGE_PIN T8    IOSTANDARD LVCMOS18 } [get_ports { d2[0] }]; # Nota: Algunos switches pueden variar voltaje segun version
set_property -dict { PACKAGE_PIN U8    IOSTANDARD LVCMOS18 } [get_ports { d2[1] }];
set_property -dict { PACKAGE_PIN R16   IOSTANDARD LVCMOS33 } [get_ports { d2[2] }];
set_property -dict { PACKAGE_PIN T13   IOSTANDARD LVCMOS33 } [get_ports { d2[3] }];

## Entrada d3 (Switches 12 al 15)
set_property -dict { PACKAGE_PIN H6    IOSTANDARD LVCMOS33 } [get_ports { d3[0] }];
set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33 } [get_ports { d3[1] }];
set_property -dict { PACKAGE_PIN U11   IOSTANDARD LVCMOS33 } [get_ports { d3[2] }];
set_property -dict { PACKAGE_PIN V10   IOSTANDARD LVCMOS33 } [get_ports { d3[3] }];

## Selector (Usaremos botones para no agotar los switches)
## Botón Derecho y Botón Izquierdo
set_property -dict { PACKAGE_PIN M17   IOSTANDARD LVCMOS33 } [get_ports { sel[0] }]; # BTNR
set_property -dict { PACKAGE_PIN P17   IOSTANDARD LVCMOS33 } [get_ports { sel[1] }]; # BTNL

## Salida y (LEDs 0 al 3)
set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports { y[0] }];
set_property -dict { PACKAGE_PIN K15   IOSTANDARD LVCMOS33 } [get_ports { y[1] }];
set_property -dict { PACKAGE_PIN J13   IOSTANDARD LVCMOS33 } [get_ports { y[2] }];
set_property -dict { PACKAGE_PIN N14   IOSTANDARD LVCMOS33 } [get_ports { y[3] }];