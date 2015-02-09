////////////
//Counter //
////////////
module counter (
  tci ai
  
);

  reg [7:0] A_tccra=8'h24;
  reg [7:0] A_tccra1=8'h44;
  reg [7:0] A_tccrb=8'h25;
  reg [7:0] A_tccrb1=8'h45;
  reg [7:0] A_ocra=8'h27;
  reg [7:0] A_ocra1=8'h47;
  reg [7:0] A_ocrb=8'h28;
  reg [7:0] A_ocrb1=8'h48;
  reg [7:0] A_tcnt=8'h26;
  reg [7:0] A_tcnt1=8'h46;
  reg [7:0] A_timsk=8'h6e;
  reg [7:0] A_tifr=8'h15;
  reg [7:0] A_tifr1=8'h35;

always @(posedge(ai.clk)or posedge(ai.rst))



endmodule