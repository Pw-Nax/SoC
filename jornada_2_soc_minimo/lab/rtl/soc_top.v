// =============================================================================
// soc_top.v — Top de síntesis para lab: SoC PicoRV32 en Arty A7-35T
//
// Puertos de board:
//   clk   100 MHz   E3
//   btn0  BTN0      D9   (presionar = reset, activo en alto)
//   led   LD0..LD3  H5,J5,T9,T10
//   sw    SW0..SW3  A8,C11,C10,A10
//   rx    UART RX   G13  (desde FTDI)
//   tx    UART TX   B11  (hacia FTDI)
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

    wire resetn = ~btn0;        // PicoRV32 usa reset activo en bajo

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
