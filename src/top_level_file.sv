`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/02/2026 02:08:58 PM
// Design Name: 
// Module Name: top_level_file
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


module top_level_file #(
    parameter DATA_WIDTH=8,
    parameter OUTPUT_WIDTH=16,
    parameter N=3
    )(
    input logic clk,
    input logic rst_n,
    input logic start,
    input logic [DATA_WIDTH-1:0] a_stream,
    input logic valid_bit_a_stream_in,
    input logic [DATA_WIDTH-1:0] b_stream,
    input logic valid_bit_b_stream_in,
    output logic [OUTPUT_WIDTH-1:0] c_stream,
    output logic c_stream_valid,
    output logic done
  );
  
    logic [N-1:0][N-1:0][DATA_WIDTH-1:0] a;
    logic [N-1:0][N-1:0]valid_bit_a_in;
    logic [N-1:0][N-1:0][DATA_WIDTH-1:0] b;
    logic [N-1:0][N-1:0]valid_bit_b_in;
    logic [2*N-2:0][DATA_WIDTH-1:0]a_staggered_output;
    logic [2*N-2:0]valid_bit_a_staggered_output;
    logic [2*N-2:0][DATA_WIDTH-1:0]b_staggered_output;
    logic [2*N-2:0]valid_bit_b_staggered_output;
    logic [2*N-2:0][OUTPUT_WIDTH-1:0] s_out_staggered;
    logic [2*N-2:0] valid_bit_out_staggered;
    logic staggered_start_a;
    logic staggered_start_b;
    logic staggered_start;
    logic stream_output_start;
    logic [N-1:0][N-1:0][OUTPUT_WIDTH-1:0] c;
    logic [N-1:0][N-1:0]valid_bit_out;
    
    assign staggered_start=staggered_start_a & staggered_start_b;
    
    stream_input_loader #(
        .N(N),
        .DATA_WIDTH(DATA_WIDTH)
    ) a_input (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .a_stream(a_stream),
        .valid_in(valid_bit_a_stream_in),
        .a_buf(a),
        .valid_bit_a_buf(valid_bit_a_in),
        .staggered_start(staggered_start_a)
    );
    
        stream_input_loader #(
        .N(N),
        .DATA_WIDTH(DATA_WIDTH)
    ) b_input (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .a_stream(b_stream),
        .valid_in(valid_bit_b_stream_in),
        .a_buf(b),
        .valid_bit_a_buf(valid_bit_b_in),
        .staggered_start(staggered_start_b)
    );
    
    matrix_row_shifter #(
        .N(N),
        .DATA_WIDTH(DATA_WIDTH)
    ) row_shifter(
        .clk(clk),
        .rst_n(rst_n),
        .row_sel(1'b1),
        .valid_bits_in(valid_bit_a_in),
        .matrix(a),
        .out_data(a_staggered_output),
        .valid_bits_out(valid_bit_a_staggered_output),
        .staggered_start(staggered_start)
    );
    
    matrix_row_shifter #(
        .N(N),
        .DATA_WIDTH(DATA_WIDTH)
    ) col_shifter(
        .clk(clk),
        .rst_n(rst_n),
        .row_sel(1'b0),
        .valid_bits_in(valid_bit_b_in),
        .matrix(b),
        .out_data(b_staggered_output),
        .valid_bits_out(valid_bit_b_staggered_output),
        .staggered_start(staggered_start)
    );
    
    dense_mult #(
        .N(N),
        .DATA_WIDTH(DATA_WIDTH),
        .OUTPUT_WIDTH(OUTPUT_WIDTH)
    )   sys_array(
        .clk(clk),
        .rst_n(rst_n),
        .a_in_bus(a_staggered_output),
        .valid_bit_a_in(valid_bit_a_staggered_output),
        .b_in_bus(b_staggered_output),
        .valid_bit_b_in(valid_bit_b_staggered_output),
        .s_out_bus(s_out_staggered),
        .valid_bit_s_out(valid_bit_out_staggered)
    );
    
    output_shift_register #(
        .N(N),
        .OUTPUT_WIDTH(OUTPUT_WIDTH)
    )   output_shifter(
        .clk(clk),
        .rst_n(rst_n),
        .data_in(s_out_staggered),
        .valid_bit_in(valid_bit_out_staggered),
        .data_out(c),
        .valid_bit_out(valid_bit_out),
        .stream_output_start(stream_output_start)
    );
    
    stream_output_loader #(
        .N(N),
        .OUTPUT_WIDTH(OUTPUT_WIDTH)
    ) output_streamer (
        .clk(clk),
        .rst_n(rst_n),
        .stream_output_start(stream_output_start),
        .data_in(c),
        .data_in_valid(valid_bit_out),
        .c_stream(c_stream),
        .c_stream_valid(c_stream_valid),
        .done(done)
    );
endmodule
