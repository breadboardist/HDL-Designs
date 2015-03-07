module alu (
	input [31:0] r1,
	input [31:0] r2,
	input [3:0] control,
	output [31:0] result,
	output zero
);

integer in1, in2, out;
reg zero;

always @(*) 
	begin
		zero = 1'b0;
		in1 = r1;
		in2 = r2;
		case(control)
			4'b0000: out = in1 + in2; //ADD and ADDI also LB, LW, SB ,SW
			4'b0001: out = in1 & in2; //AND and ANDI
			4'b0010: out = in1 | in2; //OR and ORI
			4'b0011: out = in1 << in2; //SLL, in1 shifted left by in2 amount
			4'b0100: out = (in1 < in2) ? 1 : 0; //SLT and SLTI, set on less than, output is set to 1 if in1<in2 else 0
			4'b0101: out = in1 >> in2; //SRL, in1 shifted right by in2 amount
			4'b0110: out = in1 - in2; //SUB
			4'b0111: out = in1 ^ in2; //XOR and XORI
			4'b1000: begin //BEQ, zero flag is 1 if branch is true i.e., if both inputs are equal
						if (in1 == in2) zero = 1'b1;
						else zero = 1'b0;
					  end
			4'b1001: begin //BNE, zero flag is 1 if branch is true i.e., if both inputs are not equal
						if (in1 != in2) zero = 1'b1;
						else zero = 1'b0;
					  end
			default: out = 0;
		endcase
	end
	assign result = out;
endmodule

module test_alu ();
	integer input1, input2;
	reg [3:0] cntrl;
	wire [31:0] outp; 
	wire zer;
	alu A(input1, input2, cntrl, outp, zer);
	initial
		fork
			#9 input1 = 5;
			#9 input1 = 5;
			#9 input1 = 5;
			#9 input1 = 5;
			#9 input1 = 5;
			#9 input1 = 5;
			#9 input1 = 5;
			#9 input1 = 5;
			#9 input1 = 5;
			#9 input1 = 5;
		join
	initial
		fork
			#8 input2 = 8;
			#8 input2 = 8;
			#8 input2 = 8;
			#8 input2 = 8;
			#8 input2 = 8;
			#8 input2 = 8;
			#8 input2 = 8;
			#8 input2 = 8;
			#8 input2 = 8;
			#8 input2 = 8;
		join
	initial
		fork
			#10 cntrl = 4'b0000;
			#10 cntrl = 4'b0001;
			#10 cntrl = 4'b0010;
			#10 cntrl = 4'b0011;
			#10 cntrl = 4'b0100;
			#10 cntrl = 4'b0101;
			#10 cntrl = 4'b0110;
			#10 cntrl = 4'b0111;
			#10 cntrl = 4'b1000;
			#10 cntrl = 4'b1001;
		join
	initial $monitor("Result: %d", outp);
endmodule
