`timescale 1ns/10ps
module divider #
  (
   parameter 	NUMERATOR_WIDTH = 72,
   parameter 	DENOMINATOR_WIDTH = 8,
   parameter 	QUOTIENT_WIDTH = 64 
   )
   (
    input 							  	clk,
    input 				  				rst,
    input  [NUMERATOR_WIDTH - 1:0]  	numerator_in,
    input  [DENOMINATOR_WIDTH - 1:0] 	denominator_in,
    input 				  				valid_in,
    output [QUOTIENT_WIDTH - 1:0]  		quotient_out,
    output 				  				valid_out
    );

   reg [NUMERATOR_WIDTH - 1 + 1:0] 	  numerator [NUMERATOR_WIDTH - 1:0];
   reg [DENOMINATOR_WIDTH - 1:0] 	  denominator [NUMERATOR_WIDTH - 1:0];
   reg [QUOTIENT_WIDTH - 1:0] 		  quotient [NUMERATOR_WIDTH - 1:0];
   reg [NUMERATOR_WIDTH - 1:0] 		  remainder [NUMERATOR_WIDTH - 1:0];
   reg 								  valid [NUMERATOR_WIDTH - 1:0];
   
   wire [NUMERATOR_WIDTH - 1:0] 	  remainder_next [NUMERATOR_WIDTH - 1:0];
   wire [NUMERATOR_WIDTH - 1 + 1:0]   numerator_out;
   wire [DENOMINATOR_WIDTH - 1:0] 	  denominator_out;

   assign quotient_out = quotient[NUMERATOR_WIDTH - 1];
   assign valid_out = valid[NUMERATOR_WIDTH - 1];
   assign numerator_out = numerator[NUMERATOR_WIDTH - 1];
   assign denominator_out = denominator[NUMERATOR_WIDTH - 1];

   genvar i;

   generate
      for (i = 0; i < NUMERATOR_WIDTH; i = i + 1)
		begin
	   		assign remainder_next[i] = i > 0 ? (remainder[i - 1] << 1) | numerator[i - 1][NUMERATOR_WIDTH - i - 1] : 0;

	   		always @(posedge clk) 
	   		begin
	     		if (rst)
	       			begin
						quotient[i] <= 0;
						remainder[i] <= 0;
						denominator[i] <= 0;
						numerator[i] <= 0;
						valid[i] <= 0;
	       			end
	     		else if (i == 0)
		 			begin
		    			quotient[i] <= 0;
		    			remainder[i] <= 0;
		    			denominator[i] <= denominator_in;
		    			numerator[i] <= numerator_in;
		    			valid[i] <= valid_in;
					end
	      		else 
	      			begin
		    		if (remainder_next[i] >= denominator[i - 1])
		     			begin
							remainder[i] <= remainder_next[i] - denominator[i - 1];
							quotient[i] <= quotient[i - 1] | (1 << NUMERATOR_WIDTH - i - 1);
		     			end
		    		else 
		    			begin
							remainder[i] <= remainder_next[i];
							quotient[i] <= quotient[i - 1];
		      			end
		    				denominator[i] <= denominator[i - 1];
		    				numerator[i] <= numerator[i - 1];
		    				valid[i] <= valid[i - 1];
					end	
			end
		end
    endgenerate

endmodule