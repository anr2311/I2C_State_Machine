`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.11.2024 22:02:55
// Design Name: 
// Module Name: i2c_master
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

module i2c_master_new(
    input wire clk,             // 50 MHz clock    
    input wire reset,           // Reset signal
    output wire i2c_scl,         // I2C Clock line
    output reg i2c_sda         // I2C Data line
);

// goal is to write a command to a device address 0x78 and read back data

    localparam STATE_IDLE = 0;
    localparam STATE_START = 1;
    localparam STATE_ADDR = 2;
    localparam STATE_RW = 3;
    localparam STATE_WACK = 4;    
    localparam STATE_DATA = 5;
    localparam STATE_WACK2 = 6;
    localparam STATE_STOP = 7;

    reg [7:0] state;
    reg [7:0] i2c_state;
    reg [6:0] addr;
    reg [7:0] count;
    reg [7:0] data;

    reg i2c_scl_en = 0;

    reg [30:0] clk_divider = 0; // Clock divider variable for 100 kHz generation
    reg kilo_clk;
    reg kilo_clk_posedge;
    reg kilo_clk_negedge;

    assign i2c_scl = (i2c_scl_en == 0) ? 1 : kilo_clk;

    // Clock divider to generate a 100 kHz frequency
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_divider <= 0;
            kilo_clk <= 0;
            kilo_clk_posedge <= 0;
            kilo_clk_negedge <= 0;
            state <= 0;
            i2c_sda <= 1;
            addr <= 7'h78;
            count <= 8'd0;
            data <= 8'haa;
        end 
        else begin
            if (clk_divider == 499) begin // converting 50MHz clock to 100kHz
                clk_divider <= 0;
                kilo_clk <= ~kilo_clk;
                if (kilo_clk == 1) begin
                    kilo_clk_posedge <= 1;
                    kilo_clk_negedge <= 0;
                end
                else begin
                    kilo_clk_posedge <= 0;
                    kilo_clk_negedge <= 1;
                end                                                                             
            end
            else begin
                clk_divider <= clk_divider + 1;                
            end

            if (kilo_clk_negedge == 1) begin
                kilo_clk_negedge <= 0;
                if (reset == 1) begin
                    i2c_scl_en <= 0;
                end
                else begin
                    if ((state == STATE_IDLE) || (state == STATE_START)) begin
                        i2c_scl_en <= 0;
                    end
                    else begin
                        i2c_scl_en <= 1;
                    end 
                end                
            end

            // perform I2C state machine here
            if ((kilo_clk_posedge == 1)) begin
                kilo_clk_posedge <= 0;
                case(state)
                    STATE_IDLE : begin // idle
                        i2c_sda <= 1;
                        state <= STATE_START;
                        i2c_state <= STATE_IDLE; // real state during the transaction
                    end

                    STATE_START : begin // start
                        i2c_sda <= 0;
                        state <= STATE_ADDR;
                        count <= 6;
                        i2c_state <= STATE_START; // real state during the transaction
                    end

                    STATE_ADDR : begin // send address
                        i2c_sda <= addr[count];
                        if (count == 0) state <= STATE_RW;
                        else count <= count - 1;
                        i2c_state <= STATE_ADDR; // real state during the transaction
                    end

                    STATE_RW : begin // read write data
                        i2c_sda <= 1; // 1 indicates a read
                        state <= STATE_WACK;
                        i2c_state <= STATE_RW; // real state during the transaction
                    end

                    STATE_WACK : begin // acknowledgement
                        state <= STATE_DATA;
                        count <= 7;
                        i2c_state <= STATE_WACK; // real state during the transaction
                    end

                    STATE_DATA : begin // read data
                        i2c_sda <= data[count];
                        if (count == 0) state <= STATE_WACK2;
                        else count <= count - 1;
                        i2c_state <= STATE_DATA; // real state during the transaction
                    end

                    STATE_WACK2 : begin // 2nd acknowledgement
                        i2c_sda <= 1;
                        state <= STATE_STOP;
                        i2c_state <= STATE_WACK2; // real state during the transaction
                    end

                    STATE_STOP : begin
                        i2c_sda <= 0;
                        state <= STATE_IDLE;
                        i2c_state <= STATE_STOP; // real state during the transaction
                    end
                endcase
            end
        end
    end

endmodule