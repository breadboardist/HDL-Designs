//Author - Prem Bharath Soundararajan
// IEEE754 Logarithm approximation Unit
module log (
            input clk, rst, enable
            input [31:0] Op_X,
            output [31:0] Op_Q,
	        output error,done);
	
    //Input and output
    wire [31:0] Enable_Xin;
    reg  [31:0] outQ;

    //The polynomial results need to be pipelined
    //Declare polynomial variables - Stage 1
    reg [31:0] x_2nd_0,x_3rd_0,x_4th_0,x_5th_0,x_6th_0,x_7th_0,x_8th_0,x_9th_0;
    reg [31:0] x_2nd_1,x_3rd_1,x_4th_1,x_5th_1,x_6th_1,x_7th_1,x_8th_1;
    reg [31:0] x_2nd_2,x_3rd_2,x_4th_2,x_5th_2,x_6th_2,x_7th_2,x_8th_2;
    reg [31:0] x_2nd_3,x_3rd_3,x_4th_3,x_5th_3,x_6th_3,x_7th_3,x_8th_3;
    reg [31:0] x_2nd_4,x_3rd_4,x_4th_4,x_5th_4,x_6th_4,x_7th_4,x_8th_4;
    //Declare polynomial variables - Stage 2
    reg [31:0] x2_3rd_0,x2_4th_0,x2_5th_0,x2_6th_0,x2_7th_0,x2_8th_0,x2_9th_0;
    reg [31:0] x2_3rd_1,x2_4th_1,x2_5th_1,x2_6th_1,x2_7th_1,x2_8th_1;
    reg [31:0] x2_3rd_2,x2_4th_2,x2_5th_2,x2_6th_2,x2_7th_2,x2_8th_2;
    reg [31:0] x2_3rd_3,x2_4th_3,x2_5th_3,x2_6th_3,x2_7th_3,x2_8th_3;
    reg [31:0] x2_3rd_4,x2_4th_4,x2_5th_4,x2_6th_4,x2_7th_4,x2_8th_4;
    //Declare polynomial variables - Stage 3
    reg [31:0] x3_4th_0,x3_5th_0,x3_6th_0,x3_7th_0,x3_8th_0,x3_9th_0;
    reg [31:0] x3_4th_1,x3_5th_1,x3_6th_1,x3_7th_1,x3_8th_1;
    reg [31:0] x3_4th_2,x3_5th_2,x3_6th_2,x3_7th_2,x3_8th_2;
    reg [31:0] x3_4th_3,x3_5th_3,x3_6th_3,x3_7th_3,x3_8th_3;
    reg [31:0] x3_4th_4,x3_5th_4,x3_6th_4,x3_7th_4,x3_8th_4;
    //Declare polynomial variables - Stage 4
    reg [31:0] x4_5th_0,x4_6th_0,x4_7th_0,x4_8th_0,x4_9th_0;
    reg [31:0] x4_5th_1,x4_6th_1,x4_7th_1,x4_8th_1;
    reg [31:0] x4_5th_2,x4_6th_2,x4_7th_2,x4_8th_2;
    reg [31:0] x4_5th_3,x4_6th_3,x4_7th_3,x4_8th_3;
    reg [31:0] x4_5th_4,x4_6th_4,x4_7th_4,x4_8th_4;
    //Declare polynomial variables - Stage 5
    reg [31:0] x5_6th_0,x5_7th_0,x5_8th_0,x5_9th_0;
    reg [31:0] x5_6th_1,x5_7th_1,x5_8th_1;
    reg [31:0] x5_6th_2,x5_7th_2,x5_8th_2;
    reg [31:0] x5_6th_3,x5_7th_3,x5_8th_3;
    reg [31:0] x5_6th_4,x5_7th_4,x5_8th_4;
    //Declare polynomial variables - Stage 6
    reg [31:0] x6_7th_0,x6_8th_0,x6_9th_0;
    reg [31:0] x6_7th_1,x6_8th_1;
    reg [31:0] x6_7th_2,x6_8th_2;
    reg [31:0] x6_7th_3,x6_8th_3;
    reg [31:0] x6_7th_4,x6_8th_4;
    //Declare polynomial variables - Stage 7
    reg [31:0] x7_8th_0,x7_9th_0,x8_9th_0;
    reg [31:0] x7_8th_1,x7_8th_2,x7_8th_3,x7_8th_4;
    
    //Variables to instantiate the multipliers and adders
    wire[33:0] x2,x3,x4,x5,x6,x7,x8;
    reg [31:0] y,y2,y3,y4,y5,y6,y7;
    wire [33:0] c1x,c2x,c3x,c4x,c5x,c6x,c7x,c8x;
    reg  [31:0] c1x_q,c2x_q,c3x_q,c4x_q,c5x_q,c6x_q,c7x_q,c8x_q;
    wire [33:0] a1x,a2x,a3x,a4x;
    reg  [31:0] a1x_q,a2x_q,a3x_q,a4x_q;
    wire [33:0] r1x,r2x,res;
    reg  [31:0] r1x_q,r2x_q;

    wire [33:0] xout;    
    
    //Temporary registers for pipelining
    reg ycount_0,y2count_0,y3count_0,y4count_0,y5count_0,y6count_0,y7count_0,ccount_0;
    reg ycount_1,y2count_1,y3count_1,y4count_1,y5count_1,y6count_1,y7count_1,ccount_1;
    reg ycount_2,y2count_2,y3count_2,y4count_2,y5count_2,y6count_2,y7count_2,ccount_2;
    reg ycount_3,y2count_3,y3count_3,y4count_3,y5count_3,y6count_3,y7count_3,ccount_3;
    reg ycount_4,y2count_4,y3count_4,y4count_4,y5count_4,y6count_4,y7count_4,ccount_4;
    
    reg a1count_0,a2count_0,a3count_0,axminus1_0;
    reg a1count_1,a1count_2,a1count_3,a1count_4,a1count_5,a1count_6,a1count_7,a1count_8,a1count_9,a1count_10;
    reg a2count_1,a2count_2,a2count_3,a2count_4,a2count_5,a2count_6,a2count_7,a2count_8,a2count_9,a2count_10;
    reg a3count_1,a3count_2,a3count_3,a3count_4,a3count_5,a3count_6,a3count_7,a3count_8,a3count_9,a3count_10;
    reg axminus1_1,axminus1_2,axminus1_3,axminus1_4,axminus1_5,axminus1_6,axminus1_7,axminus1_8,axminus1_9,axminus1_10;
    

    assign Enable_Xin = (enable == 1)? Op_X : 0;
	assign error = (a3count_10 ==1 && done !=1)? 1'b1 :1'b0;
	assign done = (a3count_10 ==1)? 1 :0; 
    assign Op_Q = outQ;

    reg [31:0] c1 = 32'h3f800000;     //IEEE Format 32-bit for decimal 1
    reg [31:0] c2 = 32'hbf000000;     //IEEE Format 32-bit for decimal -0.5
    reg [31:0] c3 = 32'h3eaaaaab;     //IEEE Format 32-bit for decimal 0.33
    reg [31:0] c4 = 32'hbe800000;     //IEEE Format 32-bit for decimal -0.25
    reg [31:0] c5 = 32'h3e4ccccd;     //IEEE Format 32-bit for decimal 0.2
    reg [31:0] c6 = 32'hbe2aaaab;     //IEEE Format 32-bit for decimal -0.1667
    reg [31:0] c7 = 32'h3e124925;     //IEEE Format 32-bit for decimal 0.1428
    reg [31:0] c8 = 32'hbe000000;     //IEEE Format 32-bit for decimal -0.125
 
    
    FPAdder_8_23_uid2 axminus (.clk(clk),.rst(rst),.X({2'b01,Enable_Xin}),.Y({34'h1bf800000}),.R(xout));
    
    // Multiplication of the terms of the polynomial
    FPMultiplier_8_23_8_23_8_23_uid2 u0 (.clk(clk),.rst(rst),.X({2'b01,y}),.Y({2'b01,y}),.R(x2));
    FPMultiplier_8_23_8_23_8_23_uid2 u1 (.clk(clk),.rst(rst),.X({2'b01,y2}),.Y({2'b01,x_2nd_0}),.R(x3));
    FPMultiplier_8_23_8_23_8_23_uid2 u2 (.clk(clk),.rst(rst),.X({2'b01,y3}),.Y({2'b01,x_3rd_0}),.R(x4));
    FPMultiplier_8_23_8_23_8_23_uid2 u3 (.clk(clk),.rst(rst),.X({2'b01,y4}),.Y({2'b01,x_4th_0}),.R(x5));
    FPMultiplier_8_23_8_23_8_23_uid2 u4 (.clk(clk),.rst(rst),.X({2'b01,y5}),.Y({2'b01,x_5th_0}),.R(x6));
    FPMultiplier_8_23_8_23_8_23_uid2 u5 (.clk(clk),.rst(rst),.X({2'b01,y6}),.Y({2'b01,x_6th_0}),.R(x7));
    FPMultiplier_8_23_8_23_8_23_uid2 u6 (.clk(clk),.rst(rst),.X({2'b01,y7}),.Y({2'b01,x_7th_0}),.R(x8));
    
    // Constant coefficient multiplication
    FPMultiplier_8_23_8_23_8_23_uid2 m1 (.clk(clk),.rst(rst),.X({2'b01,c1}),.Y({2'b01,x_9th_0}),.R(c1x));
    FPMultiplier_8_23_8_23_8_23_uid2 m2 (.clk(clk),.rst(rst),.X({2'b01,c2}),.Y({2'b01,x2_9th_0}),.R(c2x));
    FPMultiplier_8_23_8_23_8_23_uid2 m3 (.clk(clk),.rst(rst),.X({2'b01,c3}),.Y({2'b01,x3_9th_0}),.R(c3x));
    FPMultiplier_8_23_8_23_8_23_uid2 m4 (.clk(clk),.rst(rst),.X({2'b01,c4}),.Y({2'b01,x4_9th_0}),.R(c4x));
    FPMultiplier_8_23_8_23_8_23_uid2 m5 (.clk(clk),.rst(rst),.X({2'b01,c5}),.Y({2'b01,x5_9th_0}),.R(c5x));
    FPMultiplier_8_23_8_23_8_23_uid2 m6 (.clk(clk),.rst(rst),.X({2'b01,c6}),.Y({2'b01,x6_9th_0}),.R(c6x));
    FPMultiplier_8_23_8_23_8_23_uid2 m7 (.clk(clk),.rst(rst),.X({2'b01,c7}),.Y({2'b01,x7_9th_0}),.R(c7x));
    FPMultiplier_8_23_8_23_8_23_uid2 m8 (.clk(clk),.rst(rst),.X({2'b01,c8}),.Y({2'b01,x8_9th_0}),.R(c8x));
    
    // Adding the terms of the polynomial    
    FPAdder_8_23_uid2 a1 (.clk(clk),.rst(rst),.X({2'b01,c1x_q}),.Y({2'b01,c2x_q}),.R(a1x));
    FPAdder_8_23_uid2 a2 (.clk(clk),.rst(rst),.X({2'b01,c3x_q}),.Y({2'b01,c4x_q}),.R(a2x));
    FPAdder_8_23_uid2 a3 (.clk(clk),.rst(rst),.X({2'b01,c5x_q}),.Y({2'b01,c6x_q}),.R(a3x));
    FPAdder_8_23_uid2 a4 (.clk(clk),.rst(rst),.X({2'b01,c7x_q}),.Y({2'b01,c8x_q}),.R(a4x));
    FPAdder_8_23_uid2 a5 (.clk(clk),.rst(rst),.X({2'b01,a1x_q}),.Y({2'b01,a2x_q}),.R(r1x));
    FPAdder_8_23_uid2 a6 (.clk(clk),.rst(rst),.X({2'b01,a3x_q}),.Y({2'b01,a4x_q}),.R(r2x));
    FPAdder_8_23_uid2 a7 (.clk(clk),.rst(rst),.X({2'b01,r1x_q}),.Y({2'b01,r2x_q}),.R(res));
   
    // Adder Pipelining (each for 10 stages)
    // There is also a special case detector which detects an input of 1 and 
    // conditionally alters the pipeline so that the value of log(1)=0 is correctly
    // represented. There is no logic in the following block. The output of the various FPAdder and FPMultiplier blocks
    // are pipelined so as to wait for the adder to complete its addition.
    // This is due to the fact that the multiplier takes lesser cycle than the adder
    always@(posedge clk or posedge rst)
        begin
            if(rst)begin
                axminus1_1 <= 0;
                ycount_0 <= 0;
                y2count_0 <= 0;
                y3count_0 <= 0;
                y4count_0 <=0;
                y5count_0 <= 0;
                y6count_0 <=0;
                y7count_0 <= 0;
                ccount_0 <= 0;
                a1count_0 <=0;
                a2count_0 <=0;
                a3count_0 <= 0;
                axminus1_2 <= 0;axminus1_3 <= 0; axminus1_4 <= 0;axminus1_5 <= 0; axminus1_6 <= 0;  
                axminus1_7 <= 0;axminus1_8 <= 0; axminus1_9 <= 0;axminus1_10 <= 0; 
                a1count_1 <= 0;a1count_2 <= 0;a1count_3 <= 0;a1count_4 <= 0;a1count_5 <= 0;
                a1count_6 <= 0;a1count_7 <= 0;a1count_8 <= 0;a1count_9 <= 0;a1count_10 <= 0;
                a2count_1 <= 0;a2count_2 <= 0;a2count_3 <= 0;a2count_4 <= 0;a2count_5 <= 0;
                a2count_6 <= 0;a2count_7 <= 0;a2count_8 <= 0;a2count_9 <= 0;a2count_10 <= 0;
                a3count_1 <= 0;a3count_2 <= 0;a3count_3 <= 0;a3count_4 <= 0;a3count_5 <= 0;
                a3count_6 <= 0;a3count_7 <= 0;a3count_8 <= 0;a3count_9 <= 0;a3count_10 <= 0;
            end
            else begin
                axminus1_1 <= 1;
                axminus1_2 <= axminus1_1;
                axminus1_3 <= axminus1_2;  
                axminus1_4 <= axminus1_3;
                axminus1_5 <= axminus1_4;
                axminus1_6 <= axminus1_5;  
                axminus1_7 <= axminus1_6;
                axminus1_8 <= axminus1_7;
                axminus1_9 <= axminus1_8;  
                axminus1_10 <= axminus1_9;
                
                a1count_1 <= a1count_0;
                a1count_2 <= a1count_1;
                a1count_3 <= a1count_2;
                a1count_4 <= a1count_3;
                a1count_5 <= a1count_4;
                a1count_6 <= a1count_5;
                a1count_7 <= a1count_6;
                a1count_8 <= a1count_7;
                a1count_9 <= a1count_8;
                a1count_10 <= a1count_9;
                
                a2count_1 <= a2count_0;
                a2count_2 <= a2count_1;
                a2count_3 <= a2count_2;
                a2count_4 <= a2count_3;
                a2count_5 <= a2count_4;
                a2count_6 <= a2count_5;
                a2count_7 <= a2count_6;
                a2count_8 <= a2count_7;
                a2count_9 <= a2count_8;
                a2count_10 <= a2count_9;
                
                a3count_1 <= a3count_0;
                a3count_2 <= a3count_1;
                a3count_3 <= a3count_2;
                a3count_4 <= a3count_3;
                a3count_5 <= a3count_4;
                a3count_6 <= a3count_5;
                a3count_7 <= a3count_6;
                a3count_8 <= a3count_7;
                a3count_9 <= a3count_8;
                a3count_10 <= a3count_9;
                
                ycount_1 <= ycount_0;
                ycount_2 <= ycount_1;
                ycount_3 <= ycount_2;
                ycount_4 <= ycount_3;
                
                y2count_1 <= y2count_0;
                y2count_2 <= y2count_1;
                y2count_3 <= y2count_2;
                y2count_4 <= y2count_3;
                
                y3count_1 <= y3count_0;
                y3count_2 <= y3count_1;
                y3count_3 <= y3count_2;
                y3count_4 <= y3count_3;
                
                y4count_1 <= y4count_0;
                y4count_2 <= y4count_1;
                y4count_3 <= y4count_2;
                y4count_4 <= y4count_3;
                
                y5count_1 <= y5count_0;
                y5count_2 <= y5count_1;
                y5count_3 <= y5count_2;
                y5count_4 <= y5count_3;
                
                y6count_1 <= y6count_0;
                y6count_2 <= y6count_1;
                y6count_3 <= y6count_2;
                y6count_4 <= y6count_3;
                
                y7count_1 <= y7count_0;
                y7count_2 <= y7count_1;
                y7count_3 <= y7count_2;
                y7count_4 <= y7count_3;
                
                ccount_1 <= ccount_0;
                ccount_2 <= ccount_1;
                ccount_3 <= ccount_2;
                ccount_4 <= ccount_3;
    
            if(axminus1_10 == 1)
					 begin
						if(xout[33:32] == 2'b00) begin
						x_2nd_0 <= 32'h00000000;
						y <= 32'h00000000; end
						else begin
						x_2nd_0 <= xout[31:0];
						y <= xout[31:0]; end
			 
						ycount_0 <= 1;
            end
            
            x_2nd_1 <= x_2nd_0;
            x_2nd_2 <= x_2nd_1;
            x_2nd_3 <= x_2nd_2;
            x_2nd_4 <= x_2nd_3;
            
         
            x_3rd_0 <=x_2nd_4; 
            if(ycount_4 == 1)begin 
						if(x2[33:32]==2'b00) begin
						x2_3rd_0 <= 32'h00000000;
						y2 <= 32'h00000000;
						end
						else begin
						x2_3rd_0 <= x2[31:0];    
						y2 <= x2[31:0]; end 
						
						y2count_0 <= 1;
            end
            
            x_3rd_1 <= x_3rd_0;
            x_3rd_2 <= x_3rd_1;
            x_3rd_3 <= x_3rd_2;
            x_3rd_4 <= x_3rd_3;
            
            x2_3rd_1 <= x2_3rd_0;
            x2_3rd_2 <= x2_3rd_1;
            x2_3rd_3 <= x2_3rd_2;
            x2_3rd_4 <= x2_3rd_3;
            
            
            x_4th_0 <= x_3rd_4;       
            x2_4th_0 <= x2_3rd_4; 
           
            if(y2count_4 == 1)begin
						if(x3[33:32] == 2'b00) begin
						x3_4th_0 <= 32'h00000000;
						y3 <= 32'h00000000;end
						else begin
						x3_4th_0 <= x3[31:0];    
						y3 <= x3[31:0]; end
						 
						y3count_0 <= 1;
            end
            
            x_4th_1 <= x_4th_0;
            x_4th_2 <= x_4th_1;
            x_4th_3 <= x_4th_2;
            x_4th_4 <= x_4th_3;
            
            x2_4th_1 <= x2_4th_0;
            x2_4th_2 <= x2_4th_1;
            x2_4th_3 <= x2_4th_2;
            x2_4th_4 <= x2_4th_3;
            
            x3_4th_1 <= x3_4th_0;
            x3_4th_2 <= x3_4th_1;
            x3_4th_3 <= x3_4th_2;
            x3_4th_4 <= x3_4th_3;
            
            x_5th_0 <= x_4th_4;
            x2_5th_0 <= x2_4th_4;
            x3_5th_0 <= x3_4th_4;
            
            if(y3count_4 == 1) begin
				
						if(x4[33:32]==2'b00) begin
						x4_5th_0 <= 32'h00000000;
						y4 <= 32'h00000000;
						end
						else begin
						x4_5th_0 <= x4[31:0];
						y4 <= x4[31:0]; end
						y4count_0 <=1;
            end
            
            x_5th_1 <= x_5th_0;
            x_5th_2 <= x_5th_1;
            x_5th_3 <= x_5th_2;
            x_5th_4 <= x_5th_3;
            
            x2_5th_1 <= x2_5th_0;
            x2_5th_2 <= x2_5th_1;
            x2_5th_3 <= x2_5th_2;
            x2_5th_4 <= x2_5th_3;
            
            x3_5th_1 <= x3_5th_0;
            x3_5th_2 <= x3_5th_1;
            x3_5th_3 <= x3_5th_2;
            x3_5th_4 <= x3_5th_3;
            
            x4_5th_1 <= x4_5th_0;
            x4_5th_2 <= x4_5th_1;
            x4_5th_3 <= x4_5th_2;
            x4_5th_4 <= x4_5th_3;
    
            x_6th_0 <= x_5th_4;
            x2_6th_0 <= x2_5th_4;
            x3_6th_0 <= x3_5th_4;
            x4_6th_0 <= x4_5th_4;
            
            if(y4count_4 ==1) begin 
				
						if(x5[33:32] == 2'b00) begin
						x5_6th_0 <= 32'h00000000;
						y5 <= 32'h00000000; end
						else begin
						x5_6th_0 <= x5[31:0];
						y5 <= x5[31:0]; end
						y5count_0 <= 1;
            end
             
            x_6th_1 <= x_6th_0;               
            x_6th_2 <= x_6th_1;
            x_6th_3 <= x_6th_2;
            x_6th_4 <= x_6th_3;
            
            x2_6th_1 <= x2_6th_0;
            x2_6th_2 <= x2_6th_1;
            x2_6th_3 <= x2_6th_2;
            x2_6th_4 <= x2_6th_3;
            
            x3_6th_1 <= x3_6th_0;
            x3_6th_2 <= x3_6th_1;
            x3_6th_3 <= x3_6th_2;
            x3_6th_4 <= x3_6th_3;
            
            x4_6th_1 <= x4_6th_0;
            x4_6th_2 <= x4_6th_1;
            x4_6th_3 <= x4_6th_2;
            x4_6th_4 <= x4_6th_3;
            
            x5_6th_1 <= x5_6th_0;
            x5_6th_2 <= x5_6th_1;
            x5_6th_3 <= x5_6th_2;
            x5_6th_4 <= x5_6th_3;
            
            
            x_7th_0 <= x_6th_4;
            x2_7th_0 <= x2_6th_4;
            x3_7th_0 <= x3_6th_4;
            x4_7th_0 <= x4_6th_4;
            x5_7th_0 <= x5_6th_4;
            
            if(y5count_4 ==1 ) begin
				
				if(x6[33:32] ==2'b00) begin
				x6_7th_0 <= 32'h00000000;
				y6<= 32'h00000000;
				end
				else begin
            x6_7th_0 <= x6[31:0];
            y6 <= x6[31:0]; end
            y6count_0 <= 1;
            end
            
             x_7th_1 <= x_7th_0;               
            x_7th_2 <= x_7th_1;
            x_7th_3 <= x_7th_2;
            x_7th_4 <= x_7th_3;
            
             x2_7th_1 <= x2_7th_0;               
            x2_7th_2 <= x2_7th_1;
            x2_7th_3 <= x2_7th_2;
            x2_7th_4 <= x2_7th_3;

             x3_7th_1 <= x3_7th_0;               
            x3_7th_2 <= x3_7th_1;
            x3_7th_3 <= x3_7th_2;
            x3_7th_4 <= x3_7th_3;
            
             x4_7th_1 <= x4_7th_0;               
            x4_7th_2 <= x4_7th_1;
            x4_7th_3 <= x4_7th_2;
            x4_7th_4 <= x4_7th_3;
            
             x5_7th_1 <= x5_7th_0;               
            x5_7th_2 <= x5_7th_1;
            x5_7th_3 <= x5_7th_2;
            x5_7th_4 <= x5_7th_3;
            
             x6_7th_1 <= x6_7th_0;               
            x6_7th_2 <= x6_7th_1;
            x6_7th_3 <= x6_7th_2;
            x6_7th_4 <= x6_7th_3;
            
            
            x_8th_0 <= x_7th_4;
            x2_8th_0 <= x2_7th_4;
            x3_8th_0 <= x3_7th_4;
            x4_8th_0 <= x4_7th_4;
            x5_8th_0<= x5_7th_4;
            x6_8th_0 <= x6_7th_4;
            
            if(y6count_4 == 1) begin
						if(x7[33:32]==2'b00) begin
						x7_8th_0 <= 32'h00000000;
						y7 <= 32'h00000000;
						end
						else begin
						x7_8th_0 <= x7[31:0];
						y7 <= x7[31:0]; end
						
						y7count_0 <=1;
            end
            
            x_8th_1 <= x_8th_0;               
            x_8th_2 <= x_8th_1;
            x_8th_3 <= x_8th_2;
            x_8th_4 <= x_8th_3;
            
            x2_8th_1 <= x2_8th_0;               
            x2_8th_2 <= x2_8th_1;
            x2_8th_3 <= x2_8th_2;
            x2_8th_4 <= x2_8th_3;
            
            x3_8th_1 <= x3_8th_0;               
            x3_8th_2 <= x3_8th_1;
            x3_8th_3 <= x3_8th_2;
            x3_8th_4 <= x3_8th_3;
            
            x4_8th_1 <= x4_8th_0;               
            x4_8th_2 <= x4_8th_1;
            x4_8th_3 <= x4_8th_2;
            x4_8th_4 <= x4_8th_3;
            
            x5_8th_1 <= x5_8th_0;               
            x5_8th_2 <= x5_8th_1;
            x5_8th_3 <= x5_8th_2;
            x5_8th_4 <= x5_8th_3;
            
            x6_8th_1 <= x6_8th_0;               
            x6_8th_2 <= x6_8th_1;
            x6_8th_3 <= x6_8th_2;
            x6_8th_4 <= x6_8th_3;
            
            x7_8th_1 <= x7_8th_0;               
            x7_8th_2 <= x7_8th_1;
            x7_8th_3 <= x7_8th_2;
            x7_8th_4 <= x7_8th_3;
            
            x_9th_0 <= x_8th_4;
            x2_9th_0 <= x2_8th_4;
            x3_9th_0 <= x3_8th_4;
            x4_9th_0 <= x4_8th_4;
            x5_9th_0 <= x5_8th_4;
            x6_9th_0 <= x6_8th_4;
            x7_9th_0 <= x7_8th_4;
            
            if(y7count_4 == 1) begin
						if(x8[33:32]==2'b00) begin
						x8_9th_0 <= 32'h00000000;
						end 
						else begin
						x8_9th_0 <= x8[31:0]; end
						
						ccount_0 <= 1;
            end
      
      
            if(ccount_4 ==1) begin
				a1count_0 <= 1;
            c1x_q <= c1x[31:0];
				if(xout[33:31] == 2'b00)
				begin
					c2x_q <= 32'h00000000;
					c3x_q <= 32'h00000000;
					c4x_q <= 32'h00000000;
					c5x_q <= 32'h00000000;
					c6x_q <= 32'h00000000;
					c7x_q <= 32'h00000000;
					c8x_q <= 32'h00000000;
				end
				else begin
					c2x_q <= c2x[31:0];
					c3x_q <= c3x[31:0];
					c4x_q <= c4x[31:0];
					c5x_q <= c5x[31:0];
					c6x_q <= c6x[31:0];
					c7x_q <= c7x[31:0];
					c8x_q <= c8x[31:0];
            end
				end
            
            if(a1count_10 == 1) begin
					a1x_q <= a1x[31:0];
					a2x_q <= a2x[31:0];
					a3x_q <= a3x[31:0];
					a4x_q <= a4x[31:0];
					a2count_0 <= 1;
            end
            
            if(a2count_10 == 1) begin
					r1x_q <=r1x[31:0];
					r2x_q <=r2x[31:0];
					a3count_0 <= 1;
            end

           if(a3count_10 == 1) begin
				 if(xout[33:32]==2'b00)
				 begin
						outQ <= 32'h00000000; end
				 else begin
						outQ <= res[31:0]; end
					end
        end
    end

    
endmodule

