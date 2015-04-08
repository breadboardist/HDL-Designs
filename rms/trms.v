//
// A simple and fun test bench for the easy rms mechanism
//
`timescale 1ns/10ps


module trms();

reg clk,rst;
reg pushin;
integer X;
integer N;
reg [63:0] X2,avg;
reg [71:0] sum=0;
integer tnum=0;
reg [1:0] cmdin;
reg pullout;
wire stopout;
reg s0,s0d;
wire [31:0] Xout;
reg [31:0] Xo0,Xo0d;
reg [31:0] Xin,Xres;
reg [31:0] fexp[0:255];
reg [7:0] he,te;
integer watchdog=400;
reg bad=0;
integer numOut=0;



reg debug=0;

rms r(clk,rst,pushin,cmdin,Xin,pullout,stopout,Xout);

function [31:0] mabs;
input [31:0] iv;
reg [31:0] wk;
begin
  wk=iv;
  wk[31]=0;
  mabs=wk;
end
endfunction


initial begin
  clk=0;
  #10;
  forever #5 clk=~clk;
end

// A really hard to do in gates square root algorithm...
// DONT USE THIS ONE...  If you copy me, you could get 0 on the assignment
// Find a better one
//

function [31:0] sqrt;
input [63:0] vorig;
reg [63:0] xk,xk1,xkp1,xkt;
reg keepgoing;
integer sanity;
begin
  xk=vorig;
  sanity=0;
  keepgoing=(vorig==0)?0:1;
  while(keepgoing && (sanity < 5000) ) begin
    xkp1= (xk+vorig/xk)/2;
    if(xkp1==xk) keepgoing=0;
    xk=xkp1;
    sanity=sanity+1;
  end
  xk1=xk+1;
  xkt = xk1*xk1;
  if(xkt <= vorig) xk=xk1;
  sqrt=xk[31:0];
end
endfunction

task death;
input reg [60*8-1:0] str;
begin
  $display("");
  $display("Error  Error  Error  Error  Error");
  $display("VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV");
  while(str[60*8-1:60*8-8]==0) str=str << 8;
  $display("  %s",str);
  $display("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
  $display("Error  Error  Error  Error  Error");
  $display("");
  bad=1;
  #10;
  $finish;
end

endtask

always @(posedge(clk)) begin
  if(!rst) begin
    s0=stopout;
    Xo0=Xout;
    #0.06;
    s0d=stopout;
    Xo0d=Xout;
    if(s0 != s0d) death("No hold time on stopout");
    if(Xo0 != Xo0d) death("No hold time on Xout");
    if(s0 === 1'bx || s0 === 1'bz) death("stopout is X or Z");
    if(he != te) begin
      watchdog=watchdog-1;
      if(watchdog<1) death("Waited too long for an answer");
    end
    if(pullout==1 && stopout === 0) begin
      watchdog=400;
      if(he == te) death("You allowed a pull, and I'm not expecting anything");
      Xo0 = fexp[te];
      te=te+1;
      numOut=numOut-1;
      if(Xo0 !== Xo0d) begin
        $display("");
        $display("");
        $display("Expecting %d %16h -- Got %d %16h",Xo0,Xo0,Xo0d,Xo0d);
        death("Results error");
      end
    end
    pullout = #1 $random;
    if(numOut > 18) pullout= #1 1;
  end
end



task doatest;
integer bsize;
integer cX;
reg [31:0] wamt;
begin
  tnum=tnum+1;
  @(posedge(clk)) #1;
  if(debug) $display("(0) starting test set %4d",tnum);
  bsize=mabs($random)%255;
  while(bsize < 3 || (tnum < 20 && bsize > 30)) begin
    bsize=mabs($random)%255;
    if(tnum < 20) bsize=bsize%30;
  end
  if(debug) $display(" There will be %4d X values added",bsize);
  cX=1;
  while(cX <= bsize) begin
    X = $random;
    if(tnum < 3) X = X % 20;
    X2=X*X;
    sum=sum+X2;
    if(debug) $display("    X = %11d (0x%8h) X^2= %20d (0x%16h) sum = %20d (0x%18h)",X,X,X2,X2,sum,sum);
    if(cX==bsize) begin
      avg=sum/bsize;
      Xres=sqrt(avg);
      if(debug) $display("     avg %20d (0x%16h) result %11d (%8h)",avg,avg,Xres,Xres);
      fexp[he]=Xres;
      he=he+1;
      numOut=numOut+1;
      sum=0;     
    end
    cmdin=(cX==bsize)?3:0;
    pushin=1;
    Xin=X;
    @(posedge(clk)) #1;
    pushin=0;
    Xin=32'h01234567;
    cX=cX+1;
    wamt = (tnum<3)?15:4;
    repeat( mabs($random) % wamt ) @(posedge(clk)) #1;
  end
  if(tnum < 3) begin
    while(he != te) @(posedge(clk)) #1;
  end
end
endtask

task doatest1;
integer bsize;
integer cX;
reg [31:0] wamt;
begin
  tnum=tnum+1;
  @(posedge(clk)) #1;
  if(debug) $display("(1) starting test set %4d",tnum);
  bsize=$urandom_range(0,255);
  while(bsize < 3 || (tnum < 20 && bsize > 30)) begin
    bsize=mabs($random)%255;
    if(tnum < 20) bsize=bsize%30;
  end
  if(debug) $display(" There will be %4d X values added",bsize);
  cX=1;
  while(cX <= bsize) begin
    X = $urandom_range(0,600000);
    if($random < 0) X=-X;
    if(tnum < 3) X = X % 20;
    X2=X*X;
    sum=sum+X2;
    if(debug) $display("    X = %11d (0x%8h) X^2= %20d (0x%16h) sum = %20d (0x%18h)",X,X,X2,X2,sum,sum);
    if(1) begin
      avg=sum/cX;
      Xres=sqrt(avg);
      if(debug) $display("     avg %20d (0x%16h) result %11d (%8h)",avg,avg,Xres,Xres);
      fexp[he]=Xres;
      he=he+1;
      numOut=numOut+1;
      if(cX==bsize) sum=0;     
    end
    cmdin=(cX==bsize)?3:2;
    pushin=1;
    Xin=X;
    @(posedge(clk)) #1;
    pushin=0;
    Xin=32'h01234567;
    cX=cX+1;
    wamt = (tnum<3)?15:4;
    repeat( mabs($random) % wamt ) @(posedge(clk)) #1;
  end
end
endtask

task doatest2;
integer bsize;
integer cX;
reg [31:0] wamt;
begin
  tnum=tnum+1;
  @(posedge(clk)) #1;
  if(debug) $display("(2) starting test set %4d",tnum);
  bsize=mabs($random)%255;
  while(bsize < 3 || (tnum < 20 && bsize > 30)) begin
    bsize=mabs($random)%255;
    if(tnum < 20) bsize=bsize%30;
  end
  if(debug) $display(" There will be %4d X values added",bsize);
  cX=1;
  while(cX < bsize) begin
    X = $urandom_range(0,1000000);
    if($random < 0) X=-X;
    case($urandom_range(0,7))
      0,3,4,5: begin
           if(sum[71:64]==0) begin
             X2=X*X;
             sum=sum+X2;
             cmdin=0;      
             if(debug) $display("(0)    X = %11d (0x%8h) X^2= %20d (0x%16h) sum = %20d (0x%18h)",X,X,X2,X2,sum,sum);
           end else begin
             X2=X*X;
             sum=sum-X2;
             cmdin=1;      
             if(debug) $display("(1)    X = %11d (0x%8h) X^2= %20d (0x%16h) sum = %20d (0x%18h)",X,X,X2,X2,sum,sum);
           
           end
         end
      1: begin
           X2=X*X;
           if(cX > 0 && sum > X2) begin
             sum=sum-X2;
             cmdin=1;
    if(debug) $display("(1)    X = %11d (0x%8h) X^2= %20d (0x%16h) sum = %20d (0x%18h)",X,X,X2,X2,sum,sum);
           end else begin
             sum=sum+X2;
             cmdin=0;
    if(debug) $display("(0)    X = %11d (0x%8h) X^2= %20d (0x%16h) sum = %20d (0x%18h)",X,X,X2,X2,sum,sum);
           
           end
         end
      2,6,7: begin
           X2=X*X;
           sum=sum+X2;
           cmdin=2;
           avg=sum/cX;
           Xres=sqrt(avg);
           if(debug) $display("(2) cx %d X = %11d (0x%8h) X^2= %20d (0x%16h) sum = %20d (0x%18h)",cX,X,X,X2,X2,sum,sum);
           if(debug) $display("(2)     avg %20d (0x%16h) result %11d (%8h)",avg,avg,Xres,Xres);
           fexp[he]=Xres;
           he=he+1;
           numOut=numOut+1;
         end
    endcase
    pushin=1;
    Xin=X;
    @(posedge(clk)) #1;
    pushin=0;
    Xin=32'h01234567;
    cX=cX+((cmdin==1)?-1:1);
    repeat( $urandom_range(0,2) ) @(posedge(clk)) #1;
  end
  X= $urandom_range(0,600000);
  X2=X*X;
  sum=sum+X2;
  cmdin=3;
  avg=sum/cX;
  Xres=sqrt(avg);
  if(debug) $display("(3) cx %d X = %11d (0x%8h) X^2= %20d (0x%16h) sum = %20d (0x%18h)",cX,X,X,X2,X2,sum,sum);
  if(debug) $display("(3)     avg %20d (0x%16h) result %11d (%8h)",avg,avg,Xres,Xres);
  fexp[he]=Xres;
  he=he+1;
  numOut=numOut+1;
  pushin=1;
  Xin=X;
  @(posedge(clk)) #1;
  sum=0;
  pushin=0;
  X=32'h76543210;
  Xin=X;
end
endtask


task doatest3;
integer bsize;
integer cX;
reg [31:0] wamt;
begin
  tnum=tnum+1;
  if(debug) $display("(3) starting test set %4d",tnum);
  bsize=$urandom_range(20,255);
  if(debug) $display(" There will be %4d X values added",bsize);
  cX=1;
  while(cX <= bsize) begin
    X = $urandom_range(1000,1000000);
    if(sum[71:63] != 0) X= $urandom_range(1,10);
    if($random > 0) X=-X;
    if(debug) $display("    X = %11d (0x%8h) X^2= %20d (0x%16h) sum = %20d (0x%18h)",X,X,X2,X2,sum,sum);
    X2=X*X;
    sum=sum+X2;
    avg=sum/cX;
    Xres=sqrt(avg);
    if(debug) $display("     avg %20d (0x%16h) result %11d (%8h)",avg,avg,Xres,Xres);
    fexp[he]=Xres;
    he=he+1;
    numOut=numOut+1;
    cmdin=2;
    if(cX>=bsize) begin      
      cmdin=3;
      sum=0;
    end
    pushin=1;
    Xin=X;
    @(posedge(clk)) #1;
    pushin=0;
    Xin=32'h01234567;
    cX=cX+1;
  end
end
endtask


initial begin
  rst=0;
  pushin=0;
  pullout=0;
  Xin=32'h01234567;
  cmdin=0;
  he=0;
  te=0;
  #5;
  if(debug) begin
    $dumpfile("rms.vcd");
    $dumpvars(9,trms);
  end
  rst=1;
  repeat(5) @(posedge(clk)) #1;
  rst=0;
  repeat(mabs($random)%7+1) @(posedge(clk));
  repeat(50) doatest;
  repeat(50) doatest1;
  repeat(50) doatest2;
  repeat(50) doatest3;
  repeat(1000) @(posedge(clk));
  if(he != te) death("Not all data pulled after 1k clocks");
  $display("");
  $display("You are a wise and learned one... You passed the humble test");
  $display("");
  $finish;
end



endmodule

