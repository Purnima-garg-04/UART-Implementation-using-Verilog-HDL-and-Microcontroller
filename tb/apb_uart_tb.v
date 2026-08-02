`timescale 1ns / 1ps

module apb_uart_tb;

    parameter CLK_FREQ   = 50000000;  // 50 MHz
    parameter BAUD_RATE  = 115200;    // 115.2 kbps
    parameter CLK_PERIOD = 20;        // 20 ns clock cycle

    // APB Bus Signals
    reg        PCLK;
    reg        PRESETn;
    reg [31:0] PADDR;
    reg        PSEL;
    reg        PENABLE;
    reg        PWRITE;
    reg [31:0] PWDATA;
    wire[31:0] PRDATA;
    wire       PREADY;
    wire       PSLVERR;

    // Physical Loopback Wire
    wire loopback_wire;

    // DUT Instantiation
    apb_uart #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PADDR(PADDR),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .PSLVERR(PSLVERR),
        .rx_pin(loopback_wire),
        .tx_pin(loopback_wire)
    );

    // Clock Generation
    always #(CLK_PERIOD / 2) PCLK = ~PCLK;

    // Task: APB Write Transaction
    task apb_write(input [31:0] addr, input [31:0] data);
        begin
            @(posedge PCLK);
            PADDR   <= addr;
            PWDATA  <= data;
            PWRITE  <= 1'b1;
            PSEL    <= 1'b1;
            PENABLE <= 1'b0;

            @(posedge PCLK);
            PENABLE <= 1'b1;

            @(posedge PCLK);
            while (!PREADY) @(posedge PCLK);
            PSEL    <= 1'b0;
            PENABLE <= 1'b0;
        end
    endtask

    // Task: APB Read Transaction
    task apb_read(input [31:0] addr, output [31:0] data);
        begin
            @(posedge PCLK);
            PADDR   <= addr;
            PWRITE  <= 1'b0;
            PSEL    <= 1'b1;
            PENABLE <= 1'b0;

            @(posedge PCLK);
            PENABLE <= 1'b1;

            @(posedge PCLK);
            while (!PREADY) @(posedge PCLK);
            data    = PRDATA;
            PSEL    <= 1'b0;
            PENABLE <= 1'b0;
        end
    endtask

    reg [31:0] read_val;
    reg [7:0]  test_data = 8'hA5;

    initial begin
        // Reset and Signal Initialization
        PCLK    = 0;
        PRESETn = 0;
        PADDR   = 0;
        PSEL    = 0;
        PENABLE = 0;
        PWRITE  = 0;
        PWDATA  = 0;

        #100;
        PRESETn = 1;
        #100;

        $display("-------------------------------------------------------");
        $display("--- Starting APB UART Peripheral Verification Loop  ---");
        $display("-------------------------------------------------------");

        // Step 1: APB Write to TXDATA (0x00)
        $display("[%0t ns] APB Write: Transmitting Byte 0x%0h to TXDATA (0x00)", $time, test_data);
        apb_write(32'h00, {24'h0, test_data});

        // Step 2: Poll STATUS (0x08) until rx_done (Bit 1) is set
        $display("[%0t ns] Polling STATUS register (0x08) for RX completion...", $time);
        read_val = 0;
        while (read_val[1] == 1'b0) begin
            #5000; // Poll status every 5us
            apb_read(32'h08, read_val);
        end
        $display("[%0t ns] RX Complete detected! STATUS = 0x%0h", $time, read_val);

        // Step 3: APB Read from RXDATA (0x04)
        apb_read(32'h04, read_val);
        $display("[%0t ns] APB Read: Received Byte 0x%0h from RXDATA (0x04)", $time, read_val[7:0]);

        // Step 4: Verification Check
        if (read_val[7:0] == test_data) begin
            $display("-------------------------------------------------------");
            $display(">>> TEST PASSED: Data 0x%0h transmitted and received successfully via APB bus! <<<", read_val[7:0]);
            $display("-------------------------------------------------------");
        end else begin
            $display("-------------------------------------------------------");
            $display(">>> TEST FAILED: Sent 0x%0h, Received 0x%0h <<<", test_data, read_val[7:0]);
            $display("-------------------------------------------------------");
        end

        #1000;
        $finish;
    end

endmodule
// Added more test cases
