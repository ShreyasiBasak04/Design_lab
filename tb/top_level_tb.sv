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
    
    integer infile;
    integer outfile;
    integer r;
    integer row = 0;
    integer col = 0;
    
    initial 
    begin
        //$display("Simulation working directory: %s", $getcwd());
        infile = $fopen("input.mem","r");

        if(infile == 0) begin
            $display("ERROR: input file not found");
            $finish;
        end

    // Read matrix A
        for(int i=0;i<N;i++) begin
            for(int j=0;j<N;j++) begin
                r = $fscanf(infile,"%d",a_fixed[i][j]);
                valid_bit_a_in_fixed[i][j] = 1;
            end
        end

    // Read matrix B
        for(int i=0;i<N;i++) begin
            for(int j=0;j<N;j++) begin
                r = $fscanf(infile,"%d",b_fixed[i][j]);
                valid_bit_b_in_fixed[i][j] = 1;
            end
        end

    end
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
    always @(posedge clk) begin
        if(!done && c_stream_valid) begin
           $fwrite(outfile,"%0d ",c_stream);
           col = col + 1;

            if(col == N) begin
                $fwrite(outfile,"\n");
                col = 0;
                row = row + 1;
            end
        end
    end
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
        outfile = $fopen("output.mem","w");
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
        $fclose(infile);
        $fclose(outfile);
        $finish;
    end    
endmodule
