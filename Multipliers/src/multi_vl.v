
module multi_vl(clock, reset, mlier, mcand, prodt, start, valid);
	////////////////////////////////////
	//Ports and Register declarations //
	////////////////////////////////////
	
	input 			clock;
	input 			reset;
	input [31:0] 	mlier;
	input [31:0] 	mcand;
	input 			start;
	output [63:0] 	prodt;
	output 			valid; 

	reg   [63:0] 	prodt;
	wire  [31:0] 	reg_mlier, reg_mcand, comp_mlier, comp_mcand;
	
	reg  [63:0] 	acc_d;
	reg  [35:0] 	shift_position;
	wire [63:0] 	acc;
	wire [31:0] 	zeroes_mlier;
	reg  [5:0]   	shift_amount;
	//wire [63:0] 	multiplier;
	reg  [63:0] 	mcand_sft;
	reg  [32:0] 	mlier_sft;
	reg         	mlier_msb, mcand_msb;
	reg         	load_vals, sft_init;

	/////////////////////////////////////////////////
	// 32 clk cycle to perform shift/add operation //
	/////////////////////////////////////////////////

	// Adders to convert two's complement form of the multiplier to original form
	FullAdder32Bit U2(comp_mlier, cout1, ~mlier, 32'b1, 1'b0);
	FullAdder32Bit U3(comp_mcand, cout2, ~mcand, 32'b1, 1'b0);

	// Determine if the mlier or mcand needs conversion from two's complement form
	assign  reg_mlier = (mlier[31])? comp_mlier : mlier;
	assign  reg_mcand = (mcand[31])? comp_mcand : mcand;

	FullAdder64Bit U1	(
							.sum	(acc), 
							.cout	(), 
							.a	(acc_d), 
							.b	(mcand_sft), 
							.cin	(1'b0)
						);

	always @( posedge clock or posedge reset ) begin
	    if ( reset ) begin
	    	//Reset Everything
	        mcand_sft 		<= 0;    
	        mlier_sft 		<= 0;    
	        acc_d 			<= 0; 
	        mlier_msb 		<= 0; 
	        mcand_msb 		<= 0;   
	        shift_position 	<= 36'b1;  
			load_vals 		<= 0; 
			sft_init 		<= 1;
	    end else begin
	    	//Begin State Machine Multiplication
	        if (!load_vals) begin
	          	if (start) begin
		        	mcand_sft <= {32'b0, reg_mcand};    
		        	mlier_sft <= {1'b1,reg_mlier};     
					mlier_msb <= mlier[31]; 
					mcand_msb <= mcand[31];
	          	end else begin
		        	mcand_sft <= 0;    
		        	mlier_sft <= 0;     
					mlier_msb <= 0; 
					mcand_msb <= 0; 
					sft_init  <= 1;
	          end
	        end else begin    // Shift multiplicand based on continuous zeroes in multiplier
	                sft_init <= 0;
					mlier_sft <= (mlier_sft >> shift_amount) >> 1;  
	                if (sft_init && load_vals) begin // handle abnormal case for loading
	        			mcand_sft <=  mcand_sft << shift_amount ; 
	                end else begin
	        			mcand_sft <= (mcand_sft << shift_amount) <<1;   
	                end
			end
	        
	        if (!start) begin
				load_vals <= 0;
			end else begin
				load_vals <= 1;
			end

		// Keeping track of the shift position by shifting the shift_position register by the amount of shift
		// being performed.
		if (!start) begin
		        shift_position <= 36'b1;    
	    end else begin
		        shift_position <= (shift_position << shift_amount)<<1 ;    
		end

		if (!start) begin
		       	acc_d <= 0;    
	    end else if (sft_init && load_vals) begin
	     		acc_d <= 0;    
	    end else begin
	     		acc_d <= acc;    
		end
	end
end 

	assign zeroes_mlier = mlier_sft[31:0] ;

	always @(*) begin// figure out how many continuous 0 exist
		if (!start || !load_vals) begin
			shift_amount = 0;
		end else begin 
			case (1'b1)
				(zeroes_mlier[31:0] == 0):shift_amount = 32;
				(zeroes_mlier[30:0] == 0):shift_amount = 31;
				(zeroes_mlier[29:0] == 0):shift_amount = 30;
				(zeroes_mlier[28:0] == 0):shift_amount = 29;
				(zeroes_mlier[27:0] == 0):shift_amount = 28;
				(zeroes_mlier[26:0] == 0):shift_amount = 27;
				(zeroes_mlier[25:0] == 0):shift_amount = 26;
				(zeroes_mlier[24:0] == 0):shift_amount = 25;
				(zeroes_mlier[23:0] == 0):shift_amount = 24;
				(zeroes_mlier[22:0] == 0):shift_amount = 23;
				(zeroes_mlier[21:0] == 0):shift_amount = 22;
				(zeroes_mlier[20:0] == 0):shift_amount = 21;
				(zeroes_mlier[19:0] == 0):shift_amount = 20;
				(zeroes_mlier[18:0] == 0):shift_amount = 19;
				(zeroes_mlier[17:0] == 0):shift_amount = 18;
				(zeroes_mlier[16:0] == 0):shift_amount = 17;
				(zeroes_mlier[15:0] == 0):shift_amount = 16;
				(zeroes_mlier[14:0] == 0):shift_amount = 15;
				(zeroes_mlier[13:0] == 0):shift_amount = 14;
				(zeroes_mlier[12:0] == 0):shift_amount = 13;
				(zeroes_mlier[11:0] == 0):shift_amount = 12;
				(zeroes_mlier[10:0] == 0):shift_amount = 11;
				(zeroes_mlier[ 9:0] == 0):shift_amount = 10;
				(zeroes_mlier[ 8:0] == 0):shift_amount = 9 ;
				(zeroes_mlier[ 7:0] == 0):shift_amount = 8 ;
				(zeroes_mlier[ 6:0] == 0):shift_amount = 7 ;
				(zeroes_mlier[ 5:0] == 0):shift_amount = 6 ;
				(zeroes_mlier[ 4:0] == 0):shift_amount = 5 ;
				(zeroes_mlier[ 3:0] == 0):shift_amount = 4 ;
				(zeroes_mlier[ 2:0] == 0):shift_amount = 3 ;
				(zeroes_mlier[ 1:0] == 0):shift_amount = 2 ;
				(zeroes_mlier[ 0 ]  == 0):shift_amount = 1 ;
				default: shift_amount = 0;
			endcase
			 
		end
	end 

	// 1 clk cycle, produce sign adjustment
	wire [63: 0] 	mult_tmp;
	wire [63: 0] 	mult_out;

	assign  mult_tmp = ~(acc - 1'b1);
	assign  mult_out = ((mlier_msb ^ mcand_msb) && (|acc))? {1'b1,mult_tmp} : {1'b0, acc};

	assign valid = shift_position[34];

	always @( posedge clock or posedge reset ) begin
	    if ( reset == 1'b1 ) begin
	        prodt <= 0;    
	    end else begin
		if (zeroes_mlier[31:0] == 32'b0) begin
			prodt 	<= 0;    
		end else begin
			prodt 	<= mult_out;    
		end
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