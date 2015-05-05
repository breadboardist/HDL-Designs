`timescale 1ns/10ps
//FIFO and Memory Module of A RMS Calculator
//Author: Prem Bharath Soundararajan
//The specifications of the design are in the pdf
module fifo #
			(
				parameter WIDTH = 32,
				parameter DEPTH = 64,
				parameter ADDRESSBITS = 5,
				parameter DISTANCE = 6
			)
			( 	
				input clk,
				input rst,
				input write,
				input read,
				input [WIDTH-1:0] datain,
				output [WIDTH-1:0] dataout,
				output full,
				output empty

			);  

reg	[ADDRESSBITS-1:0] readPtr,writePtr;
reg	[DISTANCE-1:0]   distance;


reg	[WIDTH-1:0]     dataout;
reg	[WIDTH-1:0]     stack [DEPTH-1:0];

assign full = (distance == DEPTH);
assign empty = (distance == 0);

always @(posedge clk or posedge rst)begin
	if(rst) begin
			dataout<= #1 0;
			readPtr<= #1 0;
			writePtr<= #1 0;
			distance<= #1 0;
		end
	else begin case (1'b1)
					(write &&(!full)&&(!read)):begin
							stack[writePtr]	<= #1 datain;
					    	writePtr	<= #1 writePtr+1;
					    	distance	<= #1 distance+1;
						end
					((!write)&&(!empty)&&read):begin
							dataout	<= #1 stack[readPtr];
					    	readPtr	<= #1 readPtr+1;
					    	distance	<= #1 distance-1;
						end
					(write&&read&&empty):begin
							stack[writePtr]	<= #1 datain;
					    	writePtr	<= #1 writePtr+1;
					    	distance	<= #1 distance+1;
						end
					(write&&read&&full):begin
							dataout	<= #1 stack[readPtr];
					    	readPtr	<= #1 readPtr+1;
					    	distance	<= #1 distance-1;
						end
					(write&&read&&(!full)&&(!empty)):begin
							dataout	<= #1 stack[readPtr];
					    	stack[writePtr]	 <= #1 datain;
					    	readPtr	<= #1 readPtr+1;
					    	writePtr	<= #1 writePtr+1;
						end
					endcase // 1'b1
			end
	end	

endmodule
