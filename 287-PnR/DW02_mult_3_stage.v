module DW02_mult_3_stage(A,B,TC,CLK,PRODUCT);
parameter	A_width = 8;
parameter	B_width = 8;
input	[A_width-1:0]	A;
input	[B_width-1:0]	B;
input			TC,CLK;
output	[A_width+B_width-1:0]	PRODUCT;

reg	[A_width+B_width-1:0]	PRODUCT,product_piped1;
wire	[A_width+B_width-1:0]	pre_product;

wire	[A_width-1:0]	temp_a;
wire	[B_width-1:0]	temp_b;
wire	[A_width+B_width-2:0]	long_temp1,long_temp2;

assign	temp_a = (A[A_width-1])? (~A + 1'b1) : A;
assign	temp_b = (B[B_width-1])? (~B + 1'b1) : B;

assign	long_temp1 = temp_a * temp_b;
assign	long_temp2 = ~(long_temp1 - 1'b1);

assign	pre_product = (TC)? (((A[A_width-1] ^ B[B_width-1]) && (|long_temp1))?
				{1'b1,long_temp2} : {1'b0,long_temp1})
			: A * B;

always @ (posedge CLK)
begin
	product_piped1 <= pre_product;
	PRODUCT <= product_piped1;
end

endmodule

