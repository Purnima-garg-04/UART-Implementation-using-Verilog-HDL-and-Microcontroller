`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.02.2026 12:33:29
// Design Name: 
// Module Name: uart_top
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


module uart_top (
    input  wire clk,
    input  wire rst,
    input  wire tx_start,
    input  wire [7:0] tx_data,
    output wire [7:0] rx_data,
    output wire tx_done,
    output wire rx_done
);

    wire baud_tick;
    wire tx_line;

    baud_gen bg (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick)
    );

    uart_tx tx (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx_line),
        .tx_done(tx_done)
    );

    uart_rx rx (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick),
        .rx(tx_line),      // loopback
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

endmodule

