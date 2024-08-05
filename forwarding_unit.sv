`timescale 1ns/10ps

module forwarding_unit(input logic RegWrite_mstage, RegWrite_estage, RegWrite,MemWrite_m_stage,MemWrite,MemRead,MemWrite_estage,
								input logic [1:0] ALU_first_i_sel,
								input logic [2:0] ALUSrc,
								input logic [31:0] instruct_f, instruct_bits, instruct_e,
								input logic [4:0] Rd_estage, Rd_mstage, Rd_reg_stage, Rn_reg_stage,Rm_reg_stage, Rd_wbstage, Ab,
								input logic [63:0] alu_first_i_temp, sec_i_alu_temp, alu_out_mstage, alu_out_estage,Dw_wb_stage, Dw, Db_e_stage,mask_movk,Db_estage_temp,
								output logic [1:0] forward_a, forward_b,
								output logic [63:0] alu_first_i_final, alu_sec_i_final, Db, Db_m_stage, Da
								);
	
	always_comb begin
	// if alu_first_i_sel equals 0, forward_a == 2'b00 ? for DA 
		if (RegWrite_estage && (Rd_estage != 5'd31) && (Rd_estage == Rn_reg_stage))
			forward_a = 2'b01; // forward dW in mstage// forward alu_out in estage
		else if (RegWrite_mstage && (Rd_mstage != 5'd31) && (Rd_mstage == Rn_reg_stage)) // or rd == rd_e?
			forward_a = 2'b10; // forward dW in mstage
		else 	
			forward_a = 2'b00; // do nothing (Da == Da)
	end
	
	always_comb begin
		if (ALUSrc == 3'b000)
			forward_b = 2'b00;
		else if (RegWrite_estage && (Rd_estage != 5'd31) && ((Rd_estage == Rm_reg_stage) ||
					(Ab == Rd_estage)))
			forward_b = 2'b01; // forward alu_out in estage
		else if (RegWrite_mstage && (Rd_mstage != 5'd31) && ((Rd_mstage == Rm_reg_stage) || 
					(Ab == Rd_mstage)))
			forward_b = 2'b10; // forward DW in mstage
		else
			forward_b = 2'b00; // do nothing (Db == Db)
	end
	
	always_comb begin
			if (forward_a == 2'b00)begin
				assign alu_first_i_final = alu_first_i_temp;
				//assign Da = Da;
			end
			else if (forward_a == 2'b01)begin
				assign alu_first_i_final = alu_out_estage;
				//assign Da = Da;
			end
			else if (forward_a == 2'b10)begin
				assign alu_first_i_final = Dw;
				//assign Da = Da;
			end
			else begin
				assign alu_first_i_final = alu_first_i_temp;
				//assign Da = Da;
			end
		//end
	end
	
	always_comb begin
		if (forward_b == 2'b00)begin
			assign alu_sec_i_final = sec_i_alu_temp;
			assign Db = Db;
		end
		else if (forward_b == 2'b01)begin // MOVK special case
			if (!MemWrite && (ALU_first_i_sel == 2'b10))begin
				//assign alu_sec_i_final = Dw;// deleted and worked for forwarding bm
				assign Db = alu_out_estage;
				//assign alu_first_i_final = alu_first_i_temp;
				
				//assign Db = Dw;
			end
			else if (RegWrite_estage && RegWrite)begin
				assign alu_sec_i_final = alu_out_estage;
			end
			else begin
				assign Db = alu_out_estage;
				assign alu_first_i_final = alu_first_i_final;
			end
		end
		else if (forward_b == 2'b10)begin
			if (MemWrite_m_stage)begin
				assign alu_sec_i_final = Dw;
				assign Db = Dw;
			end
			else if (RegWrite && !MemRead)begin
				assign alu_sec_i_final = Dw;
				assign Db = Dw;
				assign Db = Db_estage_temp;
			end
			else if (MemWrite_estage && MemRead && RegWrite) begin
				//assign alu_sec_i_final = sec_i_alu_temp;
				assign Db = alu_out_mstage;
			end
			else
				assign Db = Dw;
		end
		else begin
			assign alu_sec_i_final = sec_i_alu_temp;
			assign Db = Db;
		end
	end

	
endmodule
