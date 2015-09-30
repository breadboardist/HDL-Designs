//16x16 Multiplier
//Submitted By: Prem Bharath Soundararajan (009430694)
`timescale 1ns / 1ps

module mult16x16 (clk94,St94,Mplier94,Mcand94,Prod94,done94);

input clk94;
input St94;
input [15:0] Mplier94;
input [15:0] Mcand94;
output [32:0] Prod94; 
output done94;

reg done94;
reg [5:0] pstate, nstate;
reg [32:0] Prod94;
reg [32:0] ACC; 

wire M;
assign M = ACC[0];

always @(posedge clk94 or posedge St94)
	begin 
 	if (St94) pstate = 0;
	else pstate = nstate;

 case (pstate)
 	0: begin  if(St94) nstate = 1; end 
 	1: if(M) nstate = 2; else nstate = 2;
 	2: nstate = 3;
 	3: if(M) nstate = 4; else nstate = 4;
 	4: nstate = 5;
 	5: if(M) nstate = 6; else nstate = 6;
 	6: nstate = 7;
 	7: if(M) nstate = 8; else nstate = 8;
 	8: nstate = 9;
 	9: if(M) nstate = 10; else nstate = 10;
 	10: nstate = 11;
 	11: if(M) nstate = 12; else nstate = 12;
 	12: nstate = 13;
 	13: if(M) nstate = 14; else nstate = 14;
 	14: nstate = 15;
 	15: if(M) nstate = 16; else nstate = 16;
 	16: nstate = 17;
 	17: if(M) nstate = 18; else nstate = 18;
 	18: nstate = 19;
 	19: if(M) nstate = 20; else nstate = 20;
 	20: nstate = 21;
 	21: if(M) nstate = 22; else nstate = 22;
 	22: nstate = 23;
 	23: if(M) nstate = 24; else nstate = 24;
 	24: nstate = 25;
 	25: if(M) nstate = 26; else nstate = 26;
 	26: nstate = 27;
 	27: if(M) nstate = 28; else nstate = 28;
 	28: nstate = 29;
 	29: if(M) nstate = 30; else nstate = 30;
 	30: nstate = 31;
 	31: if(M) nstate = 32; else nstate = 32;
 	32: nstate = 33; 
 	33: nstate = 0;
 endcase
end

always @(pstate) //Output (Action)
 case (pstate)
 	0: begin
 	ACC[32:16] = 17'b0;
 	ACC[15:0] = Mplier94;
 	end
 	1: if (M) ACC[32:16] = {1'b0, ACC[31:16]} + {1'b0, Mcand94};
 	2: ACC = {1'b0, ACC[32:1]};
 	3: if (M) ACC[32:16] = {1'b0, ACC[31:16]} + {1'b0, Mcand94};
 	4: ACC = {1'b0, ACC[32:1]};
 	5: if (M) ACC[32:16] = {1'b0, ACC[31:16]} + {1'b0, Mcand94};
 	6: ACC = {1'b0, ACC[32:1]};
 	7: if (M) ACC[32:16] = {1'b0, ACC[31:16]} + {1'b0, Mcand94};
 	8: ACC = {1'b0, ACC[32:1]};
 	9: if (M) ACC[32:16] = {1'b0, ACC[31:16]} + {1'b0, Mcand94};
 	10: ACC = {1'b0, ACC[32:1]};
 	11: if (M) ACC[32:16] = {1'b0, ACC[31:16]} + {1'b0, Mcand94};
 	12: ACC = {1'b0, ACC[32:1]};
 	13: if (M) ACC[32:16] = {1'b0, ACC[31:16]} + {1'b0, Mcand94};
 	14: ACC = {1'b0, ACC[32:1]};
 	15: if (M) ACC[32:16] = {1'b0, ACC[31:16]} + {1'b0, Mcand94};
 	16: ACC = {1'b0, ACC[32:1]};
 	17: if (M) ACC[32:16] = {1'b0, ACC[31:16]} + {1'b0, Mcand94};
 	18: ACC = {1'b0, ACC[32:1]};
 	19: if (M) ACC[32:16] = {1'b0, ACC[31:16]} + {1'b0, Mcand94};
 	20: ACC = {1'b0, ACC[32:1]};
 	21: if (M) ACC[32:16] = {1'b0, ACC[31:16]} + {1'b0, Mcand94};
 	22: ACC = {1'b0, ACC[32:1]};
 	23: if (M) ACC[32:16] = {1'b0, ACC[31:16]} + {1'b0, Mcand94};
 	24: ACC = {1'b0, ACC[32:1]};
 	25: if (M) ACC[32:16] = {1'b0, ACC[31:16]} + {1'b0, Mcand94};
 	26: ACC = {1'b0, ACC[32:1]};
 	27: if (M) ACC[32:16] = {1'b0, ACC[31:16]} + {1'b0, Mcand94};
 	28: ACC = {1'b0, ACC[32:1]};
 	29: if (M) ACC[32:16] = {1'b0, ACC[31:16]} + {1'b0, Mcand94};
 	30: ACC = {1'b0, ACC[32:1]};
 	31: if (M) ACC[32:16] = {1'b0, ACC[31:16]} + {1'b0, Mcand94};
 	32: ACC = {1'b0, ACC[32:1]};
 	33: begin 
 	done94 = 1'b1;
 	Prod94 = ACC;
 	end
 endcase
endmodule
