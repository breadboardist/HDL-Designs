`timescale 1ns/10ps
module tmulti();
  reg clock, reset, start;
  reg signed [31:0] mlier, mcand;
  wire signed [63:0] prodt;
  wire valid;

  reg debug = 1;

  reg[5:0] cnt = 1;

  initial begin
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
      cnt = 1;
    end

  always @(posedge valid) begin
    $display("clocks:%d ::: %d x %d = %d",cnt, mlier, mcand, prodt);
  end

  initial begin

	repeat (10)@(posedge clock)
    	begin
    		start = 1;
    		mlier =$random;
    		mcand =$random;
    		#(4.0*33);
    		start=0;
    	end

    #(500*2);
    $finish;
  end

  multi multi(clock, reset, mlier, mcand, prodt, start, valid);

endmodule
