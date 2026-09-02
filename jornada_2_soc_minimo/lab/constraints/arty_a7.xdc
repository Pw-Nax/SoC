## =============================================================================
## arty_a7.xdc — Constraints para Arty A7-35T
## Jornada 2: SoC PicoRV32 (soc_top)
##
## TODO 7: completar los PACKAGE_PIN que faltan (marcados abajo) usando la
## tabla de pinout de la slide "Top level de síntesis: soc_top.v y el
## pinout de la Arty A7". La estructura (set_property, IOSTANDARD,
## set_false_path) ya está armada -- solo faltan los números de pin.
## =============================================================================

set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

## ---- Reloj 100 MHz ----------------------------------------------------------
set_property -dict { PACKAGE_PIN ??? IOSTANDARD LVCMOS33 } [get_ports { clk }]
create_clock -add -name sys_clk_pin -period 10.00 [get_ports { clk }]

## ---- Reset BTN0 (active-high: presionar = reset) ----------------------------
set_property -dict { PACKAGE_PIN ??? IOSTANDARD LVCMOS33 } [get_ports { btn0 }]
set_false_path -from [get_ports btn0]

## ---- LEDs LD0..LD3 ----------------------------------------------------------
set_property -dict { PACKAGE_PIN ??? IOSTANDARD LVCMOS33 } [get_ports { led[0] }]
set_property -dict { PACKAGE_PIN ??? IOSTANDARD LVCMOS33 } [get_ports { led[1] }]
set_property -dict { PACKAGE_PIN ??? IOSTANDARD LVCMOS33 } [get_ports { led[2] }]
set_property -dict { PACKAGE_PIN ??? IOSTANDARD LVCMOS33 } [get_ports { led[3] }]

## ---- Switches SW0..SW3 — nivel de inyección de error PRBS ------------------
set_property -dict { PACKAGE_PIN ??? IOSTANDARD LVCMOS33 } [get_ports { sw[0] }]
set_property -dict { PACKAGE_PIN ??? IOSTANDARD LVCMOS33 } [get_ports { sw[1] }]
set_property -dict { PACKAGE_PIN ??? IOSTANDARD LVCMOS33 } [get_ports { sw[2] }]
set_property -dict { PACKAGE_PIN ??? IOSTANDARD LVCMOS33 } [get_ports { sw[3] }]
set_false_path -from [get_ports {sw[*]}]

## ---- UART (hacia el FTDI de la placa) ---------------------------------------
set_property -dict { PACKAGE_PIN ??? IOSTANDARD LVCMOS33 } [get_ports { rx }]
set_property -dict { PACKAGE_PIN ??? IOSTANDARD LVCMOS33 } [get_ports { tx }]
set_false_path -from [get_ports rx]
set_false_path -to   [get_ports tx]
