`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Er. Arpit Paul
// 
// Create Date: 11.05.2024 15:26:22
// Design Name: 
// Module Name: cnt_16
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


module cnt_16(                   ////////16 bit counter RTL
input wr,clk, rst, up,
input [15:0] loadin,
output reg [15:0] dout
    );
    
    
    always@(posedge clk)
    begin
    if(rst==1'b1)
    dout <= 16'd0;
    
    else if(wr==1'b1)
    dout <= loadin;
    
    else
    begin
    if(up==1'b1)
    dout <= dout +1;
    
    else
    dout <= dout-1;
    end
    end
endmodule
