`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/01/2026 06:10:59 PM
// Design Name: 
// Module Name: dense_mult_tb
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


module dense_mult_tb(

    );
parameter N = 3;
    parameter DATA_WIDTH = 8;
    parameter OUTPUT_WIDTH = 16;

    logic clk;
    logic rst_n;
    logic [DATA_WIDTH-1:0] a_in_bus [0:N+1]; 
    logic valid_bit_a_in [0:N+1];
    logic [DATA_WIDTH-1:0] b_in_bus [0:N+1];
    logic valid_bit_b_in [0:N+1];
    
    logic [OUTPUT_WIDTH-1:0] s_out_bus [0:N+1];
    logic [0:N+1]valid_bit_s_out;

    // Instantiate the Unit Under Test (UUT)
    dense_mult #(N, DATA_WIDTH, OUTPUT_WIDTH) uut (
        .clk(clk),
        .rst_n(rst_n),
        .a_in_bus(a_in_bus),
        .valid_bit_a_in(valid_bit_a_in),
        .b_in_bus(b_in_bus),
        .valid_bit_b_in(valid_bit_b_in),
        .s_out_bus(s_out_bus),
        .valid_bit_s_out(valid_bit_s_out)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Task to clear inputs
    task clear_inputs();
        for (int i = 0; i <= N+1; i++) begin
            a_in_bus[i] = 0;
            valid_bit_a_in[i] = 0;
            b_in_bus[i] = 0;
            valid_bit_b_in[i] = 0;
        end
    endtask

    initial begin
        // Initialize
        rst_n = 0;
        clear_inputs();
        
        // Reset sequence
        #20 rst_n = 1;
        @(posedge clk);

        // --- Staggered Data Injection ---
        // T1: a11, b11
        a_in_bus[0] = 1; valid_bit_a_in[0] = 1;
        a_in_bus[1] = 2; valid_bit_a_in[1] = 1;
        a_in_bus[2] = 3; valid_bit_a_in[2] = 1;
        a_in_bus[3] = 0; valid_bit_a_in[3] = 1;
        a_in_bus[4] = 0; valid_bit_a_in[4] = 1;
        b_in_bus[0] = 9; valid_bit_b_in[0] = 1;
        b_in_bus[1] = 6; valid_bit_b_in[1] = 1;
        b_in_bus[2] = 3; valid_bit_b_in[2] = 1;
        b_in_bus[3] = 0; valid_bit_b_in[3] = 1;
        b_in_bus[4] = 0; valid_bit_b_in[4] = 1;
        @(posedge clk);

        // T2: a21, a12 | b12, b21
        a_in_bus[0] = 0; valid_bit_a_in[0] = 1;
        a_in_bus[1] = 4; valid_bit_a_in[1] = 1;
        a_in_bus[2] = 5; valid_bit_a_in[2] = 1;
        a_in_bus[3] = 6; valid_bit_a_in[3] = 1;
        a_in_bus[4] = 0; valid_bit_a_in[4] = 1;
        b_in_bus[0] = 0; valid_bit_b_in[0] = 1;
        b_in_bus[1] = 8; valid_bit_b_in[1] = 1;
        b_in_bus[2] = 5; valid_bit_b_in[2] = 1;
        b_in_bus[3] = 2; valid_bit_b_in[3] = 1;
        b_in_bus[4] = 0; valid_bit_b_in[4] = 1;
        @(posedge clk);

        // T3: a31, a22, a13 | b13, b22, b31
        a_in_bus[0] = 0; valid_bit_a_in[0] = 1;
        a_in_bus[1] = 0; valid_bit_a_in[1] = 1;
        a_in_bus[2] = 7; valid_bit_a_in[2] = 1;
        a_in_bus[3] = 8; valid_bit_a_in[3] = 1;
        a_in_bus[4] = 9; valid_bit_a_in[4] = 1;
        b_in_bus[0] = 0; valid_bit_b_in[0] = 1;
        b_in_bus[1] = 0; valid_bit_b_in[1] = 1;
        b_in_bus[2] = 7; valid_bit_b_in[2] = 1;
        b_in_bus[3] = 4; valid_bit_b_in[3] = 1;
        b_in_bus[4] = 1; valid_bit_b_in[4] = 1;
        
        @(posedge clk);
        // End of data
        clear_inputs();
    
        // Wait for the systolic wave to reach the end
        repeat (10) @(posedge clk);
        
       // $display("Test Complete. Check waveforms for result emergence.");
        $finish;
    end

endmodule


