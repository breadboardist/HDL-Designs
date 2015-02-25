//---------------------Top Module--------------------//
module bits (clk, rst, pushin, datain, reqin, reqlen, pushout, lenout, dataout);

input clk ;
input rst ;
input pushin ;
input reqin ;
input [31:0] datain ;
input [3:0] reqlen ;

output pushout;
output [3:0] lenout;
output [14:0] dataout;

wire [31:0] buf_in;
wire pop;
reg temp,q;

//always @(posedge clk or posedge rst)
//if (rst) begin 
//q <= 1'b0;
//end
//else begin
//q<= 1'b1;
//end
//
//
//assign pushout = q;

syn_fifo data_fifo (.clk(clk), .rst(rst), .data_in(datain), .rd_en(pop), .wr_en(pushin), .data_out(buf_in));
op_buffer buffer (.clk(clk), .rst(rst), .push(reqin), .din(buf_in), .shiftfac(reqlen), .dout(dataout), .bits_out(lenout), .pushop(temp), .fifo_pop(pop));

endmodule
//--------------------------------------------------------//

//------------------Data FIFO-----------------------------//
module syn_fifo (
clk      , // Clock input
rst      , // Active high reset
data_in  , // Data input
rd_en    , // Read enable
wr_en    , // Write Enable
data_out   // Data Output
//empty    , // FIFO empty
//full       // FIFO full
);

// FIFO constants
parameter DATA_WIDTH = 32;
parameter ADDR_WIDTH = 5;
parameter RAM_DEPTH = (1 << ADDR_WIDTH);
// Port Declarations
input clk ;
input rst ;

input rd_en ;
input wr_en ;
input [DATA_WIDTH-1:0] data_in ;
output [DATA_WIDTH-1:0] data_out ;

reg [ADDR_WIDTH-1:0] wr_pointer;
reg [ADDR_WIDTH-1:0] rd_pointer;
reg [ADDR_WIDTH :0] status_cnt;
reg [DATA_WIDTH-1:0] data_out ;
wire [DATA_WIDTH-1:0] data_ram ;
wire full ;
wire empty ;

//FIFO Full & Empty
assign full = (status_cnt == (RAM_DEPTH-1));
assign empty = (status_cnt == 0);

//Write Poiner
always @ (posedge clk or posedge rst)
begin : WRITE_POINTER
  if (rst) begin
    wr_pointer <= 0;
  end else if (wr_en ) begin
    wr_pointer <= wr_pointer + 1;
  end
end

// Read Pointer
always @ (posedge clk or posedge rst)
begin : READ_POINTER
  if (rst) begin
    rd_pointer <= 0;
  end else if (rd_en ) begin
    rd_pointer <= rd_pointer + 1;
  end
end

// Data Read
always  @ (posedge clk or posedge rst)
begin : READ_DATA
  if (rst) begin
    data_out <= 0;
  end else if (rd_en ) begin
    data_out <= data_ram;
  end
end

//FIFO Status
always @ (posedge clk or posedge rst)
begin : STATUS_COUNTER
  if (rst) begin
    status_cnt <= 0;
  // Read but no write.
  end else if ((rd_en) && !(wr_en)
                && (status_cnt != 0)) begin
    status_cnt <= status_cnt - 1;
  // Write but no read.
  end else if ((wr_en) && !(rd_en)
               && (status_cnt != RAM_DEPTH)) begin
    status_cnt <= status_cnt + 1;
  end
end

memory fifo_mem (clk, wr_pointer, rd_pointer, data_in, data_ram, wr_en);

endmodule
//-----------------------------------------------------------------------//

//----------------------FIFO Memory : Data-------------------------------//
module memory (clk, waddr, raddr, wdata, rdata, we);
input clk;
input [4:0] waddr;
input [4:0] raddr;
input [31:0] wdata;
input we;
output [31:0] rdata;

reg [31:0] mem [0:31];     //32x32 Memory Block
reg [31:0] opdata;

always @ (posedge clk)
begin
 if (we) begin
  mem [waddr] <= wdata;
 end
  opdata <= mem [raddr];
 end
assign rdata = opdata;
endmodule
//------------------------------------------------------------------------//

//--------------------------Output Buffer & Shifter-----------------------//
module op_buffer (
  input clk,
  input rst,
  input push,
  input [31:0] din,
  input [3:0] shiftfac,
  output [14:0] dout,
  output [3:0] bits_out,
  output pushop,
  output fifo_pop
  );

reg [3:0] shift1;
reg [31:0] buf1;
reg [14:0] buf2;
reg [14:0] buf2_out;
reg [3:0] len_out;
reg drain1;
reg [3:0 ]req_len;
reg [3:0] ptr2pos;
reg pushout_req;
reg op_valid;
//assign shift1 = shiftfac;
assign dout   = buf2_out;
assign bits_out = len_out;
assign fifo_pop = drain1;
assign pushop = op_valid;

always @ (posedge clk or posedge rst) begin
 if (rst) begin
 pushout_req <= 1'b0;
 req_len  <= 4'b0;
 end
 else
 begin
 pushout_req <= push;
 req_len  <= shiftfac;
 end
end

//Buffer 1  -> Buffer 2
always @(*)
case (ptr2pos)
 4'd0 : begin
        buf2        <= buf1[14:0];
        buf1        <= buf1 >> 15;
        drain1      <= 1'b0;
        end
 4'd1 : begin
        buf2[14:1]  <= buf1[13:0];
        buf1        <= buf1 >> 14;
        drain1      <= 1'b0;
        end
 4'd2 : begin
        buf2[14:2]  <= buf1[12:0];
        buf1        <= buf1 >> 13;
        drain1      <= 1'b0;
        end
 4'd3 : begin
        buf2[14:3]   <= buf1[11:0];
        buf1         <= buf1 >> 12;
        drain1       <= 1'b0;
        end
 4'd4 : begin
        buf2[14:4]  <= buf1[10:0];
        buf1        <= buf1 >> 11;
        drain1      <= 1'b0;
        end
 4'd5 : begin
        buf2[14:5]  <= buf1[9:0];
        buf1        <= buf1 >> 10;
        drain1      <= 1'b0;
        end
 4'd6 : begin
        buf2[14:6]  <= buf1[8:0];
        buf1        <= buf1 >> 9;
        drain1      <= 1'b0;
        end
 4'd7 : begin
        buf2[14:7]  <= buf1[7:0];
        buf1        <= buf1 >> 8;
        drain1      <= 1'b0;
        end
 4'd8 : begin
        buf2[14:8]  <= buf1[6:0];
        buf1        <= buf1 >> 7;
        drain1      <= 1'b0;
        end
 4'd9 : begin
        buf2[14:9]  <= buf1[5:0];
        buf1        <= buf1 >> 6;
        drain1      <= 1'b0;
        end
 4'd10: begin
        buf2[14:10] <= buf1[4:0];
        buf1        <= buf1 >> 5;
        drain1      <= 1'b0;
        end
 4'd11: begin
        buf2[14:11] <= buf1[3:0];
        buf1        <= buf1 >> 4;
        drain1      <= 1'b0;
        end
 4'd12: begin
        buf2[14:12] <= buf1[2:0];
        buf1        <= buf1 >> 3;
        drain1      <= 1'b0;
        end
 4'd13: begin
        buf2[14:13] <= buf1[1:0];
        buf1        <= buf1 >> 2;
        drain1      <= 1'b0;
        end
 4'd14: begin
        buf2[14]    <= buf1[0];
        buf1        <= buf1 >> 1;
        drain1      <= 1'b1;
        end
 endcase

 //Buffer 2 -> Output
 always @(posedge clk or posedge rst)
 if (rst)begin
  buf2_out <= 15'b0;
  len_out  <= 4'b0;
  ptr2pos <= 4'd0;
  op_valid <= 1'b0;
 end
 else if (pushout_req) begin
  if (req_len == 4'd0) begin
  buf2_out <= 15'b0;
  len_out  <= 4'b0;
  ptr2pos <= 4'd0;
  op_valid <= 1'b1;
  end
  else if (req_len == 4'd1) begin
  buf2_out <= {14'b0,buf2[0]};
  buf2_out <= buf2_out >> 1;
  ptr2pos <= 4'd14;
  len_out  <= 4'd1;
  op_valid <= 1'b1;
  end
  else if (req_len == 4'd2) begin
  buf2_out <= {13'b0,buf2[1:0]};
  buf2_out <= buf2_out >> 2;
  ptr2pos <= 4'd13;
  len_out  <= 4'd2;
  op_valid <= 1'b1;
  end
  else if (req_len == 4'd3) begin
  buf2_out <= {12'b0,buf2[2:0]};
  buf2_out <= buf2_out >> 3;
  ptr2pos <= 4'd12;
  len_out  <= 4'd3;
  op_valid <= 1'b1;
  end
  else if (req_len == 4'd4) begin
  buf2_out <= {11'b0,buf2[3:0]};
  buf2_out <= buf2_out >> 4;
  ptr2pos <= 4'd11;
  len_out  <= 4'd4;
  op_valid <= 1'b1;
  end
  else if (req_len == 4'd5) begin
  buf2_out <= {10'b0,buf2[4:0]};
  buf2_out <= buf2_out >> 5;
  ptr2pos <= 4'd10;
  len_out  <= 4'd5;
  op_valid <= 1'b1;
  end
  else if (req_len == 4'd6) begin
  buf2_out <= {9'b0,buf2[5:0]};
  buf2_out <= buf2_out >> 6;
  ptr2pos <= 4'd9;
  len_out  <= 4'd6;
  op_valid <= 1'b1;
  end
  else if (req_len == 4'd7) begin
  buf2_out <= {8'b0,buf2[6:0]};
  buf2_out <= buf2_out >> 7;
  ptr2pos <= 4'd8;
  len_out  <= 4'd7;
  op_valid <= 1'b1;
  end
  else if (req_len == 4'd8) begin
  buf2_out <= {7'b0,buf2[7:0]};
  buf2_out <= buf2_out >> 8;
  ptr2pos <= 4'd7;
  len_out  <= 4'd8;
  op_valid <= 1'b1;
  end
  else if (req_len == 4'd9) begin
  buf2_out <= {6'b0,buf2[8:0]};
  buf2_out <= buf2_out >> 9;
  ptr2pos <= 4'd6;
  len_out  <= 4'd9;
  op_valid <= 1'b1;
  end
  else if (req_len == 4'd10) begin
  buf2_out <= {5'b0,buf2[9:0]};
  buf2_out <= buf2_out >> 10;
  ptr2pos <= 4'd5;
  len_out  <= 4'd10;
  op_valid <= 1'b1;
  end
  else if (req_len == 4'd11) begin
  buf2_out <= {4'b0,buf2[10:0]};
  buf2_out <= buf2_out >> 11;
  ptr2pos <= 4'd4;
  len_out  <= 4'd11;
  op_valid <= 1'b1;
  end
  else if (req_len == 4'd12) begin
  buf2_out <= {3'b0,buf2[11:0]};
  buf2_out <= buf2_out >> 12;
  ptr2pos <= 4'd3;
  len_out  <= 4'd12;
  op_valid <= 1'b1;
  end
  else if (req_len == 4'd13) begin
  buf2_out <= {2'b0,buf2[12:0]};
  buf2_out <= buf2_out >> 13;
  ptr2pos <= 4'd2;
  len_out  <= 4'd13;
  op_valid <= 1'b1;
  end
  else if (req_len == 4'd14) begin
  buf2_out <= {1'b0,buf2[13:0]};
  buf2_out <= buf2_out >> 14;
  ptr2pos <= 4'd1;
  len_out  <= 4'd14;
  op_valid <= 1'b1;
  end
  else if (req_len == 4'd15) begin
  buf2_out <= buf2[14:0];
  buf2_out <= buf2_out >> 15;
  ptr2pos <= 4'd0;
  len_out  <= 4'd15;
  op_valid <= 1'b1;
  end
 else
  op_valid <= 1'b0;
  end

  endmodule
  //-------------------------------------------------------//
