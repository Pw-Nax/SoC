/* =============================================================================
 * start.S — arranque mínimo para el ejercicio de spike
 *
 * Versión reducida del CRT0 que vamos a construir de punta a punta en la
 * Jornada 3 (ahí se agrega la limpieza de .bss, que acá no hace falta
 * porque el programa no tiene variables globales).
 * ============================================================================= */

.section .text.start
.global _start

_start:
    la   sp, _stack_top   /* sp = tope de RAM (del linker script) */
    call main
_halt:
    j _halt                /* main() nunca debería retornar */
