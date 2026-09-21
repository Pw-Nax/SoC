// =============================================================================
// uart.h — Interfaz pública del driver de UART (implementado en uart.c)
// Jornada 3 — PicoRV32 + BRAM + GPIO + UART
//
// El mapa de registros del hardware es un detalle interno de uart.c: este
// header solo declara lo que el resto del firmware puede usar.
// =============================================================================

#ifndef UART_H
#define UART_H

#include <stdint.h>

void uart_putc(char c);
void uart_puts(const char *s);
void uart_print_uint(uint32_t v);

// Definida (sin "static") en uart.c; "extern" acá le dice al compilador
// "este símbolo existe, se define en otro archivo" para que cualquier .c
// que incluya este header pueda leerla sin volver a definirla.
extern uint32_t uart_tx_count;

#endif /* UART_H */
