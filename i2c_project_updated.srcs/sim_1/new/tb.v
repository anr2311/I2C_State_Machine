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
 
module i2c_tb_new;
 
    // Inputs
    reg clk;
    reg reset;
    reg i2c_sda_tb;
 
    // Outputs
    wire i2c_scl;
    wire i2c_sda;
    wire [7:0] state;
 
    // Instantiate the UUT
    i2c_new uut (
        .clk(clk),
        .reset(reset),
        .i2c_sda_tb(i2c_sda_tb),
        .i2c_scl(i2c_scl),
        .i2c_sda(i2c_sda),
        .state(state)
    );
    
    localparam STATE_IDLE = 0;
    localparam STATE_START = 1;
    localparam STATE_ADDR = 2;
    localparam STATE_RW = 3;
    localparam STATE_WACK = 4;    
    localparam STATE_DATA = 5;
    localparam STATE_WACK2 = 6;
    localparam STATE_STOP = 7;
 
    reg [7:0] data; // Data to send
    reg [2:0] bit_index;
    reg [2:0] addr_bit_index;
    reg [6:0] incoming_address;
    
    reg address_check = 0;  
    reg send_again = 0; 
 
    initial begin
        clk = 0;
        forever begin
            #10 clk = ~clk; // 50 MHz clock
        end
    end
    
    always @(posedge i2c_scl) begin
        if ((state == STATE_ADDR) || (state == STATE_RW) || (state == STATE_WACK)) begin // STATE_ADDR
            incoming_address[addr_bit_index] <= i2c_sda;
            if ((addr_bit_index == 0) || (state == STATE_WACK)) begin
                addr_bit_index <= 6; // Reset address bit index after transmitting all bits
                if (incoming_address[6:0] == 7'b1111000)  address_check <= 1; 
            end               
            else
                addr_bit_index <= addr_bit_index - 1;
        end
        
        if ((state == STATE_WACK2) && (i2c_sda == 0)) begin // STATE_WACK2 failed
            send_again <= 1; // resend                        
        end
        
        if ((state == STATE_DATA) && (send_again == 1)) begin
            i2c_sda_tb = data[bit_index]; // Drive SDA bit by bit            
            if (bit_index == 0) begin
                bit_index = 7; // Reset bit index after transmitting all bits
                address_check <= 0;
                send_again <= 0;                
            end
            else
                bit_index = bit_index - 1;
        end
    end
    
    always @(posedge clk) begin       
        if ((state == STATE_WACK) && (uut.kilo_clk_posedge == 1) && (address_check == 1)) begin // STATE_ACK            
            i2c_sda_tb = 1; // Drive SDA bit to indicate ACK
        end
        
        if ((state == STATE_RW) && (uut.kilo_clk_posedge == 1) && (address_check == 0)) begin            
            i2c_sda_tb = 0; // Drive SDA bit to indicate NACK
        end
    
        if ((state == STATE_DATA) && (uut.kilo_clk_posedge == 1) && (address_check == 1)) begin // STATE_DATA
            i2c_sda_tb = data[bit_index]; // Drive SDA bit by bit            
            if (bit_index == 0) begin
                bit_index = 7; // Reset bit index after transmitting all bits
                address_check <= 0;
            end
            else
                bit_index = bit_index - 1;
        end
    end
 
    initial begin
        reset = 1;
        i2c_sda_tb = 1; // Default high (idle)
        data = 8'hAA;   // Initial data to send
        bit_index = 7;
        addr_bit_index <= 6;
 
        #2000;
        reset = 0;        
 
        #224000;
        $finish;
    end
 
endmodule