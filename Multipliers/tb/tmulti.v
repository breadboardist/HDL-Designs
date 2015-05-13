/////////////////////////////////////////////////////////////
//Testbench to test Fixed and Variable Latency Multipliers //
/////////////////////////////////////////////////////////////

`timescale 1ns/10ps
module tmulti();
  
  //Check which simulation is being performed
  `ifdef tb_fix_pre
  parameter tb_type = 1;
  parameter vcd_name = "wave/FL.vcd";
  `endif

  `ifdef tb_fix_post
  parameter tb_type = 2;
  parameter vcd_name = "wave/FLGates.vcd";
  `endif

  `ifdef tb_var_pre
  parameter tb_type = 3;
  parameter vcd_name = "wave/VL.vcd";
  `endif

  `ifdef tb_var_post
  parameter tb_type = 4;
  parameter vcd_name = "wave/VLGates.vcd";
  `endif

  ////////////////////////////////////
  //Ports and register declarations //
  ////////////////////////////////////
  
  reg clock, reset, start, start_d;
  reg [31:0] mlier, mcand, loadedmlier, loadedmcand; 
  reg [63:0] r_prodt, c_prodt; 
  wire [63:0] prodt;
  wire valid;

  wire [31:0] multiplier, multiplicand;
  wire [63:0] multiplied,comp_multiplied,exp;
  reg  [5 :0] pt;
  reg  [7 :0] latency, latency_q, loadwait;
  reg debug = 1 ;

  initial begin
    //Generate VCD
    if(debug) begin
      $dumpfile(vcd_name);
      $dumpvars(9,tmulti);
    end
    //Clocking block
    clock=0;
    forever #5.0 clock=~clock; 
  end

  initial begin
    if (tb_type == 1) 
      $display("\nFixed Latency Multiplier RTL Simulation\n");
    else if (tb_type == 2)
      $display("\nFixed Latency Multiplier GLS Simulation\n");
    else if (tb_type == 3)
      $display("\nVariable Latency Multiplier RTL Simulation\n");
    else if (tb_type == 4)
      $display("\nVariable Latency Multiplier GLS Simulation\n");

    reset=1;   start=0;   mlier=0;   mcand=0;
    #19.0;  reset=0;  #1.0;

    //Multiplier is Positive and Multiplicand is Positive
    $display("Multiplier is Positive and Multiplicand is Positive\n");
    start=1;  mlier=32'h00000001;  mcand=32'h7fffffff;  #(10.0*33);  
    start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #50.0;

    start=1;  mlier=32'h7fffffff;  mcand=32'h7fffffff;  #(10.0*33);  
    start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #50.0;

    start=1;  mlier=32'h00000001;  mcand=32'h00000001;  #(10.0*33);  
    start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #50.0;

    start=1;  mlier=32'h7fffffff;  mcand=32'h00000001;  #(10.0*33);  
    start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #50.0;

    start=1;  mlier=32'h5555aaaa;  mcand=32'h7fffffff;  #(10.0*33);  
    start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #50.0;

    start=1;  mlier=32'h76543210;  mcand=32'h7fffffff;  #(10.0*33);  
    start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #50.0;
    $display("-----------------------------------------------------");

    //Multiplier is Positive and Multiplicand is Negative
    $display("Multiplier is Positive and Multiplicand is Negative\n");
    start=1;  mlier=32'h00000001;  mcand=32'h80000000;  #(10.0*33);  
    start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #50.0;

    start=1;  mlier=32'h7fffffff;  mcand=32'h80000000;  #(10.0*33);  
    start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #50.0;

    start=1;  mlier=32'h00000001;  mcand=32'hffffffff;  #(10.0*33);  
    start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #50.0;

    start=1;  mlier=32'h7fffffff;  mcand=32'hffffffff;  #(10.0*33);  
    start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #50.0;

    start=1;  mlier=32'h5555aaaa;  mcand=32'h80000000;  #(10.0*33);  
    start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #50.0;

    start=1;  mlier=32'h76543210;  mcand=32'h80000000;  #(10.0*33);  
    start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #50.0;
    $display("-----------------------------------------------------");

    //Multiplier is Negative and Multiplicand is Positive
    $display("Multiplier is Negative and Multiplicand is Positive\n");
    start=1;  mlier=32'hffffffff;  mcand=32'h7fffffff;  #(10.0*33);  
    start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #50.0;

    start=1;  mlier=32'h80000000;  mcand=32'h7fffffff;  #(10.0*33);  
    start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #50.0;

    start=1;  mlier=32'hffffffff;  mcand=32'h00000001;  #(10.0*33);  
    start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #50.0;

    start=1;  mlier=32'h80000000;  mcand=32'h00000001;  #(10.0*33);   
    start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #50.0;

    start=1;  mlier=32'haaaa5555;  mcand=32'h7fffffff;  #(10.0*33);  
    start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #50.0;

    start=1;  mlier=32'h87654321;  mcand=32'h7fffffff;  #(10.0*33);  
    start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #50.0;
    $display("-----------------------------------------------------");

    //Multiplier is Negative and Multiplicand is Negative
    $display("Multiplier is Negative and Multiplicand is Negative\n");
    start=1;  mlier=32'hffffffff;  mcand=32'h80000000;  #(10.0*33);  
    start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #50.0;

    start=1;  mlier=32'h80000000;  mcand=32'h80000000;  #(10.0*33);  
    start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #50.0;

    start=1;  mlier=32'hffffffff;  mcand=32'hffffffff;  #(10.0*33);  
    start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #50.0;

    start=1;  mlier=32'h80000000;  mcand=32'hffffffff;  #(10.0*33);  
    start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #50.0;

    start=1;  mlier=32'haaaa5555;  mcand=32'h80000000;  #(10.0*33);  
    start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #50.0;

    start=1;  mlier=32'h87654321;  mcand=32'h80000000;  #(10.0*33);  
    start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #50.0;
    $display("-----------------------------------------------------");

    //Zero Values
    $display("Multiplier is Zero or Multiplicand is Zero\n");
    start=1;  mlier=32'h00000000;  mcand=32'h7fffffff;  #(10.0*33);  
    start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #50.0;

    start=1;  mlier=32'h00000000;  mcand=32'h80000000;  #(10.0*33);  
    start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #50.0;

    start=1;  mlier=32'h7fffffff;  mcand=32'h00000000;  #(10.0*33);   
    start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #50.0;

    start=1;  mlier=32'h80000000;  mcand=32'h00000000;  #(10.0*33);   
    start=0;  mlier=32'h00000000;  mcand=32'h00000000;  #50.0;
    $display("-----------------------------------------------------");

    // Random Values
    $display("Multiplier is Randomly Generated and Multiplicand is Randomly Generated\n");
    start=1;  mlier=$random;  mcand=$random;  #(10.0*33);  
    start=0;  mlier=$random;  mcand=$random;  #50.0;

    start=1;  mlier=$random;  mcand=$random;  #(10.0*33);  
    start=0;  mlier=$random;  mcand=$random;  #50.0;

    start=1;  mlier=$random;  mcand=$random;  #(10.0*33);   
    start=0;  mlier=$random;  mcand=$random;  #50.0;
    
    start=1;  mlier=$random;  mcand=$random;  #(10.0*33);   
    start=0;  mlier=$random;  mcand=$random;  #50.0;
    $display("-----------------------------------------------------");

    mlier=0; 
    mcand=0;

    #(1000);

    if (tb_type == 1) 
      $display("\nFixed Latency Multiplier RTL Simulation completed successfully.\n");
    else if (tb_type == 2)
      $display("\nFixed Latency Multiplier GLS Simulation completed successfully.\n");
    else if (tb_type == 3)
      $display("\nVariable Latency Multiplier RTL Simulation completed successfully.\n");
    else if (tb_type == 4)
      $display("\nVariable Latency Multiplier GLS Simulation completed successfully.\n");

    $finish;
end

//Instantiate the correct multiplier module
generate
  if (tb_type == 1 || tb_type == 2) begin : fix_latency_enable
    multi    multi   (clock, reset, mlier, mcand, prodt, start, valid);
  end else if (tb_type == 3 || tb_type == 4) begin : valatency_q_enable
    multi_vl multi_vl(clock, reset, mlier, mcand, prodt, start, valid);
  end
endgenerate


assign  multiplier = (loadedmlier[31])? (~loadedmlier + 1'b1) : loadedmlier;
assign  multiplicand = (loadedmcand[31])? (~loadedmcand + 1'b1) : loadedmcand;
assign  multiplied = multiplier* multiplicand;
assign  comp_multiplied = ~(multiplied-1'b1);
assign  exp = ((loadedmlier[31]^loadedmcand[31])&& (|multiplied)) ? {1'b1,comp_multiplied} : {1'b0,multiplied};

always @( posedge clock or posedge reset ) begin
  if (reset) begin
    pt <= 1; latency <= 0; latency_q <= 0; loadwait <= 0;
    r_prodt <= 0; loadedmlier <= 0; loadedmcand <= 0; start_d <= 0;
  end else begin
    if (loadwait[4]) begin 
	   latency_q <= 0;
    end else if (valid) begin
   	latency_q <= latency;
  end

    if (valid) begin
        loadwait <= 8'b1; 
    end else if (loadwait[7]) begin
        loadwait <= 8'b0; 
    end else if (loadwait != 0) begin
        loadwait <= {loadwait[6:0],loadwait[7]}; 
    end

    start_d <= start;
   
    
      case (1'b1)
        (valid==1): latency <= 0;
        (latency!=0): latency <= latency+1;
        (start && !start_d): latency <= 1;
      endcase // 1'b1
    //   latency <= 1; 
    // end else if (valid)begin
    //   latency <= 0; 
    // end else if (latency != 0)begin
    //   latency <= latency + 1; 
    

    if(start && !start_d)begin
      loadedmcand <= mcand; 
      loadedmlier <= mlier; 
    end

    if (latency > 33) begin
        error(1'b0, pt, prodt, exp);
    end 

    if (valid) begin
      r_prodt <= prodt;
      c_prodt <= (prodt[63]) ? ~(prodt-1) : prodt;
      pt <= pt + 1;
      $display("--> Test Pattern #%d: Multiplier=32'h%h * Multiplicand=32'h%h", pt, loadedmlier, loadedmcand);
      $display("--> Expected product is  : 64'h%h", exp);
      $display("--> Computed product is  : 64'h%h", prodt);
      $display("--> Latency is           : %d\n", latency);
      if (prodt != exp) begin
        error(1'b1, pt, prodt, exp);
      end
    end        
  end
end

task error(input status, pt, input [63:0] prodt, exp);
  begin
    $display("Error");
    $display("\n");
    $display("\n");
    if (status == 1'b1) begin
      $display("Answer Mismatch");
      $display("Expected output is %h", exp);
      $display("Produced output is %h", prodt);
    end else if (status == 1'b0) begin
      $display("Took longer than 33 cycles");
      $display("Expected output is %h", exp);
      $display("Produced output is %h", prodt);
    end  
    $display("\n");
    $display("\n");
    $display("End");
    #200;
    $finish;
  end
endtask

endmodule


