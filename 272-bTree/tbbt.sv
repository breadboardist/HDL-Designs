`timescale 1ns/10ps
// This is a simple driver for a binary tree sort problem used in EE272
`include "btclass.sv"

module testbench;

btclass bthead;
btclass wk;

initial begin
  bthead= new($random);
  //$display("Head=%d",bthead.value);
  repeat(100) begin
    wk = new($random);
    bthead.add(wk);
    // $display("\n Val=%d",wk.value);
    // $display("\n lpt=%d",bthead.lpt);
    // $display("\n gpt=%d",bthead.gpt);
  end
  $display("\n\n-------  Ascending  --------");
  bthead.printascending(bthead);
  $display("\n\n-------  Descending --------");
  bthead.printdescending();
  $display("All done");
  $finish;
end
endmodule




