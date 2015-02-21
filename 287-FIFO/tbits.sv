// A simple test bench for the bits assignment
//
`timescale 1ns/10ps

module test;

reg clk,rst,pushin;
reg [31:0] datain;
reg reqin;
reg [3:0] reqlen;
wire pushout;
wire [3:0] lenout;
wire [14:0] dataout;

reg pushout0;
reg [3:0] lenout0;
reg [14:0] dataout0;
reg draining;
reg filling;
int bitsleft;

reg running=0;

reg debug=1;

default clocking tclk @(posedge(clk)) ;
  
endclocking

typedef struct {
	reg[3:0] len;
	reg[14:0] data;
} sexp;

sexp fexp[$];

sexp exp;

task death(input string s);
  begin
    $display();
    $display();
    $display(s);
    $display();
    $display();
    $error(":-( :-( :-( ended with error");
    $display();
    $display();
    $finish;
  end
endtask

class rt;

rand reg Xpushin;
rand reg [31:0] Xdatain;
rand reg Xreqin;
rand reg [3:0] Xreqlen;
rand reg [8:0] Xdrain;
rand reg [8:0] Xfill;

reg [14:0] expdata;

reg [31*32-1:0] wk;

constraint c1 {
  Xpushin dist {
    0 := 20-19*filling,
    1 := 3  
  };
}
constraint c2 {
  Xreqlen <= bitsleft;
}


function new();
  begin
    bitsleft=0;
    wk=0;
    draining=0;
    filling=0;
  end
endfunction


task apply;
integer ix;
sexp se;
  begin
    if( bitsleft > (30*32-1) ) begin
      Xpushin=0;
    end
    if(bitsleft < Xreqlen) begin
      Xreqin=0;
    end
    if(filling) begin
      if(bitsleft < 29*32) Xreqin=0; else filling=0;
    end else if(draining) begin
      if(bitsleft > 0) Xpushin=0;
      if(bitsleft == 0) draining=0;
    end else begin
      if( Xdrain == 123 ) draining=1;
      else if(Xfill == 123) filling=1;
    end
    ##1 #1;
    pushin = Xpushin;
    datain = Xdatain;
    reqin = Xreqin;
    reqlen = Xreqlen;
    if(Xpushin) begin
      for(ix=bitsleft; ix < bitsleft+32; ix=ix+1) wk[ix]=Xdatain[ix-bitsleft];
//      wk[bitsleft+31:bitsleft]=Xdatain;
      bitsleft += 32;
      if(debug) $display("Pushing %08h",Xdatain);
    end
    if(Xreqin) begin
      expdata=wk[14:0];
      expdata &= ~(16'hffff << Xreqlen);
      se.len = Xreqlen;
      se.data=expdata;
      if(debug) $display("requesting %d bits, expecting %04h",Xreqlen,expdata);
      fexp.push_back(se);
      bitsleft -= Xreqlen;
      wk = wk >> Xreqlen;
    end
  end
endtask

task alldone;
begin
  if(fexp.size() > 0) begin
    death("You did not push out the last request within 20 clocks");
    $finish;
  end
end
endtask

endclass

rt t=new();

bits b(clk,rst,pushin, datain, reqin, reqlen, pushout, lenout, dataout);

initial begin
clk=0;
forever #5.0 clk=~clk;
end

initial begin
  #1;
  if(debug) begin
    $dumpfile("bits.vcd");
    $dumpvars(9,test);
  end
end

initial begin
rst=0;
pushin=0;
datain=0;
reqin=0;
reqlen=0;
##1 #1;
rst=1;
##5 #1;
rst=0;
##1 ;
running=1;
repeat(50000) begin
  t.randomize;
  t.apply;
end
##1 #1;
pushin=0;
reqin=0;
##20 #1;
t.alldone;
$display();
$display();
$display("all done with a smile");
$display();
$display();
$finish();
end

always @(posedge(clk)) begin
  if(running) begin
    pushout0=pushout;
    lenout0=lenout;
    dataout0=dataout;
    #0.02;
    if(pushout0 !== pushout) death("No hold time on pushout");
    if(lenout0 !== lenout) death("No hold time on lenout");
    if(dataout0 !== dataout) death("no hold time on dataout");
    if(pushout !== 0 && pushout !==1) death("X or Z on pushout");
    if(pushout) begin
      if(fexp.size() < 1) death("You pushed, and I am not expecting anything");
      exp = fexp.pop_front();
      if(lenout !== exp.len) begin
        $display();
        $display();
        $display("Length error --- Recv %h Exp %h",lenout,exp.len);
        death("length received in error");
      end
      if(dataout !== exp.data) begin
        $display();
        $display();
        $display("Data error --- Recv %h Exp %h",dataout,exp.data);
        death("Data received error");
      end
    end
  end
end



endmodule
