//
// This is a simple 5th order polynominal for ee287 systhesis and speedup work
// Copyright Morris Jones
// Spring 2014 HW
//
`timescale 1ns/10ps

module poly5(clk,rst,pushin,opin,datain,pushout,dataout);
  input clk,rst,pushin;
  input [3:0] opin;
  input [31:0] datain;
  output pushout;
  output [31:0] dataout;
  reg [31:0] a0,a1,a2,a3,a4,a5;
  reg [31:0] x;
  reg pushdata;
  reg [31:0] res;
  reg [31:0] resq;
  reg pushdataq;
  reg [31:0] t1,t2,t3,t4,t5,t6,t7,t8,t9;
  
  function [31:0] mf;
    input [31:0] a;
    input [31:0] b;
    reg [31:0] aw,bw;
    reg [63:0] z;
    reg sa,sb;
  begin
    if(a[31]) begin
      sa=1;
      aw=-a;
    end else begin
      sa=0;
      aw=a;
    end
    if(b[31]) begin
      sb=1;
      bw=-b;
    end else begin
      sb=0;
      bw=b;
    end
    z=aw*bw;
    //$display("aw %h\nbw %h\nz %h",aw,bw,z);
    if(sa^sb) z=-z;
    mf = z[47:16];
  end
  endfunction
    
  always @(posedge(clk) or posedge(rst)) begin
    if(rst) begin
      a0<=# 0.2 32'h00010000;
      a1<=# 0.2 32'h00010000;
      a2<=# 0.2 32'h00010000;
      a3<=# 0.2 32'h00010000;
      a4<=# 0.2 32'h00010000;
      a5<=# 0.2 32'h00010000;
      x <=# 0.2 0;
      pushdataq<= # 0.2 0;
      resq<=# 0.2 0;
    end else begin
      if(pushin) case(opin)
        0: a0<= #1 datain;
        1: a1<= #1 datain;
        2: a2<= #1 datain;
        3: a3<= #1 datain;
        4: a4<= #1 datain;
        5: a5<= #1 datain;
        15: begin
          x<= #1 datain;
        end
      endcase
      pushdata <= #1 pushin & (opin==15);
      pushdataq <= #1 pushdata;
      resq <= #1 res;
    end
  end
  
  always @(*) begin
    t1=mf(x,x);
    t2=mf(t1,x);
    t3=mf(t2,x);
    t4=mf(t3,x);
    t5=mf(a5,t4);
    t6=mf(a4,t3);
    t7=mf(a3,t2);
    t8=mf(a2,t1);
    t9=mf(a1,x);
    res = t5+t6+t7+t8+t9+a0;
  end
  
  assign dataout=resq;
  assign pushout=pushdataq;
  



endmodule

