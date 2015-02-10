`timescale 1ns/10ps
module tc (tci ai);

  logic [7:0] A_tccra;
  logic [7:0] A_tccra1;
  logic [7:0] A_tccrb;
  logic [7:0] A_tccrb1;
  logic [7:0] A_ocra;
  logic [7:0] A_ocra1;
  logic [7:0] A_ocrb;
  logic [7:0] A_ocrb1;
  logic [7:0] A_tcnt;
  logic [7:0] A_tcnt1;
  logic [7:0] A_timsk;
  logic [7:0] A_tifr;
  logic [7:0] A_tifr1;
  logic [31:0] i;
  bit out_clk;


  always @ (posedge(ai.clk) or posedge(ai.rst)) 
    begin
      //If reset is sent, Loading all registers with zero.
      if(ai.rst) 
        begin
        	ai.write<=0;
        	ai.addr<=0;
        	ai.wdata<=0;
        	ai.read<=0;
        	ai.rdata<=0;
        	ai.t0<=0;
        	ai.oca_data<=0;
        	ai.ocb_data<=0;
        	ai.status_reg_interrupt_enable<=0;
        	ai.interrupt_request<=0;
        	ai.interrupt_executed<=0;
        	A_tccra<=0;
        	A_tccra1<=0;
          A_tccrb<=0;
          A_tccrb1<=0;
          A_ocra<=0;
          A_ocra1<=0;
          A_ocrb<=0;
          A_ocrb1<=0;
          A_tcnt<=0;
          A_tcnt1<=0;
          A_timsk<=0;
          A_tifr<=0;
          A_tifr1<=0;
        end
        //If write data is sent, Writing all registers with data from bus
        if(ai.write)
          begin
            case(ai.addr)
              8'h24: begin 
              A_tccra<=ai.wdata;
              A_tccra1<=ai.wdata;
              end
              8'h44: begin 
              A_tccra1<=ai.wdata;
              A_tccra<=ai.wdata;
              end
              8'h25: begin 
              A_tccrb<=ai.wdata;
              A_tccrb1<=ai.wdata;
              end
              8'h45: begin 
              A_tccrb1<=ai.wdata;
              A_tccrb<=ai.wdata;
              end
              8'h27: begin 
              A_ocra<=ai.wdata;
              A_ocra1<=ai.wdata;
              end
              8'h47: begin 
              A_ocra1<=ai.wdata;
              A_ocra<=ai.wdata;
              end
              8'h28: begin
              A_ocrb<=ai.wdata;
              A_ocrb1<=ai.wdata;
              end
              8'h48: begin
              A_ocrb1<=ai.wdata;
              A_ocrb<=ai.wdata;
              end
              8'h26: begin 
              A_tcnt<=ai.wdata;
              A_tcnt1<=ai.wdata;
              end
              8'h46: begin 
              A_tcnt1<=ai.wdata;
              A_tcnt<=ai.wdata;
              end
              8'h6e: begin
              A_timsk<=ai.wdata;
              end
              8'h15: begin 
              A_tifr<=ai.wdata;
              A_tifr1<=ai.wdata;
              end
              8'h35: begin 
              A_tifr1<=ai.wdata;
              A_tifr<=ai.wdata;
              end
            endcase
          end
        //If read data is sent, data from register is read on to the bus
        if(ai.read) begin
          case(ai.addr) 
          8'h24: ai.rdata<=A_tccra;
          8'h44: ai.rdata<=A_tccra1;
          8'h25: ai.rdata<=A_tccrb;
          8'h45: ai.rdata<=A_tccrb1;
          8'h27: ai.rdata<=A_ocra;
          8'h47: ai.rdata<=A_ocra1;
          8'h28: ai.rdata<=A_ocrb;
          8'h48: ai.rdata<=A_ocrb1;
          8'h26: ai.rdata<=A_tcnt;
          8'h46: ai.rdata<=A_tcnt1;
          8'h6e: ai.rdata<=A_timsk;
          8'h15: ai.rdata<=A_tifr;
          8'h35: ai.rdata<=A_tifr1;
          endcase
        end

        /* Setting the interrupt register to proper interrupt conditions */

        //If interrupt request is granted, set interrupt_request bit to 0
        if(ai.interrupt_executed) 
        ai.interrupt_request<=0;

        //Compare counter with Output Compare A

        if(A_tcnt==A_ocra) begin 
        A_tifr[1]<=1;
        ai.interrupt_request<=1;
        end
  
        if(A_tcnt1==A_ocra1) begin 
        A_tifr1[1]<=1;
        ai.interrupt_request<=1;
        end

        //Compare counter with Output Compare B

        if(A_tcnt==A_ocrb) begin 
        A_tifr[2]<=1;
        ai.interrupt_request<=1;
        end
        
        if(A_tcnt1==A_ocrb1) begin 
        A_tifr1[2]<=1;
        ai.interrupt_request<=1;
        end


        //Check if timer is in Normal mode  
        if(A_tccra[1:0]==0 && A_tccrb[3]==0) begin
          if(A_tcnt==0) 
          A_tifr[0]<=1; 
          else if (ai.interrupt_executed)
          A_tifr[0]<=0;
        end
        
        if(A_tccra1[1:0]==0 && A_tccrb1[3]==0) begin
          if(A_tcnt1==0) 
          A_tifr1[0]<=1;
          else if (ai.interrupt_executed)
          A_tifr1[0]<=0;
        end
  
        //Setting interrupt flags to zero, once they are read  
        if(A_tifr[2]==1)
        A_tifr[2]<=0;
        
        if(A_tifr1[2]==1) 
        A_tifr1[2]<=0;
        
        if(A_tifr[1]==1) 
        A_tifr[1]<=0;
        
        if(A_tifr1[1]==1) 
        A_tifr1[1]<=0;
        
        if(A_tifr[0]==1) 
        A_tifr[0]<=0;
        
        if(A_tifr1[0]==1) 
        A_tifr1[0]<=0;


        //Set interrupt flag based on interrupt register and interrupt mask
        if(A_timsk[2]==1 && ai.status_reg_interrupt_enable) begin 
          ai.interrupt_request<=1;
        
          if(A_tifr[2]==1 && ai.status_reg_interrupt_enable) 
          ai.interrupt_executed<=1;
          
          if(A_tifr1[2]==1 && ai.status_reg_interrupt_enable) 
          ai.interrupt_executed<=1;
        end
        
        if(A_timsk[1]==1 && ai.status_reg_interrupt_enable) begin 
          ai.interrupt_request<=1;
  
          if(A_tifr[1]==1 && ai.status_reg_interrupt_enable) 
          ai.interrupt_executed<=1;
          
          if(A_tifr1[1]==1 && ai.status_reg_interrupt_enable) 
          ai.interrupt_executed<=1;
        end
  
        if(A_timsk[0]==1 && ai.status_reg_interrupt_enable) begin 
          ai.interrupt_request<=1;

          if(A_tifr[0]==1) 
          ai.interrupt_executed<=1;
          
          if(A_tifr1[0]==1) 
          ai.interrupt_executed<=1;
        end

end
//ending always block one

initial i=0;

//Basic counter, simply increments i
always @(posedge(ai.clk)) 
  begin
     if(i<7)
     i<=i+1;
     else
     i<=0;
   end
 
always @(i) 
  begin
    if(i<1)
    out_clk<=1;
    else
    out_clk<=0;
  end
//Always counter ended


always @ (posedge(out_clk))
 begin
  if(A_tccra[0]==0 && A_tccra[1]==1 && A_tccrb[3]==0) 
    begin
      A_tcnt<=A_tcnt+1;
      if(A_ocra<A_tcnt) begin
      A_tcnt<=255;
      A_tcnt<=0;
      end     
      if(A_tcnt==A_ocra) begin
      A_tcnt<=0;
      A_tifr[1]<=1;
      ai.interrupt_request<=1;
      end
    end
  
  if(A_tccra1[0]==0 && A_tccra1[1]==1 && A_tccrb1[3]==0) 
    begin
      A_tcnt1<=A_tcnt1+1;
      if(A_ocra1<A_tcnt1) begin
      A_tcnt1<=255;
      A_tcnt1<=0;
      end
      
      if(A_tcnt1==A_ocra1) begin
      A_tcnt1<=0;
      A_tifr1[1]<=1;
      ai.interrupt_request<=1;
      end
    end
end

endmodule



