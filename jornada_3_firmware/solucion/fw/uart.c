// =============================================================================
// uart.c — Driver bare-metal para uart_regs.v
// Jornada 3 — PicoRV32 + BRAM + GPIO + UART
//
// Mapa de registros (base = 0x00300000) — detalle de implementación, por eso
// vive acá y no en uart.h: el resto del firmware no necesita conocerlo.
//   +0x00  DATA   — W: byte a transmitir  /  R: byte recibido (limpia RX_VALID)
//   +0x04  STATUS — bit0=TX_BUSY  bit1=RX_VALID  bit2=RX_OVERFLOW
// =============================================================================

#include "uart.h"

#define UART_BASE    0x00300000UL
#define UART_DATA    (*(volatile uint32_t *)(UART_BASE + 0x00))
#define UART_STATUS  (*(volatile uint32_t *)(UART_BASE + 0x04))

#define UART_TX_BUSY     (1u << 0)
#define UART_RX_VALID    (1u << 1)
#define UART_RX_OVERFLOW (1u << 2)

// Bytes transmitidos desde el arranque. Sin "static": tiene enlace externo,
// por eso cualquier .c que incluya uart.h (donde está declarada "extern")
// puede leerla — por ejemplo prbs_gen.c para mostrarla por pantalla.
uint32_t uart_tx_count = 0;

// Esperar a que el transmisor esté libre. "static": enlace interno, este
// símbolo no existe para el linker fuera de uart.c — es un detalle de cómo
// uart_putc está implementada, no parte del contrato con el resto del
// firmware.
static void uart_wait_tx(void)
{
    while (UART_STATUS & UART_TX_BUSY)
        ;
}

// Enviar un byte: espera que TX no esté ocupado, luego escribe
void uart_putc(char c)
{
    uart_wait_tx();
    UART_DATA = (uint32_t)(uint8_t)c;
    uart_tx_count++;
}

// Enviar un string: llama uart_putc por cada caracter
void uart_puts(const char *s)
{
    while (*s)
        uart_putc(*s++);
}

// Imprimir un entero sin signo en decimal
void uart_print_uint(uint32_t v)
{
    char tmp[11];
    int  i = 0;
    if (v == 0) { uart_putc('0'); return; }
    while (v) { tmp[i++] = '0' + (v % 10); v /= 10; }
    while (i--) uart_putc(tmp[i]);
}
