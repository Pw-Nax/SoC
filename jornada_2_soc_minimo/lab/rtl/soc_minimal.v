// =============================================================================
// soc_minimal.v — SoC mínimo: PicoRV32 + BRAM + GPIO (LEDs + switches) + UART
//
// Objetivo: armar el SoC completo, de punta a punta: decodificador de
// dirección, instancias de BRAM/CPU/UART, registro de GPIO con switches, y
// el mux/handshake que conecta todo con el bus del procesador. No hace
// falta escribir C todavía: se prueba con un firmware ya compilado
// (fw/boot.hex), un generador PRBS con inyección de error controlada por
// los switches SW[3:0]. Escribir ese mismo firmware desde cero, con su
// propio driver de UART, es el contenido de la Jornada 3.
//
// picorv32.v, bram_sp.v y uart_regs.v (+ uart_tx.v/uart_rx.v) son módulos
// dados: no hay que reescribir su interior, solo instanciarlos.
//
// Mapa de memoria:
//   0x0000_0000 – 0x0000_3FFF  BRAM  (16 KB — instrucciones + datos)
//   0x0020_0000                GPIO_LEDS — bits [3:0] → LD0..LD3 (W)
//   0x0020_0004                GPIO_SW   — bits [3:0] ← SW0..SW3 (R)
//   0x0030_0000                UART  (DATA/STATUS)
//
// Tareas a completar:
//   TODO 1 — Decodificador de dirección (sel_bram, sel_gpio, sel_uart)
//   TODO 2 — Instanciar picorv32
//   TODO 3 — Instanciar bram_sp
//   TODO 4 — GPIO: registro de LEDs + lectura de switches
//   TODO 5 — Instanciar uart_regs
//   TODO 6 — mem_rdata (mux de 3 vías) y mem_ready con la latencia de la BRAM
//
// Verificación:
//   make sim   → Vivado XSIM: verificar escritura al GPIO y banner por UART
//   make synth → bitstream (requiere completar también constraints/arty_a7.xdc)
//   make program → programar Arty A7, mover SW[3:0] y ver que el nivel
//                  reportado por UART cambia en vivo
// =============================================================================

module soc_minimal #(
    parameter MEM_WORDS = 4096,         // 4K × 32 bits = 16 KB
    parameter CLK_HZ    = 100_000_000,
    parameter BAUD      = 115_200
)(
    input  wire        clk,
    input  wire        resetn,
    output wire [3:0]  led,
    input  wire [3:0]  sw,              // SW0..SW3 — nivel de inyección de error
    input  wire        rx,
    output wire        tx
);

// ---------------------------------------------------------------------------
// Bus PicoRV32 — señales entre el CPU y el sistema de memoria
// ---------------------------------------------------------------------------
wire [31:0] mem_addr, mem_wdata, mem_rdata;
wire  [3:0] mem_wstrb;
wire        mem_valid, mem_ready;

// ---------------------------------------------------------------------------
// TODO 1: Decodificador de dirección
//
// Tres señales combinacionales, activas cuando mem_valid=1 y la dirección
// cae en el rango de cada periférico (ver mapa de memoria arriba):
//   sel_bram: 0x000000..0x003FFF  (14 bits bajos cubren 16 KB)
//   sel_gpio: 0x200000            (dirección fija, comparar 24 bits altos)
//   sel_uart: 0x300000..0x3FFFFF  (comparar 12 bits altos)
//
// Repasá la sección "Decodificador de dirección" de las slides antes de
// escribirlo — el patrón es el mismo para los tres.
// ---------------------------------------------------------------------------


// definir sel_bram, sel_gpio, sel_uart aquí


// ---------------------------------------------------------------------------
// TODO 2: Instanciar el procesador PicoRV32
//
// El módulo se llama picorv32 (ver rtl/picorv32.v). Parámetros a fijar
// (repasá qué significa cada uno en la sección "PicoRV32: microarquitectura"
// de las slides):
//   ENABLE_MUL / ENABLE_DIV : 1 — el firmware usa multiplicación/división
//   ENABLE_IRQ              : 0 — sin interrupciones en esta jornada
//   ENABLE_COUNTERS         : 1 — habilita rdcycle (usado para delays en C)
//   PROGADDR_RESET          : dirección donde arranca el PC al reset
//   STACKADDR                : dirección inicial del stack pointer
//
// Puertos a conectar por nombre (.puerto(señal)): clk, resetn, y las 6
// señales del bus mem_* ya declaradas arriba.
// ---------------------------------------------------------------------------


// instanciar picorv32 aquí


// ---------------------------------------------------------------------------
// TODO 3: Instanciar la BRAM de instrucciones/datos
//
// El módulo se llama bram_sp (ver rtl/bram_sp.v). Parámetros:
//   DATA_W    : 32
//   ADDR_W    : $clog2(MEM_WORDS) — usá el localparam ADDR_W de abajo
//   INIT_FILE : "fw/boot.hex" — el firmware ya compilado
//
// Puertos: clk, ena (=sel_bram), wea (=|mem_wstrb, ¿por qué el OR de los
// 4 bits?), addr (mem_addr desplazado 2 bits: byte-addr -> word-addr),
// din (=mem_wdata), dout (declarar bram_rdata más abajo y usarlo acá).
// ---------------------------------------------------------------------------

localparam ADDR_W = $clog2(MEM_WORDS);  // 12


// declarar bram_rdata e instanciar bram_sp aquí


// ---------------------------------------------------------------------------
// TODO 4: GPIO — salida a LEDs (offset 0x0) y entrada de switches (offset 0x4)
//
// Una señal combinacional gpio_is_sw = mem_addr[2] distingue el offset
// dentro de la región GPIO (0x200000 vs 0x200004).
//
// Registro gpio_reg (4 bits): en reset vale 0; se actualiza con
// mem_wdata[3:0] cuando sel_gpio, !gpio_is_sw (offset de LEDs) y hay
// wstrb. led = gpio_reg (asignación continua).
//
// La lectura de sw se resuelve en el mux del TODO 6, no acá.
// ---------------------------------------------------------------------------


// definir gpio_is_sw, gpio_reg y assign led aquí


// ---------------------------------------------------------------------------
// TODO 5: Instanciar la UART
//
// El módulo se llama uart_regs (ver rtl/uart_regs.v). Parámetros:
//   CLK_HZ : CLK_HZ (parámetro del módulo)
//   BAUD   : BAUD (parámetro del módulo)
//
// Puertos: clk, resetn, sel (=sel_uart), reg_sel (=mem_addr[2], distingue
// DATA de STATUS dentro de la región UART), wstrb, wdata, rdata (declarar
// uart_rdata más abajo), ready (declarar uart_ready más abajo), rx, tx.
// ---------------------------------------------------------------------------


// declarar uart_rdata/uart_ready e instanciar uart_regs aquí


// ---------------------------------------------------------------------------
// TODO 6: Multiplexor de lectura y mem_ready con latencia correcta (3 vías)
//
// mem_rdata (combinacional): elegir entre bram_rdata, uart_rdata y el GPIO
// (que a su vez es gpio_reg o sw según gpio_is_sw) según cuál señal de
// selección esté activa.
//
// mem_ready — por qué NO es simplemente "sel_bram || sel_gpio || sel_uart":
//   La BRAM tiene 1 ciclo de latencia (dout se registra en el posedge).
//   Si mem_ready fuera inmediato, el CPU capturaría datos no válidos.
//   GPIO y UART sí son inmediatos (uart_ready ya viene resuelto del módulo).
//
// Repasá el patrón de "pulso de 1 ciclo" para mem_ready que viste en la
// sección "Interfaz de memoria PicoRV32" de las slides antes de escribirlo.
// ---------------------------------------------------------------------------


// assign mem_rdata = ...
// assign mem_ready = ...

endmodule
