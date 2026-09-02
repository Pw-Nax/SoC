/* =============================================================================
 * link.ld — Linker script para el ejercicio de Jornada 1 (spike)
 *
 * OJO: esta dirección base (0x80000000) es la convención estándar de RISC-V
 * para simuladores como spike, NO el mapa de memoria de nuestro SoC real.
 * spike reserva siempre 0x00000000-0x00000FFF para su propio debug module,
 * así que no podemos poner la RAM en 0x0 como hace la placa (eso lo vemos
 * en la Jornada 2, con PicoRV32 + BRAM en 0x000000).
 * ============================================================================= */

MEMORY {
    RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 64K
}

SECTIONS {
    .text : {
        *(.text.start)      /* _start siempre al principio */
        *(.text*)
        *(.rodata*)
    } > RAM

    .data : {
        *(.data*) *(.sdata*)
    } > RAM

    .bss : {
        *(.bss*) *(.sbss*)
        *(COMMON)
    } > RAM

    _stack_top = ORIGIN(RAM) + LENGTH(RAM);
}
