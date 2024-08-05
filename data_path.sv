`timescale 1ns/10ps

module data_path(input logic clk, reset,
						input logic Reg2Loc, xsize_loc, BrTaken, UnCondBr,
						input logic [2:0] ALUSrc, MemtoReg,
						input logic [1:0] ALU_first_i_sel,
						input logic [1:0] shamt,
						input logic [18:0] Imm19_old,
						input logic [25:0] Imm26_old,
						input logic [11:0] Imm12_old,
						input logic [8:0] Imm9_old,
						input logic [15:0] Imm16_old,
						output logic [63:0] Imm19,Imm26, Imm12, Imm9,Imm16,
						input logic [4:0] Rd, Rm, Rn,
						input logic [63:0] Db,Da,Db_saved,
						input logic [63:0] Dout, alu_out, shift_imm_adder, PC_out,Dout_8bit,
						output logic [4:0] Ab,
						output logic [3:0] xsize_loc_in,
						// shifter is the 64 bit immediate values that have to be left shifted by twice
						output logic [63:0] Res, mask_movk, mask_movz, shifter, sec_i_ALU, alu_first_i, Dw, PC_input, new_res);
			
		sign_extender dut0(.Imm19_old(Imm19_old),.Imm26_old(Imm26_old),.Imm12_old(Imm12_old),.Imm9_old(Imm9_old)
								,.Imm16_old(Imm16_old),.clk(clk),.Imm19(Imm19),.Imm26(Imm26),.Imm12(Imm12),.Imm9(Imm9),.Imm16(Imm16));
		logic [63:0] alusrc_hard0, alusrc_hard0_e_stage,memtoreg_hard0, memtoreg_hard0_e_stage;
		assign alusrc_hard0 = 64'd0;
		assign memtoreg_hard0 = 64'd0;
		
		// 2:1 mux for Reg2Loc
		mux_reg2loc dut1(.S0(Reg2Loc), .D0(Rm), .D1(Rd), .out_mux(Ab));

		// need register to store alusrc_hard0
		gen_d_FF  alusrc_hard0_estage(.q(alusrc_hard0_e_stage),.d(alusrc_hard0),.clk, .reset, .enable(1'd1));

		// second input to the ALU
		mux_4_1_alusrc_memtoreg dut2(.S0(ALUSrc[0]), .S1(ALUSrc[1]), .D0(Imm12), .D1(Db), .D2(Imm9), .D3(64'd0), .out_mux(sec_i_ALU));
		//2:1 mux for xsize_loc

		mux_xsize_loc dut3(.S0(xsize_loc), .D0(4'd8), .D1(4'd1), .out_mux(xsize_loc_in));
		//4:1 mux for MemtoReg  
		// alu_out is the output of the ALU
		assign Dout_8bit = {56'd0, Dout[7:0]};
		
		//gen_d_FF memtoreg_hard0_m_stage(.q(memtoreg_hard0_e_stage),.d(memtoreg_hard0),.clk, .reset, .enable(1'd1));
		
		mux_4_1_alusrc_memtoreg dut4(.S0(MemtoReg[0]), .S1(MemtoReg[1]), .D0(alu_out), .D1(Dout), .D2(64'd0), .D3(Dout_8bit), .out_mux(Dw));
		// 2:1 mux for BrTaken
		mux_2_1_brtaken_uncondbr dut5(.S0(BrTaken), .D0(PC_out), .D1(shift_imm_adder), .out_mux(PC_input));
		
		// 4 4:1 mux for mask and swap instruction
		// shamt[1] = instr[22]; shamt[0] = instr[21]
		mux_4_1_mask dut6(.S0(shamt[0]), .S1(shamt[1]), .D0(16'hFFFF),.D1(16'hFFFF),.D2(16'hFFFF),.D3(16'd0), .out_mux(Res[63:48]));
		mux_4_1_mask dut7(.S0(shamt[0]), .S1(shamt[1]), .D0(16'hFFFF),.D1(16'hFFFF),.D2(16'd0),.D3(16'hFFFF), .out_mux(Res[47:32]));
		mux_4_1_mask dut8(.S0(shamt[0]), .S1(shamt[1]), .D0(16'hFFFF),.D1(16'd0),.D2(16'hFFFF),.D3(16'hFFFF), .out_mux(Res[31:16]));
		mux_4_1_mask dut9(.S0(shamt[0]), .S1(shamt[1]), .D0(16'd0),.D1(16'hFFFF),.D2(16'hFFFF),.D3(16'hFFFF), .out_mux(Res[15:0]));

		mux_4_1_mask dut10(.S0(shamt[0]), .S1(shamt[1]), .D0(16'd0),.D1(16'd0),.D2(16'd0),.D3(Imm16_old), .out_mux(mask_movz[63:48]));
		mux_4_1_mask dut11(.S0(shamt[0]), .S1(shamt[1]), .D0(16'd0),.D1(16'd0),.D2(Imm16_old),.D3(16'd0), .out_mux(mask_movz[47:32]));
		mux_4_1_mask dut12(.S0(shamt[0]), .S1(shamt[1]), .D0(16'd0),.D1(Imm16_old),.D2(16'd0),.D3(16'd0), .out_mux(mask_movz[31:16]));
		mux_4_1_mask dut13(.S0(shamt[0]), .S1(shamt[1]), .D0(Imm16_old),.D1(16'd0),.D2(16'd0),.D3(16'd0), .out_mux(mask_movz[15:0]));
		
		// mux for unCondBr
		mux_2_1_brtaken_uncondbr dut14(.S0(UnCondBr), .D0(Imm19), .D1(Imm26), .out_mux(shifter));
		
		mux_4_1_mask dut16(.S0(shamt[0]), .S1(shamt[1]), .D0(Db[63:48]),.D1(Db[63:48]),.D2(Db[63:48]),.D3(Imm16_old), .out_mux(mask_movk[63:48]));
		mux_4_1_mask dut17(.S0(shamt[0]), .S1(shamt[1]), .D0(Db[47:32]),.D1(Db[47:32]),.D2(Imm16_old),.D3(Db[47:32]), .out_mux(mask_movk[47:32]));
		mux_4_1_mask dut18(.S0(shamt[0]), .S1(shamt[1]), .D0(Db[31:16]),.D1(Imm16_old),.D2(Db[31:16]),.D3(Db[31:16]), .out_mux(mask_movk[31:16]));
		mux_4_1_mask dut19(.S0(shamt[0]), .S1(shamt[1]), .D0(Imm16_old),.D1(Db[15:0]),.D2(Db[15:0]),.D3(Db[15:0]), .out_mux(mask_movk[15:0]));

		
		// 3:1 (4:1) mux for ALU_first_i_sel 
		// register to store Da value
		// register to store mask_movz and movk data values
		
		mux_4_1_alusrc_memtoreg dut15(.S0(ALU_first_i_sel[0]), .S1(ALU_first_i_sel[1]), .D0(Da), .D1(mask_movz), .D2(mask_movk), .D3(64'd0), .out_mux(alu_first_i));

		
endmodule
