// =============================================================================
// prbs_gen.c — GPIO + switches + UART: el firmware completo (Jornada 3)
//
// Es el MISMO firmware que ya viste corriendo en la Jornada 2 (te lo dimos
// compilado, como fw/boot.hex) — ahora lo escribís vos, de punta a punta,
// con tu propio driver de UART.
//
// sw.h ya decodifica los switches contra una tabla (ERR_PERIOD_TABLE): para
// qué se usa ese valor decodificado lo vas a ver en la próxima jornada —
// por ahora es solo otro ejercicio de MMIO + lookup table.
//
// Mapa de memoria:
//   0x000000 – 0x003FFF  BRAM (código + datos)
//   0x200000             GPIO_LEDS — bits [3:0] → LD0..LD3
//   0x200004             GPIO_SW   — bits [3:0] ← SW0..SW3 (ver sw.h)
//   0x300000             UART — ver uart.h
// =============================================================================

#include <stdint.h>
#include "uart.h"
#include "sw.h"

/* Puntero volátil al registro GPIO: el compilador NO puede cachearlo
   en un registro — cada acceso genera una instrucción de store/load. */
#define GPIO_LEDS  (*(volatile uint32_t *)0x200000)

static inline uint32_t rdcycle(void)
{
    uint32_t c;
    asm volatile ("csrr %0, cycle" : "=r"(c));
    return c;
}

static void delay_cycles(uint32_t n)
{
    uint32_t t0 = rdcycle();
    while ((rdcycle() - t0) < n);
}

#ifdef SIM
#  define DELAY_CYCLES  100UL
#else
#  define DELAY_CYCLES  5000000UL   /* ~50 ms a 100 MHz */
#endif

/* Entry point — llamado desde start.S después de inicializar sp y .bss */
void main(void)
{
    uart_puts("\r\n=== Jornada 3: GPIO + switches + UART ===\r\n");
    uart_puts("Move SW[3:0] y mira como cambia el valor decodificado\r\n\r\n");

    uint32_t block_num = 0;

    while (1) {
        GPIO_LEDS = block_num & 0xF;

        uart_puts("[bloque "); uart_print_uint(block_num);
        uart_puts("] SW="); uart_print_uint(sw_read());
        uart_puts(" decod="); uart_print_uint(sw_err_period());
        uart_puts("\r\n");

        block_num++;
        delay_cycles(DELAY_CYCLES);
    }
}
