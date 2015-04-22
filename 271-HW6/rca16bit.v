module half_adder(s,c,a,b);
	input a,b;
	output s,c;
	xor sum(s,a,b);
	and carry(c,a,b);
endmodule

module full_adder(s,c,a,b,cin);
	input a,b,cin;
	output s,c;
		wire s1,c1,c2;
		half_adder ha1(s1,c1,a,b);
		half_adder ha2(s,c2,s1,cin);
		or carry(c,c1,c2);
endmodule

module fulladder_4bit(s,c,a,b,cin);
	input [3:0] a,b;
	input cin;
	output [3:0] s;
	output c;
		wire c0,c1,c2;
		full_adder f0(s[0],c0,a[0],b[0],cin);
		full_adder f1(s[1],c1,a[1],b[1],c0);
		full_adder f2(s[2],c2,a[2],b[2],c1);
		full_adder f3(s[3],c,a[3],b[3],c2);
endmodule

module fulladder_16bit(s,c,a,b,cin);
	input [15:0] a,b;
	input cin;
	output [15:0] s;
	output c;
		wire c0,c1,c2;
		fulladder_4bit f0(s[3:0],c0,a[3:0],b[3:0],cin);
		fulladder_4bit f1(s[7:4],c1,a[7:4],b[7:4],c0);
		fulladder_4bit f2(s[11:8],c2,a[11:8],b[11:8],c1);
		fulladder_4bit f3(s[15:12],c,a[15:12],b[15:12],c2);
endmodule
/////////////////////////////////////////////////////////
//Testbench                                            //
// module stimulus_fulladder_16bit();                  //
// reg [15:0] a,b;                                     //
// reg cin;                                            //
// wire [15:0] s;                                      //
// wire c;                                             //
// fulladder_16bit inst_fulladdder_16bit(s,c,a,b,cin); //
// initial                                             //
// begin                                               //
// a=16'h0000; b=16'h0000; cin=0;                      //
// #10 a=16'h0011; b=16'h0001; cin=1;                  //
// #10 a=16'h0110; b=16'h0001; cin=0;                  //
// #10 a=16'h1110; b=16'h0101; cin=1;                  //
// #10 a=16'h0010; b=16'h0101; cin=0;                  //
// #10 a=16'h0110; b=16'h1001; cin=1;                  //
// #10 a=16'h0011; b=16'h1001; cin=0;                  //
// #10 a=16'h0111; b=16'h1001; cin=1;                  //
// #10 a=16'h0011; b=16'h00ab; cin=0;                  //
// #10 a=16'hab11; b=16'h11cd; cin=1;                  //
// end                                                 //
// initial begin                                       //
// 	$dumpfile("ripple.vcd");                           //
// 	$dumpvars(0,stimulus_fulladder_16bit);             //
// end                                                 //
// endmodule                                           //
/////////////////////////////////////////////////////////
