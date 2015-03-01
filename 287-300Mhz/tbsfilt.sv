// This is a simple testbench for the serial filter (sfilt.v)
//
//
`timescale 1ns/10ps
// Generated on Sun Mar  1 00:03:17 2015/n// Gate level simulation test bench only
// Generated for student
//    Prem Bharath Soundararajan 0694

// cmd codes
// 0 = first mult
// 1 = mult-accumulate
// 2 = shift right by h[6:0] and round
// 3 = send output and clear

module tbsfilt();
reg clk,rst,pushin;
reg [1:0] cmd;
integer q,h;
wire pushout;
wire [31:0] z;
reg [31:0] expected[$];
reg [31:0] expr;
reg signed [63:0] acc;

reg debug=0;
default clocking clk1 @(posedge(clk));

endclocking

class mkfv;
  rand integer q,h;
  rand reg [1:0] dly ;
endclass

class tst;
  mkfv mk;
  rand reg [10:0] numtodo;
  bit withround;
  rand integer roundamt;
  reg withResult;
  reg roundbit;
  
  constraint roundsize { roundamt >0 && roundamt < 63; }
  constraint numlimit { numtodo > 0 && numtodo < 512; }
  
  function new();
    begin
      mk = new();
    end
  endfunction
  task setqh(input reg [1:0] cx);
   begin
    mk.randomize();
    case(cx)
      0: acc=mk.q*mk.h;
      1: acc=acc+mk.q*mk.h;
      2: begin
          {acc,roundbit} = {acc,1'b0} >>> roundamt;
          acc = acc+roundbit;
         end
      3: begin
          acc=0;
         end
    endcase
    cmd= #1 cx;
    q= #1 mk.q;
    h=#1 (cx==2)?roundamt:mk.h;
    pushin=#1 1;
    ##1;
    pushin=#1 0;
    randcase
      75: mk.dly=0;
      10: mk.dly=1;
      10: mk.dly=2;
      3:  mk.dly=3;
      2:  mk.dly=5;
    endcase
    repeat(mk.dly) ##1;
   end
  endtask
  task make1test();
    randomize();
    setqh(0);
    repeat(numtodo-1) begin
      setqh(1);
    end
    randcase
      75: withround=1;
      25:  withround=0;
    endcase
    if(withround) begin
      setqh(2);
    end
    randcase 
      95: withResult=1;
       5: withResult=0;
    endcase
    if(withResult) begin
      expected.push_back(acc[31:0]);
      setqh(3);
    end
  endtask
endclass

tst t1=new();

task doatest;
  t1.make1test();
begin

end
endtask


initial begin
  if(debug) begin
    $dumpfile("sfilt.vcd");
    $dumpvars(9,tbsfilt);
  end
  clk=1;
  cmd=0;
  q=0;
  h=0;
  pushin=0;
  forever #4.125 clk=~clk; // calc clock
end


task death(input string s);
  begin
    $display("\n\n\n=-=-=-=-=-=-=-=-ERROR-=-=-=-=-=-=-=-=-=-=-=-=-=-");
    $display(s);
    $display("=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\n\n\n");
    #10;
    $finish;
  end
endtask

always @(posedge(clk)) begin
   #0.7;
   if( ! rst) begin
     if(pushout===1'bx) begin
       death("Pushout is an 'X'");
     end
     if(pushout===1) begin
       if(expected.size() < 1) begin
         death("You pushed when I wasn't expecting any output");
       end
       expr = expected.pop_front();
       if(expr !== z) begin
         $display("\n\n\n Expecting %h got %h",expr,z);
         death("Results error");
       end
     end
   end
   
end

initial begin
  rst=1;
  ##3;
  #1 rst=0;
  ##2;
  repeat(50) doatest;
  ##20;
  if(expected.size() > 0) begin
    death("Test finished, and you didn't push everything");
  end
  $display("\n\n\nWe passed the test, happy happy :)\n\n\n");
  $finish;
end

sfilt sf(clk,rst,pushin,cmd,q,h,pushout,z);



endmodule
