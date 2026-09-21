// =============================================================================
// tb_soc.v — Testbench para soc_minimal (PicoRV32 + BRAM + GPIO + UART)
// Jornada 3 — El firmware completo
//
// Verifica que el SoC arranca, el firmware escribe al GPIO múltiples veces,
// y que el mensaje de arranque llega por UART.
// Compilar con -DSIM para que el firmware use DELAY_CYCLES=100.
//
// Uso: make sim
// =============================================================================
`timescale 1ns/1ps

module tb_soc;

    localparam CLK_HZ   = 100_000_000;
    localparam SIM_BAUD = 1_000_000;        // más rápido que 115200 para simular
    localparam BIT_CYC  = CLK_HZ / SIM_BAUD;

    reg clk    = 0;
    reg resetn = 0;

    wire [3:0] led;
    wire       tx;

    always #5 clk = ~clk;   // 100 MHz

    soc_top #(
        .CLK_HZ (CLK_HZ),
        .BAUD   (SIM_BAUD)   // más rápido que 115200 real para simular en segundos
    ) dut (
        .clk  (clk),
        .btn0 (~resetn),     // btn0 activo alto → resetn = ~btn0
        .led  (led),
        .sw   (4'd8),        // nivel 8 -> periodo 1021, fijo para la simulación
        .rx   (1'b1),        // idle alto, no se usa en este lab
        .tx   (tx)
    );

    // Observar el bus PicoRV32 (acceso directo a instancia interna)
    wire        mem_valid = dut.u_soc.mem_valid;
    wire        mem_ready = dut.u_soc.mem_ready;
    wire [31:0] mem_addr  = dut.u_soc.mem_addr;
    wire [31:0] mem_wdata = dut.u_soc.mem_wdata;
    wire  [3:0] mem_wstrb = dut.u_soc.mem_wstrb;

    integer gpio_writes = 0;
    integer cycle       = 0;

    always @(posedge clk) cycle = cycle + 1;

    // Detectar escrituras al GPIO (0x200000)
    always @(posedge clk) begin
        if (mem_valid && mem_ready && |mem_wstrb &&
            mem_addr[31:8] == 24'h002000) begin
            gpio_writes = gpio_writes + 1;
            $display("  [GPIO wr] ciclo=%4d  wdata=0x%08X  led=%b",
                     cycle, mem_wdata, led);
        end
    end

    // -------------------------------------------------------------------------
    // Decodificador serie: captura 1 byte del pin TX (8N1)
    // -------------------------------------------------------------------------
    task uart_capture_byte;
        output [7:0] data_out;
        integer i;
        begin
            @(negedge tx);
            repeat (BIT_CYC / 2) @(posedge clk);
            data_out = 8'h00;
            for (i = 0; i < 8; i = i + 1) begin
                repeat (BIT_CYC) @(posedge clk);
                data_out[i] = tx;
            end
            repeat (BIT_CYC) @(posedge clk);
        end
    endtask

    reg [7:0] rx_byte;
    integer   uart_chars = 0;

    initial begin
        @(posedge resetn);
        forever begin
            uart_capture_byte(rx_byte);
            $write("%c", rx_byte);
            uart_chars = uart_chars + 1;
        end
    end

    initial begin
        $dumpfile("tb_soc.vcd");
        $dumpvars(1, tb_soc);

        // Reset activo 10 ciclos
        resetn = 0;
        repeat(10) @(posedge clk);
        resetn = 1;
        $display("\n=== SoC arrancado, esperando escrituras al GPIO y UART ===\n");

        // -DSIM → DELAY_CYCLES=100; el banner de 2 líneas tarda ~115000
        // ciclos a SIM_BAUD, más varias escrituras de bloque después
        repeat(220000) @(posedge clk);

        if (gpio_writes == 0) begin
            $display("\n[FALLA] El CPU no escribio al GPIO.");
            $display("        Verificar: make hex-sim antes de make sim.");
        end else if (uart_chars == 0) begin
            $display("\n[FALLA] No se recibio nada por UART.");
            $display("        Verificar uart.h / uart_puts().");
        end else begin
            $display("\n\n[OK] %0d escritura(s) al GPIO, %0d caracter(es) por UART — SoC funcional\n",
                      gpio_writes, uart_chars);
        end

        $finish;
    end

endmodule
