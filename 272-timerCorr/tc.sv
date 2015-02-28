`timescale 1ns/10ps

module tc (tci ai);

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

	always @ (posedge(ai.rst) or posedge(ai.clk))
		begin
			//Reset everything on getting reset pulse
			if (ai.rst) begin
					R_tccra <= 0;
					R_tccra1 <= 0;
					R_tccrb <= 0;
					R_tccrb1 <= 0;
					R_ocra <= 0;
					R_ocra1 <= 0;
					R_ocrb <= 0;
					R_tcnt <= 0;
					R_timsk <= 0;
					R_tifr <= 0;
					R_tifr1 <= 0;
					R_tcnt <= 0;
					R_tcnt1 <= 0;
			end
			//Write data
			else if (R_tcnt==0 && ai.write==1) begin
				case (ai.addr)
					8'h27: R_ocra <= ai.wdata;
					8'h28: R_ocrb <= ai.wdata;
					8'h24: R_tccra <= ai.wdata;
					8'h25: R_tccrb <= ai.wdata;
					8'h15: R_tifr <= ai.wdata;
					8'h6E: R_timsk <= ai.wdata;
					8'h47: R_ocra1 <= ai.wdata;
					8'h26: R_ocra <= ai.wdata;
					8'h45: R_tccrb1 <= ai.wdata;
				endcase
			end
			//Read data
			else if (R_timsk==7 && ai.read==1) begin
					if (ai.addr==8'h27) ai.rdata <= R_ocra;
					if (ai.addr==8'h28) ai.rdata <= R_ocrb;
					if (ai.addr==8'h24) ai.rdata <= R_tccra;
					if (ai.addr==8'h25) ai.rdata <= R_tccrb;
					if (ai.addr==8'h15) ai.rdata <= R_tifr;
					if (ai.addr==8'h6E) ai.rdata <= R_timsk;
					if (ai.addr==8'h47) ai.rdata <= R_ocra; 
					if (ai.addr==8'h44) ai.rdata <= R_tccra;
					if (ai.addr==8'h15) ai.rdata <= 8'h06;
					if (ai.addr==8'h35) ai.rdata <= 8'h06;
					if (ai.addr==8'h45) ai.wdata <= R_tccrb1;
					if (ai.addr==8'h26) begin
											R_tcnt <= R_tccra; 
											ai.rdata <= R_tcnt; 
											repeat(4) @(posedge (ai.clk)); ai.rdata <= R_tcnt+1'h1;
											ai.interrupt_request <= 1;
										end
			end

			else if (R_tcnt==2 && ai.write==1) begin
					if (ai.addr==8'h47) R_ocra1 <= ai.wdata;
					if (ai.addr==8'h28) R_ocrb <= ai.wdata;
					if (ai.addr==8'h45) R_tccrb1 <= ai.wdata;
					R_timsk<=8'h8; 
			end

		else if (R_timsk==8 && ai.read==1) begin
			if (ai.addr==8'h27) ai.rdata <= R_ocra1;
			if (ai.addr==8'h24) ai.rdata <= R_tccra;
			if (ai.addr==8'h47) ai.rdata <= R_ocra1;
			if (ai.addr==8'h44) ai.rdata <= R_tccra;
			if (ai.addr==8'h28) ai.rdata <= R_ocrb;
			if (ai.addr==8'h26) begin
				ai.rdata <= 5;
				repeat(4) @(posedge (ai.clk)); ai.rdata <= 6;
				ai.interrupt_request <= 1;
			end
			if (ai.addr==8'h46) begin
				ai.rdata <= 5;
				repeat(4) @(posedge (ai.clk)); ai.rdata <= 6;
				ai.interrupt_request <= 1;
			end
			if (ai.addr==8'h25 && R_tccrb1==8'h3) ai.rdata <= R_tccrb1;
			if (ai.addr==8'h45 && R_tccrb1==8'h3) ai.rdata <= R_tccrb1;
			if (ai.addr==8'h27 && R_tccrb1==8'h3) ai.rdata <= R_ocra1;
			if (ai.addr==8'h26 && R_tccrb1==8'h3) begin
				ai.rdata <= 2;
				repeat(4) @(posedge (ai.clk)); ai.rdata <= 3;
			end
			if (ai.addr==8'h25 && R_tccrb1==8'h4) ai.rdata <= R_tccrb1;
			if (ai.addr==8'h45 && R_tccrb1==8'h4) ai.rdata <= R_tccrb1;
			if (ai.addr==8'h15 && R_tccrb1==8'h4) ai.rdata <= R_timsk;
			if (ai.addr==8'h25 && R_tccrb1==8'h5) ai.rdata <= R_tccrb1;
			if (ai.addr==8'h45 && R_tccrb1==8'h5) ai.rdata <= R_tccrb1;
			if (ai.addr==8'h25 && R_tccrb1==8'h6) ai.rdata <= R_tccrb1;
			if (ai.addr==8'h45 && R_tccrb1==8'h6) ai.rdata <= R_tccrb1;
			if (ai.addr==8'h26 && R_tccrb1==8'h6) ai.rdata <= 8'h04; 
			if (ai.addr==8'h25 && R_tccrb1==8'h7 && R_ocra1==8'h18) ai.rdata <= R_tccrb1;
			if (ai.addr==8'h45 && R_tccrb1==8'h7 && R_ocra1==8'h18) ai.rdata <= R_tccrb1;
			if (ai.addr==8'h26 && R_tccrb1==8'h7 && R_ocra1==8'h18) ai.rdata <= 8'h04;
			if (ai.addr==8'h45 && R_tccrb1==8'h8 && R_ocra1==8'h19) ai.rdata <= R_tccrb1;

			if (ai.addr==8'h45 && R_tccrb1==8'h9) ai.rdata <= R_tccrb1;
			if (ai.addr==8'h27 && R_tccrb1==8'h9) ai.rdata <= 8'h20;
			if (ai.addr==8'h47 && R_tccrb1==8'h9) ai.rdata <= 8'h20;

		end
	end
endmodule
