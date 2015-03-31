
`timescale 1ns/100ps
module processor (clock, reset, PC, Inst, MemRead, MemWrite, Addr, Din, Dout);

input clock, reset;
input [31:0] Inst, Dout;
output MemRead, MemWrite;
output [31:0] PC, Addr, Din;

//Register Declarations

//Wire Declarations
wire [25:0] Inst_25_0;
wire [4:0] Inst_25_21;
wire [4:0] Inst_20_16;
wire [4:0] Inst_15_11;
wire [15:0] Inst_15_0;
wire [31:0] shamt; //Shift Amount for SLL and SRL
wire [31:0] pc;        //Program Counter
wire [5:0] opcode;
wire [5:0] funct;
wire bcond;
wire RegDest;
wire ALUSrc;
wire MemtoReg;
wire RegWrite; 
wire MemRead;
wire MemWrite;
wire PCSrc1;
wire PCSrc2;
wire PCSrc3;
wire [3:0] ALU_Control;
wire [31:0] ALU_Result;
wire [31:0] ALU_datain2_src0;
wire [31:0] ALU_datain2;
wire [4:0] gpr_wr_addr;
wire [4:0] gpr_rd_addr1;
wire [4:0] gpr_wr_addr0;
wire [31:0] gpr_wr_data;
wire [31:0] gpr_rd_data1;
wire [31:0] gpr_rd_data2;
wire [31:0] mem_alu_data_out;
wire [31:0] pc_plus_8;        //PC + 8 to be written to GPR[31] on JAL
wire isJAL;    //Set when Instruction is JAL
wire isSLL_SRL;//Set when Instruction is SLL or SRL
wire [31:0] Inst_15_0_signext; 
wire [31:0] br_signext_sl2;

wire [15:0] fd_Inst_15_0;
wire [25:0] fd_Inst_25_0;
wire [5:0]  fd_rs;
wire [5:0]  fd_rt;
wire [5:0]  fd_opcode;
wire [5:0]  fd_funct; 
wire        d_bcond;
wire        d_bcond_beq;
wire        d_bcond_bne;
wire [31:0] d_Inst_15_0_signext;
wire [31:0] d_br_signext_sl2;
wire d_PCSrc1; 
wire d_PCSrc2; 
wire d_PCSrc3;
wire [31:0] d_pc_plus_8;        //PC + 8 to be written to GPR[31] on JAL
reg [31:0] dx_pc_plus_8;
reg [31:0] dx_Inst;
wire [5:0] dx_opcode;
wire [5:0] dx_funct;
wire       x_ALUSrc;
wire       x_isSLL_SRL;
wire [3:0] x_ALU_Control;
reg [31:0] xm_Inst;
reg [31:0] xm_pc_plus_8;
wire [5:0] xm_opcode;
wire       m_MemRead;
wire       m_MemWrite;
reg [31:0] mw_Inst;
reg [31:0] mw_pc_plus_8;
wire [5:0] mw_opcode; 
wire [5:0] mw_funct;
wire       w_RegWrite;
wire       w_RegDest;
wire       w_MemtoReg;
wire       w_isJAL; 
assign opcode = Inst[31:26];
assign funct  = Inst[5:0];
assign Inst_25_0   = Inst[25:0];
assign Inst_25_21  = Inst[25:21];
assign Inst_20_16  = Inst[20:16];
assign Inst_15_11  = Inst[15:11];
assign Inst_15_0   = Inst[15:0];
assign shamt       = {27'd0,Inst[10:6]};

assign fd_rs = fd_Inst[25:21];
assign fd_rt = fd_Inst[20:16];


 
always@(posedge clock or posedge reset) begin
  if(reset==1'b1) begin
    //-----Fetch - Decode-----
      fd_Inst <= #TD 32'd0;
    
    //-----Decode - Execute-----
      dx_Inst <= #TD 32'd0;
      dx_pc_plus_8 <= #TD 32'd0; //for JAL
    
    //-----Execute - Memory-----
      xm_Inst      <= #TD 32'd0;
      xm_pc_plus_8 <= #TD 32'd0; //for JAL
    
    //-----Execute - Memory-----
      xm_Inst      <= #TD 32'd0;
      xm_pc_plus_8 <= #TD 32'd0; //for JAL
    
    //-----Memory - Writeback-----
      mw_Inst      <= #TD 32'd0;
      mw_pc_plus_8 <= #TD 32'd0; //for JAL
   end
   else begin
     fd_Inst      <= #TD Inst;
     dx_Inst      <= #TD fd_Inst;
     dx_pc_plus_8 <= #TD d_pc_plus_8;  
     xm_Inst      <= #TD dx_Inst;
     xm_pc_plus_8 <= #TD dx_pc_plus_8;
     mw_Inst      <= #TD xm_Inst;
     mw_pc_plus_8 <= #TD xm_pc_plus_8;
   end
end

assign fd_Inst_15_0 = fd_Inst[15:0];
assign fd_Inst_25_0 = fd_Inst[25:0]; 
 
//Sign extension for Instruction[15:0] for
//*branch address calculation
//*Alu source
signext signext_u0(.ip(fd_Inst_15_0        ),
                   .op(d_Inst_15_0_signext)
                   );

assign d_Inst_15_0_signext;
//Left shift for branch address calculation
lshift lshift_u0(.ip(d_Inst_15_0_signext),
                 .op(d_br_signext_sl2   )
                );


//Program Counter Module with PCSrc Mux
pc pc_u0 (.clk           (clock         ),
          .rst           (reset         ), 
          .fd_br_signext_sl2(d_br_signext_sl2), 
          .fd_Inst_25_0     (fd_Inst_25_0     ),
          .gpr_rd_data1  (gpr_rd_data1  ), 
          .jump          (d_PCSrc1        ), 
          .branch        (d_PCSrc2        ),
          .jump_reg      (d_PCSrc3        ),
          .pc            (pc            ),
          .d_pc_plus_8   (d_pc_plus_8     )
         );

// Control Unit
control_unit control_unit_u0(.mw_opcode    (mw_opcode    ),
                             .mw_funct     (mw_funct     ),
                             .xm_opcode    (xm_opcode    ),
                             .dx_opcode    (dx_opcode    ),
                             .dx_funct     (dx_funct     ),
                             .fd_opcode    (fd_opcode    ),
                             .fd_funct     (fd_funct     ),
                             .d_bcond      (d_bcond      ),
                             .w_RegWrite   (w_RegWrite   ),
                             .w_RegDest    (w_RegDest    ),
                             .w_MemtoReg   (w_MemtoReg   ),
                             .w_isJAL      (w_isJAL      ),
                             .m_MemRead    (m_MemRead    ),
                             .m_MemWrite   (m_MemWrite   ),
                             .x_ALUSrc     (x_ALUSrc     ),
                             .x_isSLL_SRL  (x_isSLL_SRL  ),
                             .x_ALU_Control(x_ALU_Control),
                             .d_PCSrc1     (d_PCSrc1     ),
                             .d_PCSrc2     (d_PCSrc2     ),
                             .d_PCSrc3     (d_PCSrc3     )
                            );
assign mw_opcode = mw_Inst[31:26];
assign mw_funct  = mw_Inst[5:0];
assign xm_opcode = xm_Inst[31:26];
assign dx_opcode = dx_Inst[31:26];
assign dx_funct  = dx_Inst[5:0];
assign fd_opcode = fd_Inst[31:26];
assign fd_funct  = fd_Inst[5:0];

// -------Checking for BRANCH in DECODE stage itself---------
assign d_bcond_beq = (fd_opcode==`BEQ) ? (fd_rs==fd_rt): 1'b0;
assign d_bcond_bne = (fd_opcode==`BNE) ? (fd_rs!=fd_rt): 1'b0;
assign d_bcond      = d_bcond_beq || d_bcond_bne;
//-----------------------------------------------------------

//Multiplexer to select write address of GPR
mux_2x1 #(.DATA_WIDTH(5)
         ) mux_2x1_u0(.ip1(Inst_15_11 ), //When Instruction is R-type
                      .ip0(Inst_20_16 ), //When Instruction is I-type 
                      .sel(RegDest    ), //1-Inst[15:0];0-Inst[20:16]
                      .out(gpr_wr_addr0)
                     );

mux_2x1 #(.DATA_WIDTH(5)
         ) mux_2x1_u1(.ip1(5'd31       ), //When JAL write PC+8 to gpr[31] 
                      .ip0(gpr_wr_addr0), 
                      .sel(isJAL       ),
                      .out(gpr_wr_addr )
                     );
                          
//Multiplexer to select write back to GPR from ALU or MEM
//Another multiplexer selects this data and JAL address(PC+8)
mux_2x1 #(.DATA_WIDTH(32)
         )mux_2x1_u2(.ip1(Dout            ), // Dout -> read data from Data memory
                     .ip0(ALU_Result      ),
                     .sel(MemtoReg        ),
                     .out(mem_alu_data_out)
                    );

mux_2x1 #(.DATA_WIDTH(32)
         )mux_2x1_u3(.ip1(pc_plus_8),
                     .ip0(mem_alu_data_out),
                     .sel(isJAL),
                     .out(gpr_wr_data)
                    );
//Read register 1 address for SLL and SRL alone is to be taken from
//Inst[20:16](Rt); others from Inst[25:21] (Rs)
mux_2x1 #(.DATA_WIDTH(5)
         )mux_2x1_u4(.ip1(Inst_20_16),
                     .ip0(Inst_25_21),
                     .sel(isSLL_SRL),
                     .out(gpr_rd_addr1)
                    );

gpr gpr_u0(.clk     (clock       ),
           .RegWrite(RegWrite    ),
           .rd_addr1(gpr_rd_addr1),
           .rd_addr2(Inst_20_16  ),
           .wr_addr (gpr_wr_addr ),
           .wr_data (gpr_wr_data ),
           .rd_data1(gpr_rd_data1),
           .rd_data2(gpr_rd_data2)
          );

//ALU operand source Mux
//Need an additional mux to input SHAMT(shift amount) for SLL and SRL
mux_2x1 #(.DATA_WIDTH(32)
         )mux_2x1_u5(.ip1(Inst_15_0_signext), 
                     .ip0(gpr_rd_data2     ), 
                     .sel(ALUSrc           ), 
                     .out(ALU_datain2_src0 )
                    );
//Mux used to take case of SLL and SRL instructions
mux_2x1 #(.DATA_WIDTH(32)
         )mux_2x1_u6 (.ip1(shamt            ), 
                      .ip0(ALU_datain2_src0 ), 
                      .sel(isSLL_SRL        ), 
                      .out(ALU_datain2      )
                     );
//ALU module
alu alu_u0(
	  .r1     (gpr_rd_data1),
	  .r2     (ALU_datain2 ),
	  .control(ALU_Control ),
	  .result (ALU_Result  ),
	  .bcond  (bcond       )
         );

assign PC = pc;
assign Din = gpr_rd_data2;
assign Addr = ALU_Result;

endmodule

