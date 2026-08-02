module apb_uart #(
    parameter CLK_FREQ  = 50000000,
    parameter BAUD_RATE = 115200
)(
    // APB3 System Signals
    input  wire        PCLK,
    input  wire        PRESETn,
    input  wire [31:0] PADDR,
    input  wire        PSEL,
    input  wire        PENABLE,
    input  wire        PWRITE,
    input  wire [31:0] PWDATA,
    output reg  [31:0] PRDATA,
    output wire        PREADY,
    output wire        PSLVERR,

    // UART Physical Lines
    input  wire        rx_pin,
    output wire        tx_pin
);

    // Memory Offsets
    localparam ADDR_TXDATA = 8'h00;
    localparam ADDR_RXDATA = 8'h04;
    localparam ADDR_STATUS = 8'h08;

    // Registers and Wires
    reg [7:0] tx_reg;
    reg       tx_start;
    wire      tx_done;
    wire      rx_done;
    wire[7:0] rx_data;
    wire      baud_tick;

    // Zero-Wait-State APB Controls
    assign PREADY  = 1'b1;
    assign PSLVERR = 1'b0;

    // Sub-Module Instantiations
    baud_gen #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_baud_gen (
        .clk(PCLK),
        .reset_n(PRESETn),
        .baud_tick(baud_tick)
    );

    uart_tx u_uart_tx (
        .clk(PCLK),
        .reset_n(PRESETn),
        .baud_tick(baud_tick),
        .tx_start(tx_start),
        .tx_data(tx_reg),
        .tx_pin(tx_pin),
        .tx_done(tx_done)
    );

    uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_uart_rx (
        .clk(PCLK),
        .reset_n(PRESETn),
        .rx_pin(rx_pin),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    // APB Write Register Logic
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            tx_reg   <= 8'd0;
            tx_start <= 1'b0;
        end else begin
            tx_start <= 1'b0; // Self-clearing
            if (PSEL && PENABLE && PWRITE) begin
                case (PADDR[7:0])
                    ADDR_TXDATA: begin
                        tx_reg   <= PWDATA[7:0];
                        tx_start <= 1'b1; // Trigger TX on write
                    end
                    default: ;
                endcase
            end
        end
    end

    // APB Read Register Logic
    always @(*) begin
        PRDATA = 32'd0;
        if (PSEL && !PWRITE) begin
            case (PADDR[7:0])
                ADDR_TXDATA: PRDATA = {24'd0, tx_reg};
                ADDR_RXDATA: PRDATA = {24'd0, rx_data};
                ADDR_STATUS: PRDATA = {30'd0, rx_done, tx_done};
                default:     PRDATA = 32'd0;
            endcase
        end
    end

endmodule
// Verified APB memory map offsets

// Refactored PREADY/PSLVERR logic
