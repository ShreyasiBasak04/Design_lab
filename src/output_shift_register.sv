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
    parameter N=3,
    parameter OUTPUT_WIDTH=16
)(
    input logic clk,
    input logic rst_n,
    input logic [2*N-2:0][OUTPUT_WIDTH-1:0] data_in,
    input logic [2*N-2:0] valid_bit_in,
    output logic [N-1:0][N-1:0][OUTPUT_WIDTH-1:0]data_out,
    output logic [N-1:0][N-1:0]valid_bit_out,
    output logic stream_output_start
  );
    logic [N-1:0][N-1:0][OUTPUT_WIDTH-1:0]data_out_reg;
    logic [N-1:0][N-1:0]valid_bit_out_reg;
    logic match_found;
    logic [2*N-2:0] mask;
    always_ff@(posedge clk)
    begin
        if(~rst_n)
        begin 
            data_out_reg<='{default:'0};
            valid_bit_out_reg<='{default:'0};
        end
        else
        begin
            match_found = 1'b0;
            for( int i= 0;i< N; ++i)
            begin
                // Create a temporary mask for the bits [i : 2*N-2-i]

                mask = '0;
                for (int m = 0; m < 2*N-1; m++) begin
                     if (m >= i && m <= (2*N-2-i)) 
                        mask[m] = 1'b1;
                end

                // Now check if all bits covered by the mask are high in the input
                if (!match_found && ((valid_bit_in & mask) == mask)) begin
                    match_found <= 1'b1;
                    if(i==0)
                       stream_output_start<=1'b1;
                    else
                        stream_output_start<=1'b0;
                    for(int j=0;j<N-i;j++)
                    begin
                        data_out_reg[i][N-1-j]<=data_in[i+j];
                        valid_bit_out_reg[i][N-1-j]<=valid_bit_in[i+j];
                    end
                    for (int k = 1; k < (N - i); k++) 
                    begin
                        data_out_reg[i+k][i] <= data_in[N-1+k];
                        valid_bit_out_reg[i+k][i] <= valid_bit_in[N-1+k];
                    end 
                end
            end
        end
    end
    assign data_out=data_out_reg;
    assign valid_bit_out=valid_bit_out_reg;
endmodule
