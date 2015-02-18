// Design with error number 1
// The timer counter described in the atmel document
`timescale 1ns/10ps


module tc(tci.tc ai);

typedef struct packed {
	logic [1:0] coma;
	logic [1:0] comb;
	logic [1:0] reserved;
	logic [1:0] wgm10;
} tccra_struct;

typedef struct packed {
	logic foca;
	logic focb;
	logic [1:0] reserved;
	logic wgm2;
	logic [2:0] cs;
} tccrb_struct;

typedef struct packed {
  logic [4:0] reserved;
  logic ocieb;
  logic ociea;
  logic toie;
 } timsk_struct;

typedef struct packed {
  logic [4:0] reserved;
  logic ocfb;
  logic ocfa;
  logic tov;
 } tifr_struct;

tccra_struct tccra,tccra_d;
tccrb_struct tccrb,tccrb_d;
timsk_struct timsk,timsk_d;
tifr_struct tifr,tifr_d;

logic [2:0] wgm;

reg [7:0] tcnt,tcnt_d,ocra,ocra_d,ocrb,ocrb_d;
reg [7:0] ocra_wk,ocra_wk_d,ocrb_wk,ocrb_wk_d;
reg [10:0] clkdiv,clkdiv_d;
reg t0a,t0b;
reg tov,tov_d;
reg top;
reg bottom;

logic timer_event;
logic oca_raw,ocb_raw;
reg oca_d,oca,ocb_d,ocb;
reg cntdir,cntdir_d;
reg irq,irq_d,intr_exec;

assign ai.oca_data = oca;
assign ai.ocb_data = ocb;
assign ai.interrupt_request=irq;

always @(*) begin
  ai.rdata=8'bX;
  if(ai.read) case(ai.addr)
    8'h66,8'h46: ai.rdata = tcnt;
    8'h27,8'h47: ai.rdata = ocra;
    8'h28,8'h48: ai.rdata = ocrb;
    8'h24,8'h44: ai.rdata = tccra;
    8'h25,8'h45: ai.rdata = tccrb;
    8'h6e: ai.rdata = timsk;
    8'h15,8'h35: ai.rdata = tifr;
  endcase

end


always @(*) begin
  tccrb_d = tccrb;
  tccra_d = tccra;
  tcnt_d = tcnt;
  tov_d = tov;
  ocra_d = ocra;
  ocrb_d = ocrb;
  ocra_wk_d = ocra_wk;
  ocrb_wk_d = ocrb_wk;
  oca_raw = ocra_wk == tcnt;
  ocb_raw = ocrb_wk == tcnt;
  timsk_d = timsk;
  top=0;
  tov=0;
  bottom=0;
  cntdir_d = cntdir;
  oca_d = oca;
  ocb_d = ocb;
  tifr_d = tifr;

  wgm = { tccrb.wgm2, tccra.wgm10};
    case(tccrb.cs)
    0: timer_event=0;
    1: timer_event=1;
    2: timer_event=clkdiv[2:0]==0;
    3: timer_event=clkdiv[5:0]==0;
    4: timer_event=clkdiv[7:0]==0;
    5: timer_event=clkdiv[9:0]==0;
    6: timer_event= t0b&(~t0a);
    7: timer_event= (~t0b)&t0a;
  endcase
  clkdiv_d = clkdiv+1;

  if(ai.write && (ai.addr==8'h26||ai.addr==8'h46)) begin
    tcnt_d = ai.wdata;
  end else begin
    if(timer_event) case(wgm)
      0: begin
           tcnt_d = tcnt+1;
           if(tcnt_d == 8'hff) begin
             tov=1;
             top=1;
           end
           if(tcnt_d == 8'h00) bottom=1;
           ocra_wk_d = ocra;
           ocrb_wk_d = ocrb;
         end
      1: begin
           tcnt_d = tcnt + ((cntdir)?8'hff:8'h1);
           if(tcnt_d==0) begin
             tov=1;
             cntdir_d=0;
           end
           if(tcnt_d==8'hff) begin
             cntdir_d=1;
             ocra_wk_d = ocra;
             ocrb_wk_d = ocrb;
           end
         end
      2: begin
           tcnt_d = tcnt+1;
           if(tcnt == ocra) begin
             top=1;
             tcnt_d=0;
           end
           tov = (tcnt_d == 8'hff);
           ocra_wk_d = ocra;
           ocrb_wk_d = ocrb;
         end
      3: begin
           tcnt_d = tcnt + 1;
           if(tcnt_d==0) begin
             ocra_wk_d = ocra;
             ocrb_wk_d = ocrb;
             end
           if(tcnt==8'hff) begin
             tov=1;
           end
         end
      4: begin
         end
      5: begin
           tcnt_d = tcnt + ((cntdir)?8'hff:8'h1);
           if(tcnt_d==0) begin
             tov=1;
             cntdir_d=0;
           end
           if(tcnt_d==ocra_wk) begin
             cntdir_d=1;
             ocra_wk_d = ocra;
             ocrb_wk_d = ocrb;
           end
         end
      6: begin

         end
      7: begin
           tcnt_d = tcnt + 1;
           if(tcnt_d==0) begin
             ocra_wk_d = ocra;
             ocrb_wk_d = ocrb;
             end
           if(tcnt==ocra_wk) begin
             tcnt_d=0;
           end
           if(tcnt_d == 8'hff) tov=1;
         end
    endcase
  end
  if(ai.write && (ai.addr == 8'h25 || ai.addr == 8'h45)) begin
    tccrb_d = ai.wdata;
    tccrb_d.reserved = 0;
  end else begin
    tccrb_d.foca=0;
    tccrb_d.focb=0;
  end
  if(ai.write && (ai.addr == 8'h24 || ai.addr == 8'h44)) begin
    tccra_d = ai.wdata;
    tccra_d.reserved = 0;
  end else begin
  end
  if(ai.write && (ai.addr == 8'h27 || ai.addr == 8'h47)) begin
    ocra_d = ai.wdata;
  end
  if(ai.write && (ai.addr == 8'h28 || ai.addr == 8'h48)) begin
    ocrb_d = ai.wdata;
  end
  if(ai.write && (ai.addr == 8'h6e)) begin
    timsk_d = { 5'b0, ai.wdata[2:0]};
  end
  if(timer_event==1) case(tccra.wgm10)
    0,2: begin
           if(oca_raw) case(tccra.coma)
             0: oca_d = 0;
             1: oca_d = ~ oca;
             2: oca_d = 0;
             3: oca_d = 1;
           endcase
           if(ocb_raw) case(tccra.comb)
             0: ocb_d = 0;
             1: ocb_d = ~ ocb;
             2: ocb_d = 0;
             3: ocb_d = 1;
           endcase
         end
    3:   begin // fast pwm
    	   if(oca_raw) case(tccra.coma)
    	     0: oca_d = 0;
    	     1: oca_d = (tccrb.wgm2)?oca:0;
    	     2: oca_d = 0;
    	     3: oca_d = 1;
    	   endcase
    	   if(bottom && tccra.coma==2) ocra_d = 1;
    	   if(bottom && tccra.coma==3) ocra_d = 0;
    	   if(ocb_raw) case(tccra.comb)
    	     0: ocb_d = 0;
    	     2: ocb_d = 0;
    	     3: ocb_d = 1;
    	   endcase
    	   if(bottom && tccra.comb==2) ocrb_d = 1;
    	   if(bottom && tccra.comb==3) ocrb_d = 0;
         end
    1:   begin
           if(oca_raw) case(tccra.coma)
             0: oca_d=0;
             1: oca_d=(tccrb.wgm2)?~oca:0;
             2: oca_d=cntdir;
             3: oca_d=~cntdir;
           endcase
           if(ocb_raw) case(tccra.comb)
             0: ocb_d=0;
             2: ocb_d=cntdir;
             3: ocb_d=~cntdir;
           endcase
         end
  endcase
  if(ai.write && (ai.addr==8'h15 || ai.addr==8'h35))begin
    tifr_d[2:0]= tifr_d[2:0] & (~ai.wdata[2:0]);
  end
  intr_exec = irq & ai.interrupt_executed;
  if(oca_raw && timer_event) begin
    tifr_d.ocfa = 1;
  end
  if(ocb_raw && timer_event) begin
    tifr_d.ocfb=1;
  end
  if(tov && timer_event ) begin
    tifr_d.tov=1;
  end
  if(intr_exec) begin
    tifr=0;
  end
  irq_d = (((tifr&timsk) != 0) && ai.status_reg_interrupt_enable!=0)&(!intr_exec);

end


always @(posedge(ai.clk) or posedge(ai.rst)) begin
  if(ai.rst) begin
    tccra<= #1 0;
    tccrb<= #1 0;
    timsk<= #1 0;
    tifr <= #1 0;
    tcnt <= #1 0;
    ocra <= #1 0;
    ocrb <= #1 0;
    t0a <= #1 0;
    t0b <= #1 0;
    clkdiv <= #1 0;
    tov <= #1 0;
    cntdir <= #1 0;
    oca <= #1 0;
    ocb <= #1 0;
    irq <= #1 0;
    ocra_wk <= #1 0;
    ocrb_wk <= #1 0;
  end else begin
    tccra <= #1 tccra_d;
    tccrb <= #1 tccrb_d;
    timsk <= #1 timsk_d;
    tifr <= #1 tifr_d;
    tcnt <= #1 tcnt_d;
    ocra <= #1 ocra_d;
    ocrb <= #1 ocrb_d;
    t0a <= #1 ai.t0;
    t0b <= #1 t0a;
    clkdiv <= #1 clkdiv_d;
    tov <= #1 tov_d;
    cntdir <= #1 cntdir_d;
    oca <= #1 oca_d;
    ocb <= #1 ocb_d;
    irq <= #1 irq_d;
    ocra_wk <= #1 ocra_wk_d;
    ocrb_wk <= #1 ocrb_wk_d;
  end

end



endmodule


