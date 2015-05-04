`timescale 1ns/10ps

module serial_scan_testbench();

reg clk,rst,pushin;
reg [31:0] datain;
reg reqin;
reg [3:0] reqlen;
wire pushout;
reg scanIn, scanEnable, scanOut;
wire [3:0] lenout;
wire [14:0] dataout;

bits b (clk, rst, pushin, datain, reqin, reqlen, pushout, scanIn, scanEnable, scanOut, lenout, dataout);

 always
 #5 clk = ~clk;
 
initial begin
  //Reset the system
  rst=0;
  pushin=0;
  datain=0;
  clk = 1;
  scanIn =0;
  scanEnable = 0;
  #5 rst = 1;
  #5 rst = 0;
  //Done resetting
  pushin = 1;
  //Enable scan for scanning into the design
  #30 scanEnable = 1;
  scanIn = 1;
  #10 scanIn = 0;
  #10 scanIn = 1;
  #10 scanIn = 1;
  #10 scanIn = 1;
  #10 scanEnable = 0; scanIn = 0;
  //Waiting for one clock before reading out through scanOut
  #10 scanEnable = 1;
  #50 scanEnable = 0; //Wait for all bits to be scanned out
  #500 $finish;
 end 

initial begin
    $dumpfile("serial.vcd");
    $dumpvars;
  end
endmodule
