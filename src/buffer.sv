`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/01/2026 04:39:07 PM
// Design Name: 
// Module Name: buffer
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


module buffer #(
    parameter DATA_WIDTH=8
)(
    input logic clk,
    input logic rst_n,
    input logic valid_bit_in,
    input logic [DATA_WIDTH-1:0] data_in,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic valid_bit_out
);
    always_ff@(posedge clk)
    begin
        if(~rst_n)
        begin
            data_out<='0;
            valid_bit_out<=1'b0;
        end
        else
        begin
            data_out<=data_in;
            valid_bit_out<=valid_bit_in;
        end
    end
endmodule
