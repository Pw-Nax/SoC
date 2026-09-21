# =============================================================================
# program.tcl — Programar Arty A7 via JTAG
# Jornada 4 — SoC 2-Core con Mailbox
# =============================================================================

open_hw_manager
connect_hw_server
open_hw_target

set device [lindex [get_hw_devices] 0]
current_hw_device $device
refresh_hw_device $device

set_property PROGRAM.FILE {soc_2core_top.bit} $device
program_hw_devices $device
refresh_hw_device $device

close_hw_target
disconnect_hw_server
close_hw_manager

puts "\[OK\] Arty A7 programada con soc_2core_top.bit"
