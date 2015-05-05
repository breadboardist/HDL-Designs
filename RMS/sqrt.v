`timescale 1ns/10ps
//Square Root Module of A RMS Calculator
//Author: Prem Bharath Soundararajan
//The specifications of the design are in the pdf
module sqrt #
  (
    parameter INPUT_BITS   = 64,
    parameter OUTPUT_BITS  = 32 
  )
  (
   input                        clk,        
   input                        rst,    
   input                        start,      
   input [INPUT_BITS-1:0]       radicand,   
   output reg                   data_valid, 
   output reg [OUTPUT_BITS-1:0] root        
   );
  
  reg [OUTPUT_BITS-1:0]            start_gen;    
  reg [OUTPUT_BITS*INPUT_BITS-1:0] root_gen;     
  reg [OUTPUT_BITS*INPUT_BITS-1:0] radicand_gen; 

  wire [OUTPUT_BITS*INPUT_BITS-1:0] mask_gen;

  always @ (posedge clk or posedge rst) begin
    if (rst) begin
      start_gen[0]                 <= 0;
      radicand_gen[INPUT_BITS-1:0] <= 0;
      root_gen[INPUT_BITS-1:0]     <= 0;
    end
    else begin
      start_gen[0] <= start;
      if ( mask_gen[INPUT_BITS-1:0] <= radicand ) begin
        radicand_gen[INPUT_BITS-1:0] <= radicand - mask_gen[INPUT_BITS-1:0];
        root_gen[INPUT_BITS-1:0] <= mask_gen[INPUT_BITS-1:0];
      end
      else begin
        radicand_gen[INPUT_BITS-1:0] <= radicand;
        root_gen[INPUT_BITS-1:0] <= 0;
      end
    end
  end
  //Algorithm described here
  //http://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Binary_numeral_system_.28base_2.29
  generate
    genvar i;
    for (i = 0; i < OUTPUT_BITS; i = i + 1) begin: mask_4
      if (i % 2)
        assign mask_gen[INPUT_BITS*(OUTPUT_BITS-i)-1:INPUT_BITS*(OUTPUT_BITS-i-1)]  = 4 << 4 * (i/2);
      else
        assign mask_gen[INPUT_BITS*(OUTPUT_BITS-i)-1:INPUT_BITS*(OUTPUT_BITS-i-1)]  = 1 << 4 * (i/2);
    end
    
    for (i = 0; i < OUTPUT_BITS - 1; i = i + 1) begin: pipeline
      always @ (posedge clk or posedge rst) begin : pipeline_stage
        if (rst) begin
          start_gen[i+1]                                    <= 0;
          radicand_gen[INPUT_BITS*(i+2)-1:INPUT_BITS*(i+1)] <= 0;
          root_gen[INPUT_BITS*(i+2)-1:INPUT_BITS*(i+1)]     <= 0;
        end
        else begin
          start_gen[i+1] <= start_gen[i];
          if ((root_gen[INPUT_BITS*(i+1)-1:INPUT_BITS*i] + 
               mask_gen[INPUT_BITS*(i+2)-1:INPUT_BITS*(i+1)]) <= radicand_gen[INPUT_BITS*(i+1)-1:INPUT_BITS*i]) begin
	    radicand_gen[INPUT_BITS*(i+2)-1:INPUT_BITS*(i+1)] <= radicand_gen[INPUT_BITS*(i+1)-1:INPUT_BITS*i] - 
                                                                 mask_gen[INPUT_BITS*(i+2)-1:INPUT_BITS*(i+1)] - 
                                                                 root_gen[INPUT_BITS*(i+1)-1:INPUT_BITS*i];
	    root_gen[INPUT_BITS*(i+2)-1:INPUT_BITS*(i+1)] <= (root_gen[INPUT_BITS*(i+1)-1:INPUT_BITS*i] >> 1) + 
                                                             mask_gen[INPUT_BITS*(i+2)-1:INPUT_BITS*(i+1)];
          end
          else begin
	    radicand_gen[INPUT_BITS*(i+2)-1:INPUT_BITS*(i+1)] <= radicand_gen[INPUT_BITS*(i+1)-1:INPUT_BITS*i];
	    root_gen[INPUT_BITS*(i+2)-1:INPUT_BITS*(i+1)]     <= root_gen[INPUT_BITS*(i+1)-1:INPUT_BITS*i] >> 1;
          end
        end
      end
    end
  endgenerate

  always @ (posedge clk or posedge rst) begin
    if (rst) begin
      data_valid <= 0;
      root       <= 0;
    end
    else begin
      data_valid <= start_gen[OUTPUT_BITS-1];
      if (root_gen[OUTPUT_BITS*INPUT_BITS-1:OUTPUT_BITS*INPUT_BITS-INPUT_BITS] > root_gen[OUTPUT_BITS*INPUT_BITS-1:OUTPUT_BITS*INPUT_BITS-INPUT_BITS])
        root <= root_gen[OUTPUT_BITS*INPUT_BITS-1:OUTPUT_BITS*INPUT_BITS-INPUT_BITS] + 1;
      else
        root  <= root_gen[OUTPUT_BITS*INPUT_BITS-1:OUTPUT_BITS*INPUT_BITS-INPUT_BITS];
    end
  end

endmodule