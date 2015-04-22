`timescale 1ns/10ps
// tb code

module tmulti();
  reg clock, reset, start;
  reg [31:0] mlier, mcand;
  wire [63:0] prodt;
  wire valid;

  reg debug = 1 ;

  initial begin
    if(debug) begin
      $dumpfile("multi.vcd");
      $dumpvars(9,tmulti);
    end
    clock=0;
    forever #2.0 clock=~clock; 
  end
  initial begin
    reset=0;
    #2.0;
    reset=1;
    start=0;
    mlier=0; 
    mcand=0;
    #9.0;

    reset=0;
    #2.5;
    start=1;
    mlier=32'h8;
    mcand=32'h00012345; 
    #(4.0*33);
    start=0;
    #4.0;

    start=1;
    mlier=32'h2; 
    mcand=32'h000fffff;
    #(4.0*33);
    start=0;
    #4.0;

    start=1;
    mlier=32'h4; 
    mcand=32'h000fffff;
    #(4.0*33);
    start=0;
    #4.0;

    start=1;
    mlier=32'h8; 
    mcand=32'h000fffff;
    #(4.0*33);
    start=0;
    #4.0;

    start=1;
    mlier=32'h1; 
    mcand=32'h00012345;
    #(4.0*33);
    start=0;
    #4.0;

    start=1;
    mlier=32'h0; 
    mcand=32'h00012345;
    #(4.0*33);
    start=0;

    mlier=0; 
    mcand=0;


    #(500*2);

    $finish;
  end

  multi multi(clock, reset, mlier, mcand, prodt, start, valid);

endmodule
