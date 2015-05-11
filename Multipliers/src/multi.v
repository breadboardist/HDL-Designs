`timescale 1ns/10ps
module multi(clock, reset, mlier, mcand, prodt, start, valid);

	////////////////////////////////////
	//Ports and Register declarations //
	////////////////////////////////////
	
	input 			clock;
	input 			reset;
	input [31:0]	mlier;
	input [31:0] 	mcand;
	input 			start;
	output [63:0] 	prodt;
	output 			valid; 

	reg   [63:0] prodt;
	wire         valid;
	wire  [31:0] reg_mlier, reg_mcand, comp_mlier, comp_mcand;

	reg  [63:0] acc_d;
	reg  [33:0] shift_position;
	wire [63:0] acc;
	reg  [63:0] mcand_sft;
	reg  [31:0] mlier_sft;
	reg         load_vals;
	wire [63:0] true_mcand;
	reg         msb_mlier, msb_mcand;


	/////////////////////////////////////////////////
	// 32 clk cycle to perform shift/add operation //
	/////////////////////////////////////////////////

	// Adders to convert two's complement form of the multiplier to original form
	FullAdder32Bit U2 (comp_mlier, cout1, ~mlier, 32'b1, 1'b0);
	FullAdder32Bit U3 (comp_mcand, cout2, ~mcand, 32'b1, 1'b0);

	// Determine if the mlier or mcand needs conversion from two's complement form
	assign  reg_mlier = (mlier[31])? comp_mlier : mlier;
	assign  reg_mcand = (mcand[31])? comp_mcand : mcand;

	assign true_mcand = mlier_sft[0]? mcand_sft:0;

	FullAdder64Bit U1	(
							.sum	(acc), 
							.cout	(), 
							.a		(acc_d), 
							.b		(true_mcand), 
							.cin	(1'b0)
						);

	always @( posedge clock or posedge reset ) begin
		//Reset Everything
	    if ( reset ) begin
	        mcand_sft 	<= 0;    
	        mlier_sft 	<= 0;    
	        acc_d 		<= 0;
	        msb_mlier 	<= 0; 
	        msb_mcand 	<= 0;   
	        shift_position 	<= 34'b1;    
			load_vals 	<= 0;
	    end else begin
	    //Begin State Machine Multiplication 
	    	if (!load_vals) begin
	        	if (start) begin
			        mcand_sft <= {32'b0, reg_mcand};    
			        mlier_sft <= {1'b1 , reg_mlier};     
					msb_mlier <= mlier[31]; 
					msb_mcand <= mcand[31];
	          	end else begin
		        	mcand_sft <= 0;    
		        	mlier_sft <= 0;     
					msb_mlier <= 0; 
					msb_mcand <= 0;
	          end
			end else begin
				mcand_sft <= {mcand_sft[62:0], 1'b0};
				mlier_sft <= {1'b0, mlier_sft[31:1]};
			end

	    	if (!start) begin
				load_vals <= 0;
			end else begin
				load_vals <= 1;
			end

			if (!start) begin
		       	acc_d			<= 0;    
		        shift_position 	<= 34'b1;    
			end else begin
		       	acc_d 			<= acc;    
		        shift_position 	<= {shift_position[32:0], 1'b0};    
			end
	   	end
	end 

	///////////////////////////////////////////////////////////////
	// 1 clk cycle to perform sign adjustment and produce result //
	///////////////////////////////////////////////////////////////
	
	wire [63: 0] prodt_tmp;
	wire [63: 0] prodt_out;

	//Produce sign adjustment depending on the MSB of the inputs and output
	assign  prodt_tmp = ~(acc - 1'b1);
	assign  prodt_out = ((msb_mlier ^ msb_mcand) && (|acc))? {1'b1,prodt_tmp} : {1'b0, acc};

	//When 33 clock cycles have been completed, the valid signal can be asserted
	assign valid = shift_position[33];

	always @( posedge clock or posedge reset ) begin
	    if ( reset ) begin
	        prodt <= 0;    
	    end else begin 
	       	prodt <= prodt_out;    
	    end
	end 

endmodule

module FullAdder1Bit (sum, cout, a, b, cin);
	input a, b, cin; 
	output sum, cout;
	wire sum_1st, cout_1st;
	
	assign sum_1st = a ^ b;
	assign cout_1st = a & b;
	
	assign sum = sum_1st ^ cin;
	assign cout = (sum_1st & cin) | cout_1st;
endmodule

module FullAdder8Bit (sum, cout, a, b, cin);
	input  [7:0] a, b; 
	input        cin;
	output [7:0] sum;
	output       cout;
	wire cin2,cin3,cin4,cin5,cin6,cin7,cin8;
	
	FullAdder1Bit add1_inst1(sum[0], cin2, a[0], b[0], cin);
	FullAdder1Bit add1_inst2(sum[1], cin3, a[1], b[1], cin2);
	FullAdder1Bit add1_inst3(sum[2], cin4, a[2], b[2], cin3);
	FullAdder1Bit add1_inst4(sum[3], cin5, a[3], b[3], cin4);
	FullAdder1Bit add1_inst5(sum[4], cin6, a[4], b[4], cin5);
	FullAdder1Bit add1_inst6(sum[5], cin7, a[5], b[5], cin6);
	FullAdder1Bit add1_inst7(sum[6], cin8, a[6], b[6], cin7);
	FullAdder1Bit add1_inst8(sum[7], cout, a[7], b[7], cin8);
endmodule

module FullAdder32Bit (sum, cout, a, b, cin);
	input  [31:0] a, b; 
	input         cin;
	output [31:0] sum;
	output        cout;
	wire cin2,cin3,cin4;
	
	FullAdder8Bit add8_inst1(sum[ 7: 0], cin2, a[ 7: 0], b[ 7: 0], cin);
	FullAdder8Bit add8_inst2(sum[15: 8], cin3, a[15: 8], b[15: 8], cin2);
	FullAdder8Bit add8_inst3(sum[23:16], cin4, a[23:16], b[23:16], cin3);
	FullAdder8Bit add8_inst4(sum[31:24], cout, a[31:24], b[31:24], cin4);
endmodule

module FullAdder64Bit (sum, cout, a, b, cin);
	input  [63:0] a, b; 
	input         cin;
	output [63:0] sum;
	output        cout;
	wire cin2;

	FullAdder32Bit add32_inst1(sum[31: 0], cin2, a[31: 0], b[31: 0], cin);
	FullAdder32Bit add32_inst2(sum[63:32], cout, a[63:32], b[63:32], cin2);
endmodule


