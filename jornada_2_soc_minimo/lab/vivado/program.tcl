# =============================================================================
# program.tcl — Programar Arty A7 via JTAG (lab)
# Uso: vivado -mode batch -source vivado/program.tcl  (ejecutar desde lab/)
# =============================================================================

open_hw_manager
connect_hw_server
open_hw_target [lindex [get_hw_targets] 0]
set device [lindex [get_hw_devices] 0]
current_hw_device $device
refresh_hw_device $device

set_property PROGRAM.FILE {soc_top.bit} $device
program_hw_devices $device

puts "\n\[OK\] Arty A7 programada con soc_top.bit\n"

close_hw_target
disconnect_hw_server
close_hw_manager
