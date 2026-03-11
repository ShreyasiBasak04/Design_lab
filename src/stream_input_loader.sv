`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/11/2026 03:23:08 PM
// Design Name: 
// Module Name: stream_input_loader
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


module stream_input_loader #(
    parameter DATA_WIDTH=8,
    parameter N=4
)(
    input logic clk,
    input logic rst_n,
    input logic start,
    input logic [DATA_WIDTH-1:0]a_stream,
    input logic valid_in,
    output logic [N-1:0][N-1:0][DATA_WIDTH-1:0] a_buf ,
    output logic [N-1:0][N-1:0]valid_bit_a_buf,
    output logic staggered_start
    );
    typedef enum logic {IDLE, LOAD} state_t;
    state_t state;

    logic [$clog2(N*N):0] load_count;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            state      <= IDLE;
            load_count <= 0;
            staggered_start<=0;
        end
        else begin
            case (state)
                IDLE: begin
                     if(start)
                     begin
                        if(valid_in)
                        begin
                            state      <= LOAD;
                            a_buf[0][0]<=a_stream;
                            valid_bit_a_buf[0][0]<=valid_in;
                            load_count <= 1;
                        end
                       
                        staggered_start<=0;
                     end
                     
                 end

                LOAD: begin
                        if(valid_in)
                        begin
                            a_buf[load_count / N][load_count % N] <= a_stream;
                            valid_bit_a_buf[load_count / N][load_count % N] <= valid_in;
                            load_count <= load_count + 1; 
                            if (load_count == N*N-1)
                            begin
                                state <= IDLE;
                                staggered_start<=1;
                            end
                        end
                    
                end

   
            endcase
        end
    end
endmodule
