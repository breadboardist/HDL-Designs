module tr_latch (q_out, enable, data);
 output q_out;
 input enable, data;
 reg q_out;
 always @ (enable or data) begin
  if (enable) q_out = data;
 end
endmodule
module t_tr_latch ();
 wire q_out;
 reg enable, data;
 tr_latch M0 (q_out, enable, data);
 initial fork
  #3 data = 0;
  #5 forever #2 data = ~data;
  #30 data = 0;
 join
 initial fork
  #10 enable = 0;
  #20 enable = 1;
  #40 enable = 0;
join
 initial #100 $finish;
endmodule
