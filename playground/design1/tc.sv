
module tc(tci g);

logic [7:0]tccra;
logic [7:0]tccra1;
logic [7:0]tccrb;
logic [7:0]tccrb1;
logic [7:0]ocra;
logic [7:0]ocra1;
logic [7:0]ocrb;
logic [7:0]ocrb1;
logic [7:0]tcnt;
logic [7:0]tcnt1;
logic [7:0]timsk;
logic [7:0]tifr;
logic [7:0]tifr1;


logic clk_div_8;
logic [1:0]count;

always @(posedge(g.clk) or posedge (g.rst))
	begin
		if(g.rst)
			begin 
				
				tccra <= 0;
				tccra1<= 0;
				tccrb <= 0;
				tccrb1<= 0;
				ocra  <= 0;
				ocra1 <= 0;
				ocrb  <= 0;
				ocrb1 <= 0;
				tcnt  <= 0;
				tcnt1 <= 0;
				timsk <= 0;
				tifr  <= 0;
				tifr1 <= 0;
				clk_div_8 <= 0;
			end 

		else 
			if(g.write)
				begin
					case(g.addr)
						
							8'h24 :
								begin 
								tccra <= g.wdata;
								tccra1<= g.wdata;
								end 
							8'h44 :begin 
								tccra <= g.wdata;
								tccra1<= g.wdata;
								end 

							8'h25 :begin 
								tccrb <= g.wdata;
								tccrb1<= g.wdata;
							       end 
							8'h45 :begin 
								tccrb <= g.wdata;
								tccrb1<= g.wdata;
							       end 
							8'h27 :begin 
								ocra  <= g.wdata;
								ocra1<= g.wdata;
							       end 
							8'h47 :
								begin
								ocra  <= g.wdata;
								ocra1 <= g.wdata;
								end 
							8'h28 :begin 
								ocrb  <= g.wdata;
								ocrb1 <= g.wdata;
							       end 
							8'h48 :begin 
								ocrb  <= g.wdata;
								ocrb1 <= g.wdata;
							       end 	
							8'h26 :begin tcnt  <= g.wdata;tcnt1 <= g.wdata;end 
							8'h46 :begin tcnt  <= g.wdata;tcnt1 <= g.wdata;end 
							8'h6e :timsk <= g.wdata;
							8'h15 :begin tifr  <= g.wdata;tifr1 <= g.wdata; end 
							8'h35 :begin tifr <= g.wdata;tifr1 <= g.wdata;end 
						
					 endcase
				end 
		else 
			if(g.read)
				begin
					case(g.addr)
						

						/*	8'h24 :begin g.rdata=tccra;g.rdata=tccra1;end 
							8'h44 :begin g.rdata=tccra;g.rdata=tccra1;end 
							8'h25 :begin g.rdata=tccrb;g.rdata=tccrb1;end 
							8'h45 :begin g.rdata=tccrb;g.rdata=tccrb1;end 
							8'h27 :begin g.rdata=ocra;g.rdata=ocra1; end 
							8'h47 :begin g.rdata=ocra;g.rdata=ocra1;end 
							8'h28 :begin g.rdata=ocrb;g.rdata=ocrb1;end 
							8'h48 :begin g.rdata=ocrb;g.rdata=ocrb1;end 
							8'h26 :begin g.rdata=tcnt;g.rdata=tcnt1;end 
							8'h46 :begin g.rdata=tcnt;g.rdata=tcnt1;end 
							8'h6e :g.rdata=timsk;
							8'h15 :g.rdata=tifr;// g.rdata=tifr1; 
							8'h35 : g.rdata=tifr1;//g.rdata=tifr1 
						
					*/


							8'h24 :g.rdata<=tccra;//g.rdata=tccra1;end 
							8'h44 :g.rdata<=tccra1;//g.rdata=tccra1;end 
							8'h25 :g.rdata<=tccrb;//g.rdata=tccrb1;end 
							8'h45 :g.rdata<=tccrb1;//g.rdata=tccrb1;end 
							8'h27 :g.rdata<=ocra;//g.rdata=ocra1; end 
							8'h47 :g.rdata<=ocra1;//g.rdata=ocra1;end 
							8'h28 :g.rdata<=ocrb;//g.rdata=ocrb1;end 
							8'h48 :g.rdata<=ocrb1;//g.rdata=ocrb1;end 
							8'h26 :g.rdata<=tcnt;//g.rdata=tcnt1;end 
							8'h46 :g.rdata<=tcnt1;//g.rdata=tcnt1;end 
							8'h6e :g.rdata<=timsk;
							8'h15 :g.rdata<=tifr;// g.rdata=tifr1; 
							8'h35 : g.rdata<=tifr1;//g.rdata=tifr1 

					endcase
			
							
				end 
	end 
			

always @(posedge (g.clk) or posedge (g.rst))
	begin 
		if(g.rst)
			//clk8 = 0;
			count<=0;
		else 
			count <= count +1;
	if (count == 3 && (tccra[1:0] == 2'b10 && tccrb[3]== 0))
		clk_div_8 <= ~clk_div_8;


       end 
			
/*always @(posedge (g.clk) or posedge (g.rst))
	begin 
		if(g.rst)
			
				tcnt = 0;
		else 
				tcnt = tcnt +1;
       end 
*/

always @(posedge (clk_div_8) or posedge (g.rst))
	begin 
		if(g.rst)
				begin 
				tcnt1 <= 0;
				tcnt <= 0;
				end 
		else 
				begin 
				tcnt <= tcnt +1 ;
				tcnt1 <= tcnt1 +1;
				end 
       end 
				
always @(posedge (g.clk) or posedge (g.rst))
	begin
		if ( tccra[1:0] == 0 && tccrb[3]== 0)
			begin
				if (tcnt == 8'hff)
					begin 
					g.interrupt_request <= 1 ;
					tifr <= 3'b11;
					tifr1 <= 3'b11;
					end 
				else 	
					begin	
					tifr <= 0;
					tifr1 <= 0;
					end 
			end 
end 
	//else 

always @(posedge (clk_div_8) or posedge (g.rst))
begin 
			if ( tccra[1:0] == 2'b10 && tccrb[3]== 0)
				begin 
					if (tcnt == ocra)
						begin
						
						tcnt <= 0;
						tcnt1 <= 0;
						g.interrupt_request <= 1 ;
						
						
						tifr <= 3'b011 ;
						tifr1 <= 3'b011 ;
						
						end 
					else 
						begin
						tifr <= 0;
						tifr1<= 0 ;
						end
					if(tcnt == ocrb)
						begin 
						//tcnt <= 0;
						//tcnt1 <= 0;
						g.interrupt_request <= 1 ;
						tifr<= 3'b101;
						tifr1<= 3'b101;
						
						end 
					else
						begin 
						tifr <= 0;
						tifr1<= 0 ;
						end 
				end 


						end 				
			
always @(posedge (g.clk) or posedge (g.rst))
	begin
		if(g.interrupt_executed)
			begin 
			g.interrupt_request <= 0;
			tifr <= 0;
			tifr1 <= 0; 
			end 
		
			begin 
			tifr <= tifr ;
			tifr1 <= tifr1 ;
			end 
	end 
				
endmodule 
						






