// =============================================================================
// uart.c — Driver bare-metal para uart_regs.v  [ESQUELETO PARA ESTUDIANTES]
// Jornada 3 — PicoRV32 + BRAM + GPIO + UART
//
// Mapa de registros (base = 0x00300000), ya dado por el hardware:
//   +0x00  DATA   — W: byte a transmitir  /  R: byte recibido (limpia RX_VALID)
//   +0x04  STATUS — bit0=TX_BUSY  bit1=RX_VALID  bit2=RX_OVERFLOW
//
// Es un detalle interno de este archivo: por eso vive acá y no en uart.h,
// que es el contrato público con el resto del firmware.
//
// Lo que falta es el DRIVER: la lógica en C que espera a que el hardware
// esté listo antes de escribir/leer. Esa es la parte de esta jornada.
// =============================================================================

#include "uart.h"

#define UART_BASE    0x00300000UL
#define UART_DATA    (*(volatile uint32_t *)(UART_BASE + 0x00))
#define UART_STATUS  (*(volatile uint32_t *)(UART_BASE + 0x04))

#define UART_TX_BUSY     (1u << 0)
#define UART_RX_VALID    (1u << 1)
#define UART_RX_OVERFLOW (1u << 2)

// Bytes transmitidos desde el arranque — enlace externo (sin "static"),
// declarada "extern" en uart.h para que prbs_gen.c pueda leerla.
uint32_t uart_tx_count = 0;

// ---------------------------------------------------------------------------
// TODO 1: Esperar a que el transmisor esté libre.
//   Mientras UART_STATUS tenga el bit UART_TX_BUSY en 1, el hardware
//   todavía está mandando el byte anterior — escribir uno nuevo ahora lo
//   pisaría. Patrón: "while (ocupado) ;"
//
//   Esta función es "static": solo la usa uart_putc, acá mismo en este
//   archivo. Al linker ni le llega el símbolo — es un detalle interno,
//   no parte del contrato de uart.h.
// ---------------------------------------------------------------------------
static void uart_wait_tx(void)
{
    /* TODO 1: while (UART_STATUS & UART_TX_BUSY) ; */
}

// Enviar un byte (ya dado, usa uart_wait_tx de arriba)
void uart_putc(char c)
{
    uart_wait_tx();
    UART_DATA = (uint32_t)(uint8_t)c;
    uart_tx_count++;
}

// Enviar un string: llama uart_putc por cada caracter (ya dado)
void uart_puts(const char *s)
{
    while (*s)
        uart_putc(*s++);
}

// ---------------------------------------------------------------------------
// TODO 2: Imprimir un entero sin signo en decimal.
//   No hay una instrucción que convierta un número a texto: hay que
//   construirlo dígito por dígito. Idea: ir dividiendo por 10 y guardando
//   el resto (v % 10) en un buffer, de menos significativo a más
//   significativo, y después imprimir el buffer al revés.
// ---------------------------------------------------------------------------
void uart_print_uint(uint32_t v)
{
    char tmp[11];
    int  i = 0;
    if (v == 0) { uart_putc('0'); return; }

    /* TODO 2: while (v) { tmp[i++] = '0' + (v % 10); v /= 10; } */

    while (i--) uart_putc(tmp[i]);
}
