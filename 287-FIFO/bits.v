`timescale 1ns/10ps
module bits (input clk, input  rst, input pushin, input [31:0] datain, 
			 input reqin, input [3:0] reqlen, output pushout,
			 output [3:0] lenout, output [14:0] dataout);


	/////////////////////
	//Internal Signals //
	/////////////////////
	reg pushout_d1;
	reg pushout_d2;
	reg [3:0] lenout_d1;
	reg [3:0] lenout_d2;

	reg [4:0]  wrt_ptr;
	reg [9:0]  rd_ptr;
	reg [15:0] dataout_flop;
	reg [15:0] dataout2;

	///////////
	//Buffer //
	///////////
	reg [1055:0] buf_fifo;

	/////////////////
	//Reg->Output //
	/////////////////
	assign pushout = pushout_d1;
	assign dataout = dataout2;
	assign lenout = lenout_d1;

	/////////////////////////
	//Write Pointer Logic //
	/////////////////////////
	always @ (posedge clk or posedge rst)
		begin  
			if (rst) begin
				wrt_ptr <=#1 0;
			end 
		else if (pushin) begin
				wrt_ptr <=  wrt_ptr + 1; //Basically a counter that increments everytime pushin is high.
		end
	end

	///////////////////////////////
	//Output through flip-flops //
	///////////////////////////////
	always @(posedge clk or posedge rst)
		begin
			if(rst)
				begin
					dataout2 <= #1 0;
					lenout_d1 <= #1 0;
					pushout_d1 <= #1 0;
				end
			else 
				begin
					pushout_d1 <= #1 pushout_d2;
					dataout2 <= #1 dataout_flop;
					lenout_d1 <= #1 lenout_d2;
				end 
	end


	///////////////////////////////
	//Buffer and Shifting Logic //
	///////////////////////////////
	always @(posedge clk)
		begin
			if (rst)
				begin
					buf_fifo <= #1 0;
					dataout_flop <= #1 0;
					rd_ptr <= #1 0;
				end
			else if(reqin)
				begin
					case (reqlen)
						0: dataout_flop <= #1 0;
						1: dataout_flop <= #1 buf_fifo[rd_ptr+:1];
						2: dataout_flop <= #1 buf_fifo[rd_ptr+:2];
						3: dataout_flop <= #1 buf_fifo[rd_ptr+:3];
						4: dataout_flop <= #1 buf_fifo[rd_ptr+:4];
						5: dataout_flop <= #1 buf_fifo[rd_ptr+:5];
						6: dataout_flop <= #1 buf_fifo[rd_ptr+:6];
						7: dataout_flop <= #1 buf_fifo[rd_ptr+:7];
						8: dataout_flop <= #1 buf_fifo[rd_ptr+:8];
						9: dataout_flop <= #1 buf_fifo[rd_ptr+:9];
						10: dataout_flop <= #1 buf_fifo[rd_ptr+:10];
						11: dataout_flop <= #1 buf_fifo[rd_ptr+:11];
						12: dataout_flop <= #1 buf_fifo[rd_ptr+:12];
						13: dataout_flop <= #1 buf_fifo[rd_ptr+:13];
						14: dataout_flop <= #1 buf_fifo[rd_ptr+:14];
						15: dataout_flop <= #1 buf_fifo[rd_ptr+:15];
						default: dataout_flop <= #1 0;
					endcase
					rd_ptr <= rd_ptr + reqlen;
				end
			if(pushin) 
				begin
					case (wrt_ptr)
						0: begin
							buf_fifo[31:0] <= #1 datain;
							buf_fifo[1055:1024] <= #1 datain;
						   end
						1: buf_fifo[63:32] <= #1 datain;
						2: buf_fifo[95:64] <= #1 datain;
						3: buf_fifo[127:96] <= #1 datain;
						4: buf_fifo[159:128] <= #1 datain;
						5: buf_fifo[191:160] <= #1 datain;
						6: buf_fifo[223:192] <= #1 datain;
						7: buf_fifo[255:224] <= #1 datain;
						8: buf_fifo[287:256] <= #1 datain;
						9: buf_fifo[319:288] <= #1 datain;
						10: buf_fifo[351:320] <= #1 datain;
						11: buf_fifo[383:352] <= #1 datain;
						12: buf_fifo[415:384] <= #1 datain;
						13: buf_fifo[447:416] <= #1 datain;
						14: buf_fifo[479:448] <= #1 datain;
						15: buf_fifo[511:480] <= #1 datain;
						16: buf_fifo[543:512] <= #1 datain;
						17: buf_fifo[575:544] <= #1 datain;
						18: buf_fifo[607:576] <= #1 datain;
						19: buf_fifo[639:608] <= #1 datain;
						20: buf_fifo[671:640] <= #1 datain;
						21: buf_fifo[703:672] <= #1 datain;
						22: buf_fifo[735:704] <= #1 datain;
						23: buf_fifo[767:736] <= #1 datain;
						24: buf_fifo[799:768] <= #1 datain;
						25: buf_fifo[831:800] <= #1 datain;
						26: buf_fifo[863:832] <= #1 datain;
						27: buf_fifo[895:864] <= #1 datain;
						28: buf_fifo[927:896] <= #1 datain;
						29: buf_fifo[959:928] <= #1 datain;
						30: buf_fifo[991:960] <= #1 datain;
						31: buf_fifo[1023:992] <= #1 datain;
						default : begin
							buf_fifo[31:0] <= #1 datain;
							buf_fifo[1055:1024] <= #1 datain;
						   end
					endcase
			end

	end
	///////////////////////
	//Output Flip-Flops //
	///////////////////////
	always @(posedge clk)
		begin
			if(rst)
				begin 
					pushout_d2<=#1 0;
					lenout_d2<=#1 0;
				end 
			else if(reqin)
				begin
					pushout_d2<=#1  1;
					lenout_d2<= #1 reqlen;
				end
			else
				begin
					pushout_d2<=#1  0;
					lenout_d2<= #1 lenout_d1;
				end
		end

endmodule
