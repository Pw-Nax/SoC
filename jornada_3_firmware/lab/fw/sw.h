// =============================================================================
// sw.h — Driver de los switches SW[3:0] de la Arty A7  [ESQUELETO PARA ESTUDIANTES]
//
// Mapeados como GPIO de entrada en 0x200004 (offset +0x4 dentro de la misma
// región GPIO donde vive GPIO_LEDS en 0x200000). Seleccionan en vivo, sin
// recompilar, uno de 16 niveles de inyección de error del stream PRBS.
//
// Mismo patrón MMIO que ya escribiste para GPIO_LEDS en prbs_gen.c, pero
// de lectura en vez de escritura.
// =============================================================================
#ifndef SW_H
#define SW_H

#include <stdint.h>

// ---------------------------------------------------------------------------
// TODO 1: Definir el puntero volátil al registro GPIO_SW en 0x00200004.
//   Mismo patrón que GPIO_LEDS: #define GPIO_SW (*(volatile uint32_t *)<dirección>)
// ---------------------------------------------------------------------------
/* TODO 1: #define GPIO_SW (*(volatile uint32_t *)0x00200004) */

// ---------------------------------------------------------------------------
// TODO 2: Leer los 4 switches. El registro comparte word con otros bits de
//   la región GPIO: enmascarar con 0xF antes de devolver el valor.
// ---------------------------------------------------------------------------
static inline uint32_t sw_read(void) {
    /* TODO 2: return GPIO_SW & 0xFu; */
    return 0;
}

// Periodo de inyección (en bits) por nivel de SW[3:0]. Nivel 0 = sin
// errores. El resto: valores impares/primos, decrecientes dentro de cada
// grupo (a menor período, errores más frecuentes = BER más alto), para no
// alinear con el empaquetado de 32 bits por palabra.
//
// TODO 3: completar los 3 valores faltantes (marcados abajo), manteniendo
//   la tendencia decreciente de cada grupo. No hace falta que sean primos
//   exactos — cualquier impar en el rango sugerido funciona.
static const uint32_t ERR_PERIOD_TABLE[16] = {
    0,                                          /* 0000: sin errores         */
    100003, 50021, 25013, 16001,                /* 0001..0100: BER bajo      */
    8009,   4001,  0 /* TODO 3: ~2000 */, 1021, /* 0101..1000: BER medio     */
    509,    0 /* TODO 3: ~250 */, 127,   61,     /* 1001..1100: BER alto     */
    31,     17,    0 /* TODO 3: ~10, impar */    /* 1101..1111: BER muy alto */
};

static inline uint32_t sw_err_period(void) {
    return ERR_PERIOD_TABLE[sw_read()];
}

#endif /* SW_H */
