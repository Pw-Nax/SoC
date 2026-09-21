# =============================================================================
# Makefile — Jornada 3: PicoRV32 + BRAM + GPIO — Flujo de Compilación
# =============================================================================

CROSS    ?= riscv-none-elf
CC        = $(CROSS)-gcc
OBJCOPY   = $(CROSS)-objcopy
OBJDUMP   = $(CROSS)-objdump
READELF   = $(CROSS)-readelf

VIVADO    = vivado
GTKWAVE   = gtkwave
IVERILOG  = iverilog
VVP       = vvp

ARCH      = -march=rv32im_zicsr -mabi=ilp32
CFLAGS    = $(ARCH) -Os -ffreestanding -nostdlib
LDFLAGS   = $(ARCH) -nostdlib -T fw/link.ld

PICORV32  = rtl/picorv32.v
SIM_SRCS  = $(PICORV32) rtl/bram_sp.v rtl/uart_tx.v rtl/uart_rx.v rtl/uart_regs.v rtl/soc_minimal.v rtl/soc_top.v sim/tb_soc.v

TOP = soc_top
BIT = $(TOP).bit

.PHONY: hex hex-sim disasm disasm-src header sim wave synth gui program check clean help

# ─── Firmware (hardware) ─────────────────────────────────────────────────────
fw/prbs_gen.elf: fw/start.S fw/prbs_gen.c fw/uart.c fw/link.ld fw/uart.h fw/prbs.h fw/sw.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ fw/start.S fw/prbs_gen.c fw/uart.c

fw/prbs_gen.bin: fw/prbs_gen.elf
	$(OBJCOPY) -O binary $< $@

fw/boot.hex: fw/prbs_gen.bin
	python3 fw/bin2hex.py $< > $@
	@wc -l fw/boot.hex | awk '{print "[OK] fw/boot.hex: " $$1 " palabras de 32 bits"}'

hex: fw/boot.hex

# ─── Firmware (simulación) ───────────────────────────────────────────────────
fw/prbs_gen_sim.elf: fw/start.S fw/prbs_gen.c fw/uart.c fw/link.ld fw/uart.h fw/prbs.h fw/sw.h
	$(CC) $(CFLAGS) $(LDFLAGS) -DSIM -o $@ fw/start.S fw/prbs_gen.c fw/uart.c

fw/prbs_gen_sim.bin: fw/prbs_gen_sim.elf
	$(OBJCOPY) -O binary $< $@

fw/boot_sim.hex: fw/prbs_gen_sim.bin
	python3 fw/bin2hex.py $< > $@
	@echo "[OK] fw/boot_sim.hex (DELAY_CYCLES=200)"

hex-sim: fw/boot_sim.hex

# ─── Análisis: desensamblado ─────────────────────────────────────────────────
disasm: fw/prbs_gen.elf
	@echo ""
	@echo "=== Desensamblado de fw/prbs_gen.elf ==="
	@echo ""
	$(OBJDUMP) -d -M no-aliases fw/prbs_gen.elf

# Interleave código C con el assembler generado (requiere -g en CFLAGS)
disasm-src: CFLAGS += -g
disasm-src: fw/prbs_gen.elf
	$(OBJDUMP) -d -S -M no-aliases fw/prbs_gen.elf

# Ver header del ELF (formato, entry point, tipo de máquina)
header: fw/prbs_gen.elf
	@echo ""
	@echo "=== Header del ELF ==="
	$(READELF) -h fw/prbs_gen.elf

# Ver secciones y tamaños
sections: fw/prbs_gen.elf
	@echo ""
	@echo "=== Secciones del ELF ==="
	$(READELF) -S fw/prbs_gen.elf
	@echo ""
	@echo "=== Mapa de memoria ==="
	$(CROSS)-nm --print-size --size-sort fw/prbs_gen.elf | tail -20

# ─── Simulación iverilog ──────────────────────────────────────────────────────
sim.vvp: $(SIM_SRCS) fw/boot_sim.hex
	$(IVERILOG) -g2005 -DSIM -o $@ $(SIM_SRCS)

sim: sim.vvp
	$(VVP) $<

wave: tb_soc.vcd
	$(GTKWAVE) tb_soc.vcd &

# ─── Vivado ───────────────────────────────────────────────────────────────────
xsim: hex hex-sim
	mkdir -p vivado_work
	$(VIVADO) -mode batch -source vivado/sim.tcl \
	          -log vivado_work/sim.log -journal vivado_work/sim.jou

synth: hex
	mkdir -p vivado_work
	$(VIVADO) -mode batch -source vivado/build.tcl \
	          -log vivado_work/build.log -journal vivado_work/build.jou

gui: hex hex-sim
	mkdir -p vivado_work
	$(VIVADO) -mode gui -source vivado/open_gui.tcl \
	          -log vivado_work/gui.log -journal vivado_work/gui.jou &

program: $(BIT)
	$(VIVADO) -mode batch -source vivado/program.tcl \
	          -log vivado_work/program.log -journal vivado_work/program.jou

$(BIT):
	@echo "[ERROR] $(BIT) no encontrado — ejecutar 'make synth' primero"
	@exit 1

# ─── Utilidades ──────────────────────────────────────────────────────────────
check:
	@echo "=== Verificando herramientas ==="
	@command -v $(CC)       >/dev/null 2>&1 && echo "[OK]    $(CC)"    || echo "[FALTA] $(CC)"
	@command -v $(IVERILOG) >/dev/null 2>&1 && echo "[OK]    iverilog" || echo "[FALTA] iverilog"
	@command -v $(VIVADO)   >/dev/null 2>&1 && echo "[OK]    vivado"   || echo "[FALTA] vivado"
	@test -f $(PICORV32)    && echo "[OK]    picorv32.v" || echo "[FALTA] $(PICORV32)"

clean:
	rm -f fw/*.elf fw/*.bin fw/*.hex
	rm -f sim.vvp tb_soc.vcd
	rm -f $(BIT) rpt_*.txt
	rm -rf vivado_work/ .Xil/ usage_statistics_webtalk.*

help:
	@echo ""
	@echo "  Jornada 3 — PicoRV32 + BRAM + GPIO — Flujo de Compilación"
	@echo ""
	@echo "  make check       Verificar herramientas"
	@echo "  make hex         Compilar firmware → fw/boot.hex"
	@echo "  make hex-sim     Compilar con -DSIM (delay corto para simulación)"
	@echo "  make disasm      Desensamblado completo del firmware"
	@echo "  make disasm-src  Desensamblado con código C intercalado"
	@echo "  make header      Ver header del ELF (readelf -h)"
	@echo "  make sections    Ver secciones y tamaños del ELF (readelf -S)"
	@echo "  make sim         Simular con iverilog (requiere: make hex-sim)"
	@echo "  make wave        Abrir VCD en GTKWave"
	@echo "  make synth       Sintetizar con Vivado (batch)"
	@echo "  make gui         Abrir proyecto en Vivado GUI"
	@echo "  make program     Programar la Arty A7"
	@echo "  make clean       Limpiar archivos generados"
	@echo ""
