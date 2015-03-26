module compare (A_gt_B, A_lt_B, A_eq_B, A0, A1, B0, B1); 
	output A_gt_B, A_lt_B, A_eq_B;
	input A0, A1, B0, B1;
	nor (A_gt_B, A_lt_B, A_eq_B); or (A_lt_B, w1, w2, w3); and (A_eq_B, w4, w5);
	and (w1, w6, B1);
	and (w2, w6, w7, B0); and (w3, w7, B0, B1); not (w6, A1);
	not (w7, A0);
	xnor (w4, A1, B1);
	xnor (w5, A0, B0); 
endmodule

module test_compare ( );
  wire A_gt_B, A_lt_B, A_eq_B;
  reg  A0, A1, B0, B1;
  compare M1 (A_gt_B, A_lt_B, A_eq_B, A0, A1, B0, B1);
  initial begin
    #100 $finish;
  end
  initial begin
    #10 A0 = 0; A1 = 0; B0 = 0; B1 = 0;
    #10 A0 = 1'b1;
    #10 A0 = 1'b0; A1 = 1'b1;
    #10 A0 = 1'b1;
    #10 B0 = 1'b1;
    #10 B0 = 1'b0; B1 = 1'b1;
    #10 B0 = 1'b1;
    #10 A0 = 0; A1 = 0;
	#10 B0 = 1'b0;
    #10 B0 = 1'b1; B1 = 1'b0;
    #10 B0 = 1'b0;
  end
  initial begin
  	$dumpfile("compare.vcd");
  	$dumpvars(0,test_compare);
  end
endmodule