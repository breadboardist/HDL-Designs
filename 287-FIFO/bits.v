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
					// if(reqlen==0)
					// 	begin 
					// 			dataout_flop<= #1 0;
					// 	end
					case (reqlen)
						0: dataout_flop = 0;
						1: dataout_flop = buf_fifo[rd_ptr+:1];
						2: dataout_flop = buf_fifo[rd_ptr+:2];
						3: dataout_flop = buf_fifo[rd_ptr+:3];
						4: dataout_flop = buf_fifo[rd_ptr+:4];
						5: dataout_flop = buf_fifo[rd_ptr+:5];
						6: dataout_flop = buf_fifo[rd_ptr+:6];
						7: dataout_flop = buf_fifo[rd_ptr+:7];
						8: dataout_flop = buf_fifo[rd_ptr+:8];
						9: dataout_flop = buf_fifo[rd_ptr+:9];
						10: dataout_flop = buf_fifo[rd_ptr+:10];
						11: dataout_flop = buf_fifo[rd_ptr+:11];
						12: dataout_flop = buf_fifo[rd_ptr+:12];
						13: dataout_flop = buf_fifo[rd_ptr+:13];
						14: dataout_flop = buf_fifo[rd_ptr+:14];
						15: dataout_flop = buf_fifo[rd_ptr+:15];
						default: dataout = 0;
					endcase
					// else if(reqlen==1)
					// 	begin
					// 		dataout_flop<= #1 buf_fifo[rd_ptr+:1];
					// 	end
					// else if(reqlen==2)
					// 	begin
					// 		dataout_flop<= #1 buf_fifo[rd_ptr+:2];
					// 	end
					// else if(reqlen ==3)
					// 	begin
					// 		dataout_flop<= #1 buf_fifo[rd_ptr+:3];
					// 	end
					// else if(reqlen==4)
					// 	begin
					// 		dataout_flop<= #1 buf_fifo[rd_ptr+:4];
					// 	end
					// else if(reqlen==5)
					// 	begin
					// 		dataout_flop<= #1 buf_fifo[rd_ptr+:5];
					// 	end
					// else if(reqlen==6)
					// 	begin
					// 		dataout_flop<= #1 buf_fifo[rd_ptr+:6];
					// 	end
					// else if(reqlen==7)
					// 	begin
					// 		dataout_flop<= #1 buf_fifo[rd_ptr+:7];
					// 	end
					// else if(reqlen==8)
					// 	begin
					// 		dataout_flop<= #1 buf_fifo[rd_ptr+:8];
					// 	end
					// else if(reqlen==9)
					// 	begin
					// 		dataout_flop<= #1 buf_fifo[rd_ptr+:9];
					// 	end
					// else if(reqlen==10)
					// 	begin
					// 		dataout_flop<=#1 buf_fifo[rd_ptr+:10];
					// 	end
					// else if(reqlen==11)
					// 	begin
					// 		dataout_flop<=#1 buf_fifo[rd_ptr+:11];
					// 	end
					// else if(reqlen==12)
					// 	begin
					// 		dataout_flop<=#1 buf_fifo[rd_ptr+:12];
					// 	end
					// else if(reqlen==13)
					// 	begin
					// 		dataout_flop<= #1 buf_fifo[rd_ptr+:13];
					// 	end
					// else if(reqlen==14)
					// 	begin
					// 		dataout_flop<= #1 buf_fifo[rd_ptr+:14];
					// 	end
					// else if(reqlen==15)
					// 	begin
					// 		dataout_flop<= #1 buf_fifo[rd_ptr+:15];
					// 	end
					rd_ptr <= rd_ptr + reqlen;
				end

			if(pushin) begin
				if(wrt_ptr == 0) begin
					buf_fifo[31:0] <= datain;
					buf_fifo[1055:1024]<=datain;
				end
			else if (wrt_ptr==1) begin
				buf_fifo[63:32]<=datain;
			end
			else if(wrt_ptr==2) begin
				buf_fifo[95:64]<=datain;
			end
			else if(wrt_ptr==3) begin
				buf_fifo[127:96]<=datain;
			end
			else if(wrt_ptr==4) begin
				buf_fifo[159:128]<=datain;
			end
			else if(wrt_ptr==5) begin
				buf_fifo[191:160]<=datain;
			end
			else if(wrt_ptr==6) begin
				buf_fifo[223:192]<=datain;
			end
			else if(wrt_ptr==7) begin
				buf_fifo[255:224]<=datain;
			end
			else if(wrt_ptr==8) begin
				buf_fifo[287:256]<=datain;
			end
			else if(wrt_ptr==9) begin
				buf_fifo[319:288]<=datain;
			end
			else if(wrt_ptr==10) begin
				buf_fifo[351:320]<=datain;
			end
			else if(wrt_ptr==11) begin
				buf_fifo[383:352]<=datain;
			end
			else if(wrt_ptr==12) begin
				buf_fifo[415:384]<=datain;
			end
			else if(wrt_ptr==13) begin
				buf_fifo[447:416]<=datain;
			end
			else if(wrt_ptr==14) begin
				buf_fifo[479:448]<=datain;
			end
			else if(wrt_ptr==15) begin
				buf_fifo[511:480]<=datain;
			end
			else if(wrt_ptr==16) begin
				buf_fifo[543:512]<=datain;
			end
			else if(wrt_ptr==17) begin
				buf_fifo[575:544]<=datain;
			end
			else if(wrt_ptr==18) begin
				buf_fifo[607:576]<=datain;
			end
			else if(wrt_ptr==19) begin
				buf_fifo[639:608]<=datain;
			end
			else if(wrt_ptr==20) begin
				buf_fifo[671:640]<=datain;
			end
			else if(wrt_ptr==21) begin
				buf_fifo[703:672]<=datain;
			end
			else if(wrt_ptr==22) begin
				buf_fifo[735:704]<=datain;
			end
			else if(wrt_ptr==23) begin
				buf_fifo[767:736]<=datain;
			end
			else if(wrt_ptr==24) begin
				buf_fifo[799:768]<=datain;
			end
			else if(wrt_ptr==25) begin
				buf_fifo[831:800]<=datain;
			end
			else if(wrt_ptr==26) begin
				buf_fifo[863:832]<=datain;
			end
			else if(wrt_ptr==27) begin
				buf_fifo[895:864]<=datain;
			end
			else if(wrt_ptr==28) begin
				buf_fifo[927:896]<=datain;
			end
			else if(wrt_ptr==29) begin
				buf_fifo[959:928]<=datain;
			end
			else if(wrt_ptr==30) begin
				buf_fifo[991:960]<=datain;
			end
			else if(wrt_ptr==31) begin
				buf_fifo[1023:992]<=datain;
			end

		end

	end
//-----------------------output---------------//
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
