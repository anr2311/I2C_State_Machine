`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.11.2024 22:14:08
// Design Name: 
// Module Name: tb_i2c_master
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

module i2c_master_tb;

    // inputs
    reg clk;
    reg reset;

    // outputs
    wire i2c_scl;
    wire i2c_sda;

    // instantiating the UUT
    i2c_master uut(
        .clk(clk),
        .reset(reset),
        .i2c_scl(i2c_scl),
        .i2c_sda(i2c_sda)
    );

    initial begin
        clk = 0;
        forever begin
            #1 clk = ~clk;
        end
    end

    initial begin
        reset = 1;

        #10;

        reset = 0;

        #100;
        $finish;
    end

endmodule

//////////////////////////////////////////////////////////////////////////////////