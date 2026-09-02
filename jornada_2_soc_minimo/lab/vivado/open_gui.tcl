# =============================================================================
# open_gui.tcl — Abrir proyecto en Vivado GUI (síntesis + simulación)
# Requiere: fw/boot.hex  (ejecutar 'make hex' antes)
# Uso: vivado -mode gui -source vivado/open_gui.tcl  (ejecutar desde lab/)
# =============================================================================

set PROJECT_NAME soc_lab
set PART         xc7a35ticsg324-1L
set TOP          soc_top
set SIM_TOP      tb_soc_minimal

create_project $PROJECT_NAME vivado_work/$PROJECT_NAME -part $PART -force

# PicoRV32 (copia local, autocontenida)
add_files rtl/picorv32.v

# RTL + constraints + testbench
add_files          [glob rtl/*.v]
add_files -fileset constrs_1 constraints/arty_a7.xdc
add_files -fileset sim_1     sim/tb_soc_minimal.v

set_property top     $TOP     [current_fileset]
set_property top     $SIM_TOP [get_filesets sim_1]
set_property top_lib {}       [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Pre-copia fw/boot_sim.hex al xsim working dir antes de que el usuario lance la sim.
# Usamos info script para derivar lab_dir de forma robusta (independiente del CWD).
# xvlog usa --incr y no borra archivos existentes; xelab resuelve $readmemh("fw/boot.hex")
# relativo al xsim dir, donde ya estará el archivo.
set script_dir [file dirname [file normalize [info script]]]
set lab_dir    [file normalize [file join $script_dir ..]]
set proj_dir   [get_property DIRECTORY [current_project]]
set proj_name  [get_property NAME      [current_project]]
set xsim_dir   [file join $proj_dir ${proj_name}.sim sim_1 behav xsim]
file mkdir [file join $xsim_dir fw]
file copy -force [file join $lab_dir fw boot_sim.hex] [file join $xsim_dir fw boot.hex]
puts "\[open_gui\] boot_sim.hex → $xsim_dir/fw/boot.hex"

# Runtime 25us > duración del testbench (2000 ciclos × 10ns = 20us).
# Vivado genera "run 25us"; xsim se detiene antes en el $finish del testbench.
# Nota: {} vacío y {all} son ignorados por Vivado 2024.2 y vuelve al default 1000ns.
set_property xsim.simulate.runtime {25us} [get_filesets sim_1]

puts "\n\[OK\] Proyecto '$PROJECT_NAME' listo en Vivado GUI"
puts "      Síntesis:   Flow Navigator → Run Implementation"
puts "      Simulación: Flow Navigator → Run Simulation → Run Behavioral Simulation\n"
