# =============================================================================
# sim.tcl — Simulación behavioral: tb_soc_minimal (SoC PicoRV32, Jornada 2)
# fw/boot.hex y fw/boot_sim.hex vienen dados, ya compilados.
# Uso: vivado -mode batch -source vivado/sim.tcl
# =============================================================================

set PART    xc7a35ticsg324-1L
set SIM_TOP tb_soc_minimal
set PROJ    sim_proj

create_project $PROJ vivado_work/$PROJ -part $PART -force

# PicoRV32 (copia local, autocontenida)
add_files rtl/picorv32.v

# RTL del lab y testbench
add_files          [glob rtl/*.v]
add_files -fileset sim_1 sim/tb_soc_minimal.v

set_property top     $SIM_TOP [get_filesets sim_1]
set_property top_lib {}       [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# xelab corre desde .../xsim/ y resuelve $readmemh("fw/boot.hex") desde ahí.
# Copiamos boot_sim.hex (delay=100 ciclos, -DSIM) como fw/boot.hex antes de
# launch_simulation. xvlog usa --incr y no borra el directorio existente.
set xsim_dir [file normalize [file join vivado_work $PROJ ${PROJ}.sim sim_1 behav xsim]]
file mkdir [file join $xsim_dir fw]
file copy -force fw/boot_sim.hex [file join $xsim_dir fw boot.hex]

launch_simulation -simset sim_1 -mode behavioral

# ---------------------------------------------------------------------------
# Señales de debug más importantes, agrupadas en el visor de formas de onda
# de Vivado. Se guardan en ${SIM_TOP}.wcfg para reabrir el mismo layout
# (Tools > Waveform Configuration > Open, o con 'make gui').
#
# launch_simulation ya creó una vista por defecto con TODAS las señales
# top-level sin agrupar (add_wave / automático de Vivado); create_wave_config
# la descarta y arranca de una vista en blanco para no duplicar señales.
# ---------------------------------------------------------------------------
create_wave_config

set grp_clk [add_wave_group "Reloj / Reset"]
add_wave -into $grp_clk {/tb_soc_minimal/clk}
add_wave -into $grp_clk {/tb_soc_minimal/resetn}

set grp_bus [add_wave_group "Bus PicoRV32"]
add_wave -into $grp_bus {/tb_soc_minimal/mem_valid}
add_wave -into $grp_bus {/tb_soc_minimal/mem_ready}
add_wave -into $grp_bus -radix hex {/tb_soc_minimal/mem_addr}
add_wave -into $grp_bus -radix hex {/tb_soc_minimal/mem_wdata}
add_wave -into $grp_bus -radix bin {/tb_soc_minimal/mem_wstrb}

set grp_out [add_wave_group "Salidas del SoC"]
add_wave -into $grp_out -radix bin {/tb_soc_minimal/led}
add_wave -into $grp_out {/tb_soc_minimal/tx}

set grp_mon [add_wave_group "Monitor del testbench"]
add_wave -into $grp_mon {/tb_soc_minimal/cycle}
add_wave -into $grp_mon {/tb_soc_minimal/gpio_writes}
add_wave -into $grp_mon {/tb_soc_minimal/uart_chars}
add_wave -into $grp_mon -radix hex {/tb_soc_minimal/rx_byte}
add_wave -into $grp_mon {/tb_soc_minimal/errors}

run all
save_wave_config ${SIM_TOP}.wcfg
close_sim

# Copiar VCD al directorio del lab para 'make wave'
set vcd_src [file join vivado_work $PROJ ${PROJ}.sim sim_1 behav xsim ${SIM_TOP}.vcd]
if {[file exists $vcd_src]} {
    file copy -force $vcd_src ${SIM_TOP}.vcd
    puts "\n\[OK\] ${SIM_TOP}.vcd copiado — ejecutar 'make wave' para ver formas de onda\n"
} else {
    puts "\n\[WARN\] VCD no encontrado en $vcd_src\n"
}

if {[file exists ${SIM_TOP}.wcfg]} {
    puts "\[OK\] ${SIM_TOP}.wcfg guardado — abrir en Vivado GUI para ver el layout de señales\n"
} else {
    puts "\[WARN\] ${SIM_TOP}.wcfg no se generó\n"
}
