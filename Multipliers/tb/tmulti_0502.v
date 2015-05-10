// This is a simple testbench for 271hw
// Name: Zan Zhan, SJSU ID: 010057489
//
`timescale 1ns/10ps

module tmulti();

`ifdef tb_fix
parameter fix_lt = 1;
parameter vcd_name = "wave/multi_fix.vcd";
`endif

`ifdef tb_var
parameter fix_lt = 0;
parameter vcd_name = "wave/multi_var.vcd";
`endif

reg clock, reset, start;
reg [31:0] mlier, mcand;
reg [63:0] r_prodt, c_prodt; 
wire [63:0] prodt;
wire valid;

wire [31:0] q0,h0;
wire [63:0] mr1,mr2,exp;
reg  [3 :0] pt;
reg  [7 :0] t_cnt;
reg debug = 1 ;

initial begin
  if(debug) begin
    $dumpfile(vcd_name);
    $dumpvars(9,tmulti);
  end
  clock=0;
  forever #5.0 clock=~clock; 
end

initial begin
  if (fix_lt) 
  $display("\nInstance fix latency multiplier and kick off test.\n");
  else
  $display("\nInstance variable latency multiplier and kick off test.\n");

  reset=1;   start=0;   mlier=0;   mcand=0;
  #19.0;
  reset=0;
  #5.0;

  start=1;
  mlier=32'hbffffffe;  mcand=32'h7aaaaaaa; 
  #(10.0*33);
  start=0;
  #10.0;

  start=1;
  mlier=32'hbffffffe;  mcand=32'hfaaaaaaa;
  #(10.0*33);
  start=0;
  #10.0;

  start=1;
  mlier=32'h4; 
  mcand=32'h000fffff;
  #(10.0*33);
  start=0;
  #10.0;

  start=1;
  mlier=32'hfffffffe; 
  mcand=32'h8fffffee;
  #(10.0*33);
  start=0;
  #10.0;

  start=1;
  mlier=32'hefffffff;
  mcand=32'he9876543; 
  #(10.0*33);
  start=0;
  #10.0;

  start=1;
  mlier=32'h82211212; 
  mcand=32'h00012345;
  #(10.0*33);
  start=0;
  #10.0;

  start=1;
  mlier=32'h80000011; 
  mcand=32'h80012345;
  #(10.0*33);
  start=0;
  #10.0;

  start=1;
  mlier=32'h71234567; 
  mcand=32'hb0012345;
  #(10.0*33);
  start=0;
  #10.0;

  mlier=0; 
  mcand=0;


  #(500*2);
  $display("\n\n\nWe passed the test, happy :)\n\n\n");
  $finish;
end

//*****************************************************
generate
if (fix_lt) begin : fix_latency_enable
multi    multi   (clock, reset, mlier, mcand, prodt, start, valid);

end else begin    : var_latency_enable
multi_vl multi_vl(clock, reset, mlier, mcand, prodt, start, valid);
end
endgenerate
//*****************************************************

assign  q0 = (mlier[31])? (~mlier + 1'b1) : mlier;
assign  h0 = (mcand[31])? (~mcand + 1'b1) : mcand;
assign  mr1= q0*h0;
assign  mr2= ~(mr1-1'b1);
assign  exp= ((mlier[31]^mcand[31])&& (|mr1)) ? {1'b1,mr2} : {1'b0,mr1};

always @( posedge clock or posedge reset ) begin
  if (reset) begin
    pt <= 1;
    t_cnt <= 0;
    r_prodt <= 0;
  end else begin
    if(start)begin 
      t_cnt <= t_cnt + 1;
    end else begin
      t_cnt <= 0;
    end

    if (valid) begin
      r_prodt <= prodt;
      c_prodt <= (prodt[63]) ? ~(prodt-1) : prodt;
      pt <= pt + 1;
      $display("=> No.%d test pattern, mlier=32'h%h, mcand=32'h%h;", pt, mlier, mcand);
      $display("=> Expect data is : 64'h%h", exp);
      $display("=> Product data is: 64'h%h", prodt);
      $display("=> Total %d latency, test ok \n", t_cnt);
      if (prodt != exp) begin
        death(pt, prodt, exp);
      end
    end        
  end
end

task death(input [3:0] s, input [63:0] prodt, exp);
  begin
    $display("-=-=-=-=-=-=-=-=-ERROR Message-=-=-=-=-=-=-=-=-=-");
    $display("\n");
    $display("\n");
    $display("Data No.%d dose not match", s);
    $display("Expect data is %h", exp);
    $display("Product is     %h", prodt);
    $display("\n");
    $display("\n");
    $display("-=-=-=-=-=-=-=-=-     End    -=-=-=-=-=-=-=-=-=-");
    #200;
    $finish;
  end
endtask

endmodule


