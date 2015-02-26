`timescale 1ns/10ps
 

module bits (input clk,input  rst, input pushin, input [31:0] datain, 
             input reqin,input 
             [3:0] reqlen, 
             output  pushout, output [3:0] lenout,output [14:0] dataout);
   
   
//---------------Internal registers-----------------//
reg pushout_d1;
reg pushout_d2;
reg [3:0] lenout_d1;
reg [3:0] lenout_d2;

reg [4:0]  wr_p;
reg [9:0]  r_p;
reg [15:0] dataout_flop;
reg [15:0] dataout2;

//---------fifo----------------//
reg [1055:0] buf_fifo;

//---------------assign outputs -----------------//

assign pushout=pushout_d1;
assign dataout= dataout2;
assign lenout= lenout_d1;

//--------------write pointer------------------------//

always @ (posedge clk or posedge rst)
begin  
      if (rst) begin
		wr_p <=#1 0;
	      end 
  else if (pushin) begin
		wr_p <=  wr_p + 1;
		end
end

//------------------Flipflops---------------//
always @(posedge clk or posedge rst)
begin
if(rst)
begin
  dataout2<=#1 0;
    lenout_d1<=#1 0;
    pushout_d1<=#1 0;
 end
else begin
pushout_d1<=#1 pushout_d2;
dataout2<=#1 dataout_flop;
lenout_d1<=#1 lenout_d2;
end 
end


//------------------------output -----------------------//
always @(posedge clk)
begin

if (rst)
begin
buf_fifo<= #1 0;
dataout_flop<=#1 0;
r_p<=#1 0;
end
else if(reqin)
begin
	    if(reqlen==0)
	    begin 
	    dataout_flop<= #1 0;
	    end
	    
	    else if(reqlen==1)
	    begin
	    dataout_flop<= #1 buf_fifo[r_p+:1];
	    end
	    else if(reqlen==2)
	    begin
	    dataout_flop<= #1 buf_fifo[r_p+:2];
	    end
	    else if(reqlen ==3)
	    begin
	    dataout_flop<= #1 buf_fifo[r_p+:3];
	    end
	    else if(reqlen==4)
	    begin
	    dataout_flop<= #1 buf_fifo[r_p+:4];
	    end
	    else if(reqlen==5)
	    begin
	    dataout_flop<= #1 buf_fifo[r_p+:5];
	    end
	    else if(reqlen==6)
	    begin
	    dataout_flop<= #1 buf_fifo[r_p+:6];
	    end
	    else if(reqlen==7)
	    begin
	    dataout_flop<= #1 buf_fifo[r_p+:7];
	    end
	    else if(reqlen==8)
	    begin
	    dataout_flop<= #1 buf_fifo[r_p+:8];
	    end
	    else if(reqlen==9)
	    begin
	    dataout_flop<= #1 buf_fifo[r_p+:9];
	    end
	    else if(reqlen==10)
	    begin
	    dataout_flop<=#1 buf_fifo[r_p+:10];
	    end
	    else if(reqlen==11)
	    begin
	    dataout_flop<=#1 buf_fifo[r_p+:11];
	    end
	    else if(reqlen==12)
	    begin
	    dataout_flop<=#1 buf_fifo[r_p+:12];
	    end
	    else if(reqlen==13)
	    begin
	    dataout_flop<= #1 buf_fifo[r_p+:13];
	    end
	    else if(reqlen==14)
	    begin
	    dataout_flop<= #1 buf_fifo[r_p+:14];
	    end
	    else if(reqlen==15)
	    begin
	    dataout_flop<= #1 buf_fifo[r_p+:15];
	    end

r_p <= r_p + reqlen;
end

if(pushin) begin
	if(wr_p == 0) begin
	  buf_fifo[31:0] <= datain;
	  buf_fifo[1055:1024]<=datain;
	  end
	    else if (wr_p==1) begin
	      buf_fifo[63:32]<=datain;
	      end
	    else if(wr_p==2) begin
	      buf_fifo[95:64]<=datain;
	      end
	    else if(wr_p==3) begin
	      buf_fifo[127:96]<=datain;
	      end
	    else if(wr_p==4) begin
	      buf_fifo[159:128]<=datain;
	      end
	    else if(wr_p==5) begin
	      buf_fifo[191:160]<=datain;
	      end
	    else if(wr_p==6) begin
	      buf_fifo[223:192]<=datain;
	      end
	    else if(wr_p==7) begin
	      buf_fifo[255:224]<=datain;
	      end
	    else if(wr_p==8) begin
	      buf_fifo[287:256]<=datain;
	      end
	else if(wr_p==9) begin
	  buf_fifo[319:288]<=datain;
	  end
	  else if(wr_p==10) begin
	  buf_fifo[351:320]<=datain;
	  end
	  else if(wr_p==11) begin
	  buf_fifo[383:352]<=datain;
	  end
	  else if(wr_p==12) begin
	  buf_fifo[415:384]<=datain;
	  end
	  else if(wr_p==13) begin
	  buf_fifo[447:416]<=datain;
	  end
	  else if(wr_p==14) begin
	  buf_fifo[479:448]<=datain;
	  end
	  else if(wr_p==15) begin
	  buf_fifo[511:480]<=datain;
	  end
	  else if(wr_p==16) begin
	  buf_fifo[543:512]<=datain;
	  end
	  else if(wr_p==17) begin
	  buf_fifo[575:544]<=datain;
	  end
	  else if(wr_p==18) begin
	  buf_fifo[607:576]<=datain;
	  end
	  else if(wr_p==19) begin
	  buf_fifo[639:608]<=datain;
	  end
	  else if(wr_p==20) begin
	  buf_fifo[671:640]<=datain;
	  end
	  else if(wr_p==21) begin
	  buf_fifo[703:672]<=datain;
	  end
	  else if(wr_p==22) begin
	  buf_fifo[735:704]<=datain;
	  end
	  else if(wr_p==23) begin
	  buf_fifo[767:736]<=datain;
	  end
	  else if(wr_p==24) begin
	  buf_fifo[799:768]<=datain;
	  end
	  else if(wr_p==25) begin
	  buf_fifo[831:800]<=datain;
	  end
	  else if(wr_p==26) begin
	  buf_fifo[863:832]<=datain;
	  end
	  else if(wr_p==27) begin
	  buf_fifo[895:864]<=datain;
	  end
	  else if(wr_p==28) begin
	  buf_fifo[927:896]<=datain;
	  end
	  else if(wr_p==29) begin
	  buf_fifo[959:928]<=datain;
	  end
	  else if(wr_p==30) begin
	  buf_fifo[991:960]<=datain;
	  end
	  else if(wr_p==31) begin
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
