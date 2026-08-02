module uart_tx (
    input  wire       clk,
    input  wire       reset_n,
    input  wire       baud_tick,
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output reg        tx_pin,
    output reg        tx_done
);
    localparam IDLE  = 2'b00,
               START = 2'b01,
               DATA  = 2'b10,
               STOP  = 2'b11;

    reg [1:0] state;
    reg [2:0] bit_index;
    reg [7:0] tx_shift_reg;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state        <= IDLE;
            tx_pin       <= 1'b1;
            tx_done      <= 1'b1;
            bit_index    <= 3'd0;
            tx_shift_reg <= 8'd0;
        end else begin
            case (state)
                IDLE: begin
                    tx_pin  <= 1'b1;
                    tx_done <= 1'b1;
                    if (tx_start) begin
                        tx_shift_reg <= tx_data;
                        tx_done      <= 1'b0;
                        state        <= START;
                    end
                end

                START: begin
                    tx_done <= 1'b0;
                    if (baud_tick) begin
                        tx_pin    <= 1'b0; // Start Bit (0)
                        bit_index <= 3'd0;
                        state     <= DATA;
                    end
                end

                DATA: begin
                    tx_done <= 1'b0;
                    if (baud_tick) begin
                        tx_pin <= tx_shift_reg[bit_index]; // LSB First
                        if (bit_index == 3'd7) begin
                            state <= STOP;
                        end else begin
                            bit_index <= bit_index + 1'b1;
                        end
                    end
                end

                STOP: begin
                    tx_done <= 1'b0;
                    if (baud_tick) begin
                        tx_pin  <= 1'b1; // Stop Bit (1)
                        tx_done <= 1'b1;
                        state   <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule
// Added TX FSM state descriptions
