module counter (clock, in, load, dec, zero);
 input       clock;
 input [3:0] in;
 input       load;
 input       dec;
 output      zero;
 reg   [3:0] value;
 wire        zero;
 assign zero = ~|value;
 always @ (posedge clock)
  begin
   if (load) value <= in;
   else if (dec && !zero) value <= value - 1'b1;
end
endmodule