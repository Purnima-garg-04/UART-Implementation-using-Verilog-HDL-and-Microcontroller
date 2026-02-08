`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.02.2026 12:32:37
// Design Name: 
// Module Name: uart_rx
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


module uart_rx (
    input  wire clk,
    input  wire rst,
    input  wire baud_tick,
    input  wire rx,
    output reg  [7:0] rx_data,
    output reg  rx_done
);

    reg [3:0] bit_count;
    reg [7:0] shift_reg;
    reg busy;
    reg half_tick;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rx_done   <= 0;
            bit_count <= 0;
            busy      <= 0;
            half_tick <= 0;
        end else begin
            rx_done <= 0;

            /* Detect start bit */
            if (!busy && rx == 0) begin
                busy      <= 1;
                bit_count <= 0;
                half_tick <= 1;   // wait half bit
            end

            /* Wait half baud to align sampling */
            else if (busy && half_tick && baud_tick) begin
                half_tick <= 0;   // aligned to bit center
            end

            /* Sample data bits */
            else if (busy && !half_tick && baud_tick) begin
                bit_count <= bit_count + 1;

                if (bit_count < 8)
                    shift_reg <= {rx, shift_reg[7:1]};

                if (bit_count == 8) begin
                    rx_data <= shift_reg;
                    rx_done <= 1;
                    busy    <= 0;
                end
            end
        end
    end

endmodule


