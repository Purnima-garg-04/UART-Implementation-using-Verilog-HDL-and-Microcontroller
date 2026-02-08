# UART Implementation Using Verilog HDL

This folder contains the Verilog HDL implementation of a UART
(Universal Asynchronous Receiver Transmitter) designed at the
Register Transfer Level (RTL).

The design includes separate modules for baud rate generation,
data transmission, and data reception, and is verified using
a dedicated testbench.

---

## Modules Included

- `baud_gen.v` – Baud rate generator
- `uart_tx.v`  – UART transmitter
- `uart_rx.v`  – UART receiver
- `uart_top.v` – Top-level module
- `uart_tb.v`  – Testbench for simulation

---

## UART Configuration

- Frame format: 8-N-1
- Baud rate: 9600 bps
- Parity: None
- Stop bits: 1
- Verification: Simulation using testbench

---

## How to Simulate

1. Open Vivado
2. Add all Verilog files
3. Set `uart_tb` as simulation top module
4. Run behavioral simulation
5. Observe UART waveform for TX and RX

---

## Result

The UART transmitter and receiver were successfully verified
through simulation. The received data matches the transmitted
data after one complete UART frame duration.

