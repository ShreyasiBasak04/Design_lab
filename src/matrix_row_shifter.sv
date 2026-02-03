`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.02.2026 16:13:26
// Design Name: 
// Module Name: matrix_row_shifter
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


module matrix_row_shifter #(
    parameter N = 3,
    parameter DATA_WIDTH = 8
)(
    input logic clk,
    input logic rst_n,
    input logic row_sel,
    input logic  valid_bits_in [0:N-1][0:N-1],
    input logic [DATA_WIDTH-1:0] matrix [0:N-1][0:N-1],  // 3x3 input matrix
    output logic [DATA_WIDTH-1:0] out_data  [0:4],         // 5-element output
    output logic valid_bits_out [0:4]
);

    // Internal state machine and registers
    logic [$clog2(N):0] state;        // 0=idle, 1-3=rows
    logic [DATA_WIDTH-1:0] shift_reg [0:4];  // 5 positions
    logic valid_shift_reg [0:4];
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (row_sel && !rst_n) begin
            state <= 0;
            valid_shift_reg <= '{5{1'b0}};
        end
        if (row_sel && rst_n) begin
            case (state)
                0: begin  // Load first row + zeros
                    shift_reg[0] <= matrix[0][0];  // 1
                    shift_reg[1] <= matrix[0][1];  // 2  
                    shift_reg[2] <= matrix[0][2];  // 3
                    shift_reg[3] <= 0;
                    shift_reg[4] <= 0;
                    valid_shift_reg[0] <= valid_bits_in[0][0];  // 1
                    valid_shift_reg[1] <= valid_bits_in[0][1];  // 2  
                    valid_shift_reg[2] <= valid_bits_in[0][2];  // 3
                    valid_shift_reg[3] <= 1;
                    valid_shift_reg[4] <= 1;
                    state <= 1;
                end
                1: begin  // Shift LEFT, load row1 at RIGHT
                    shift_reg[0] <= 0;           // New zero
                    shift_reg[1] <= matrix[1][0]; // 1→pos1
                    shift_reg[2] <= matrix[1][1]; // 2→pos2  
                    shift_reg[3] <= matrix[1][2]; // 4→pos3
                    shift_reg[4] <= 0; // 5→pos4
                    valid_shift_reg[0] <= 1;           // New zero
                    valid_shift_reg[1] <= valid_bits_in[1][0]; // 1→pos1
                    valid_shift_reg[2] <= valid_bits_in[1][1]; // 2→pos2  
                    valid_shift_reg[3] <= valid_bits_in[1][2]; // 4→pos3
                    valid_shift_reg[4] <= 1; // 5
                    state <= 2;
                end
                2: begin  // Continue shift pattern
                    shift_reg[0] <= 0;
                    shift_reg[1] <= 0; 
                    shift_reg[2] <= matrix[2][0]; 
                    shift_reg[3] <= matrix[2][1]; // 7→pos3
                    shift_reg[4] <= matrix[2][2]; // 8→pos4
                    valid_shift_reg[0] <= 1;
                    valid_shift_reg[1] <= 1; 
                    valid_shift_reg[2] <= valid_bits_in[2][0]; 
                    valid_shift_reg[3] <= valid_bits_in[2][1]; // 7→pos3
                    valid_shift_reg[4] <= valid_bits_in[2][2]; // 8→pos4
                    state <= 0;
                end
            endcase
        end
    end
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n && !row_sel) begin
            state <= 0;
            valid_shift_reg <= '{5{1'b0}};
        end
        if (rst_n && !row_sel) begin
            case (state)
                0: begin  // Load first row + zeros
                    shift_reg[0] <= matrix[0][0];  // 1
                    shift_reg[1] <= matrix[1][0];  // 2  
                    shift_reg[2] <= matrix[2][0];  // 3
                    shift_reg[3] <= '0;
                    shift_reg[4] <= '0;
                    valid_shift_reg[0] <= valid_bits_in[0][0];  // 1
                    valid_shift_reg[1] <= valid_bits_in[1][0];  // 2  
                    valid_shift_reg[2] <= valid_bits_in[2][0];  // 3
                    valid_shift_reg[3] <= 1;
                    valid_shift_reg[4] <= 1;
                    state <= 1;
                end
                1: begin  // Shift LEFT, load row1 at RIGHT
                    shift_reg[0] <= 0;           // New zero
                    shift_reg[1] <= matrix[0][1]; // 1→pos1
                    shift_reg[2] <= matrix[1][1]; // 2→pos2  
                    shift_reg[3] <= matrix[2][1]; // 4→pos3
                    shift_reg[4] <= 0; // 5→pos4
                    valid_shift_reg[0] <= 1;           // New zero
                    valid_shift_reg[1] <= valid_bits_in[0][1]; // 1→pos1
                    valid_shift_reg[2] <= valid_bits_in[1][1]; // 2→pos2  
                    valid_shift_reg[3] <= valid_bits_in[2][1]; // 4→pos3
                    valid_shift_reg[4] <= 1; // 5
                    state <= 2;
                end
                2: begin  // Continue shift pattern
                    shift_reg[0] <= '0;
                    shift_reg[1] <= '0; 
                    shift_reg[2] <= matrix[0][2]; 
                    shift_reg[3] <= matrix[1][2]; // 7→pos3
                    shift_reg[4] <= matrix[2][2]; // 8→pos4
                    valid_shift_reg[0] <= 1;
                    valid_shift_reg[1] <= 1; 
                    valid_shift_reg[2] <= valid_bits_in[0][2]; 
                    valid_shift_reg[3] <= valid_bits_in[1][2]; // 7→pos3
                    valid_shift_reg[4] <= valid_bits_in[2][2]; // 8→pos4
                    state <= 0;
                end
            endcase
        end
    end    

    
    assign out_data = shift_reg;  // Direct connection
    assign valid_bits_out = valid_shift_reg;
endmodule
