`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/02/2026 11:10:12 AM
// Design Name: 
// Module Name: output_shift_register
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


module output_shift_register #(
    parameter OUTPUT_WIDTH=16

    )(
    input logic clk,
    input logic rst_n,
    input logic [OUTPUT_WIDTH-1:0] data_in[0:4],
    input logic [0:4] valid_bit_in,
    output logic [OUTPUT_WIDTH-1:0]data_out[0:2][0:2],
    output logic valid_bit_out
    );
    logic [OUTPUT_WIDTH-1:0]data_out_reg[0:2][0:2];
    logic valid_bit_out_reg;
    always_ff@(posedge clk)
    begin
        if(~rst_n)
        begin 
            data_out_reg<='{default:'0};
            valid_bit_out_reg<=1'b0;
        end
        else
        begin
            if(&valid_bit_in)
            begin 
                data_out_reg[0][2]<=data_in[0];
                data_out_reg[0][1]<=data_in[1];
                data_out_reg[0][0]<=data_in[2];
                data_out_reg[1][0]<=data_in[3];
                data_out_reg[2][0]<=data_in[4];
            end
            else if(&valid_bit_in[1:3])
            begin
                data_out_reg[1][2]<=data_in[1];
                data_out_reg[1][1]<=data_in[2];
                data_out_reg[2][1]<=data_in[3];
            end 
            else if(valid_bit_in[2])
            begin
                data_out_reg[2][2]<=data_in[2];
                valid_bit_out_reg<=1'b1;
            end
            else
            begin
                data_out_reg<=data_out_reg;
                valid_bit_out_reg<=1'b0;
            end
        end
    end
    assign data_out=data_out_reg;
    assign valid_bit_out=valid_bit_out_reg;
endmodule
