module sqrt64(clk, rdy, reset, x, acc);
   input  clk;
   output rdy;
   input  reset;

   input [63:0] x;
   output [31:0] acc;


   // acc holds the accumulated result, and acc2 is the accumulated
   // square of the accumulated result.
   reg [31:0] acc;
   reg [63:0] acc2;

   // Keep track of which bit I'm working on.
   reg [5:0]  bitl;
   reg [31:0] bitm;
   //assign bitm = 1 << bitl;
   reg [63:0] bit2;
   //assign bit2 = 1 << (bitl << 1);

   // The output is ready when the bitl counter underflows.
   reg rdy;
   //assign rdy = bitl[5];

   // guess holds the potential next values for acc, and guess2 holds
   // the square of that guess. The guess2 calculation is a little bit
   // subtle. The idea is that:
   //
   //      guess2 = (acc + bit) * (acc + bit)
   //             = (acc * acc) + 2*acc*bit + bit*bit
   //             = acc2 + 2*acc*bit + bit2
   //             = acc2 + 2 * (acc<<bitl) + bit
   //
   // This works out using shifts because bit and bit2 are known to
   // have only a single bit in them.
   reg [31:0] guess;
   //assign guess = acc | bitm;
   reg [63:0] guess2;
   //assign guess2 = acc2 + bit2 + ((acc << bitl) << 1);

   always @(*)
   begin
      bitm = 1 << bitl;
      bit2 = 1 << (bitl << 1);
      rdy = bitl[5];
      guess = acc | bitm;
      guess2 = acc2 + bit2 + ((acc << bitl) << 1);
   end

   always @(posedge reset or posedge clk)
   begin
      if (reset) begin
       acc <= 0;
       acc2 <= 0;
       bitl <= 31;
      end
      else begin
	     if (guess2 <= x) begin
	        acc  <= guess;
	        acc2 <= guess2;
	     end
	     bitl <= bitl - 1;
      end
   end
endmodule

/////////////////////////
//Testbench for sqrt64 //
/////////////////////////

module main;
   reg clk, reset;
   reg [63:0] value;
   wire [31:0] result;
   wire rdy;
   sqrt64 root(.clk(clk), .rdy(rdy), .reset(reset), .x(value), .acc(result));
   always #4 clk = ~clk;
   always @(posedge rdy) begin
      $display("sqrt(%d) --> %d", value, result);
      $finish;
   end
initial begin
$dumpfile("sqrt64dump.vcd");
$dumpvars(0, main);
end
   initial begin
      clk = 0;
      reset = 1;
      $monitor($time,,"%m.acc = %b", root.acc);
      #100 value =64'd1231231231314096;
      reset = 0;
   end
endmodule /* main */
