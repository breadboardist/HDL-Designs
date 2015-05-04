///////////////////////////////
//32-bit to 15-bit(max) FIFO //
//Prem Bharath Soundararajan //
///////////////////////////////
`timescale 1ns/10ps
module bits (input clk, input  rst, input pushin, input [31:0] datain, 
			 input reqin, input [3:0] reqlen, output pushout, input scanIn, input scanEnable, output scanOut,
			 output [3:0] lenout, output [14:0] dataout);


	/////////////////////
	//Internal Signals //
	/////////////////////
	reg pushout_stg_1;
	reg pushout_stg_2;
	reg [3:0] lenout_stg_1;
	reg [3:0] lenout_stg_2;
	reg [4:0]  wrt_ptr;
	reg [9:0]  rd_ptr;
	reg [15:0] dataout_stg_1;
	reg [15:0] dataout_stg_2;

	///////////
	//Buffer //
	///////////
	reg [1055:0] buffer;

	/////////////////
	//Reg->Output //
	/////////////////
	assign pushout = pushout_stg_2;
	assign dataout = dataout_stg_2;
	assign lenout = lenout_stg_2;
	assign scanOut = (scanEnable)?wrt_ptr[4]:0; /*Not in unscannable BITS*/

	/////////////////////////
	//Write Pointer Logic //
	/////////////////////////
	always @ (posedge clk or posedge rst)
		begin  
			if (rst) begin
				wrt_ptr <=#1 0;
			end 
		else if (pushin) begin
			if (scanEnable) begin /*Not in unscannable BITS*/
				wrt_ptr <= {wrt_ptr[3:0], scanIn}; /*Not in unscannable BITS*/
			end
			else begin wrt_ptr <=  wrt_ptr + 1; end
		end
	end

	///////////////////////////////
	//Output through flip-flops //
	///////////////////////////////
	always @(posedge clk or posedge rst)
		begin
			if(rst)
				begin
					dataout_stg_2 <= #1 0;
					lenout_stg_2 <= #1 0;
					pushout_stg_2 <= #1 0;
				end
			else 
				begin
					pushout_stg_2 <= #1 pushout_stg_1;
					dataout_stg_2 <= #1 dataout_stg_1;
					lenout_stg_2 <= #1 lenout_stg_1;
				end 
	end

	always @(posedge clk)
		begin
			if(rst)
				begin 
					pushout_stg_1 <= #1 0;
					lenout_stg_1 <= #1 0;
				end 
			else if(reqin)
				begin
					pushout_stg_1 <= #1  1;
					lenout_stg_1 <= #1 reqlen;
				end
			else
				begin
					pushout_stg_1 <= #1  0;
					lenout_stg_1 <= #1 lenout_stg_2;
				end
	end


	///////////////////////////////
	//Buffer and Shifting Logic //
	///////////////////////////////
	always @(posedge clk)
		begin
			if (rst)
				begin
					buffer <= #1 0;
					dataout_stg_1 <= #1 0;
					rd_ptr <= #1 0;
				end
			else if(reqin)
				begin
					case (reqlen)
						0: dataout_stg_1 <= #1 0;
						1: dataout_stg_1 <= #1 buffer[rd_ptr+:1];
						2: dataout_stg_1 <= #1 buffer[rd_ptr+:2];
						3: dataout_stg_1 <= #1 buffer[rd_ptr+:3];
						4: dataout_stg_1 <= #1 buffer[rd_ptr+:4];
						5: dataout_stg_1 <= #1 buffer[rd_ptr+:5];
						6: dataout_stg_1 <= #1 buffer[rd_ptr+:6];
						7: dataout_stg_1 <= #1 buffer[rd_ptr+:7];
						8: dataout_stg_1 <= #1 buffer[rd_ptr+:8];
						9: dataout_stg_1 <= #1 buffer[rd_ptr+:9];
						10: dataout_stg_1 <= #1 buffer[rd_ptr+:10];
						11: dataout_stg_1 <= #1 buffer[rd_ptr+:11];
						12: dataout_stg_1 <= #1 buffer[rd_ptr+:12];
						13: dataout_stg_1 <= #1 buffer[rd_ptr+:13];
						14: dataout_stg_1 <= #1 buffer[rd_ptr+:14];
						15: dataout_stg_1 <= #1 buffer[rd_ptr+:15];
						default: dataout_stg_1 <= #1 0;
					endcase
					rd_ptr <= rd_ptr + reqlen;	//Keep moving the read pointer until it wraps around. Imagine it more like a 
												//circular slider than a stack of plates.
				end
			if(pushin) 
				begin
					case (wrt_ptr)
						0: begin
							buffer[31:0] <= #1 datain;
							buffer[1055:1024] <= #1 datain;
						   end
						1: buffer[63:32] <= #1 datain;
						2: buffer[95:64] <= #1 datain;
						3: buffer[127:96] <= #1 datain;
						4: buffer[159:128] <= #1 datain;
						5: buffer[191:160] <= #1 datain;
						6: buffer[223:192] <= #1 datain;
						7: buffer[255:224] <= #1 datain;
						8: buffer[287:256] <= #1 datain;
						9: buffer[319:288] <= #1 datain;
						10: buffer[351:320] <= #1 datain;
						11: buffer[383:352] <= #1 datain;
						12: buffer[415:384] <= #1 datain;
						13: buffer[447:416] <= #1 datain;
						14: buffer[479:448] <= #1 datain;
						15: buffer[511:480] <= #1 datain;
						16: buffer[543:512] <= #1 datain;
						17: buffer[575:544] <= #1 datain;
						18: buffer[607:576] <= #1 datain;
						19: buffer[639:608] <= #1 datain;
						20: buffer[671:640] <= #1 datain;
						21: buffer[703:672] <= #1 datain;
						22: buffer[735:704] <= #1 datain;
						23: buffer[767:736] <= #1 datain;
						24: buffer[799:768] <= #1 datain;
						25: buffer[831:800] <= #1 datain;
						26: buffer[863:832] <= #1 datain;
						27: buffer[895:864] <= #1 datain;
						28: buffer[927:896] <= #1 datain;
						29: buffer[959:928] <= #1 datain;
						30: buffer[991:960] <= #1 datain;
						31: buffer[1023:992] <= #1 datain;
						default : begin
							buffer[31:0] <= #1 datain;
							buffer[1055:1024] <= #1 datain;
						   end
					endcase
			end

	end
endmodule
