# UART-Implementation-using-Verilog-HDL-and-Microcontroller
This repository presents a complete implementation of **UART (Universal Asynchronous Receiver Transmitter)** using both:
- **Verilog HDL** (RTL-level design and simulation)
- **8051 Microcontroller** (Embedded C programming)

The goal of this project is to understand UART communication from **both hardware and software perspectives**, providing a strong foundation in serial communication used in embedded systems and digital design.


## What is UART?
UART (Universal Asynchronous Receiver Transmitter) is a widely used serial communication protocol that enables data transfer between devices without a shared clock.

### Key characteristics:
- Asynchronous communication
- Full-duplex transmission
- Uses only two data lines:
  - TX (Transmit)
  - RX (Receive)


## UART Frame Format (8-N-1)

Each UART data frame consists of:

- **1 Start Bit** (logic 0)
- **8 Data Bits** (LSB first)
- **No Parity Bit**
- **1 Stop Bit** (logic 1)

Total bits per frame = **10 bits**

## Project Implementations

This project is divided into two main parts:

## 🔹 Part 1: UART Using Verilog HDL

### Description
In this part, UART is designed at the **Register Transfer Level (RTL)** using Verilog HDL.  
Separate modules are implemented for baud rate generation, transmission, and reception.  
The design is verified through simulation using a testbench.

### Features
- Custom baud rate generator
- UART Transmitter (TX)
- UART Receiver (RX)
- Start bit detection and stop bit handling
- Loopback-based verification
- Fully simulated and waveform verified

### Tools Used
- Verilog HDL
- Vivado (Simulation)
- RTL Design Methodology

### Verification
- UART waveform observed in simulation
- Correct reception of transmitted data (example: `0x55`)
- Receiver output updates only after full frame reception
- Timing verified according to selected baud rate



## 🔹 Part 2: UART Using 8051 Microcontroller

### Description
In this part, UART is implemented using the **built-in serial port of the 8051 microcontroller**.  
The UART is configured using special function registers, and data transmission and reception are performed using embedded C.

### UART Configuration
- UART Mode: Mode 1 (8-bit UART)
- Baud Rate: 4800 bps
- Crystal Frequency: 11.0592 MHz
- Parity: None
- Stop Bits: 1
- Communication Method: Polling

Timer 1 is configured in Mode 2 (8-bit auto-reload) to generate the baud rate.
The SMOD bit is cleared to ensure standard baud rate operation.

### Registers Used
| Register | Description |
|--------|-------------|
| TMOD | Configures Timer 1 in Mode 2 |
| TH1 | Sets baud rate to 4800 bps |
| SCON | Selects UART Mode 1 and enables receiver |
| PCON | Ensures SMOD = 0 |
| SBUF | Serial data buffer |
| TI | Indicates transmit completion |
| RI | Indicates data reception |

### Tools Used
- Embedded C
- EdSim51 / Keil (Simulation)

### Result
UART communication using the 8051 microcontroller was successfully implemented
at 4800 baud rate. Characters received through the serial interface were
correctly echoed back, confirming proper UART initialization, reception, and
transmission. Startup garbage data was safely handled.
