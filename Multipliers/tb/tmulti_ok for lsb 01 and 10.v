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

reg clock, reset, start, start_bf;
reg [31:0] mlier, mcand, r_mlier, r_mcand; 
reg [63:0] r_prodt, c_prodt; 
wire [63:0] prodt;
wire valid;

wire [31:0] q0,h0;
wire [63:0] mr1,mr2,exp;
reg  [5 :0] pt;
reg  [7 :0] latency;
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
  #19.0;  reset=0;  #1.0;
//** multiplier is positive and multiplcant is positive *
  start=1;  mlier=32'h55555555;  mcand=32'h00000001;  #(10.0*33);  
  start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #20.0;

  start=1;  mlier=32'h5aaaaaaa;  mcand=32'h00000001;  #(10.0*33);  
  start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #20.0;

  start=1;  mlier=32'h555fff55;  mcand=32'h7fffffff;  #(10.0*33);  
  start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #20.0;

  start=1;  mlier=32'h7fffff55;  mcand=32'h7fffffff;  #(10.0*33);  
  start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #20.0;

  start=1;  mlier=32'h7ffffffa;  mcand=32'h00000001;  #(10.0*33);  
  start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #20.0;

  start=1;  mlier=32'h00000001;  mcand=32'h7fffffff;  #(10.0*33);  
  start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #20.0;

  start=1;  mlier=32'h00000000;  mcand=32'h7fffffff;  #(10.0*33);  
  start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #20.0;

  start=1;  mlier=32'h00000001;  mcand=32'h00000001;  #(10.0*33);  
  start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #20.0;

//** multiplier is positive and multiplcant is negtive **
  start=1;  mlier=32'h00000001;  mcand=32'h80000000;  #(10.0*33);  
  start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #20.0;

  start=1;  mlier=32'h7ffffffa;  mcand=32'h80000000;  #(10.0*33);  
  start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #20.0;

  start=1;  mlier=32'h00000001;  mcand=32'hffffffff;  #(10.0*33);  
  start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #20.0;

  start=1;  mlier=32'h5555555a;  mcand=32'h80000000;  #(10.0*33);  
  start=0;  mlier=32'h00000000;  mcand=32'h00000000; #20.0;
//  start=1;  mlier=32'h55555555;  mcand=32'h80000000;  #(10.0*33);  
//  start=0;  mlier=32'h00000000;  mcand=32'h00000000; #20.0;

//** multiplier is negtive and multiplcant is positive ***
  start=1;  mlier=32'h80000000;  mcand=32'h00000001;  #(10.0*33);   
  start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #20.0;

  start=1;  mlier=32'h80000000;  mcand=32'h7fffffff;  #(10.0*33);  
  start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #20.0;

  start=1;  mlier=32'hffffffff;  mcand=32'h00000001;  #(10.0*33);  
  start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #20.0;

  start=1;  mlier=32'haaaaaaaa;  mcand=32'h7fffffff;  #(10.0*33);  
  start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #20.0;

//** multiplier is negtive and multiplcant is negtive ****
  start=1;  mlier=32'hffffffff;  mcand=32'h80000000;  #(10.0*33);  
  start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #20.0;

  start=1;  mlier=32'h80000000;  mcand=32'h80000000;  #(10.0*33);  
  start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #20.0;

  start=1;  mlier=32'hffffffff;  mcand=32'hffffffff;  #(10.0*33);  
  start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #20.0;

  start=1;  mlier=32'haaaaaaaa;  mcand=32'h80000000;  #(10.0*33);  
  start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #20.0;

//** zero case ****
  start=1;  mlier=32'h00000000;  mcand=32'h7fffffff;  #(10.0*33);  
  start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #20.0;

  start=1;  mlier=32'h7fffffff;  mcand=32'h00000000;  #(10.0*33);   
  start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #20.0;

  start=1;  mlier=32'h80000000;  mcand=32'h00000000;  #(10.0*33);   
  start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #20.0;

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

assign  q0 = (r_mlier[31])? (~r_mlier + 1'b1) : r_mlier;
assign  h0 = (r_mcand[31])? (~r_mcand + 1'b1) : r_mcand;
assign  mr1= q0*h0;
assign  mr2= ~(mr1-1'b1);
assign  exp= ((r_mlier[31]^r_mcand[31])&& (|mr1)) ? {1'b1,mr2} : {1'b0,mr1};

always @( posedge clock or posedge reset ) begin
  if (reset) begin
    pt <= 1; latency <= 0;
    r_prodt <= 0; r_mlier <= 0; r_mcand <= 0; start_bf <= 0;
  end else begin
    start_bf <= start;
   
    if(start && !start_bf)begin
      latency <= 1; 
    end else if (valid)begin
      latency <= 0; 
    end else if (latency != 0)begin
      latency <= latency + 1; 
    end 

    if(start && !start_bf)begin
      r_mcand <= mcand; 
      r_mlier <= mlier; 
    end

    if (latency > 33) begin
        death(4'h2, pt, prodt, exp);
    end 

    if (valid) begin
      r_prodt <= prodt;
      c_prodt <= (prodt[63]) ? ~(prodt-1) : prodt;
      pt <= pt + 1;
      $display("=> No.%d test pattern, mlier=32'h%h, mcand=32'h%h;", pt, r_mlier, r_mcand);
      $display("=> Expect data is : 64'h%h", exp);
      $display("=> Product data is: 64'h%h", prodt);
      $display("=> Total %d latency, test ok \n", latency);
      if (prodt != exp) begin
        death(4'h1, pt, prodt, exp);
      end
    end        
  end
end

task death(input [3:0] status, pt, input [63:0] prodt, exp);
  begin
    $display("-=-=-=-=-=-=-=-=-ERROR Message-=-=-=-=-=-=-=-=-=-");
    $display("\n");
    $display("\n");

    if (status == 4'h1) begin
      $display("Data No.%d dose not match", pt);
      $display("Expect data is %h", exp);
      $display("Product is     %h", prodt);
    end else if (status == 4'h2) begin
      $display("no valid output is detected in 33 clock");
      $display("Expect data is %h", exp);
      $display("Product is     %h", prodt);
    end  
    
    $display("\n");
    $display("\n");
    $display("-=-=-=-=-=-=-=-=-     End    -=-=-=-=-=-=-=-=-=-");
    #200;
    $finish;
  end
endtask

endmodule


