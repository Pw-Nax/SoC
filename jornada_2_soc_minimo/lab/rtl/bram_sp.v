// =============================================================================
// bram_sp.v — BRAM Single-Port genérica, inferencia automática por Vivado
//
// Objetivo: escribir RTL que Vivado reconozca como BRAM (RAMB36E1) en lugar
// de implementarlo con LUTs o FFs distribuidos.
//
// La clave es el patrón de lectura SINCRÓNICA: si dout se registra en el
// mismo clk que lee mem[addr], Vivado infiere BRAM en modo "read-first".
//
// Tareas a completar:
//   TODO 1 — Array de memoria con atributo ram_style
//   TODO 2 — Inicialización opcional desde archivo .hex ($readmemh)
//   TODO 3 — Bloque always sincrónico read-first
//
// Verificación: make sim  →  make synth  →  revisar rpt_utilization.txt:
//   debe aparecer "Block RAM Tile : 1" o similar.
// =============================================================================

module bram_sp #(
    parameter DATA_W   = 32,
    parameter ADDR_W   = 10,
    parameter INIT_FILE = ""
)(
    input  wire              clk,
    input  wire              ena,   // chip enable (1 = acceso activo)
    input  wire              wea,   // write enable (1 = escribir)
    input  wire [ADDR_W-1:0] addr,
    input  wire [DATA_W-1:0] din,
    output reg  [DATA_W-1:0] dout
);

    // -------------------------------------------------------------------------
    // TODO 1: Declarar el array de memoria
    //
    // Forma:   reg [DATA_W-1:0] mem [0:(1<<ADDR_W)-1];
    //
    // Agregar ANTES de la declaración:
    //   (* ram_style = "block" *)
    // Esto le indica a Vivado que use BRAM física, no LUTs.
    // Sin este atributo, Vivado puede inferir LUTRAM si el array es pequeño.
    // -------------------------------------------------------------------------


    // -------------------------------------------------------------------------
    // TODO 2: Inicialización desde archivo hex (opcional)
    //
    // Usar un bloque generate/initial:
    //
    //   generate
    //     if (INIT_FILE != "") begin
    //       initial $readmemh(INIT_FILE, mem);
    //     end
    //   endgenerate
    //
    // $readmemh carga el archivo en tiempo de elaboración; el contenido queda
    // embebido en el bitstream de Vivado. Útil para pre-cargar firmware.
    // -------------------------------------------------------------------------


    // -------------------------------------------------------------------------
    // TODO 3: Bloque always sincrónico — modo READ-FIRST
    //
    // always @(posedge clk) begin
    //   if (ena) begin
    //     if (wea)
    //       mem[addr] <= din;       // escritura
    //     dout <= mem[addr];        // lectura SIEMPRE (incluso en escritura)
    //   end
    // end
    //
    // "Read-first": dout refleja el valor ANTERIOR al ciclo de escritura.
    // Este patrón es el que Vivado reconoce para inferir RAMB36E1.
    //
    // ATENCIÓN: dout es registrado → hay 1 ciclo de latencia entre presentar
    // addr y recibir el dato. El módulo que usa esta BRAM debe manejar
    // esa latencia en la señal mem_ready (ver mem_subsys.v TODO 5).
    // -------------------------------------------------------------------------


endmodule
