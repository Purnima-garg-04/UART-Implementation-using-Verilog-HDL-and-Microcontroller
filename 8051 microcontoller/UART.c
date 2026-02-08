#include <reg51.h>

/* ---------- UART Initialization ---------- */
void UART_init(void)
{
    TMOD = 0x20;        // Timer1, Mode2
    TH1  = 0xFA;        // 4800 baud @ 11.0592 MHz
    SCON = 0x50;        // Mode1, REN enabled
    PCON &= 0x7F;       // SMOD = 0
    TR1  = 1;

    /* Flush receiver */
    RI = 0;
    TI = 0;
    SBUF = 0;
}

/* ---------- Transmit one character ---------- */
void tx_data(unsigned char ch)
{
    SBUF = ch;
    while (TI == 0);
    TI = 0;
}

/* ---------- Receive one character (SAFE) ---------- */
unsigned char rx_data(void)
{
    unsigned char ch;

    /* Wait for real data */
    while (RI == 0);

    ch = SBUF;
    RI = 0;

    return ch;
}

/* ---------- MAIN PROGRAM ---------- */
void main(void)
{
    unsigned char rx;

    UART_init();

    /* ---- DISCARD FIRST GARBAGE BYTE ---- */
    if (RI)
    {
        rx = SBUF;
        RI = 0;
    }

    while (1)
    {
        rx = rx_data();   // Receive only real data
        tx_data(rx);     // Echo back
    }
}
