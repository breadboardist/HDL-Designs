
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
	//wire  			cout1, cout2;
	reg  [63:0] 	s_buf;
	reg  [35:0] 	sft_cnt;
	wire [63:0] 	sum;
	wire [31:0] 	reg_mlier_judge;
	integer     	sft_num;
	wire [63:0] 	multiplier;
	reg  [63:0] 	h_sft;
	reg  [32:0] 	q_sft;
	reg         	mlier_msb, mcand_msb;
	reg         	load_ok, first_sft;

	// 32 clk cycle, produce sft/add operation
	FullAdder32Bit U2(comp_mlier, cout1, ~mlier, 32'b1, 1'b0);
	FullAdder32Bit U3(comp_mcand, cout2, ~mcand, 32'b1, 1'b0);

	assign  reg_mlier = (mlier[31])? comp_mlier : mlier;
	assign  reg_mcand = (mcand[31])? comp_mcand : mcand;

	FullAdder64Bit U1	(
							.sum	(sum), 
							.cout	(), 
							.a	(s_buf), 
							.b	(h_sft), 
							.cin	(1'b0)
						);

	always @( posedge clock or posedge reset ) begin
	    if ( reset == 1'b1 ) begin
	        h_sft <= 0;    
	        q_sft <= 0;    
	        s_buf <= 0; mlier_msb <= 0; mcand_msb <= 0;   
	        sft_cnt <= 36'b1;  
		load_ok <= 0; first_sft <= 1;
	    end else begin 
	        if (!load_ok) begin
	          if (start) begin
		        h_sft <= {32'b0, reg_mcand};    
		        q_sft <= {1'b1,reg_mlier};     
			mlier_msb <= mlier[31]; mcand_msb <= mcand[31];
	          end else begin
		        h_sft <= 0;    
		        q_sft <= 0;     
			mlier_msb <= 0; mcand_msb <= 0; first_sft <= 1;
	          end
	        end else begin    // shift multiplicant based on continuous 0 bit in multiplier
	                first_sft <= 0;
			q_sft <= (q_sft >> sft_num) >> 1;  
	                if (first_sft && load_ok) begin // handle abnormal case for loading
	        		h_sft <=  h_sft << sft_num ; 
	                end else begin
	        		h_sft <= (h_sft << sft_num) <<1;   
	                end
		end
	        
	        if (!start) begin
			load_ok <= 0;
		end else begin
			load_ok <= 1;
		end

	// sft_cnt is used to count multipier's sft status.
		if (!start) begin
		        sft_cnt <= 36'b1;    
	        end else begin
		        sft_cnt <= (sft_cnt << sft_num)<<1 ;    
		end

		if (!start) begin
		       	s_buf <= 0;    
	        end else if (first_sft && load_ok) begin
	     		s_buf <= 0;    
	        end else begin
	     		s_buf <= sum;    
		end

	    end
	end 

	assign reg_mlier_judge = q_sft[31:0] ;

	always @(*) begin// figure out how many continuous 0 exist
		if (!start || !load_ok) begin
			sft_num = 0;
		end else begin 
			case (1'b1)
				(reg_mlier_judge[31:0] == 0):sft_num = 32;
				(reg_mlier_judge[30:0] == 0):sft_num = 31;
				(reg_mlier_judge[29:0] == 0):sft_num = 30;
				(reg_mlier_judge[28:0] == 0):sft_num = 29;
				(reg_mlier_judge[27:0] == 0):sft_num = 28;
				(reg_mlier_judge[26:0] == 0):sft_num = 27;
				(reg_mlier_judge[25:0] == 0):sft_num = 26;
				(reg_mlier_judge[24:0] == 0):sft_num = 25;
				(reg_mlier_judge[23:0] == 0):sft_num = 24;
				(reg_mlier_judge[22:0] == 0):sft_num = 23;
				(reg_mlier_judge[21:0] == 0):sft_num = 22;
				(reg_mlier_judge[20:0] == 0):sft_num = 21;
				(reg_mlier_judge[19:0] == 0):sft_num = 20;
				(reg_mlier_judge[18:0] == 0):sft_num = 19;
				(reg_mlier_judge[17:0] == 0):sft_num = 18;
				(reg_mlier_judge[16:0] == 0):sft_num = 17;
				(reg_mlier_judge[15:0] == 0):sft_num = 16;
				(reg_mlier_judge[14:0] == 0):sft_num = 15;
				(reg_mlier_judge[13:0] == 0):sft_num = 14;
				(reg_mlier_judge[12:0] == 0):sft_num = 13;
				(reg_mlier_judge[11:0] == 0):sft_num = 12;
				(reg_mlier_judge[10:0] == 0):sft_num = 11;
				(reg_mlier_judge[ 9:0] == 0):sft_num = 10;
				(reg_mlier_judge[ 8:0] == 0):sft_num = 9 ;
				(reg_mlier_judge[ 7:0] == 0):sft_num = 8 ;
				(reg_mlier_judge[ 6:0] == 0):sft_num = 7 ;
				(reg_mlier_judge[ 5:0] == 0):sft_num = 6 ;
				(reg_mlier_judge[ 4:0] == 0):sft_num = 5 ;
				(reg_mlier_judge[ 3:0] == 0):sft_num = 4 ;
				(reg_mlier_judge[ 2:0] == 0):sft_num = 3 ;
				(reg_mlier_judge[ 1:0] == 0):sft_num = 2 ;
				(reg_mlier_judge[ 0 ]  == 0):sft_num = 1 ;
				default: sft_num = 0;
			endcase
			 
		end
	end 

	// 1 clk cycle, produce sign adjustment
	wire [63: 0] 	mult_tmp;
	wire [63: 0] 	mult_out;

	assign  mult_tmp = ~(sum - 1'b1);
	assign  mult_out = ((mlier_msb ^ mcand_msb) && (|sum))? {1'b1,mult_tmp} : {1'b0, sum};

	assign valid = sft_cnt[34];

	always @( posedge clock or posedge reset ) begin
	    if ( reset == 1'b1 ) begin
	        prodt <= 0;    
	    end else begin
		if (reg_mlier_judge[31:0] == 32'b0) begin
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