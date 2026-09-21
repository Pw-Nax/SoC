# =============================================================================
# open_gui.tcl — Abrir proyecto en Vivado GUI (lab 4b)
# Uso: vivado -mode gui -source vivado/open_gui.tcl  (desde lab/)
# =============================================================================

set PART xc7a35ticsg324-1L
set TOP  soc_top
set PROJ gui_proj

create_project $PROJ vivado_work/$PROJ -part $PART -force

add_files rtl/picorv32.v
add_files [glob rtl/*.v]
add_files -fileset constrs_1 constraints/arty_a7.xdc

add_files -fileset sim_1 sim/tb_soc.v
set_property top $TOP [current_fileset]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
