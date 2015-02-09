`timescale 1ns/10ps

/////////////////////////////
//Interface from testbench //
/////////////////////////////
interface tci ;
  logic clk;
  logic rst;
  logic write;
  logic [7:0] addr;
  logic [7:0] wdata;
  logic read;
  logic [7:0] rdata;
  logic t0;
  logic oca_data,ocb_data;
  logic interrupt_request;
  logic status_reg_interrupt_enable;
  logic interrupt_executed;

  modport tc(input clk, input rst, input write, input addr,
    input wdata, input read, output rdata,input t0,output oca_data,
    output ocb_data,input status_reg_interrupt_enable,
    output interrupt_request,input interrupt_executed);

endinterface

////////////
//Counter //
////////////
module counter (
  input clk,
  input bottom,
  input top,
  output count,
  output clear,
  output direction,
  output int_request,
  output tcnt0
  
);

  reg [7:0] tcnt0;
  



endmodule