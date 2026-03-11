`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/02/2026 03:00:55 PM
// Design Name: 
// Module Name: top_level_tb
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


module top_level_tb(

    );
    localparam N=5;
    localparam DATA_WIDTH=8;
    localparam OUTPUT_WIDTH=16;
    
    
    logic clk;
    logic rst_n;
    logic start;
    logic [DATA_WIDTH-1:0] a_stream;
    logic valid_bit_a_stream_in;
    logic [DATA_WIDTH-1:0] b_stream;
    logic valid_bit_b_stream_in;
    logic [OUTPUT_WIDTH-1:0] c_stream;
    logic c_stream_valid;
    logic done;
    logic [DATA_WIDTH-1:0] a_fixed[0:N-1][0:N-1];
    logic valid_bit_a_in_fixed[0:N-1][0:N-1];
    logic [DATA_WIDTH-1:0] b_fixed[0:N-1][0:N-1];
    logic valid_bit_b_in_fixed[0:N-1][0:N-1];
    assign a_fixed='{'{1,2,3,4,5},'{6,7,8,9,10},'{11,12,13,14,15},'{16,17,18,19,20},'{21,22,23,24,25}};
    assign valid_bit_a_in_fixed='{'{1,1,1,1,1},'{1,1,1,1,1},'{1,1,1,1,1},'{1,1,1,1,1},'{1,1,1,1,1}};
    assign b_fixed='{'{25,24,23,22,21},'{20,19,18,17,16},'{15,14,13,12,11},'{10,9,8,7,6},'{5,4,3,2,1}};
    assign valid_bit_b_in_fixed='{'{1,1,1,1,1},'{1,1,1,1,1},'{1,1,1,1,1},'{1,1,1,1,1},'{1,1,1,1,1}};
        
    top_level_file #(
        .DATA_WIDTH(8),
        .OUTPUT_WIDTH(16),
        .N(N)
    ) dut(
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .a_stream(a_stream),
        .valid_bit_a_stream_in(valid_bit_a_stream_in),
        .b_stream(b_stream),
        .valid_bit_b_stream_in(valid_bit_b_stream_in),
        .c_stream(c_stream),
        .c_stream_valid(c_stream_valid),
        .done(done)
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    task clear_inputs();
        
            a_stream = '0;
            valid_bit_a_stream_in= '0;
            b_stream = '0;
            valid_bit_b_stream_in= '0;
      
    endtask
    
    initial begin
        // Initialize
        rst_n = 0;
        start=0;
        clear_inputs();
        
        // Reset sequence
        #20 rst_n = 1;
        @(posedge clk);
        start=1;
        a_stream=a_fixed[0][0];
        valid_bit_a_stream_in=valid_bit_a_in_fixed[0][0]; 
        b_stream=b_fixed[0][0];
        valid_bit_b_stream_in=valid_bit_b_in_fixed[0][0];   
        
        for(int i=1;i<=N*N;++i)
        begin
            @(posedge clk);
            start=0;
            a_stream=a_fixed[i/N][i%N];
            valid_bit_a_stream_in=valid_bit_a_in_fixed[i/N][i%N];
            b_stream=b_fixed[i/N][i%N];
            valid_bit_b_stream_in=valid_bit_b_in_fixed[i/N][i%N];
        end
       
        // End of data
        clear_inputs();
    
        // Wait for the systolic wave to reach the end
        repeat (50) @(posedge clk);
        $finish;
    end
endmodule
