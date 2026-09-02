# =============================================================================
# Makefile — Jornada 1: primer programa RISC-V corriendo en spike
# =============================================================================

CROSS   ?= riscv-none-elf
CC       = $(CROSS)-gcc
OBJDUMP  = $(CROSS)-objdump
READELF  = $(CROSS)-readelf

ARCH     = -march=rv32im -mabi=ilp32
CFLAGS   = $(ARCH) -O0 -g -ffreestanding -nostdlib

SPIKE    = spike
SPIKEFLAGS = --isa=rv32im

.PHONY: run debug debug-demo disasm check clean help

fw/gpio_demo.elf: fw/start.S fw/gpio_demo.c fw/link.ld
	$(CC) $(CFLAGS) -T fw/link.ld -o $@ fw/start.S fw/gpio_demo.c

# ─── Correr bajo spike ────────────────────────────────────────────────────
# Traza completa, no interactiva: se detiene sola a los 16 instrucciones
# (5 de arranque interno de spike + 11 de nuestro programa).
run: fw/gpio_demo.elf
	$(SPIKE) $(SPIKEFLAGS) --instructions=16 -l $<

# Debugger interactivo: vos escribís los comandos (reg, mem, run N, q...)
debug: fw/gpio_demo.elf
	$(SPIKE) -d $(SPIKEFLAGS) $<

# Mismo debugger pero con los comandos ya guionados (ver spike/cmds_demo.txt)
debug-demo: fw/gpio_demo.elf
	$(SPIKE) -d $(SPIKEFLAGS) --debug-cmd=spike/cmds_demo.txt $< < /dev/null

disasm: fw/gpio_demo.elf
	$(OBJDUMP) -d -M no-aliases fw/gpio_demo.elf

# ─── Verificación de herramientas ────────────────────────────────────────
check:
	@command -v $(CC)    >/dev/null 2>&1 && echo "[OK]    $(CC)"    || echo "[FALTA] $(CC)"
	@command -v $(SPIKE) >/dev/null 2>&1 && echo "[OK]    spike"    || echo "[FALTA] spike (ver comun/tools/spike-linux-x64.tar.gz)"

clean:
	rm -f fw/gpio_demo.elf

help:
	@echo ""
	@echo "  Jornada 1 — Ejercicio con spike"
	@echo ""
	@echo "  make check        Verificar que el toolchain y spike estén en el PATH"
	@echo "  make run          Compilar y correr una traza completa (no interactiva)"
	@echo "  make debug        Compilar y abrir el debugger interactivo de spike"
	@echo "  make debug-demo   Compilar y correr la secuencia guionada de la slide"
	@echo "  make disasm       Ver el desensamblado del programa"
	@echo "  make clean        Limpiar el .elf generado"
	@echo ""
