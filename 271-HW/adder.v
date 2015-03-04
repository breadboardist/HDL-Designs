module Add_full (sum, c_out, a, b, c_in);
   output sum, c_out;
   input a, b, c_in;
   wire w1, w2, w3;
   Add_half M1 (w1, w2, a, b);
   Add_half M2 (sum, w3, w1, c_in);
   or #1 M3 (c_out, w2, w3);
endmodule
module Add_half (sum, c_out, a, b);
   output sum, c_out;
   input a,b;
   xor #1 M1 (sum, a, b);
   and #1 M2 (c_out, a, b);
endmodule
module t_Adder();
   wire sum, c_out;
   reg a, b, c_in;
   Add_full M0 (sum, c_out, a, b, c_in);
   initial begin
      $dumpfile("adder.vcd");
      $dumpvars(0,t_Adder);
   end
   initial
      $monitor($time,,"a=%b, b=%b, c_in=%b, sum=%b, c_out=%b", a, b,
      c_in, sum, c_out);
   initial begin
      #100 $finish;
   end
   initial begin
      #10 a=0; b=0; c_in=0;
      #10 a=0; b=0; c_in=1;
      #10 a=0; b=1; c_in=0;
      #10 a=0; b=1; c_in=1;
      #10 a=1; b=0; c_in=0;
      #10 a=1; b=0; c_in=1;
      #10 a=1; b=1; c_in=0;
      #10 a=1; b=1; c_in=1;
   end
endmodule