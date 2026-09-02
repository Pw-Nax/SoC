# =============================================================================
# Makefile — Jornada 2: SoC PicoRV32 completo (BRAM + GPIO + switches + UART)
# =============================================================================

VIVADO  := vivado
GTKWAVE := gtkwave

TOP := soc_top
BIT := $(TOP).bit

.PHONY: sim wave synth gui program clean check help

check:
	@echo "=== Verificando herramientas ==="
	@command -v $(VIVADO)  >/dev/null 2>&1 && echo "[OK]    vivado"  || echo "[FALTA] vivado"
	@command -v $(GTKWAVE) >/dev/null 2>&1 && echo "[OK]    gtkwave" || echo "[FALTA] gtkwave"
	@test -f fw/boot.hex     && echo "[OK]    fw/boot.hex"     || echo "[FALTA] fw/boot.hex"
	@test -f fw/boot_sim.hex && echo "[OK]    fw/boot_sim.hex" || echo "[FALTA] fw/boot_sim.hex"

# ---------------------------------------------------------------------------
# El firmware (fw/boot.hex, fw/boot_sim.hex) viene DADO, ya compilado.
# Escribirlo desde cero, con su propio driver de UART, es el contenido de
# la Jornada 3 — acá el foco es el RTL, no el firmware.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Simulación (usa fw/boot.hex y fw/boot_sim.hex ya dados)
# ---------------------------------------------------------------------------
sim:
	mkdir -p vivado_work
	$(VIVADO) -mode batch -source vivado/sim.tcl \
	          -log vivado_work/sim.log \
	          -journal vivado_work/sim.jou

wave: tb_soc_minimal.vcd
	$(GTKWAVE) tb_soc_minimal.vcd tb_soc_minimal.gtkw &

# ---------------------------------------------------------------------------
# Síntesis y programación
# ---------------------------------------------------------------------------
synth:
	mkdir -p vivado_work
	$(VIVADO) -mode batch -source vivado/build.tcl \
	          -log vivado_work/build.log \
	          -journal vivado_work/build.jou

gui:
	mkdir -p vivado_work
	$(VIVADO) -mode gui -source vivado/open_gui.tcl \
	          -log vivado_work/gui.log \
	          -journal vivado_work/gui.jou &

program: $(BIT)
	$(VIVADO) -mode batch -source vivado/program.tcl \
	          -log vivado_work/program.log \
	          -journal vivado_work/program.jou

$(BIT):
	@echo "[ERROR] $(BIT) no encontrado — ejecutar 'make synth' primero"
	@exit 1

# ---------------------------------------------------------------------------
clean:
	rm -f tb_soc_minimal.vcd
	rm -rf vivado_work/ .Xil/ usage_statistics_webtalk.*

help:
	@echo ""
	@echo "  Jornada 2 — SoC PicoRV32 completo"
	@echo ""
	@echo "  make check    Verificar herramientas y firmware dado"
	@echo "  make sim      Simular con Vivado XSIM (fw/boot_sim.hex ya dado)"
	@echo "  make wave     Abrir formas de onda en GTKWave"
	@echo "  make synth    Sintetizar con Vivado (batch)"
	@echo "  make gui      Abrir proyecto en Vivado GUI (sim + synth)"
	@echo "  make program  Programar la Arty A7"
	@echo "  make clean    Limpiar archivos generados"
	@echo ""
