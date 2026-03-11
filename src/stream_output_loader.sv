`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/11/2026 06:50:05 PM
// Design Name: 
// Module Name: stream_output_loader
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


module stream_output_loader#(
    parameter OUTPUT_WIDTH=16,
    parameter N=3
)(
    input logic clk,
    input logic rst_n,
    input logic stream_output_start,
    input logic [N-1:0][N-1:0][OUTPUT_WIDTH-1:0]data_in,
    input logic [N-1:0][N-1:0]data_in_valid,
    output logic [OUTPUT_WIDTH-1:0] c_stream,
    output logic c_stream_valid,
    output logic done

);
    
    logic [$clog2(N)-1:0] row;
    logic [$clog2(N)-1:0] col;
    
    always_ff@(posedge clk)
    begin
        if(!rst_n)
        begin
            row  <= 0;
            col  <= 0;
            done <= 1'b0;
        end
        else
        begin
            if(stream_output_start)
            begin
                row  <= 0;
                col  <= 0;
                done <= 1'b0;
            end
            else if(c_stream_valid)
            begin
                if(row==N-1 && col==N-1)
                begin 
                   done<=1;
                end
                else
                    if (col == N-1) begin
                        col <= 0;
                        row <= row + 1;
                    end
                    else begin
                        col <= col + 1;
                    end
            end
        end
    end
    
    always_comb
    begin
        c_stream=data_in[row][col];
        c_stream_valid=data_in_valid[row][col];
    end
endmodule
