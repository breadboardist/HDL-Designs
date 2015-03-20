
# NC-Sim Command File
# TOOL:	ncsim	14.10-p001
#
#
# You can restore this configuration with:
#
#      irun +access+r processor.v control_unit.v pc.v alu.v signext.v lshift.v adder.v gpr.v mux_2x1.v test.v -s -input restore.tcl
#

set tcl_prompt1 {puts -nonewline "ncsim> "}
set tcl_prompt2 {puts -nonewline "> "}
set vlog_format %h
set vhdl_format %v
set real_precision 6
set display_unit auto
set time_unit module
set heap_garbage_size -200
set heap_garbage_time 0
set assert_report_level note
set assert_stop_level error
set autoscope yes
set assert_1164_warnings yes
set pack_assert_off {}
set severity_pack_assert_off {note warning}
set assert_output_stop_level failed
set tcl_debug_level 0
set relax_path_name 1
set vhdl_vcdmap XX01ZX01X
set intovf_severity_level ERROR
set probe_screen_format 0
set rangecnst_severity_level ERROR
set textio_severity_level ERROR
set vital_timing_checks_on 1
set vlog_code_show_force 0
set assert_count_attempts 1
set tcl_all64 false
set tcl_runerror_exit false
set assert_report_incompletes 0
set show_force 1
set force_reset_by_reinvoke 0
set tcl_relaxed_literal 0
set probe_exclude_patterns {}
set probe_packed_limit 4k
set probe_unpacked_limit 16k
set assert_internal_msg no
set svseed 1
set assert_reporting_mode 0
alias . run
alias iprof profile
alias quit exit
database -open -vcd -into verilog.dump _verilog.dump1 -timescale fs
database -open -shm -into waves.shm waves -default
database -open -vcd -into mips.vcd _mips.vcd1 -timescale fs
probe -create -database waves tb_mips.P.Addr tb_mips.P.Din tb_mips.mem_addr tb_mips.MemRead tb_mips.P.Dout tb_mips.P.Inst tb_mips.P.MemRead tb_mips.P.MemWrite tb_mips.P.PC tb_mips.P.clock tb_mips.P.reset tb_mips.P.control_unit_u0.funct tb_mips.P.control_unit_u0.opcode tb_mips.P.Inst_15_0_signext tb_mips.P.gpr_rd_data2 tb_mips.P.Inst_15_0 tb_mips.P.gpr_u0.rd_data1 tb_mips.P.gpr_u0.rd_data2 tb_mips.P.gpr_u0.rd_addr2 tb_mips.P.gpr_u0.rd_addr1 tb_mips.P.gpr_u0.RegWrite tb_mips.P.gpr_u0.wr_data tb_mips.MemWrite tb_mips.P.gpr_u0.gpr tb_mips.DataMem tb_mips.P.alu_u0.r1 tb_mips.P.alu_u0.r2 tb_mips.P.alu_u0.in1 tb_mips.P.alu_u0.in2 tb_mips.P.alu_u0.out tb_mips.P.gpr_rd_data1 tb_mips.P.Inst_20_16 tb_mips.P.ALU_datain2 tb_mips.P.ALU_datain2_src0 tb_mips.P.shamt tb_mips.P.gpr_rd_addr1 tb_mips.P.isSLL_SRL tb_mips.P.ALUSrc tb_mips.P.ALU_Control tb_mips.P.ALU_Result tb_mips.P.bcond
probe -create -database waves tb_mips.P.RegWrite
probe -create -database waves tb_mips.P.pc_u0.jump tb_mips.P.pc_u0.branch tb_mips.P.pc_u0.jump_reg
probe -create -database waves tb_mips.P.pc_u0.br_loc

simvision -input restore.tcl.svcf
