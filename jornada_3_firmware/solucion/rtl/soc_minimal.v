// =============================================================================
// soc_minimal.v — SoC mínimo: PicoRV32 + BRAM + GPIO (LEDs + switches) + UART
// Jornada 3 — PicoRV32 + BRAM + GPIO + UART
//
// Mapa de memoria:
//   0x0000_0000 – 0x0000_3FFF  BRAM instrucciones/datos (16 KB)
//   0x0020_0000                GPIO_LEDS — bits [3:0] → LD0..LD3 (W)
//   0x0020_0004                GPIO_SW   — bits [3:0] ← SW0..SW3 (R)
//   0x0030_0000                UART — DATA/STATUS (ver uart.h)
// =============================================================================

module soc_minimal #(
    parameter MEM_WORDS = 4096,         // 4K × 32 bits = 16 KB
    parameter CLK_HZ    = 100_000_000,
    parameter BAUD      = 115_200
)(
    input  wire        clk,
    input  wire        resetn,
    output wire [3:0]  led,
    input  wire [3:0]  sw,
    input  wire        rx,
    output wire        tx
);

// ---------------------------------------------------------------------------
// Bus PicoRV32
// ---------------------------------------------------------------------------
wire [31:0] mem_addr, mem_wdata, mem_rdata;
wire  [3:0] mem_wstrb;
wire        mem_valid, mem_ready;

picorv32 #(
    .ENABLE_MUL      (1),
    .ENABLE_DIV      (1),
    .ENABLE_IRQ      (0),
    .ENABLE_COUNTERS (1),
    .PROGADDR_RESET  (32'h0000_0000),
    .STACKADDR       (MEM_WORDS * 4)    // stack al final de la BRAM
) cpu (
    .clk       (clk),
    .resetn    (resetn),
    .mem_valid (mem_valid),
    .mem_ready (mem_ready),
    .mem_addr  (mem_addr),
    .mem_wdata (mem_wdata),
    .mem_rdata (mem_rdata),
    .mem_wstrb (mem_wstrb)
);

// ---------------------------------------------------------------------------
// Decodificación de dirección
// ---------------------------------------------------------------------------
wire sel_bram = mem_valid && (mem_addr[31:14] == 18'h0);      // 0x000000..0x003FFF
wire sel_gpio = mem_valid && (mem_addr[31:8]  == 24'h002000); // 0x00200000
wire sel_uart = mem_valid && (mem_addr[31:20] == 12'h003);    // 0x300000..0x3FFFFF

// ---------------------------------------------------------------------------
// BRAM de instrucciones/datos
// ---------------------------------------------------------------------------
localparam ADDR_W = $clog2(MEM_WORDS);  // 12

wire [31:0] bram_rdata;

bram_sp #(
    .DATA_W   (32),
    .ADDR_W   (ADDR_W),
`ifdef SIM
    .INIT_FILE("fw/boot_sim.hex")
`else
    .INIT_FILE("fw/boot.hex")
`endif
) u_bram (
    .clk  (clk),
    .ena  (sel_bram),
    .wea  (mem_wstrb),
    .addr (mem_addr[ADDR_W+1:2]),
    .din  (mem_wdata),
    .dout (bram_rdata)
);

// ---------------------------------------------------------------------------
// GPIO — salida a LEDs (offset 0x0) y entrada de switches (offset 0x4)
// ---------------------------------------------------------------------------
wire gpio_is_sw = mem_addr[2];   // 0x200000=LEDs(W) / 0x200004=SW(R)

reg [3:0] gpio_reg;

always @(posedge clk) begin
    if (!resetn)
        gpio_reg <= 4'b0000;
    else if (sel_gpio && !gpio_is_sw && |mem_wstrb)
        gpio_reg <= mem_wdata[3:0];
end

assign led = gpio_reg;

// ---------------------------------------------------------------------------
// UART — periférico dado (el driver en C es lo que se completa en este lab)
// ---------------------------------------------------------------------------
wire [31:0] uart_rdata;
wire        uart_ready;

uart_regs #(
    .CLK_HZ (CLK_HZ),
    .BAUD   (BAUD)
) u_uart (
    .clk     (clk),
    .resetn  (resetn),
    .sel     (sel_uart),
    .reg_sel (mem_addr[2]),
    .wstrb   (mem_wstrb),
    .wdata   (mem_wdata),
    .rdata   (uart_rdata),
    .ready   (uart_ready),
    .rx      (rx),
    .tx      (tx)
);

// ---------------------------------------------------------------------------
// Multiplexor de datos de lectura y ready
// ---------------------------------------------------------------------------
assign mem_rdata = sel_bram ? bram_rdata :
                    sel_uart ? uart_rdata :
                    sel_gpio ? (gpio_is_sw ? {28'b0, sw} : {28'b0, gpio_reg}) :
                    32'h0;

// BRAM tiene 1 ciclo de latencia (output registrado): delay ready por 1 ciclo
// Patrón picosoc: pulso de 1 ciclo, no nivel continuo
reg bram_ready_r;
always @(posedge clk)
    bram_ready_r <= sel_bram && !mem_ready;

assign mem_ready = bram_ready_r || sel_gpio || uart_ready;

endmodule
