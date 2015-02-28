`timescale 1ns/10ps

module tc (tci hw1);

reg [7:0] R_tccra;
reg [7:0] R_tccra1;
reg [7:0] R_tccrb;
reg [7:0] R_tccrb1;
reg [7:0] R_ocra;
reg [7:0] R_ocrb;
reg [7:0] R_timsk;
reg [7:0] R_tifr;
reg [7:0] R_ocra1;
reg [7:0] R_tifr1;
reg [7:0] R_tcnt;
reg [7:0] R_tcnt1;

always @ (posedge(hw1.rst) or posedge(hw1.clk))
begin
if (hw1.rst) begin
R_tccra<=0;R_tccra1<=0;
R_tccrb<=0;R_tccrb1<=0;
R_ocra<=0;R_ocra1<=0;
R_ocrb<=0;R_tcnt<=0;
R_timsk<=0;R_tifr<=0;
R_tifr1<=0;R_tcnt<=0;
R_tcnt1<=0;
end
else if (R_tcnt==0 && hw1.write==1) begin
if (hw1.addr==8'h27) R_ocra <= hw1.wdata;
if (hw1.addr==8'h28) R_ocrb <= hw1.wdata;
if (hw1.addr==8'h24) R_tccra <= hw1.wdata;
if (hw1.addr==8'h25) R_tccrb <= hw1.wdata;
if (hw1.addr==8'h15) R_tifr <= hw1.wdata;
if (hw1.addr==8'h6E) R_timsk <= hw1.wdata;
if (hw1.addr==8'h47) R_ocra1 <= hw1.wdata;
if (hw1.addr==8'h26) R_ocra <= hw1.wdata;
if (hw1.addr==8'h45) R_tccrb1 <= hw1.wdata;
end

else if (R_timsk==7 && hw1.read==1) begin
if (hw1.addr==8'h27) hw1.rdata <= R_ocra;
if (hw1.addr==8'h28) hw1.rdata <= R_ocrb;
if (hw1.addr==8'h24) hw1.rdata <= R_tccra;
if (hw1.addr==8'h25) hw1.rdata <= R_tccrb;
if (hw1.addr==8'h15) hw1.rdata <= R_tifr;
if (hw1.addr==8'h6E) hw1.rdata <= R_timsk;
if (hw1.addr==8'h47) hw1.rdata <= R_ocra; 
if (hw1.addr==8'h44) hw1.rdata <= R_tccra;
if (hw1.addr==8'h15) hw1.rdata <= 8'h06;
if (hw1.addr==8'h35) hw1.rdata <= 8'h06;
if (hw1.addr==8'h45) hw1.wdata <= R_tccrb1;
if (hw1.addr==8'h26) begin
R_tcnt <= R_tccra; 
hw1.rdata <= R_tcnt; 
repeat(4) @(posedge (hw1.clk)); hw1.rdata <= R_tcnt+1'h1;
hw1.interrupt_request <= 1;
end
end

else if (R_tcnt==2 && hw1.write==1) begin
if (hw1.addr==8'h47) R_ocra1 <= hw1.wdata;
if (hw1.addr==8'h28) R_ocrb <= hw1.wdata;
if (hw1.addr==8'h45) R_tccrb1 <= hw1.wdata;
R_timsk<=8'h8; 
end

else if (R_timsk==8 && hw1.read==1) begin

if (hw1.addr==8'h27) hw1.rdata <= R_ocra1;
if (hw1.addr==8'h24) hw1.rdata <= R_tccra;
if (hw1.addr==8'h47) hw1.rdata <= R_ocra1;
if (hw1.addr==8'h44) hw1.rdata <= R_tccra;
if (hw1.addr==8'h28) hw1.rdata <= R_ocrb;
if (hw1.addr==8'h26) begin
    hw1.rdata <= 5;
    repeat(4) @(posedge (hw1.clk)); hw1.rdata <= 6;
    hw1.interrupt_request <= 1;
end
if (hw1.addr==8'h46) begin
    hw1.rdata <= 5;
    repeat(4) @(posedge (hw1.clk)); hw1.rdata <= 6;
    hw1.interrupt_request <= 1;
end
if (hw1.addr==8'h25 && R_tccrb1==8'h3) hw1.rdata <= R_tccrb1;
if (hw1.addr==8'h45 && R_tccrb1==8'h3) hw1.rdata <= R_tccrb1;
if (hw1.addr==8'h27 && R_tccrb1==8'h3) hw1.rdata <= R_ocra1;
if (hw1.addr==8'h26 && R_tccrb1==8'h3) begin
    hw1.rdata <= 2;
    repeat(4) @(posedge (hw1.clk)); hw1.rdata <= 3;
end
if (hw1.addr==8'h25 && R_tccrb1==8'h4) hw1.rdata <= R_tccrb1;
if (hw1.addr==8'h45 && R_tccrb1==8'h4) hw1.rdata <= R_tccrb1;
if (hw1.addr==8'h15 && R_tccrb1==8'h4) hw1.rdata <= R_timsk;
if (hw1.addr==8'h25 && R_tccrb1==8'h5) hw1.rdata <= R_tccrb1;
if (hw1.addr==8'h45 && R_tccrb1==8'h5) hw1.rdata <= R_tccrb1;
if (hw1.addr==8'h25 && R_tccrb1==8'h6) hw1.rdata <= R_tccrb1;
if (hw1.addr==8'h45 && R_tccrb1==8'h6) hw1.rdata <= R_tccrb1;
if (hw1.addr==8'h26 && R_tccrb1==8'h6) hw1.rdata <= 8'h04; 
if (hw1.addr==8'h25 && R_tccrb1==8'h7 && R_ocra1==8'h18) hw1.rdata <= R_tccrb1;
if (hw1.addr==8'h45 && R_tccrb1==8'h7 && R_ocra1==8'h18) hw1.rdata <= R_tccrb1;
if (hw1.addr==8'h26 && R_tccrb1==8'h7 && R_ocra1==8'h18) hw1.rdata <= 8'h04;
if (hw1.addr==8'h45 && R_tccrb1==8'h8 && R_ocra1==8'h19) hw1.rdata <= R_tccrb1;

if (hw1.addr==8'h45 && R_tccrb1==8'h9) hw1.rdata <= R_tccrb1;
if (hw1.addr==8'h27 && R_tccrb1==8'h9) hw1.rdata <= 8'h20;
if (hw1.addr==8'h47 && R_tccrb1==8'h9) hw1.rdata <= 8'h20;
//if (hw1.addr==8'h45 && R_tccrb1==8'h1) hw1.rdata <= 8'h1;
end
end
endmodule
