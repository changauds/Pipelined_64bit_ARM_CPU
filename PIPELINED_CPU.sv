`timescale 1ns/10ps

module PIPELINED_CPU(input logic clock, reset
				);
	
	logic Reg2Loc, xsize_loc, BrTaken, UnCondBr;
	logic [63:0] PC_temp;
	logic [4:0] Rm, Rn, Rd;
	logic [2:0] ALUSrc, MemtoReg;
	logic [1:0] shamt, ALU_first_i_sel;
	logic [63:0] alu_first_i;
	logic [18:0] Imm19_old; // for b_lt and CBZ
	logic [25:0] Imm26_old; // for branch
	logic [11:0] Imm12_old; // for addi
	logic [8:0] Imm9_old; // for ldur, ldurb, stur, sturb
	logic [15:0] Imm16_old; // for movk, movz
	logic [63:0] Imm19,Imm26, Imm12, Imm9,Imm16;
	logic [63:0] Db, Da;
	logic [63:0] Dout, alu_out;
	logic [4:0] Ab;
	logic [3:0] xsize_loc_in;
	// shifter is the 64 bit immediate values that have to be left shifted by twice
	logic [63:0] Res, shifter, sec_i_ALU, Dw, PC_out, shift_imm_adder, PC_input,Dout_8bit, mask_movk, mask_movz, new_res;
	logic negativef, overflowf, zerof, carryf;
	logic flag_enable;
	logic [31:0] instruct_bits;
	logic RegWrite,MemRead, MemWrite;
	logic [2:0] ALUOp;

	// pipelined variables
	logic [2:0] ALUOp_e_stage;
	logic [63:0] Db_e_stage, Db_m_stage, alu_out_e_stage, alu_out_m_stage, alu_first_i_e_stage, sec_i_ALU_e_stage, Dw_estage, Dw_mstage, Dw_wbstage;
	logic [31:0] instruct_bits_if_stage;
	logic [3:0] xsize_loc_m_stage, xsize_loc_e_stage;
	logic RegWrite_mstage, RegWrite_estage, RegWrite_wbstage, MemWrite_e_stage, MemWrite_m_stage, MemRead_e_stage, MemRead_m_stage;
	logic UnCondBr_if_stage, BrTaken_rdstage;
	logic [4:0] Rd_mstage, Rd_estage, Rd_wbstage, Rn_estage;
	logic [1:0] forward_a, forward_b;
	logic [2:0]ALUSrc_e_stage, MemtoReg_m_stage, MemtoReg_e_stage;
	logic [1:0]shamt_rd_stage;
	logic [63:0] mask_movz_estage, mask_movk_estage, Imm12_e_stage, Imm9_e_stage, alusrc_hard0, alusrc_hard0_e_stage;
	logic [63:0] memtoreg_hard0, memtoreg_hard0_e_stage, Dout_m_stage, Dout8bit_m_stage, Da_e_stage, Imm26_if_stage, Imm19_if_stage, Imm9_if_stage;
	logic [31:0] instruction_e, PC_temp_out, instruction_final, shifter_temp_f;
	logic BrTaken_final;
	logic [63:0] alu_first_i_temp, sec_i_alu_temp;
	logic [15:0] Imm16_estage;
	
	// implement instruction bits for execution stage; take that and implement a mux to choose between using instruction reg stage and instruction exec stage
	logic [63:0] shifter_temp, PC_temp_f, shifter_final;
	logic [1:0] add_zero;
	logic [63:0] Cin, Cout;
	logic zero_f, zero_asdfa;
	logic flag_enable_mstage, flag_enable_estage, previous_zerof;


	
	
	// control signals for forwarding
	gen_d_FF_3bit  alu_src_e_stage(.q(ALUSrc_e_stage),.d(ALUSrc),.clk(clock), .reset, .enable(1'd1));
	// need register to store Imm12
	// need register to store Db
	gen_d_FF  Db_value_e_stage(.q(Db_e_stage),.d(Db),.clk(clock), .reset, .enable(1'd1));
	gen_d_FF db_m_stage(.q(Db_m_stage),.d(Db_e_stage),.clk(clock),.reset, .enable(1'd1));
	// need register to store Imm9
	gen_d_FF  imm9_e_stage(.q(Imm9_e_stage),.d(Imm9),.clk(clock), .reset, .enable(1'd1));
	// need register to store alusrc_hard0
	gen_d_FF  alusrc_hard0_estage(.q(alusrc_hard0_e_stage),.d(alusrc_hard0),.clk(clock), .reset, .enable(1'd1));
	gen_d_FF_16bit imm16_forward(.q(Imm16_estage), .d(Imm16), .clk(clock), .reset, .enable(1'd1));

	// other forwarding sources
	gen_d_FF_32bit instructbit_ifstage(.q(instruct_bits_if_stage),.d(instruct_bits),.clk(clock),.reset, .enable(1'd1));
	gen_d_FF_32bit instructbit_ifstage2(.q(instruction_e),.d(instruct_bits_if_stage),.clk(clock),.reset, .enable(1'd1));
	//gen_d_FF_32bit instructbit_ifstage3(.q(instruction_final),.d(instruction_f),.clk(clock),.reset, .enable(1'd1));

	mux_ff RegWrite_e_stage(.d_(RegWrite), .enable(1'd1), .q_(RegWrite_estage), .reset, .clk(clock));
	mux_ff RegWrite_m_stage(.d_(RegWrite_estage), .enable(1'd1), .q_(RegWrite_mstage), .reset, .clk(clock));
	mux_ff RegWrite_wb_stage(.d_(RegWrite_mstage), .enable(1'd1), .q_(RegWrite_wbstage), .reset, .clk(clock));

	gen_d_FF_5bit Rd_e_stage(.q(Rd_estage),.d(Rd),.clk(clock),.reset, .enable(1'd1));
	gen_d_FF_5bit Rd_m_stage(.q(Rd_mstage),.d(Rd_estage),.clk(clock),.reset, .enable(1'd1));
	gen_d_FF_5bit Rd_wb_stage(.q(Rd_wbstage),.d(Rd_mstage),.clk(clock),.reset, .enable(1'd1));
	//gen_d_FF_5bit Rn_e_stage(.q(Rn_estage),.d(Rn),.clk(clock),.reset, .enable(1'd1));
	
	gen_d_FF dw_wb_stage(.q(Dw_wbstage),.d(Dw),.clk(clock),.reset, .enable(1'd1));
	
	gen_d_FF_3bit aluop_e_stage(.q(ALUOp_e_stage),.d(ALUOp),.clk(clock),.reset, .enable(1'd1));
	gen_d_FF alu_first_i_estage(.q(alu_first_i_e_stage),.d(alu_first_i),.clk(clock),.reset, .enable(1'd1));
	gen_d_FF alu_sec_i_estage(.q(sec_i_ALU_e_stage),.d(sec_i_ALU),.clk(clock),.reset, .enable(1'd1));
		
	mux_ff memwrite_e_stage(.q_(MemWrite_e_stage),.d_(MemWrite),.clk(clock),.reset, .enable(1'd1));
	mux_ff memwrite_m_stage(.q_(MemWrite_m_stage),.d_(MemWrite_e_stage),.clk(clock),.reset, .enable(1'd1));
	mux_ff memread_e_stage(.q_(MemRead_e_stage),.d_(MemRead),.clk(clock),.reset, .enable(1'd1));
	mux_ff memread_m_stage(.q_(MemRead_m_stage),.d_(MemRead_e_stage),.clk(clock),.reset, .enable(1'd1));
	
	//gen_d_FF alu_out_estage(.q(alu_out_e_stage),.d(alu_out),.clk(clock),.reset, .enable(1'd1));
	gen_d_FF alu_out_mstage(.q(alu_out_m_stage),.d(alu_out),.clk(clock),.reset, .enable(1'd1));
	gen_d_FF_4bit xsize_locin_e_stage(.q(xsize_loc_e_stage), .d(xsize_loc_in), .clk(clock), .reset, .enable(1'd1));
	gen_d_FF_4bit xsize_locin_m_stage(.q(xsize_loc_m_stage), .d(xsize_loc_e_stage), .clk(clock), .reset, .enable(1'd1));
	
	// registers to hold select bits for xsizeloc
	//mux_ff xsize_loc_estage(.q_(xsize_loc_e_stage),.d_(xsize_loc),.clk(clock), .reset, .enable(1'd1));
	//mux_ff xsize_loc_memstage(.q_(xsize_loc_m_stage),.d_(xsize_loc_e_stage),.clk(clock), .reset, .enable(1'd1));
	
	// needs registers for the reg to execute stage and execute to the memory stage
	gen_d_FF_3bit memtoreg_e_stage(.q(MemtoReg_e_stage),.d(MemtoReg),.clk(clock), .reset, .enable(1'd1));
	gen_d_FF_3bit memtoreg_m_stage(.q(MemtoReg_m_stage),.d(MemtoReg_e_stage),.clk(clock), .reset, .enable(1'd1));

	gen_d_FF dout_m_stage(.q(Dout_m_stage),.d(Dout),.clk(clock), .reset, .enable(1'd1));
	gen_d_FF dout_8bit_m_stage(.q(Dout8bit_m_stage),.d(Dout_8bit),.clk(clock), .reset, .enable(1'd1));
	
	//gen_d_FF_2bit shamt_rd_stage0(.q(shamt_rd_stage),.d(shamt),.clk(clock), .reset, .enable(1'd1));
	
	gen_d_FF  Da_data_e_stage(.q(Da_e_stage),.d(Da),.clk(clock), .reset, .enable(1'd1));
	
	gen_d_FF  maskmovz_e_stage(.q(mask_movz_estage),.d(mask_movz),.clk(clock), .reset, .enable(1'd1));
	gen_d_FF  maskmovk_e_stage(.q(mask_movk_estage),.d(mask_movk),.clk(clock), .reset, .enable(1'd1));
	
	mux_ff flag_enable_e_stage(.q_(flag_enable_estage), .d_(flag_enable), .clk(clock), .reset, .enable(1'd1));
	mux_ff flag_enable_m_stage(.q_(flag_enable_mstage), .d_(flag_enable_estage), .clk(clock), .reset, .enable(1'd1));

	
	// rd stage for generating control signals
	mux_ff BrTaken_rd_stage(.d_(BrTaken), .enable(1'd1), .q_(BrTaken_rdstage), .reset, .clk(clock));
	mux_ff BrTaken_mstage(.d_(BrTaken_rdstage), .enable(1'd1), .q_(BrTaken_m_stage), .reset, .clk(clock));
		
	gen_d_FF  Imm26_ifstage(.q(Imm26_if_stage),.d(Imm26_old),.clk(clock), .reset, .enable(1'd1));
	mux_ff UnCondBr_ifstage(.d_(UnCondBr), .enable(1'd1), .q_(UnCondBr_if_stage), .reset, .clk(clock));
	gen_d_FF  Imm19_ifstage(.q(Imm19_if_stage),.d(Imm19_old),.clk(clock), .reset, .enable(1'd1));
	gen_d_FF_9bit Imm9_ifstage(.q(Imm9_if_stage),.d(Imm9_old),.clk(clock),.reset, .enable(1'd1));

	//logic BrTaken_f, overflow_f, negative_f;

	//assign reset = 1'b1;PC
	data_path dut0(.clk(clock), .reset(reset),.Reg2Loc(Reg2Loc), .xsize_loc(xsize_loc), .BrTaken(BrTaken), .UnCondBr(UnCondBr), .ALUSrc(ALUSrc), 
						.MemtoReg(MemtoReg_m_stage), .shamt(shamt), .Imm19_old(Imm19_old), .Imm26_old(Imm26_old), .Imm12_old(Imm12_old), .Imm9_old(Imm9_old),
						.Imm16_old(Imm16_old), .Imm19(Imm19), .Imm26(Imm26), .Imm12(Imm12), .Imm9(Imm9), .Imm16(Imm16), .Rd(Rd), .Rm(Rm), .Db(Db), 
						.Dout(Dout), .alu_out(alu_out_m_stage), .shift_imm_adder(shift_imm_adder), .PC_out(PC_out), .Ab(Ab), .xsize_loc_in(xsize_loc_in),
						.Res(Res), .mask_movk(mask_movk), .mask_movz(mask_movz), .shifter(shifter), .sec_i_ALU(sec_i_alu_temp), .Dw(Dw), .PC_input(PC_input), .ALU_first_i_sel(ALU_first_i_sel),
						.Rn(Rn), .Da(Da), .alu_first_i(alu_first_i_temp), .new_res(new_res), .Dout_8bit(Dout_8bit));
	
	logic negative_f, overflow_f, previous_negativef, previous_overflow, negative_asadf, overflowasdf, flag_check;
	
	forwarding_control_path dut1(.clk(clock), .reset(reset), .negativef(negative_f), .overflowf(overflow_f), .carryf(previous_carryout), .instruct_bits(instruct_bits_if_stage),
						.BrTaken(BrTaken), .Reg2Loc(Reg2Loc), .RegWrite(RegWrite), .MemRead(MemRead), .MemWrite(MemWrite), .UnCondBr(UnCondBr), .xsize_loc(xsize_loc),
						.ALUSrc(ALUSrc), .ALUOp(ALUOp), .MemtoReg(MemtoReg), .ALU_first_i_sel(ALU_first_i_sel), .flag_enable(flag_enable), .zerof(zero_f), .flag_check(flag_check));
	
	logic [10:0] adds, subs, mov_k;
	assign adds = (instruction_e[31:21] == 11'b10101011000) ? 1'b1: 1'b0;
	assign subs = (instruction_e[31:21] == 11'b11101011000) ? 1'b1: 1'b0;
	//assign mov_k = (instruct_bits[31:23] == 9'b111100101)
	always_comb begin
		if (!adds || !subs) begin
			negative_f = previous_negativef;
			overflow_f = previous_overflow;
			zero_f = zero_asdfa;
		end
		else begin
			negative_f = negative_asadf;
			overflow_f = overflowasdf;
			zero_f = previous_zerof;
		end
		//if (
	end
	// logic required for the instruction datapath 
	// requires a flip flop to store instructions
	gen_d_FF1 dut2(.q(PC_temp),.d(PC_input), .clk(clock),.reset(reset), .enable(1'd1));
	
	instructmem dut3(.address(PC_temp),.instruction(instruct_bits),.clk(clock));

	// adders for instruction memory (instruction datapath)
	assign add_zero = 2'b00;
	assign shifter_temp = {shifter[61:0], add_zero};

	gen_d_FF1 PC_temp_ff(.q(PC_temp_f),.d(PC_temp), .clk(clock),.reset(reset), .enable(1'd1));
	//gen_d_FF1 shft_temp_ff(.q(shifter_temp_f),.d(shifter_temp), .clk(clock),.reset(reset), .enable(1'd1));
	
	full_adder dut4(.A(shifter_temp), .B(PC_temp_f), .Cin(Cin), .Sum(shift_imm_adder), .Cout(), .overflow(), 
						.select(3'b010), .negative(), .zero(), .carry_flag());
					
	full_adder dut5(.A(64'd4), .B(PC_temp), .Cin(Cin), .Sum(PC_out), .Cout(), .overflow(), .select(3'b010), 
						.negative(), .zero(), .carry_flag());
	
	//logic required to connect regfile to instruction then to alu
	assign Rn = instruct_bits_if_stage[9:5];
	assign Rm = instruct_bits_if_stage[20:16];
	assign Rd = instruct_bits_if_stage[4:0];
	assign shamt = instruct_bits_if_stage[22:21];

	assign Imm19_old = instruct_bits_if_stage[23:5];
	assign Imm26_old = instruct_bits_if_stage[25:0];
	assign Imm12_old = instruct_bits_if_stage[21:10];
	assign Imm9_old = instruct_bits_if_stage[20:12];
	assign Imm16_old = instruct_bits_if_stage[20:5];
	
	// forwarding unit for ADDI instruction
	forwarding_unit forwarding(.ALUSrc(ALUSrc), .ALU_first_i_sel(ALU_first_i_sel), .RegWrite_mstage(RegWrite_mstage), .RegWrite_estage(RegWrite_estage), .Rd_estage(Rd_estage),.alu_out_mstage(alu_out_m_stage), .alu_out_estage(alu_out),
						.forward_a(forward_a), .forward_b(forward_b), .alu_first_i_temp(alu_first_i_temp), .sec_i_alu_temp(sec_i_alu_temp), .Rd_mstage(Rd_mstage), .Rd_reg_stage(Rd), 
						.Rn_reg_stage(Rn), .Rm_reg_stage(Rm), .alu_first_i_final(alu_first_i), .alu_sec_i_final(sec_i_ALU), .instruct_bits(instruct_bits_if_stage), .Db(Db), .RegWrite(RegWrite),
						.Rd_wbstage(Rd_wbstage), .Db_m_stage(Db_m_stage), .Dw_wb_stage(Dw_wbstage), .Dw(Dw), .Db_e_stage(Db_e_stage), .MemWrite_m_stage(MemWrite_m_stage), .instruct_e(instruction_e), .mask_movk(mask_movk)
						, .instruct_f(instruct_bits), .MemWrite(MemWrite), .MemRead(MemRead), .Ab(Ab), .Da(Da), .MemWrite_estage(MemWrite_e_stage), .Db_estage_temp(Db_e_stage));	
	logic use_clock;
	not #0.05 (not_clock, clock);

	always_comb begin
		if ((instruct_bits_if_stage[31:23] == 9'b111100101) || (instruct_bits_if_stage[31:21] == 11'b00111000000)
				|| (instruct_bits_if_stage[31:21] == 11'b11111000000) || (instruct_bits_if_stage[31:21] == 11'b11111000010))
			use_clock = clock;
		else
			use_clock = not_clock;
	end
	
	assign Dout_8bit = {56'd0, Dout[7:0]};
	
	regfile dut6(.ReadRegister1(Rn), .ReadRegister2(Ab), .WriteRegister(Rd_wbstage), .WriteData(Dw_wbstage), .RegWrite(RegWrite_wbstage), .clk(use_clock), 
					.ReadData1(Da), .ReadData2(Db));
					
	//regfile_movk dut6pt2(.ReadRegister1(Rn), .ReadRegister2(Ab), .WriteRegister(Rd_wbstage), .WriteData(Dw_wbstage), .RegWrite(RegWrite_wbstage), .clk(clock), 
	//				.ReadData1(Da), .ReadData2(Db_movk));
					
	// when branch is first fetched (instruction_bits_if_stage)
		// brtaken should still be 0 so instruction_bit + 4 = 32 for example
	// at instruction[32], brtaken is 0 but at the next cycle is when we fetch the instruction we branched to 
	
	//logic negative_asadf, zero_asdfa, overflowasdf, carry_out;
	alu dut7(.A(alu_first_i_e_stage), .B(sec_i_ALU_e_stage), .cntrl(ALUOp_e_stage), .result(alu_out), .negative(negative_asadf), .zero(zero_asdfa),
					.overflow(overflowasdf), .carry_out(carry_out));
	
	zero_flag_ff dut_zerof(.q(previous_zerof),.d(zero_asdfa), .clk(not_clock), .reset(reset),.enable(flag_enable_estage));

	negative_flag_ff dut_neg_f(.q(previous_negativef),.d(negative_asadf),.clk(not_clock), .reset(reset), .enable(flag_enable_estage));

	
	overflow_flag_ff dut_overflow_f(.q(previous_overflow),.d(overflowasdf),.clk(not_clock), .reset(reset),.enable(flag_enable_estage));
	
	carry_flag_ff dut_carry_out_f(.q(previous_carryout),.d(carry_out), .clk(not_clock), .reset(reset),.enable(flag_enable_estage));
	
					
	// logic required for datamemory connections
	datamem dut8(.address(alu_out_m_stage), .write_enable(MemWrite_m_stage), .read_enable(MemRead_m_stage), .write_data(Db_m_stage), .clk(clock), 
					.xfer_size(xsize_loc_m_stage), .read_data(Dout));
endmodule

module PIPELINED_CPU_testbench();
	logic clock, reset;
	
	PIPELINED_CPU dut1(.clock(clock), .reset(reset));
	
	parameter clock_period = 100;
	
	initial begin
		clock <= 0;
		forever #(clock_period / 2) clock <= ~clock;
	end
	
	initial begin
		reset <= 1;
					#100; @(posedge clock);
		reset <= 0;
					#100000; @(posedge clock);
		$stop;
	end
	

endmodule
