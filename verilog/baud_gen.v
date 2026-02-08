`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.02.2026 12:31:14
// Design Name: 
// Module Name: baud_gen
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


module baud_gen #
(
    parameter CLK_FREQ = 50_000_000,
    parameter BAUD_RATE = 9600
)
(
    input  wire clk,
    input  wire rst,
    output reg  baud_tick
);

    localparam integer BAUD_COUNT = CLK_FREQ / BAUD_RATE;
    integer count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count     <= 0;
            baud_tick <= 0;
        end else begin
            if (count == BAUD_COUNT - 1) begin
                count     <= 0;
                baud_tick <= 1;
            end else begin
                count     <= count + 1;
                baud_tick <= 0;
            end
        end
    end

endmodule
