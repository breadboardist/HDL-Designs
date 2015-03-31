
`timescale 1ns/100ps
module control_unit(mw_opcode,mw_funct,xm_opcode,dx_opcode,dx_funct,fd_opcode,fd_funct,w_RegWrite,w_RegDest,w_MemtoReg,w_isJAL,m_MemRead,m_MemWrite,x_ALUSrc,x_isSLL_SRL,x_ALU_Control,d_PCSrc1,d_PCSrc2,d_PCSrc3);
input [5:0] mw_opcode;       //Instr[31:26]
input [5:0] mw_funct;        //Defines operation when Instructyion in R type
input [5:0] xm_opcode;
input [5:0] dx_opcode;
input [5:0] dx_funct;
input [5:0] fd_opcode;
input [5:0] fd_funct;
input d_bcond;              //1 when opcode is BEQ and BNE
output w_RegWrite;          //GPR wite Disabled(0)/Enabled(1)
output w_RegDest;           //Write Destination register location
                          //RegDest = 1 -> R-type - Instr[15:11]
                          //RegDest = 0 -> I-type - Instr[21:16]
output w_MemtoReg;          //Steer ALU(0)/Load memory(1) output to GPR write port
output w_isJAL;             // Instruction is JAL
output m_MemRead;           //Read from Data memory(LW/LB=1)
output m_MemWrite;          //Write to Data memory(SW/SB=1)
output x_ALUSrc;            //When Instructions is SLL or SRL, indiacated by isSLL_SRL,
                          //2nd input to ALU is SHAMT ie.,Inst[10:6]
                          //else 
                          //2nd input to ALU; ALUSrc=0-> Read data 2; ALUSrc=1->Immediate
output x_isSLL_SRL;         //Set when Instruction is SLL or SRL
output [3:0] x_ALU_Control; //Defines the ALU operation 
output d_PCSrc1;            //PCSrc1(1)-> Next PC is Jump address
                          //PCSrc1(0)-> Next PC based on PCSrc2
output d_PCSrc2;            //When PCSrc1=0-->
                          //if PCSrc2=1-> Next PC based on Immediate address
                          //if PCSrc2=0-> Next PC is PC+4
output d_PCSrc3;            //if PCSrc3=1-> Next PC is GPR[rs]

`define ADD  6'b100000
`define AND  6'b100100 
`define JR   6'b001000
`define NOP  6'b000000
`define OR   6'b100101 
`define SLL  6'b000000
`define SLT  6'b101010
`define SRL  6'b000010
`define SUB  6'b100010
`define XOR  6'b100110 

`define ADDI 6'b001000
`define ANDI 6'b001100
`define BEQ  6'b000100
`define BNE  6'b000101
`define LB   6'b100000
`define LW   6'b100011
`define SB   6'b101000
`define SW   6'b101011
`define SLTI 6'b001010 
`define ORI  6'b001101
`define XORI 6'b001110

`define J    6'b000010
`define JAL  6'b000011

reg [3:0] x_alu_ctrl;

//-----Memory - Writeback-----
assign w_RegDest   = (mw_opcode==6'b0);  //1 - rd; 0 - rs

assign w_MemtoReg  = (mw_opcode==`LW) || (mw_opcode==`LB); //1 - WB from Mem
                                                           //0 - WB from ALU 
assign w_isJAL     = (mw_opcode==`JAL); // On JAL, the writing of PC to GPR[31]
                                        // happens at 

//GPR wite Disabled(0)/Enabled(1)
assign w_RegWrite  = (mw_opcode!=`SW)   &&  (mw_opcode!=`SB)  &&  
                     (mw_opcode!=`BEQ)  &&  (mw_opcode!=`BNE) && 
                     (mw_opcode!=`J)    &&  
                     (!((mw_opcode==6'd0) &&  (mw_funct==`JR)));

//-----Execute - Memory-----
assign m_MemRead   = (xm_opcode==`LW)  || (xm_opcode==`LB);

assign m_MemWrite  = (xm_opcode==`SW)  || (xm_opcode==`SB);

//-----Decode - Execute-----

assign x_ALUSrc    = (dx_opcode!=6'b0) && (dx_opcode!=`BEQ) && (dx_opcode!=`BNE);

assign x_isSLL_SRL = (dx_opcode==6'b0) && ((dx_funct==`SLL)||(dx_funct==`SRL));

assign x_ALU_Control = x_alu_ctrl;

//Possibility of removing one bit frommm alu_ctrl
always@(*) begin
  casex({dx_opcode,dx_funct})
    {6'd0 ,`ADD},{`ADDI,6'dx},
    {`LB  ,6'dx},{`LW  ,6'dx},
    {`SB  ,6'dx},{`SW  ,6'dx} : x_alu_ctrl = 4'd0;
    {6'd0 ,`AND},{`ANDI,6'dx} : x_alu_ctrl = 4'd1;
    {6'd0 ,`OR} ,{`ORI ,6'dx} : x_alu_ctrl = 4'd2;
    {6'd0 ,`SLL}              : x_alu_ctrl = 4'd3;
    {6'd0 ,`SLT},{`SLTI,6'dx} : x_alu_ctrl = 4'd4;
    {6'd0 ,`SRL}              : x_alu_ctrl = 4'd5;
    {6'd0 ,`SUB}              : x_alu_ctrl = 4'd6;
    {6'd0 ,`XOR},{`XORI,6'dx} : x_alu_ctrl = 4'd7;
//     {`BEQ ,6'dx}              : alu_ctrl = 4'd8;
//     {`BNE ,6'dx}              : alu_ctrl = 4'd9;
    default                   : x_alu_ctrl = 4'd15;
  endcase
end

//-----Fetch - Decode-----
assign d_PCSrc1    = (fd_opcode==`J)   || (fd_opcode==`JAL);

assign d_PCSrc2    = ((fd_opcode==`BEQ) || (fd_opcode==`BNE)) && (d_bcond==1'b1);

assign d_PCSrc3    = (fd_opcode==6'd0) && (fd_funct==`JR);



 
   
endmodule
