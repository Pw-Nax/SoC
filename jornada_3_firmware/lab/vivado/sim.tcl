# =============================================================================
# sim.tcl — Simulación XSIM: tb_soc (SoC PicoRV32, lab 4b)
# Uso: vivado -mode batch -source vivado/sim.tcl  (ejecutar desde lab/)
# =============================================================================

set PART    xc7a35ticsg324-1L
set SIM_TOP tb_soc
set PROJ    sim_proj

create_project $PROJ vivado_work/$PROJ -part $PART -force

add_files rtl/picorv32.v
add_files          [glob rtl/*.v]
add_files -fileset sim_1 sim/tb_soc.v

set_property top     $SIM_TOP [get_filesets sim_1]
set_property top_lib {}       [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Pre-copiar boot_sim.hex al directorio de XSIM (resuelve $readmemh relativo)
set xsim_dir [file normalize [file join vivado_work $PROJ ${PROJ}.sim sim_1 behav xsim]]
file mkdir [file join $xsim_dir fw]
file copy -force fw/boot_sim.hex [file join $xsim_dir fw boot.hex]

launch_simulation -simset sim_1 -mode behavioral
run all
close_sim

set vcd_src [file join vivado_work $PROJ ${PROJ}.sim sim_1 behav xsim ${SIM_TOP}.vcd]
if {[file exists $vcd_src]} {
    file copy -force $vcd_src ${SIM_TOP}.vcd
    puts "\n\[OK\] ${SIM_TOP}.vcd — ejecutar 'make wave' para abrir GTKWave\n"
}
