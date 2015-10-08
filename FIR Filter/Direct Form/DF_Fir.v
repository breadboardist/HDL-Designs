`timescale 1 ns / 1 ns

module DF_Fir
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

  // Internal Signals - All wires. Nothing is registered
  reg  signed [15:0] delay_pipeline [0:8];

  wire signed [30:0] product9, product8, product7,
                     product6, product5, product4,
                     product3, product2, product1;

  wire signed [31:0] mul_temp, mul_temp_1, mul_temp_2,
                     mul_temp_3, mul_temp_4, mul_temp_5,
                     mul_temp_6,mul_temp_7, mul_temp_8;

  wire signed [32:0] product1_cast;

  wire signed [32:0] sum1, sum2, sum3,
                     sum4, sum5, sum6,
                     sum7, sum8;

  wire signed [32:0] add_signext, add_signext_1, add_signext_2,
                     add_signext_3, add_signext_4, add_signext_5,
                     add_signext_6, add_signext_7, add_signext_8,
                     add_signext_9, add_signext_10, add_signext_11,
                     add_signext_12, add_signext_13, add_signext_14,
                     add_signext_15;

  wire signed [33:0] add_temp, add_temp_1, add_temp_2,
                     add_temp_3, add_temp_4, add_temp_5,
                     add_temp_6, add_temp_7;

  reg  signed [32:0] output_register;

  //Delay Blocks and Registering Output
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
          output_register <= sum8;
        end
      end
    end


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

  assign product1_cast = $signed({{2{product1[30]}}, product1});

  assign mul_temp_8 = delay_pipeline[0] * coeff1;
  assign product1 = mul_temp_8[30:0];

  assign add_signext = product1_cast;
  assign add_signext_1 = $signed({{2{product2[30]}}, product2});
  assign add_temp = add_signext + add_signext_1;
  assign sum1 = add_temp[32:0];

  assign add_signext_2 = sum1;
  assign add_signext_3 = $signed({{2{product3[30]}}, product3});
  assign add_temp_1 = add_signext_2 + add_signext_3;
  assign sum2 = add_temp_1[32:0];

  assign add_signext_4 = sum2;
  assign add_signext_5 = $signed({{2{product4[30]}}, product4});
  assign add_temp_2 = add_signext_4 + add_signext_5;
  assign sum3 = add_temp_2[32:0];

  assign add_signext_6 = sum3;
  assign add_signext_7 = $signed({{2{product5[30]}}, product5});
  assign add_temp_3 = add_signext_6 + add_signext_7;
  assign sum4 = add_temp_3[32:0];

  assign add_signext_8 = sum4;
  assign add_signext_9 = $signed({{2{product6[30]}}, product6});
  assign add_temp_4 = add_signext_8 + add_signext_9;
  assign sum5 = add_temp_4[32:0];

  assign add_signext_10 = sum5;
  assign add_signext_11 = $signed({{2{product7[30]}}, product7});
  assign add_temp_5 = add_signext_10 + add_signext_11;
  assign sum6 = add_temp_5[32:0];

  assign add_signext_12 = sum6;
  assign add_signext_13 = $signed({{2{product8[30]}}, product8});
  assign add_temp_6 = add_signext_12 + add_signext_13;
  assign sum7 = add_temp_6[32:0];

  assign add_signext_14 = sum7;
  assign add_signext_15 = $signed({{2{product9[30]}}, product9});
  assign add_temp_7 = add_signext_14 + add_signext_15;
  assign sum8 = add_temp_7[32:0];

  // Assignment Statements
  assign filter_out = output_register;
endmodule
