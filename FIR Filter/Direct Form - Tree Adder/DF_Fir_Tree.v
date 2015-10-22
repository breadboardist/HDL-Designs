`timescale 1 ns / 1 ns

module DF_Fir_Tree
               (
                clk,
                clk_enable,
                reset,
                filter_in,
                filter_out
                );

  input   clk; 
  input   clk_enable; 
  input   reset; 
  input   signed [15:0] filter_in; 
  output  signed [32:0] filter_out;

  // Filter Coefficients
  parameter signed [15:0] coeff1 = 16'b1111111011110100;
  parameter signed [15:0] coeff2 = 16'b0000000111111000;
  parameter signed [15:0] coeff3 = 16'b0001011011011010;
  parameter signed [15:0] coeff4 = 16'b0011111001001011;
  parameter signed [15:0] coeff5 = 16'b0101001111011110;
  parameter signed [15:0] coeff6 = 16'b0011111001001011;
  parameter signed [15:0] coeff7 = 16'b0001011011011010;
  parameter signed [15:0] coeff8 = 16'b0000000111111000;
  parameter signed [15:0] coeff9 = 16'b1111111011110100;

  // Internal Signals
  reg  signed [15:0] delay_pipeline [0:8];

  wire signed [30:0] product9, product8, product7,
                     product6, product5, product4,
                     product3, product2, product1;

  wire signed [31:0] mul_temp, mul_temp_1, mul_temp_2,
                     mul_temp_3, mul_temp_4, mul_temp_5,
                     mul_temp_6,mul_temp_7, mul_temp_8;

  wire signed [32:0] sum1_1, sum1_2, sum1_3,
                     sum1_4, sum2_1, sum2_2,
                     sum3_1, sum4_1;

  wire signed [30:0] add_signext, add_signext_1,  add_signext_2,
                     add_signext_3,  add_signext_4,  add_signext_5,  
                     add_signext_6,  add_signext_7; 

  wire signed [32:0] add_signext_8, add_signext_9, add_signext_10, 
                     add_signext_11, add_signext_12, add_signext_13, 
                     add_signext_14, add_signext_15; 

  wire signed [31:0] add_temp, add_temp_1, add_temp_2, add_temp_3;
  wire signed [33:0] add_temp_4, add_temp_5, add_temp_6, add_temp_7; 
  
  reg  signed [32:0] output_register; 

  // Block Statements
  always @( posedge clk or posedge reset)
    begin
      if (reset == 1'b1) begin
        delay_pipeline[0] <= 0;
        delay_pipeline[1] <= 0;
        delay_pipeline[2] <= 0;
        delay_pipeline[3] <= 0;
        delay_pipeline[4] <= 0;
        delay_pipeline[5] <= 0;
        delay_pipeline[6] <= 0;
        delay_pipeline[7] <= 0;
        delay_pipeline[8] <= 0;
        output_register <= 0;
      end
      else begin
        if (clk_enable == 1'b1) begin
          delay_pipeline[0] <= filter_in;
          delay_pipeline[1] <= delay_pipeline[0];
          delay_pipeline[2] <= delay_pipeline[1];
          delay_pipeline[3] <= delay_pipeline[2];
          delay_pipeline[4] <= delay_pipeline[3];
          delay_pipeline[5] <= delay_pipeline[4];
          delay_pipeline[6] <= delay_pipeline[5];
          delay_pipeline[7] <= delay_pipeline[6];
          delay_pipeline[8] <= delay_pipeline[7];
          output_register <= sum4_1;
        end
      end
    end 

  //Multiplication Operations  
  assign mul_temp = delay_pipeline[8] * coeff9;
  assign product9 = mul_temp[30:0];

  assign mul_temp_1 = delay_pipeline[7] * coeff8;
  assign product8 = mul_temp_1[30:0];

  assign mul_temp_2 = delay_pipeline[6] * coeff7;
  assign product7 = mul_temp_2[30:0];

  assign mul_temp_3 = delay_pipeline[5] * coeff6;
  assign product6 = mul_temp_3[30:0];

  assign mul_temp_4 = delay_pipeline[4] * coeff5;
  assign product5 = mul_temp_4[30:0];

  assign mul_temp_5 = delay_pipeline[3] * coeff4;
  assign product4 = mul_temp_5[30:0];

  assign mul_temp_6 = delay_pipeline[2] * coeff3;
  assign product3 = mul_temp_6[30:0];

  assign mul_temp_7 = delay_pipeline[1] * coeff2;
  assign product2 = mul_temp_7[30:0];

  assign mul_temp_8 = delay_pipeline[0] * coeff1;
  assign product1 = mul_temp_8[30:0];

  //Addition Operations
  assign add_signext = product9;
  assign add_signext_1 = product8;
  assign add_temp = add_signext + add_signext_1;
  assign sum1_1 = $signed({{1{add_temp[31]}}, add_temp});

  assign add_signext_2 = product7;
  assign add_signext_3 = product6;
  assign add_temp_1 = add_signext_2 + add_signext_3;
  assign sum1_2 = $signed({{1{add_temp_1[31]}}, add_temp_1});

  assign add_signext_4 = product5;
  assign add_signext_5 = product4;
  assign add_temp_2 = add_signext_4 + add_signext_5;
  assign sum1_3 = $signed({{1{add_temp_2[31]}}, add_temp_2});

  assign add_signext_6 = product3;
  assign add_signext_7 = product2;
  assign add_temp_3 = add_signext_6 + add_signext_7;
  assign sum1_4 = $signed({{1{add_temp_3[31]}}, add_temp_3});

  assign add_signext_8 = sum1_1;
  assign add_signext_9 = sum1_2;
  assign add_temp_4 = add_signext_8 + add_signext_9;
  assign sum2_1 = add_temp_4[32:0];

  assign add_signext_10 = sum1_3;
  assign add_signext_11 = sum1_4;
  assign add_temp_5 = add_signext_10 + add_signext_11;
  assign sum2_2 = add_temp_5[32:0];

  assign add_signext_12 = sum2_1;
  assign add_signext_13 = sum2_2;
  assign add_temp_6 = add_signext_12 + add_signext_13;
  assign sum3_1 = add_temp_6[32:0];

  assign add_signext_14 = sum3_1;
  assign add_signext_15 = $signed({{2{product1[30]}}, product1});
  assign add_temp_7 = add_signext_14 + add_signext_15;
  assign sum4_1 = add_temp_7[32:0];

  // Assignment Statements
  assign filter_out = output_register;
endmodule  // DF_Fir_Tree
