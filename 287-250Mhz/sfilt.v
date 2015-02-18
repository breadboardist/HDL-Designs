// This is a sample example for a serial filter block
// This will be used for the pipelining problem
//
`timescale 1ns/10ps
// cmd codes
// 0 = first mult
// 1 = mult-accumulate
// 2 = shift right by h[6:0] and round
// 3 = send output and clear
module sfilt(input clk, input rst, input pushin, input [1:0] cmd,
	input [31:0] q, input [31:0] h,
	output pushout, output [31:0] z);
reg signed [63:0] acc,acc_d;
integer q0,q0_d,h0,h0_d,dout,dout_d;
reg push0,push0_0,push0_1,push0_2;;
reg _pushout,_pushout_d;
reg [1:0] cmd0,cmd0_0,cmd0_1,cmd0_2;
reg roundit;

wire cmd0_en_0,cmd1_en_0,cmd2_en_0,cmd3_en_0,cmd1_en_2_pulse;
reg cmd0_en_1,cmd0_en_2,cmd0_en_2_d,cmd1_en_1,cmd1_en_2,cmd1_en_2_d,cmd2_en_1,cmd2_en_2,cmd3_en_1,cmd3_en_2;
reg signed [63:0] out0_0,out0_1,out0_2,out1_0,out1_1,out1_2,out2_2,out3_2,acc_cmd2,acc_cmd1;
reg signed [6:0]  h0_0,h0_1;
 
//Generating enables for each command type
assign cmd0_en_0 = (cmd0 == 2'd0) && push0;
assign cmd1_en_0 = (cmd0 == 2'd1) && push0;
assign cmd2_en_0 = (cmd0 == 2'd2) && push0;
assign cmd3_en_0 = (cmd0 == 2'd3) && push0;

//Propogating cmd, cmd enables, push signals to all pipeline stages
always @(posedge(clk) or posedge(rst))
	if(rst) begin
	 cmd0_en_1   <= #1 1'b0;
	 cmd1_en_1   <= #1 1'b0;
	 cmd2_en_1   <= #1 1'b0;
	 cmd3_en_1   <= #1 1'b0;
	 cmd0_en_2_d <= #1 1'b0;
	 cmd1_en_2_d <= #1 1'b0;
	 push0_0     <= #1 1'b0;
	 push0_1     <= #1 1'b0;
	 push0_2     <= #1 1'b0;
	 cmd0_0      <= #1 2'd0;
	 cmd0_1      <= #1 2'd0;
	 cmd0_2      <= #1 2'd0;
	end
	else begin
	 cmd0_en_1   <= #1 cmd0_en_0;
	 cmd1_en_1   <= #1 cmd1_en_0;
	 cmd2_en_1   <= #1 cmd2_en_0;
	 cmd3_en_1   <= #1 cmd3_en_0;
	 cmd0_en_2   <= #1 cmd0_en_1;
	 cmd1_en_2   <= #1 cmd1_en_1;
	 cmd2_en_2   <= #1 cmd2_en_1;
	 cmd3_en_2   <= #1 cmd3_en_1;
	 cmd0_en_2_d <= #1 cmd0_en_2;
	 cmd1_en_2_d <= #1 cmd1_en_2;
	 push0_0     <= #1 push0;
	 push0_1     <= #1 push0_0;
	 push0_2     <= #1 push0_1;
	 cmd0_0      <= #1 cmd0;
	 cmd0_1      <= #1 cmd0_0;
	 cmd0_2      <= #1 cmd0_1;
	end

//Pipelining the cmd0 - 3 Stages
always @(posedge(clk) or posedge(rst))
begin
	if(rst) begin
		out0_0 <= #1 63'd0;
		out0_1 <= #1 63'd0;
		out0_2 <= #1 63'd0;
	end
	else begin
		out0_0 <= #1 q0*h0;
		out0_1 <= #1 out0_0;
		 if(cmd0_en_2 == 1'b1) begin
			out0_2 <= #1 out0_1;
		 end
	end
end

//Pulse generated to detect previous cmd

assign cmd1_en_2_pulse = (cmd1_en_2 == 1'b1) && (cmd1_en_2_d == 1'b0);

//Logic to take data from cmd0 or from accumulator

always @ (*)
begin
	if(cmd1_en_2_pulse == 1'b1) begin
		if(cmd0_en_2_d == 1'b1) begin
			acc_cmd1 = out0_2;
		end
		else begin
			acc_cmd1 = acc;
		end
	end
	else begin
		acc_cmd1 = out1_2;
	end
end

//Pipelining Multiply & Accumulate - 3 Stages - cmd1

always @(posedge(clk) or posedge(rst))
begin
	if(rst) begin
		out1_0 <= #1 63'd0;
		out1_1 <= #1 63'd0;
		out1_2 <= #1 63'd0;
	end
	else begin
			out1_0 <= #1 q0*h0;
			out1_1 <= #1 out1_0;
		  if(cmd1_en_2 == 1'b1) begin
			out1_2 <= out1_1 + acc_cmd1;
		end
	end
end

//Logic to take output from cmd1 or accumulator
always @ (*)
begin
	if(cmd2_en_2 == 1'b1) begin
		if(cmd0_en_2_d == 1'b1) begin
			acc_cmd2 = out0_2;
		end
		else if(cmd1_en_2_d==1'b1) begin
			acc_cmd2 = out1_2;
		end
		else begin
			acc_cmd2 = acc;
		end
	end
	else begin
		acc_cmd2 = 64'd0;
	end
end

//Pipelining the shift factor for cmd2
always @(posedge(clk) or posedge(rst))
begin
	if(rst) begin
		h0_0   <= #1 7'd0;
		h0_1   <= #1 7'd0;
		out2_2 <= #1 64'd0;
	end
	else begin
		if(cmd2_en_0 == 1'b1) begin
			h0_0 <= #1 h0[6:0];
		end

		if(cmd2_en_1 == 1'b1) begin
			h0_1 <= #1 h0_0;
		end

		if(cmd2_en_2 == 1'b1) begin
			{out2_2,roundit} <= #1 {acc_cmd2,1'b0} >>> h0_1[6:0];
		end
	end
end

always @(*) begin
	q0_d = q0;
	h0_d = h0;
	acc_d = acc;
	dout_d = dout;
	_pushout_d=0;
	if(pushin) begin
		q0_d = q;
		h0_d = h;
	end
	if(push0_2) begin
		case(cmd0_2)
			0: begin
					acc_d = out0_2;
				end
			1: begin
					acc_d = out1_2;
				end
			2: begin
					acc_d = out2_2 + ((roundit)?64'b1:64'b0);
				end
			3: begin
					dout_d = acc[31:0];
					acc_d = 0;
					_pushout_d=1;
				end
		endcase
	end
end

assign pushout = _pushout;
assign z = dout;

//Registering input and output signals
always @(posedge(clk) or posedge(rst))
	if(rst) begin
		push0 <= #1 0;
		acc <= #1 0;
		q0 <= #1 0;
		h0 <= #1 0;
		dout <= #1 0;
		cmd0 <= #1 0;
		_pushout <= #1 0;
	end else begin
		push0 <= #1 pushin;
		cmd0 <= #1 cmd;
		acc <= #1 acc_d;
		q0 <= #1 q0_d;
		h0 <= #1 h0_d;
		dout <= #1 dout_d;
		_pushout <= #1 _pushout_d;
	end

endmodule
