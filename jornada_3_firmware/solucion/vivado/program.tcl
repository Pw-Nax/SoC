# =============================================================================
# program.tcl — Programar Arty A7-35T (lab 4b)
# Uso: vivado -mode batch -source vivado/program.tcl  (desde lab/)
# =============================================================================

open_hw_manager
connect_hw_server -allow_non_jtag
open_hw_target
current_hw_device [get_hw_devices xc7a35t_0]
set_property PROGRAM.FILE {soc_top.bit} [get_hw_devices xc7a35t_0]
program_hw_devices [get_hw_devices xc7a35t_0]
close_hw_target
