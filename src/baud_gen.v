module baud_gen #(
    parameter CLK_FREQ  = 50000000, // 50 MHz Clock
    parameter BAUD_RATE = 115200    // Target Baud Rate
)(
    input  wire clk,
    input  wire reset_n,
    output reg  baud_tick
);
    // Calculated Divider Ratio (~434 clock cycles)
    localparam BAUD_DIV = CLK_FREQ / BAUD_RATE;
    reg [$clog2(BAUD_DIV)-1:0] counter;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            counter   <= 0;
            baud_tick <= 1'b0;
        end else begin
            if (counter == BAUD_DIV - 1) begin
                counter   <= 0;
                baud_tick <= 1'b1;
            end else begin
                counter   <= counter + 1'b1;
                baud_tick <= 1'b0;
            end
        end
    end
endmodule
// End of baud_gen module
