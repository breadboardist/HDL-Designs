`timescale 1ns/10ps
module tmulti();
  reg clock, reset, start;
  reg signed [31:0] mlier, mcand;
  wire signed [63:0] prodt;
  wire valid;
  reg signed [63:0] ex_prodt;
  reg [4:0] i,j;
  reg debug = 1;

  reg[5:0] cnt = 1;

  initial begin
    i = 1;
    j = 0;
    if(debug) begin
      $dumpfile("multi.vcd");
      $dumpvars(9,tmulti);
    end
    clock=0;
    forever #2.0 clock=~clock;
  end

  always @(posedge clock) begin
    cnt = cnt +1;
  end

  always @(posedge start)
    begin
      ex_prodt = mlier * mcand;
      $display("\t\t  Expected answer = %h",ex_prodt);
      cnt = 1;
    end

  always @(posedge valid) begin
      $display("clocks:%d ::: %h x %h = %h",cnt, mlier, mcand, prodt);
      j=j+1;
      if (ex_prodt==prodt) begin $display("--------------Correct answer computed[%d/%d]------------",i,j); i=i+1; end      
  end

  multi multi(clock, reset, mlier, mcand, prodt, start, valid);

  initial begin
    reset=0;
    #2.0;
    reset=1;
    start=0;
    mlier=0;
    mcand=0;
    #9.0;
    reset=0;

    repeat (20) begin
      start = 1;
      mlier = $random%32'hfffffff;
      mcand = $random%32'hfffffff;
      #(4.0*33) start = 0;
      #4.0;
    end

    #1500 $finish;

  end

endmodule
