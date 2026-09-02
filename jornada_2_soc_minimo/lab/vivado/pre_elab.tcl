# =============================================================================
# pre_elab.tcl — Hook pre-elaboración: copia fw/boot_sim.hex al xsim dir
#
# Vivado ejecuta este script ANTES de xelab (elaboración). En ese momento
# el directorio de xsim ya existe (lo creó xvlog) y xelab puede resolver
# $readmemh("fw/boot.hex") relativo a él.
#
# Funciona para batch (launch_simulation) y GUI (Run Behavioral Simulation).
# =============================================================================

# Derivar lab_dir desde la ubicación de este script
# (pre_elab.tcl está en lab/vivado/ → lab/ es un nivel arriba)
set script_dir [file dirname [file normalize [info script]]]
set lab_dir    [file normalize [file join $script_dir ..]]

# Derivar xsim working directory desde el proyecto Vivado actual
set proj_dir  [get_property DIRECTORY [current_project]]
set proj_name [get_property NAME [current_project]]
set xsim_dir  [file join $proj_dir ${proj_name}.sim sim_1 behav xsim]

# Copiar boot_sim.hex (delay=100 ciclos, -DSIM) como fw/boot.hex para que
# $readmemh("fw/boot.hex") en bram_sp.v cargue el firmware de simulación.
set fw_src [file join $lab_dir fw boot_sim.hex]
if {[file exists $fw_src]} {
    file mkdir [file join $xsim_dir fw]
    file copy -force $fw_src [file join $xsim_dir fw boot.hex]
    puts "\[pre_elab\] fw/boot_sim.hex → $xsim_dir/fw/boot.hex"
} else {
    puts "\[pre_elab\] WARNING: $fw_src no encontrado — ejecutar 'make sim' primero"
}
