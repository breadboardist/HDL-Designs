module bits (
	input clk,
	input rst,
	input pushin,
	input [31:0] datain,
	input reqin,
	input reqlen,
	output pushout,
	output lenout,
	output dataout
		
);

reg pushout;

always @(posedge (clk))
	begin
		pushout<=0;
	end


endmodule