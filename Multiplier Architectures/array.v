//Array Multiplier
//Submitted By: Prem Bharath Soundararajan (009430694)
module FullAdder (A,B,Cin,S,Cout);
input A,B,Cin;
output S,Cout;
assign S = A ^ B ^ Cin;
assign Cout = {A&B} | {B&Cin} | {A&Cin};
endmodule

module array_multiplier (start94,multiplier94,multiplicand94,product94);

parameter WIDTH=16;

input start94;
input [WIDTH-1:0] multiplier94;
input [WIDTH-1:0] multiplicand94;
output [2*WIDTH-1:0] product94;
reg [2*WIDTH-1:0] product94;
reg [WIDTH-1:0] multiplier94_d,multiplicand94_d;

wire [2*WIDTH-1:0] out_p;
wire [WIDTH:0]sum[WIDTH:0];
wire [WIDTH:0]cout[WIDTH:0];

always @(start94) begin
        if(start94) begin
                multiplier94_d = multiplier94;
                multiplicand94_d = multiplicand94;
                product94 = 0;
        end else begin
                product94 = out_p;
        end
end
assign out_p[0] = multiplier94_d[0] & multiplicand94_d[0];
genvar i,j,k;
generate
for(i=1;i<WIDTH;i=i+1) begin: Loop_1
        for(j=0;j<WIDTH;j=j+1) begin: Loop_2
                if(i==1) begin
                        if(j==0) begin
                                FullAdder add(.A(multiplier94_d[i-1]&multiplicand94_d[j+1]), .B(multiplier94_d[i]&multiplicand94_d[j]), .Cin(1'b0), .S(sum[i][j]), .Cout(cout[i][j]));
                        end else if(j==WIDTH-1) begin
                                FullAdder add(.A(1'b1), .B(~{multiplier94_d[i]&multiplicand94_d[j]}), .Cin(cout[i][j-1]), .S(sum[i][j]), .Cout(cout[i][j]));
                        end else if(j==WIDTH-2) begin
                                FullAdder add(.A(~{multiplier94_d[i-1]&multiplicand94_d[j+1]}), .B(multiplier94_d[i]&multiplicand94_d[j]), .Cin(cout[i][j-1]), .S(sum[i][j]), .Cout(cout[i][j]));
                        end else begin
                                FullAdder add(.A(multiplier94_d[i-1]&multiplicand94_d[j+1]), .B(multiplier94_d[i]&multiplicand94_d[j]), .Cin(cout[i][j-1]), .S(sum[i][j]), .Cout(cout[i][j]));
                        end
                end else if(i==WIDTH-1) begin
                        if(j==0) begin
                                FullAdder add(.A(~{multiplier94_d[i]&multiplicand94_d[j]}), .B(sum[i-1][j+1]), .Cin(1'b0), .S(sum[i][j]), .Cout(cout[i][j]));
                        end else if(j==WIDTH-1) begin
                                FullAdder add(.A(multiplier94_d[i]&multiplicand94_d[j]), .B(cout[i-1][j]), .Cin(cout[i][j-1]), .S(sum[i][j]), .Cout(cout[i][j]));
                        end else begin
                                FullAdder add(.A(~{multiplier94_d[i]&multiplicand94_d[j]}), .B(sum[i-1][j+1]), .Cin(cout[i][j-1]), .S(sum[i][j]), .Cout(cout[i][j]));
                        end
                end else begin
                        if(j==0) begin
                                FullAdder add(.A(multiplier94_d[i]&multiplicand94_d[j]), .B(sum[i-1][j+1]), .Cin(1'b0), .S(sum[i][j]), .Cout(cout[i][j]));
                        end else if(j==WIDTH-1) begin
                                FullAdder add(.A(~{multiplier94_d[i]&multiplicand94_d[j]}), .B(cout[i-1][j]), .Cin(cout[i][j-1]), .S(sum[i][j]), .Cout(cout[i][j]));
                        end else begin
                                FullAdder add(.A(multiplier94_d[i]&multiplicand94_d[j]), .B(sum[i-1][j+1]), .Cin(cout[i][j-1]), .S(sum[i][j]), .Cout(cout[i][j]));
                        end
                end
        end
end
for(k=1;k<2*WIDTH-1;k=k+1) begin: Loop_3
        if(k>=WIDTH)
                assign out_p[k] = sum[WIDTH-1][k-WIDTH+1];
        else
                assign out_p[k] = sum[k][0];
end
endgenerate

FullAdder add_last(.A(1'b1), .B(1'b0), .Cin(cout[WIDTH-1][WIDTH-1]), .S(out_p[2*WIDTH-1]), .Cout());
endmodule