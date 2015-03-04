`timescale 1ns/10ps
module delay_mux (y, Sel, A, B, C, D);
   input A, B, C, D, Sel;
   output y;
   wire Out1, Out2;
   nand #3 M1(Out1, A, B);
   nand #4 M2(Out2, C, D);
   mux M3(y, Out1, Out2, Sel);
endmodule
//module mux(y, y1, y2, Sel);
  // input y1, y2, Sel;
  // output y;
  // wire w1, w2;
  // or M1(w1, y1, Sel);
  // or M2(w2, y2, Sel);
  // nand M3(y, w1, w1);
//endmodule
module t_delay_mux ();
   reg A, B, C, D, Sel;
   wire y;
   delay_mux M0(y, Sel, A, B, C, D);
   initial
      $monitor($time,,"A=%b, B=%b, C=%b, D=%b, Sel=%b, y=%b", A, B,
      C, D, Sel, y);
   initial begin
      $dumpfile("delay_mux.vcd");
      $dumpvars(0,t_delay_mux);
   end
   initial begin
      #150 $finish;
   end
   initial begin
      #10 A=0; B=0; C=0; D=0; Sel=0;
      #10 A=0; B=0; C=0; D=0; Sel=1;
      #10 A=1; B=0; C=0; D=0; Sel=0;
      #10 A=1; B=0; C=0; D=0; Sel=1;
      #10 A=0; B=1; C=0; D=0; Sel=0;
      #10 A=0; B=1; C=0; D=0; Sel=1;
      #10 A=1; B=1; C=0; D=0; Sel=0;
      #10 A=1; B=1; C=0; D=0; Sel=1;
      #10 A=0; B=0; C=1; D=0; Sel=0;
      #10 A=0; B=0; C=1; D=0; Sel=1;
      #10 A=0; B=0; C=0; D=1; Sel=0;
      #10 A=0; B=0; C=0; D=1; Sel=1;
   end
endmodule
