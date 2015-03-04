module Problem_2 (Y1, Y2, A, B, C, D);
 output Y1, Y2;
 input A, B, C, D;
 not (A_not, A);
 not (B_not, B);
 not (C_not, C);
 not (D_not, D);
 and (w4, A_not, B, C_not, D_not);
 and (w5, A_not, B, C_not, D);
 and (w6, A_not, B, C, D_not);
and (w7, A_not, B, C, D);
 and (w11, A, B_not, C, D);
 and (w12, A, B, C_not, D_not);
 and (w13, A, B, C_not, D);
 or  (Y1, w4, w5, w6, w7, w11, w12, w13);
 and (w1, A_not, B_not, C_not, D);
 and (w2, A_not, B_not, C, D_not);
 or  (Y2, w1, w2, w4, w5);
endmodule

module t_Problem_2();
 reg A, B, C, D;
 wire Y1, Y2;
 Problem_2 M0 (Y1, Y2, A, B, C, D);
 initial begin
   #5 {A, B, C, D} = 4'b0000;
   #5 {A, B, C, D} = 4'b0001;
   #5 {A, B, C, D} = 4'b0010;
   #5 {A, B, C, D} = 4'b0011;
   #5 {A, B, C, D} = 4'b0100;
   #5 {A, B, C, D} = 4'b0101;
   #5 {A, B, C, D} = 4'b0110;
   #5 {A, B, C, D} = 4'b0111;
   #5 {A, B, C, D} = 4'b1000;
   #5 {A, B, C, D} = 4'b1001;
   #5 {A, B, C, D} = 4'b1010;
   #5 {A, B, C, D} = 4'b1011;
   #5 {A, B, C, D} = 4'b1100;
   #5 {A, B, C, D} = 4'b1101;
   #5 {A, B, C, D} = 4'b1110;
   #5 {A, B, C, D} = 4'b1111;
 end
 initial begin
   #100 $finish;
 end
initial
begin
#5; 
$dumpfile("problem_2.vcd");
$dumpvars(0,t_Problem_2);
end
endmodule
