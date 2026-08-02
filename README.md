# UART Implementation using Verilog HDL and Microcontroller

This repository contains the Verilog HDL implementation of a Universal Asynchronous Receiver-Transmitter (UART) with an Advanced Peripheral Bus (APB) interface.

## Project Structure
- `baud_gen.v`: Baud rate generator module.
- `uart_tx.v`: UART transmitter logic.
- `uart_rx.v`: UART receiver logic.
- `apb_uart.v`: APB wrapper mapping UART registers to the APB bus.
- `apb_uart_tb.v`: Testbench for verifying the APB UART module.

## Register Map
| Address Offset | Register | Description |
|----------------|----------|-------------|
| `0x00`         | TXDATA   | Write data to transmit |
| `0x04`         | RXDATA   | Read received data |
| `0x08`         | STATUS   | Bit 0: TX done, Bit 1: RX done |

## Features
- Parameterizable clock frequency and baud rate.
- Standard APB interface for easy integration with microcontrollers.
- Independent TX and RX modules.
