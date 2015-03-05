//
// This is a single channel data receiver
// It receives the data for a channel, decides what to do with it, and then provides
// The results to the output interface(s)
// 
`timescale 1ns/10ps


module ddec(Clk,Reset,software_reset,ChData,channel_stream0,channel_stream1,channel_stream2,
channel_stream3,channel_stream4,channel_stream5,channel_stream6,channel_stream7,
channel_push,channel_num,channel_stop,channel_data,myinterface,chan_enable);

input Clk,Reset,software_reset,myinterface,chan_enable;
input [1:0] ChData;
input [15:0] channel_stream0,channel_stream1,channel_stream2,channel_stream3,channel_stream4,
		channel_stream5,channel_stream6,channel_stream7;
output channel_push;
output [7:0] channel_num;
output [9:0] channel_data;
input channel_stop;

wire [15:0] channel_stream[0:7];
assign channel_stream[0]=channel_stream0;
assign channel_stream[1]=channel_stream1;
assign channel_stream[2]=channel_stream2;
assign channel_stream[3]=channel_stream3;
assign channel_stream[4]=channel_stream4;
assign channel_stream[5]=channel_stream5;
assign channel_stream[6]=channel_stream6;
assign channel_stream[7]=channel_stream7;

// K,rdout,bitsout
function [6:0] b6dec;
input rdin;
input [5:0] bitsin;
begin
 if(rdin==0) begin
  case(bitsin)
    6'b111001: b6dec=7'b0100000;
    6'b101110: b6dec=7'b0100001;
    6'b101101: b6dec=7'b0100010;
    6'b100011: b6dec=7'b0000011;
    6'b101011: b6dec=7'b0100100;
    6'b100101: b6dec=7'b0000101;
    6'b100110: b6dec=7'b0000110;
    6'b000111: b6dec=7'b0000111;
    6'b100111: b6dec=7'b0101000;
    6'b101001: b6dec=7'b0001001;
    6'b101010: b6dec=7'b0001010;
    6'b001011: b6dec=7'b0001011;
    6'b101100: b6dec=7'b0001100;
    6'b001101: b6dec=7'b0001101;
    6'b001110: b6dec=7'b0001110;
    6'b111010: b6dec=7'b0101111;
    6'b110110: b6dec=7'b0110000;
    6'b110001: b6dec=7'b0010001;
    6'b110010: b6dec=7'b0010010;
    6'b010011: b6dec=7'b0010011;
    6'b110100: b6dec=7'b0010100;
    6'b010101: b6dec=7'b0010101;
    6'b010110: b6dec=7'b0010110;
    6'b010111: b6dec=7'b0110111;
    6'b110011: b6dec=7'b0111000;
    6'b011001: b6dec=7'b0011001;
    6'b011010: b6dec=7'b0011010;
    6'b011011: b6dec=7'b0111011;
    6'b011100: b6dec=7'b0011100;
    6'b011101: b6dec=7'b0111101;
    6'b011110: b6dec=7'b0111110;
    6'b110101: b6dec=7'b0111111;
    6'b111100: begin
	b6dec=7'b1111100;
    end
    default: begin
      b6dec=7'b0000000;
    end
  endcase

 end else begin
  case(bitsin)
    6'b000110: b6dec=7'b0000000;
    6'b010001: b6dec=7'b0000001;
    6'b010010: b6dec=7'b0000010;
    6'b100011: b6dec=7'b0100011;
    6'b010100: b6dec=7'b0000100;
    6'b100101: b6dec=7'b0100101;
    6'b100110: b6dec=7'b0100110;
    6'b111000: b6dec=7'b0100111;
    6'b011000: b6dec=7'b0001000;
    6'b101001: b6dec=7'b0101001;
    6'b101010: b6dec=7'b0101010;
    6'b001011: b6dec=7'b0101011;
    6'b101100: b6dec=7'b0101100;
    6'b001101: b6dec=7'b0101101;
    6'b001110: b6dec=7'b0101110;
    6'b000101: b6dec=7'b0001111;
    6'b001001: b6dec=7'b0010000;
    6'b110001: b6dec=7'b0110001;
    6'b110010: b6dec=7'b0110010;
    6'b010011: b6dec=7'b0110011;
    6'b110100: b6dec=7'b0110100;
    6'b010101: b6dec=7'b0110101;
    6'b010110: b6dec=7'b0110110;
    6'b101000: b6dec=7'b0010111;
    6'b001100: b6dec=7'b0011000;
    6'b011001: b6dec=7'b0111001;
    6'b011010: b6dec=7'b0111010;
    6'b100100: b6dec=7'b0011011;
    6'b011100: b6dec=7'b0111100;
    6'b100010: b6dec=7'b0011101;
    6'b100001: b6dec=7'b0011110;
    6'b001010: b6dec=7'b0011111;
    6'b000011: begin
	b6dec=7'b1011100;
    end
    default: begin
      b6dec=7'b0000000;
    end
  endcase

 end
end
endfunction

function [3:0] b4dec;
input rdin;
input M;
input [3:0] bitsin;
begin
 if(M==0) begin
  if(rdin == 0) begin
    case(bitsin)
     4'b1101: b4dec=4'b1000;
     4'b1001: b4dec=4'b0001;
     4'b1010: b4dec=4'b0010;
     4'b0011: b4dec=4'b0011;
     4'b1011: b4dec=4'b1100;
     4'b0101: b4dec=4'b0101;
     4'b0110: b4dec=4'b0110;
     4'b0111: b4dec=4'b1111;
     4'b1110: b4dec=4'b1111;
     default: begin
      b4dec=0;
     end
    endcase
  end else if(rdin==1) begin
    case(bitsin)
     4'b0010: b4dec=4'b0000;
     4'b1001: b4dec=4'b1001;
     4'b1010: b4dec=4'b1010;
     4'b1100: b4dec=4'b1011;
     4'b0100: b4dec=4'b0100;
     4'b0101: b4dec=4'b1101;
     4'b0110: b4dec=4'b1110;
     4'b1000: b4dec=4'b0111;
     4'b0001: b4dec=4'b0111;
     default: begin
      b4dec=0;
     end
    endcase
  end else begin
    b4dec=0;
  end
 end else begin
  if(rdin == 0) begin
    case(bitsin)
     4'b1101: b4dec=4'b1000;
     4'b0110: b4dec=4'b0001;
     4'b0101: b4dec=4'b0010;
     4'b0011: b4dec=4'b0011;
     4'b1011: b4dec=4'b1100;
     4'b1010: b4dec=4'b0101;
     4'b1001: b4dec=4'b0110;
     4'b1110: b4dec=4'b1111;
     default: begin
      b4dec=0;
     end
    endcase
  end else if(rdin==1) begin
    case(bitsin)
     4'b0010: b4dec=4'b0000;
     4'b1001: b4dec=4'b1001;
     4'b1010: b4dec=4'b1010;
     4'b1100: b4dec=4'b1011;
     4'b0100: b4dec=4'b0100;
     4'b0101: b4dec=4'b1101;
     4'b0110: b4dec=4'b1110;
     4'b0001: b4dec=4'b0111;
     default: begin
      b4dec=0;
     end
    endcase
  end else begin
    b4dec=0;
  end
 end
end
endfunction
//
// The simple state machine for testing purposes
//
reg [3:0] cs,ns;	// the state values
reg [4:0] cnt,cnt_d;	// counts the bits shifted in
reg [9:0] sr,sr_d;
reg sync;		// we are on the sync byte (First one).
reg bytemark,bytemark_d;	// tells when a byte is in.
reg bytemarke,bytemarke_d;	// The early version for calculation of stuff...
reg rdbyte,rdbyte_d,rd5;	// helps with the rd calculation
reg [7:0] Byte,byte_d;	// the received byte
reg M,M_d;		// was this a control code
reg [15:0] straddr,straddr_d;	// the stream address
reg strmatch;		// did we have a match on this address?
reg [7:0] chnum,chnum_d,chmatch;	//
reg _cpush,firstData,CRCdata;
reg firstData_d,CRCdata_d;


assign channel_num = chnum;
assign channel_push = _cpush;
assign channel_data = { firstData, CRCdata, Byte };

always @(negedge(Clk) or posedge(Reset)) begin
 if(Reset) begin
   cs<= #1 0;
   cnt<= #1 0;
   sr <= #1 0;
   bytemark <= #1 0;
   rdbyte <= #1 0;
   M <= #1 0;
   Byte <= #1 0;
   bytemarke <= #1 0;
   straddr <= #1 0;
   chnum <= #1 0;
   firstData <= #1 0;
   CRCdata <= #1 0;
 end else begin
   cs<= #1 ns;
   cnt<= #1 cnt_d;
   sr <= #1 sr_d;
   bytemark <= #1 bytemarke && sync==0 ;
   bytemarke <= #1 bytemarke_d;
   rdbyte <= #1 rdbyte_d;
   M <= #1 M_d;
   Byte <= #1 byte_d;
   straddr <= #1 straddr_d;
   chnum <= #1 chnum_d;
   firstData <= #1 firstData_d;
   CRCdata <= #1 CRCdata_d;
 end

end

always @(*) begin
 sr_d = {ChData,sr[9:2]};
 sync = (sr == 10'b1001111100);
 byte_d = Byte;
 rdbyte_d = rdbyte;
 M_d = M;
 if(bytemarke) begin
  {M_d,rd5,byte_d[4:0]}=b6dec(rdbyte,sr[5:0]);
  {rdbyte_d,byte_d[7:5]}=b4dec(rd5,M_d,sr[9:6]);
 end
 bytemarke_d=0;
 if(sync) begin 
   cnt_d=1;
   rdbyte_d=1;
 end else if(cnt == 4) begin
   bytemarke_d=1;
   cnt_d=0;
 end else cnt_d=cnt+1;
end

always @(*) begin : cmpadr
 integer i;
 strmatch=0;
 chmatch=0;
// if(myinterface==1) $display("ch str 0 %d chan_enable %h",channel_stream[0],chan_enable);
 for(i=0; i < 8; i=i+1) if((chan_enable==1) && (straddr == channel_stream[i])) begin
	strmatch=1;
	chmatch[i]=1;
 end
 if(straddr==0&&myinterface==0) begin
	strmatch=1;
        chmatch[0]=1;
 end
end

always @(*) begin
  ns=cs;
  straddr_d = straddr;
  chnum_d = chnum;
  _cpush=0;
  firstData_d=firstData;
  CRCdata_d=CRCdata;
  if(Reset) ns=0; else case(cs)
    0: begin
        CRCdata_d=0;
	firstData_d=0;
	if(sync) ns=1; else ns=0;
       end
    1: begin
        CRCdata_d=0;
	if(bytemark==1 && M==1 && Byte== 8'h3C) ns=2; else if(bytemark) ns=0; else ns=1;
       end
    2: if(sync) ns=1; else if(bytemark) begin
         if(M==1) begin
		ns=0;	// we had an error, start over again
         end else begin
		straddr_d[7:0]=Byte;
		ns=8;	// get the low byte of the address
         end
       end
    8: begin
        if(sync) ns=1; else if(bytemark==1) begin
          straddr_d[15:8]=Byte;
          ns=3;
        end
       end
    3: begin
       if(sync) ns=1; else
        if(strmatch) begin
	 ns=4;		// now, put out this one...
         chnum_d = chmatch;	// set up the channel number for this operation
	 firstData_d=1;
        end else ns=0;	// this one is not output, so look for the next sync pattern
    end
    4: begin		// Wait for a byte, and then push it out
       CRCdata_d=0;
       if(sync) ns=1; else
       if(bytemark==1 && M==0) ns=5; else if(bytemark==1 && M==1 && Byte== 8'h5c) begin 
	ns=6; 
        CRCdata_d=1;
        firstData_d=0;
       end else	if(bytemark==1) ns=0;
    end
    5: begin
       _cpush=1;
       if(sync==1) ns=1; else if(bytemark==1) ns=0; else
       if(channel_stop) ns=5; else begin
	 ns=4;
         firstData_d=0;
       end
    end
    6: begin
       if(sync) ns=1; else
       if(bytemark==1 && M==0) ns=7; else if(bytemark==1 && M==1 && Byte==8'hdc) begin
         ns=0;	// done with this one, look for a sync...
       end
    end
    7: begin
       _cpush=1;
       if(sync) ns=1; else
       if(channel_stop) ns=7; else begin
	 ns=6;
         CRCdata_d=0;
       end
    end
  endcase

end


endmodule

