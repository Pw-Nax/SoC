// =============================================================================
// tb_soc_minimal.v — Testbench para soc_minimal (PicoRV32 + BRAM + GPIO + UART)
//
// Verifica que el SoC arranca, el firmware escribe al GPIO múltiples veces,
// y que el banner de arranque llega por UART.
//
// Uso: make sim   (compila boot_sim.hex con -DSIM automáticamente)
// =============================================================================
`timescale 1ns/1ps

module tb_soc_minimal;

    localparam CLK_HZ   = 100_000_000;
    localparam SIM_BAUD = 1_000_000;        // más rápido que 115200 para simular
    localparam BIT_CYC  = CLK_HZ / SIM_BAUD;

    reg clk    = 0;
    reg resetn = 0;

    wire [3:0] led;
    wire       tx;

    always #5 clk = ~clk;  // 100 MHz

    soc_minimal #(
        .CLK_HZ (CLK_HZ),
        .BAUD   (SIM_BAUD)
    ) dut (
        .clk    (clk),
        .resetn (resetn),
        .led    (led),
        .sw     (4'd8),     // nivel 8 -> periodo 1021, fijo para la simulación
        .rx     (1'b1),     // idle alto, no se usa en este lab
        .tx     (tx)
    );

    // -------------------------------------------------------------------------
    // Observar el bus PicoRV32
    // -------------------------------------------------------------------------
    wire        mem_valid = dut.mem_valid;
    wire        mem_ready = dut.mem_ready;
    wire [31:0] mem_addr  = dut.mem_addr;
    wire [31:0] mem_wdata = dut.mem_wdata;
    wire  [3:0] mem_wstrb = dut.mem_wstrb;

    integer errors     = 0;
    integer gpio_writes = 0;
    integer cycle      = 0;

    always @(posedge clk) cycle = cycle + 1;

    // Detectar escrituras al GPIO
    always @(posedge clk) begin
        if (mem_valid && mem_ready && |mem_wstrb &&
            mem_addr[31:8] == 24'h002000) begin
            gpio_writes = gpio_writes + 1;
            $display("  [GPIO wr] ciclo=%0d  wdata=0x%08X  led=%b",
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
        $dumpfile("tb_soc_minimal.vcd");
        $dumpvars(1, tb_soc_minimal);   // solo señales top-level

        // Reset activo 10 ciclos
        resetn = 0;
        repeat(10) @(posedge clk);
        resetn = 1;
        $display("\n=== SoC arrancado (resetn=1), esperando GPIO y UART ===");

        // Con -DSIM (delay=100 ciclos) y UART a SIM_BAUD, el banner + varias
        // escrituras entran cómodos en este presupuesto de ciclos
        repeat(150000) @(posedge clk);

        if (gpio_writes == 0) begin
            $display("\n[FALLA] El CPU no escribio al GPIO");
            $display("        Verificar boot.hex (compilar con: make sim)");
            errors = errors + 1;
        end else begin
            $display("\n[OK]    %0d escritura(s) al GPIO — firmware ejecutando", gpio_writes);
        end

        if (uart_chars == 0) begin
            $display("[FALLA] No se recibio nada por UART");
            errors = errors + 1;
        end else begin
            $display("[OK]    %0d caracter(es) por UART", uart_chars);
        end

        if (errors == 0)
            $display("\n[OK] soc_minimal operativo\n");
        else
            $display("\n[FALLA] %0d error(es)\n", errors);

        $finish;
    end

endmodule
