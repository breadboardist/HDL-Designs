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
reg push0,push0_p0,push0_p1,push0_p2;
reg _pushout,_pushout_d;
reg [1:0] cmd0,cmd0_p0,cmd0_p1,cmd0_p2;
reg roundit;  

wire en0_p0,en1_p0,en2_p0,en3_p0;  //jj
reg en0_p1,en0_p2,en0_p2_d1;  //jj en0_p2_d1 -en0_p2 registered
reg en1_p1,en1_p2,en1_p2_d1;  //jj en1_p2_d1 -en1_p2 registered
reg en2_p1,en2_p2;  //jj
reg en3_p1,en3_p2;  //jj
reg signed [63:0] out0_p0,out0_p1,out0_p2;  //jj
reg signed [63:0] out1_p0,out1_p1,out1_p2;  //jj
reg signed [63:0] out2_p2;  //jj
reg signed [63:0] out3_p2;
reg signed [6:0]  h0_p0,h0_p1;
reg signed [63:0] acc_cmd2; //jj Accumulator value when CMD = 2 
                            //   and input for pipe stage = 2
reg signed [63:0] acc_cmd1;  //jj On Ist cycle of case 1, use acc else out1_p2 
wire en1_p2_pulse;  //jj To detect rising edge of en1_p2

// Generating Enables  //jj

assign en0_p0 = (cmd0 == 2'd0) && push0;
assign en1_p0 = (cmd0 == 2'd1) && push0;
assign en2_p0 = (cmd0 == 2'd2) && push0;
assign en3_p0 = (cmd0 == 2'd3) && push0;

always @(posedge(clk) or posedge(rst))   //jj
begin
  if(rst) begin
    cmd0_p0 <= #1 2'd0; 
    cmd0_p1 <= #1 2'd0;
    cmd0_p2 <= #1 2'd0;
    push0_p0 <= #1 1'b0; 
    push0_p1 <= #1 1'b0;
    push0_p2 <= #1 1'b0;
  end
  else begin
    cmd0_p0 <= #1 cmd0; 
    cmd0_p1 <= #1 cmd0_p0;
    cmd0_p2 <= #1 cmd0_p1;
    push0_p0 <= #1 push0; 
    push0_p1 <= #1 push0_p0;
    push0_p2 <= #1 push0_p1;
  end
end 

always @(posedge(clk) or posedge(rst))   //jj
begin
  if(rst) begin
    en0_p1 <= #1 1'b0; 
    en1_p1 <= #1 1'b0;
    en2_p1 <= #1 1'b0;
    en3_p1 <= #1 1'b0;
  end
  else begin
    en0_p1 <= #1 en0_p0; 
    en1_p1 <= #1 en1_p0;
    en2_p1 <= #1 en2_p0;
    en3_p1 <= #1 en3_p0;
  end
end 

always @(posedge(clk) or posedge(rst))   //jj
begin
  if(rst) begin
    en0_p2 <= #1 1'b0; 
    en1_p2 <= #1 1'b0;
    en2_p2 <= #1 1'b0;
    en3_p2 <= #1 1'b0;
    en0_p2_d1 <= #1 1'b0; 
    en1_p2_d1 <= #1 1'b0;
  end
  else begin
    en0_p2 <= #1 en0_p1; 
    en1_p2 <= #1 en1_p1;
    en2_p2 <= #1 en2_p1;
    en3_p2 <= #1 en3_p1;
    en0_p2_d1 <= #1 en0_p2; 
    en1_p2_d1 <= #1 en1_p2;
  end
end 


always @(posedge(clk) or posedge(rst))   //jj
begin
  if(rst) begin
    out0_p0 <= #1 63'd0; 
    out0_p1 <= #1 63'd0; 
    out0_p2 <= #1 63'd0; 
  end
  else begin
      out0_p0 <= #1 q0*h0; 

      out0_p1 <= #1 out0_p0;

    if(en0_p2 == 1'b1) begin
      out0_p2 <= #1 out0_p1;
    end
  end
end
//-----------------------------------------------------------
assign en1_p2_pulse = (en1_p2==1'b1) && (en1_p2_d1==1'b0);

always @ (*)
begin
  if(en1_p2_pulse==1'b1) begin
    if(en0_p2_d1==1'b1) begin
      acc_cmd1 = out0_p2;
    end
    else begin
      acc_cmd1 = acc;
    end
  end
  else begin
    acc_cmd1 = out1_p2; 
  end
end
//assign acc_cmd1 = (en1_p2_pulse==1'b1) ? acc : out1_p2;

always @(posedge(clk) or posedge(rst))   //jj
begin
  if(rst) begin
    out1_p0 <= #1 63'd0; 
    out1_p1 <= #1 63'd0; 
    out1_p2 <= #1 63'd0; 
  end
  else begin
      out1_p0 <= #1 q0*h0; 

      out1_p1 <= #1 out1_p0;

    if(en1_p2 == 1'b1) begin
      out1_p2 <= out1_p1 + acc_cmd1;
    end
  end
end
//-----------------------------------------------------------


// -------------------------------------------

always @ (*)
begin
  if(en2_p2==1'b1) begin
    if(en0_p2_d1==1'b1) begin
      acc_cmd2 = out0_p2;
    end
    else if(en1_p2_d1==1'b1) begin
      acc_cmd2 = out1_p2;
    end
    else begin
      acc_cmd2 = acc;
    end
  end
  else begin
    acc_cmd2 = 64'd0;
  end
end
      
always @(posedge(clk) or posedge(rst))   //jj
begin
  if(rst) begin
    h0_p0   <= #1 7'd0; 
    h0_p1   <= #1 7'd0;
    out2_p2 <= #1 64'd0; 
  end
  else begin
    if(en2_p0 == 1'b1) begin
      h0_p0 <= #1 h0[6:0]; 
    end

    if(en2_p1 == 1'b1) begin
      h0_p1 <= #1 h0_p0;
    end

    if(en2_p2 == 1'b1) begin
      {out2_p2,roundit} <= #1 {acc_cmd2,1'b0} >>> h0_p1[6:0];
    end
  end
end


assign pushout = _pushout;
assign z = dout;

//always @(*) begin
//  q0_d = q0;
//  h0_d = h0;
//  acc_d = acc;
//  dout_d = dout;
//  _pushout_d=0;
//  if(pushin) begin
//    q0_d = q;
//    h0_d = h;
//  end
//  if(push0) begin
//    case(cmd0)
//      0: begin
//           acc_d = q0*h0;
//         end
//      1: begin
//           acc_d = q0*h0+acc;
//         end
//      2: begin
//           {acc_d,roundit} = {acc,1'b0} >>> h0[6:0];
//           acc_d = acc_d + ((roundit)?64'b1:64'b0);
//         end
//      3: begin
//           dout_d = acc[31:0];
//           acc_d = 0;
//           _pushout_d=1;
//         end
//    endcase
//  end
//end
//
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
  if(push0_p2) begin
    case(cmd0_p2)
      0: begin
           acc_d = out0_p2; 
         end
      1: begin
           acc_d = out1_p2; 
         end
      2: begin
           acc_d = out2_p2 + ((roundit)?64'b1:64'b0);
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
	
