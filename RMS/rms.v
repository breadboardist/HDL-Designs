`timescale 1ns/10ps
//Top Module of A RMS Calculator
//Author: Prem Bharath Soundararajan
//The specifications of the design are in the pdf
module rms #
			(
				parameter INPUT = 32,
				parameter OUTPUT = 32,
				parameter COUNTERBITS = 8,
				parameter COMMANDBITS = 2

			)
			(
				input clk,
				input rst,
				input pushin,
				input [COMMANDBITS-1:0] cmdin,
				input [INPUT-1:0] Xin,
				input pullout,
				output stopout,
				output [OUTPUT-1:0] Xout
  			);

  reg 					pushin_d, pushin_d0, pushin_d1, pushin_d2,
  						stopout_d, stopout_d0, stopout_d1,
  						pushout_d, empty_d, clearRMS_Queue;	

  reg [COMMANDBITS-1:0]	cmdin_d, cmdin_d0, cmdin_d1;
  reg [INPUT-1:0]		Xin_d;
  reg [INPUT-1:0]	  	unsignedX;
  reg [((INPUT*2)-1):0]	square;
  reg [COUNTERBITS-1:0] counter;
  reg [((2*INPUT)+COUNTERBITS)-1:0]	accumulator;
  

  wire full, empty, writeEnable, readEnable, sqrtReady, quotientReady;

  wire [OUTPUT-1:0]	fifoOutput;
  wire [OUTPUT-1:0] sqrt;
  wire [((OUTPUT*2)-1):0] quotient;

  assign writeEnable = sqrtReady;
  assign readEnable = ~empty & pullout;


  /////////////////////////////////////////////////////////////////////////////////////////////
  //Control logic - This always block generates all the control flags, reads the input data, // 
  //squares the input and pipelines the process to achieve higher clock speeds				 //
  /////////////////////////////////////////////////////////////////////////////////////////////
  always@(posedge clk or posedge rst)  begin
	if (rst) begin
		pushin_d0 <= 0;
		pushin_d1 <= 0;
		pushin_d2 <= 0;
		cmdin_d <= 0;
		cmdin_d0 <= 0; 
		cmdin_d1 <= 0;
		pushin_d <= 0;
		Xin_d <= 0;
		unsignedX <= 0;
		square <= 0;
		accumulator <= 0;
		counter <= 0;
		clearRMS_Queue <= 0;
		pushout_d <= 0;
		empty_d <= 1;
		stopout_d <= 1;
		stopout_d0 <= 1; 
		stopout_d1 <= 1;
	end else begin
		pushin_d1 <= pushin;
		pushin_d2 <= pushin_d1;
		cmdin_d0 <= cmdin;
		cmdin_d1 <= cmdin_d0;
		pushin_d <= pushin_d2;
		cmdin_d <= cmdin_d1;
		Xin_d <= Xin;
		unsignedX <= (Xin_d[31])? (~Xin_d + 1'b1) : Xin_d;
		square <= unsignedX * unsignedX;
		//Reads the command bits and performs the appropriate operation
		case (1'b1)
			(clearRMS_Queue): begin
					if (pushin_d) begin
						accumulator <= square;
						counter <= 1;
					end else begin
						accumulator <= 0;
						counter <= 0;
					end
				end

			(pushin_d && cmdin_d != 2'b01): begin
				accumulator <= accumulator + square;
				counter <= counter+1;
			end

			(pushin_d && cmdin_d == 2'b01): begin
			accumulator <= accumulator - square;
			counter <= counter-1;
			end	
		endcase
	
		if (pushin_d && cmdin_d == 2'b11) begin
			clearRMS_Queue <= 1;
		end else begin
			clearRMS_Queue <= 0;
		end

		if (pushin_d && (cmdin_d == 2'b10 || cmdin_d == 2'b11)) begin
			pushin_d0 <= pushin_d;  
		end else begin
			pushin_d0 <= 0;
		end

		if (!empty) begin
			empty_d <= #1 0;
		end else if (pullout) begin	
			empty_d <= #1 1;
		end
		
		if (readEnable) begin
			stopout_d0 <= #1 1'b0;
		end else if (pullout) begin
			stopout_d0 <= #1 1'b1;
		end
		
		pushout_d <= pullout;
	end		
  end

divider dividerU1 (
					.clk			(clk), 
					.rst			(rst), 
					.valid_in		(pushin_d0), 
					.numerator_in	(accumulator), 
					.denominator_in	(counter), 
					.quotient_out	(quotient), 
					.valid_out		(quotientReady)
				);


sqrt sqrtU1 (
				.clk		(clk), 
				.rst		(rst), 
				.start		(quotientReady), 
				.radicand	(quotient), 
				.root		(sqrt), 
				.data_valid	(sqrtReady)
			);


fifo fifoU1 (
    				.dataout (fifoOutput),
    				.full    (full),
    				.empty   (empty),
    				.datain  (sqrt),
    				.write   (writeEnable),
    				.read    (readEnable),
    				.clk     (clk),
    				.rst     (rst)
  			  );

assign stopout = stopout_d0;
assign Xout = fifoOutput;

endmodule  

