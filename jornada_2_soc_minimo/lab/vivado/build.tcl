# =============================================================================
# build.tcl — Jornada 2: SoC PicoRV32 + BRAM + GPIO
# Uso: vivado -mode batch -source vivado/build.tcl  (ejecutar desde lab/)
# =============================================================================

set PART xc7a35ticsg324-1L
set TOP  soc_top

create_project -in_memory -part $PART

# PicoRV32 (copia local, autocontenida)
read_verilog rtl/picorv32.v

# RTL del lab
read_verilog [glob rtl/*.v]

synth_design -top $TOP -part $PART

read_xdc constraints/arty_a7.xdc

opt_design
place_design
route_design

write_bitstream -force ${TOP}.bit

report_utilization    -file rpt_utilization.txt
report_timing_summary -file rpt_timing.txt
report_power          -file rpt_power.txt
report_drc            -file rpt_drc.txt

puts "\n\[OK\] ${TOP}.bit generado\n"
puts "      Revisar rpt_utilization.txt para confirmar BRAM e instrucciones del CPU\n"
