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
reg push0;
reg _pushout,_pushout_d;
reg [1:0] cmd0;
reg roundit;

assign pushout = _pushout;
assign z = dout;

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
  if(push0) begin
    case(cmd0)
      0: begin
           acc_d = q0*h0;
         end
      1: begin
           acc_d = q0*h0+acc;
         end
      2: begin
           {acc_d,roundit} = {acc,1'b0} >>> h0[6:0];
           acc_d = acc_d + ((roundit)?64'b1:64'b0);
         end
      3: begin
           dout_d = acc[31:0];
           acc_d = 0;
           _pushout_d=1;
         end
    endcase
  end
end

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
	
