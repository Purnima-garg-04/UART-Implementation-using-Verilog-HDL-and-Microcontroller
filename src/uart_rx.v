module uart_rx #(
    parameter CLK_FREQ  = 50000000,
    parameter BAUD_RATE = 115200
)(
    input  wire       clk,
    input  wire       reset_n,
    input  wire       rx_pin,
    output reg  [7:0] rx_data,
    output reg        rx_done
);
    localparam BAUD_DIV = CLK_FREQ / BAUD_RATE; // ~434
    localparam HALF_DIV = BAUD_DIV / 2;         // ~217

    localparam IDLE  = 2'b00,
               START = 2'b01,
               DATA  = 2'b10,
               STOP  = 2'b11;

    reg [1:0] state;
    reg [2:0] bit_index;
    reg [$clog2(BAUD_DIV)-1:0] clk_count;
    reg [7:0] rx_shift_reg;

    // 2-Stage Synchronizer to prevent metastability
    reg rx_sync_0, rx_sync_1;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            rx_sync_0 <= 1'b1;
            rx_sync_1 <= 1'b1;
        end else begin
            rx_sync_0 <= rx_pin;
            rx_sync_1 <= rx_sync_0;
        end
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state        <= IDLE;
            rx_data      <= 8'd0;
            rx_done      <= 1'b0;
            clk_count    <= 0;
            bit_index    <= 3'd0;
            rx_shift_reg <= 8'd0;
        end else begin
            case (state)
                IDLE: begin
                    rx_done   <= 1'b0;
                    clk_count <= 0;
                    bit_index <= 3'd0;
                    if (rx_sync_1 == 1'b0) begin // Start bit edge
                        state <= START;
                    end
                end

                START: begin
                    if (clk_count == HALF_DIV - 1) begin
                        if (rx_sync_1 == 1'b0) begin // Midpoint check
                            clk_count <= 0;
                            state     <= DATA;
                        end else begin
                            state     <= IDLE; // False start
                        end
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                DATA: begin
                    if (clk_count == BAUD_DIV - 1) begin
                        clk_count <= 0;
                        rx_shift_reg[bit_index] <= rx_sync_1; // Sample center
                        if (bit_index == 3'd7) begin
                            state <= STOP;
                        end else begin
                            bit_index <= bit_index + 1'b1;
                        end
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                STOP: begin
                    if (clk_count == BAUD_DIV - 1) begin
                        clk_count <= 0;
                        rx_data   <= rx_shift_reg;
                        rx_done   <= 1'b1;
                        state     <= IDLE;
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule
// Enhanced RX sampling logic
