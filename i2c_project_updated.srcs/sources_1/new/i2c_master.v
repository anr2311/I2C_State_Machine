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

//////////////////////////////////////////////////////////////////////////////////
// Logic as from Youtube video

module i2c_master(
    input wire clk,             // 50 MHz clock
    input wire reset,           // Reset signal
    output reg i2c_scl,         // I2C Clock line
    output reg i2c_sda,         // I2C Data line
);

// goal is to write a command to a device address 0x78

    localparam STATE_IDLE = 0;
    localparam STATE_START = 1;
    localparam STATE_ADDR = 2;
    localparam STATE_RW = 3;
    localparam STATE_WACK = 4;
    localparam STATE_WACK2 = 7;
    localparam STATE_DATA = 5;
    localparam STATE_STOP = 6;

    reg [7:0] state;
    reg [6:0] addr;
    reg [7:0] count;
    reg [7:0] data;

    always @(posedge clk) begin
        if (reset == 1) begin
            state <= 0;
            i2c_sda <= 1;
            i2c_scl <= 1;
            addr <= 7'h78;
            count <= 8'd0;
            data <= 8'haa;
        end
        else begin
            case(state)
                STATE_IDLE : begin // idle
                    i2c_sda <= 1;
                    state <= STATE_START;
                end

                STATE_START : begin // start
                    i2c_sda <= 1;
                    state <= STATE_ADDR;
                    count <= 6;
                end

                STATE_ADDR : begin // send address
                    i2c_sda <= addr[count];
                    if (count == 0) state <= STATE_RW;
                    else count <= count - 1;
                end

                STATE_RW : begin // read write data
                    i2c_sda <= 1; // 1 indicates a read
                    state <= STATE_WACK;
                end

                STATE_WACK : begin // acknowledgement
                    state <= STATE_DATA;
                    count <= 7;
                end

                STATE_DATA : begin // read data
                    i2c_sda <= data[count];
                    if (count == 0) state <= STATE_WACK2;
                    else couunt <= count - 1;
                end

                STATE_WACK2 : begin // 2nd acknowledgement
                    state <= STATE_STOP;
                end

                STATE_STOP : begin
                    i2c_sda <= 1;
                    state <= STATE_IDLE;
                end
            end
        end
    end

endmodule

//////////////////////////////////////////////////////////////////////////////////

