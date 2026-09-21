// =============================================================================
// soc_top.v — Top de síntesis para lab_b: SoC PicoRV32 en Arty A7-35T
//
// Puertos de board:
//   clk   100 MHz   E3
//   btn0  BTN0      D9   (presionar = reset, activo en alto)
//   led   LD0..LD3  H5,J5,T9,T10
//   sw    SW0..SW3  A8,C11,C10,A10
//   rx    UART RX   G13  (desde FTDI)
//   tx    UART TX   B11  (hacia FTDI)
//
// Power-on-reset: PicoRV32 necesita ver un flanco real de resetn (no solo el
// nivel estático que deja la configuración) para arrancar a pedir memoria.
// por_cnt arranca en 0 (vía GSR) y mantiene resetn bajo unos pocos ciclos
// después de cada configuración, sin depender de que alguien apriete BTN0.
// =============================================================================

module soc_top #(
    parameter CLK_HZ = 100_000_000,
    parameter BAUD   = 115_200
)(
    input  wire       clk,
    input  wire       btn0,     // BTN0 active-high → resetn active-low
    output wire [3:0] led,
    input  wire [3:0] sw,
    input  wire       rx,
    output wire       tx
);

    reg [3:0] por_cnt = 4'h0;   // valor inicial explícito: modela el GSR real
                                // de la FPGA también en simulación (iverilog
                                // no inicializa regs en 0 por su cuenta)
    wire      por_done = (por_cnt == 4'hF);
    always @(posedge clk)
        if (!por_done) por_cnt <= por_cnt + 1;

    wire resetn = por_done & ~btn0;   // PicoRV32 usa reset activo en bajo

    soc_minimal #(
        .CLK_HZ (CLK_HZ),
        .BAUD   (BAUD)
    ) u_soc (
        .clk    (clk),
        .resetn (resetn),
        .led    (led),
        .sw     (sw),
        .rx     (rx),
        .tx     (tx)
    );

endmodule
