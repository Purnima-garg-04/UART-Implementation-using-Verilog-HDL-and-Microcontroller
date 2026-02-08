`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.02.2026 12:31:59
// Design Name: 
// Module Name: uart_tx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_tx (
    input  wire clk,
    input  wire rst,
    input  wire baud_tick,
    input  wire tx_start,
    input  wire [7:0] tx_data,
    output reg  tx,
    output reg  tx_done
);

    reg [3:0] bit_count;
    reg [9:0] shift_reg;
    reg busy;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx        <= 1'b1;
            tx_done   <= 0;
            busy      <= 0;
            bit_count <= 0;
        end else begin
            tx_done <= 0;

            if (tx_start && !busy) begin
                // Frame: stop | data | start
                shift_reg <= {1'b1, tx_data, 1'b0};
                busy      <= 1;
                bit_count <= 0;
            end

            if (busy && baud_tick) begin
                tx        <= shift_reg[0];
                shift_reg <= shift_reg >> 1;
                bit_count <= bit_count + 1;

                if (bit_count == 9) begin
                    busy    <= 0;
                    tx_done <= 1;
                    tx      <= 1'b1;
                end
            end
        end
    end

endmodule

