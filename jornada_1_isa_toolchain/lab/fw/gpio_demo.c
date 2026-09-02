/* =============================================================================
 * gpio_demo.c — el mismo GPIO = 0x1 de la slide, corriendo de verdad
 * ============================================================================= */

#define GPIO (*(volatile unsigned int *)0x80001000)

void main(void) {
    /* TODO: escribir 0x1 en GPIO (una sola línea, la misma que en la slide) */
    while (1) ;
}
