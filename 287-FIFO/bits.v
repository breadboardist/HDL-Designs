`timescale 1ns/10ps
module bits (
	input clk,
	input rst,
	input pushin,
	input [31:0] datain,
	input reqin,
	input [3:0] reqlen,
	output pushout,
	output [3:0] lenout,
	output [14:0] dataout
		
);

reg pushout;

always @(posedge (clk))
	begin
		pushout<=0;
	end


endmodule