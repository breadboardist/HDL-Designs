`timescale 1ns/10ps
module multi_vl(clock, reset, mlier, mcand, prodt, start, valid);

input clock;
input reset;
input [31:0] mlier;
input [31:0] mcand;
input start;
output [63:0] prodt;
output valid; 

reg   [63:0] prodt;
reg          valid;
wire  [31:0] q0, h0;

reg  [63:0] s_buf;
reg  [35:0] sft_cnt;
wire [63:0] sum;
wire  [63:0] h_sft;
wire  [32:0] q_sft;
wire [31:0] q0_judge;
integer     sft_num;
wire [63:0] multiplier;
reg  [5 :0] t_cnt;
reg  [63:0] h_ibuf;
reg  [32:0] q_ibuf;

parameter P_1dly = 0;

// 32 clk cycle, produce sft/add operation

assign  q0 = mlier;
assign  h0 = mcand;


always @( posedge clock or posedge reset ) begin
    if ( reset ) begin
        t_cnt <= 1;    
    end else if (start) begin
        t_cnt <= t_cnt + 1;    
    end else begin
        t_cnt <= 1;    
    end
end 	


add_full_64b add_full_64b(
	.sum	(sum), 
	.cout	(), 
	.a	(s_buf), 
	.b	(h_ibuf), 
	.cin	(1'b0));

reg init_flag ;
reg first_sft ;
wire [32:0] q0_tmp = {1'b1, q0};
wire [32:0] q0_tmp1 = {1'b1, q0} >> sft_num; 

always @( posedge clock or posedge reset ) begin
    if ( reset ) begin
        h_ibuf <= 0;    
        q_ibuf <= 0;    
        s_buf <= 0;    
        sft_cnt <= 36'b1;    
	init_flag <= 1;
	first_sft <= 1;
    end else begin 
    if (start) begin

	init_flag <= ~start;

	if (init_flag) begin // load new multipier and multiplicant
	        h_ibuf <= h0 ;    
	        q_ibuf <= {1'b1,q0};     
	end else begin                // shift multiplicant based on continuous 0 bit in multiplier
		if (first_sft) begin
			first_sft <= 0 ;
		        h_ibuf <= h_ibuf << sft_num; 
		        q_ibuf <= (q_ibuf >> sft_num) >> 1;  
		end else begin
		        h_ibuf <= (h_ibuf << sft_num) << 1; 
		        q_ibuf <= (q_ibuf >> sft_num) >> 1;  
		end
	end

	if (init_flag) begin
	        sft_cnt <= 33'b1;    
	end else begin
		        sft_cnt <= (sft_cnt << sft_num) << 1;    
	end

	if (!init_flag && !first_sft) begin
	       	s_buf <= sum;    
	end

    end else begin
	init_flag <= 1;
	first_sft <= 1;
	sft_cnt <= 36'b1; 
        h_ibuf <= 0;    
        q_ibuf <= 0;    
        s_buf <= 0;    
	end
    end
end 

assign q0_judge = q_ibuf[31:0] ;

always @(*) begin
	if (!start) begin
		sft_num = 0;
	end else if (!sft_cnt[33] && !init_flag) begin // figure out how many continuous 0 exist
		case(1'b1)
			(q0_judge[30:0] ==0):sft_num = 31;
			(q0_judge[29:0] ==0):sft_num = 30;
			(q0_judge[28:0] == 0):sft_num = 29;
			(q0_judge[27:0] == 0):sft_num = 28;
			(q0_judge[26:0] == 0):sft_num = 27;
			(q0_judge[25:0] == 0):sft_num = 26;
			(q0_judge[24:0] == 0):sft_num = 25;
			(q0_judge[23:0] == 0):sft_num = 24;
			(q0_judge[22:0] == 0):sft_num = 23;
			(q0_judge[21:0] == 0):sft_num = 22;
			(q0_judge[20:0] == 0):sft_num = 21;
			(q0_judge[19:0] == 0):sft_num = 20;
			(q0_judge[18:0] == 0):sft_num = 19;
			(q0_judge[17:0] == 0):sft_num = 18;
			(q0_judge[16:0] == 0):sft_num = 17;
			(q0_judge[15:0] == 0):sft_num = 16;
			(q0_judge[14:0] == 0):sft_num = 15;
			(q0_judge[13:0] == 0):sft_num = 14;
			(q0_judge[12:0] == 0):sft_num = 13;
			(q0_judge[11:0] == 0):sft_num = 12;
			(q0_judge[10:0] == 0):sft_num = 11;
			(q0_judge[ 9:0] == 0):sft_num = 10;
			(q0_judge[ 8:0] == 0):sft_num = 9 ;
			(q0_judge[ 7:0] == 0):sft_num = 8 ;
			(q0_judge[ 6:0] == 0):sft_num = 7 ;
			(q0_judge[ 5:0] == 0):sft_num = 6 ;
			(q0_judge[ 4:0] == 0):sft_num = 5 ;
			(q0_judge[ 3:0] == 0):sft_num = 4 ;
			(q0_judge[ 2:0] == 0):sft_num = 3 ;
			(q0_judge[ 1:0] == 0):sft_num = 2 ;
			(q0_judge[ 0] == 0):sft_num = 1 ;
			default:sft_num = 0;
		endcase
	end
end 

// 1 clk cycle, produce sign adjustment
wire [62: 0] mult_tmp;
wire [63: 0] mult_out;

assign  mult_tmp = ~(s_buf - 1'b1);
assign  mult_out = ((mlier[31] ^ mcand[31]) && (|s_buf))? {1'b1,mult_tmp} : {1'b0, s_buf};

reg valid_buf;

always @( posedge clock or posedge reset ) begin
    if ( reset ) begin
	valid <= 0;
	valid_buf <= 0;
        prodt <= 0;    
    end else begin
	valid_buf <= sft_cnt[33];
	if (!start) begin
		valid 	<= 0;
       		prodt 	<= 0;    
	end else if (!init_flag && first_sft && (h_ibuf[31:0] == 0 || q_ibuf[31:0] == 0 )) begin
		valid 	<= 1;
       		prodt 	<= 0;    
	end else begin
		valid 	<= sft_cnt[33] & ~valid_buf;
       		prodt 	<= mult_out;    
	end 
    end
end 

endmodule

module add_full_1b (sum, cout, a, b, cin);
	input a, b, cin; output sum, cout;
	wire sum_1st, cout_1st;

	assign sum_1st = a ^ b;
	assign cout_1st = a & b;
	assign sum = sum_1st ^ cin;
	assign cout = (sum_1st & cin) | cout_1st;
endmodule

module add_full_8b (sum, cout, a, b, cin);
	input  [7:0] a, b; 
	input        cin;
	output [7:0] sum;
	output       cout;
	wire cin2,cin3,cin4,cin5,cin6,cin7,cin8;

	add_full_1b add1_inst1(sum[0], cin2, a[0], b[0], cin);
	add_full_1b add1_inst2(sum[1], cin3, a[1], b[1], cin2);
	add_full_1b add1_inst3(sum[2], cin4, a[2], b[2], cin3);
	add_full_1b add1_inst4(sum[3], cin5, a[3], b[3], cin4);
	add_full_1b add1_inst5(sum[4], cin6, a[4], b[4], cin5);
	add_full_1b add1_inst6(sum[5], cin7, a[5], b[5], cin6);
	add_full_1b add1_inst7(sum[6], cin8, a[6], b[6], cin7);
	add_full_1b add1_inst8(sum[7], cout, a[7], b[7], cin8);
endmodule

module add_full_32b (sum, cout, a, b, cin);
	input  [31:0] a, b; 
	input         cin;
	output [31:0] sum;
	output        cout;
	wire cin2,cin3,cin4;

	add_full_8b add8_inst1(sum[ 7: 0], cin2, a[ 7: 0], b[ 7: 0], cin);
	add_full_8b add8_inst2(sum[15: 8], cin3, a[15: 8], b[15: 8], cin2);
	add_full_8b add8_inst3(sum[23:16], cin4, a[23:16], b[23:16], cin3);
	add_full_8b add8_inst4(sum[31:24], cout, a[31:24], b[31:24], cin4);
endmodule

module add_full_64b (sum, cout, a, b, cin);
	input  [63:0] a, b; 
	input         cin;
	output [63:0] sum;
	output        cout;
	wire cin2;

	add_full_32b add32_inst1(sum[31: 0], cin2, a[31: 0], b[31: 0], cin);
	add_full_32b add32_inst2(sum[63:32], cout, a[63:32], b[63:32], cin2);
endmodule


