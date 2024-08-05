`timescale 1ns/10ps

module forwarding_control_path (input logic clk, reset,
						input logic negativef, overflowf, carryf, zerof,
						input logic [31:0] instruct_bits,
						output logic flag_enable,
						output logic BrTaken, Reg2Loc, RegWrite,MemRead, MemWrite, UnCondBr, xsize_loc,flag_check,
						output logic [1:0] ALU_first_i_sel,
						output logic [2:0] ALUSrc, ALUOp, MemtoReg);
							
	//logic flag_check; // calculated during ADDS instruction, but used for B.LT instruction

	// result should go into the first input to the mux for memtoreg
	assign flag_check = (negativef != overflowf) ? 1'b1:1'b0;
	logic ADDI, ADDS, B, B_LT, CBZ, LDUR, LDURB, MOVK, MOVZ, STUR, STURB, SUBS;
	// to assign instruction bits to each operation
	always_comb begin
		ADDI = (instruct_bits[31:22] == 10'b1001000100);
		ADDS = (instruct_bits[31:21] == 11'b10101011000);
		B = (instruct_bits[31:26] == 6'b000101);
		B_LT = (instruct_bits[31:24] == 8'b01010100);
		CBZ = (instruct_bits[31:24] == 8'b10110100);
		LDUR = (instruct_bits[31:21] == 11'b11111000010);
		LDURB = (instruct_bits[31:21] == 11'b00111000010);
		MOVK = (instruct_bits[31:23] == 9'b111100101);
		MOVZ = (instruct_bits[31:23] == 9'b110100101);
		STUR = (instruct_bits[31:21] == 11'b11111000000);
		STURB = (instruct_bits[31:21] == 11'b00111000000);
		SUBS = (instruct_bits[31:21] == 11'b11101011000);
	end	
	// to assign control signals to each operation
	always_comb begin
		if (ADDI) begin
			BrTaken = 0;
			Reg2Loc = 1; // dont care
			RegWrite = 1;
			MemRead = 0;
			MemWrite = 0;
			UnCondBr = 1; // dont care
			xsize_loc = 1; // dont care
			ALUSrc = 3'd0;
			ALUOp = 3'd2;
			MemtoReg = 3'd0;
			ALU_first_i_sel = 2'd0; 
			flag_enable = 0;
		end
		else if (ADDS) begin
			BrTaken = 0;
			Reg2Loc = 0; // dont care
			RegWrite = 1;
			MemRead = 0;
			MemWrite = 0;
			UnCondBr = 0; // dont care
			xsize_loc = 1; // dont care
			ALUSrc = 3'd1;
			ALUOp = 3'd2;
			MemtoReg = 3'd0;
			ALU_first_i_sel = 2'd0;
			flag_enable = 1;
		end
		else if (B) begin
			BrTaken = 1;
			Reg2Loc = 0; // dont care
			RegWrite = 0;
			MemRead = 0;
			MemWrite = 0;
			UnCondBr = 1;
			xsize_loc = 1; // dont care
			ALUSrc = 3'd0; // dont care
			ALUOp = 3'd2; // dont care
			MemtoReg = 3'd0; // dont care
			ALU_first_i_sel = 2'd0;
			flag_enable = 0;
		end
		else if (B_LT) begin
			BrTaken = flag_check;
			Reg2Loc = 0; // dont care
			RegWrite = 0;
			MemRead = 0;
			MemWrite = 0;
			UnCondBr = 0;
			xsize_loc = 1; // dont care
			ALUSrc = 3'd0; // dont care
			ALUOp = 3'd0; // dont care
			MemtoReg = 3'd0; // dont care
			ALU_first_i_sel = 2'd0;
			flag_enable = 0;
		end
		else if (CBZ) begin
			BrTaken = zerof;
			Reg2Loc = 1; 
			RegWrite = 0;
			MemRead = 0;
			MemWrite = 0;
			UnCondBr = 0;
			xsize_loc = 1; // dont care
			ALUSrc = 3'd1;
			ALUOp = 3'd0;
			MemtoReg = 3'd0; // dont care
			ALU_first_i_sel = 2'd3;
			flag_enable = 1;
		end
		else if (LDUR) begin
			BrTaken = 0;
			Reg2Loc = 1; // dont care
			RegWrite = 1;
			MemRead = 1;
			MemWrite = 0;
			UnCondBr = 0; // dont care
			xsize_loc = 0;
			ALUSrc = 3'b010;
			ALUOp = 3'd2;
			MemtoReg = 3'd1;
			ALU_first_i_sel = 2'd0;
			flag_enable = 0;
		end
		else if (LDURB) begin
			BrTaken = 0;
			Reg2Loc = 1;
			RegWrite = 1;
			MemRead = 1;
			MemWrite = 0;
			UnCondBr = 0; // dont care
			xsize_loc = 1;
			ALUSrc = 3'b010;
			ALUOp = 3'd2;
			MemtoReg = 3'd3;
			ALU_first_i_sel = 2'd0;
			flag_enable = 0;
		end
		else if (MOVK) begin
			BrTaken = 0;
			Reg2Loc = 1; 
			RegWrite = 1;
			MemRead = 0;
			MemWrite = 0;
			UnCondBr = 0; // dont care
			xsize_loc = 0; // dont care
			ALUSrc = 3'd3;
			ALUOp = 3'd2;
			MemtoReg = 3'd0;
			ALU_first_i_sel = 2'd2;
			flag_enable = 0;
		end
		else if (MOVZ) begin
			BrTaken = 0;
			Reg2Loc = 0;
			RegWrite = 1;
			MemRead = 0;
			MemWrite = 0;
			UnCondBr = 0; // dont care
			xsize_loc = 0; // dont care
			ALUSrc = 3'd3;
			ALUOp = 3'd2;
			MemtoReg = 3'd0;
			ALU_first_i_sel = 2'd1;
			flag_enable = 0;
		end
		else if (STUR) begin
			BrTaken = 0;
			Reg2Loc = 1;
			RegWrite = 0;
			MemRead = 0;
			MemWrite = 1;
			UnCondBr = 0; // dont care
			xsize_loc = 0;
			ALUSrc = 3'd2;
			ALUOp = 3'd2;
			MemtoReg = 3'd0; // dont care
			ALU_first_i_sel = 2'd0;
			flag_enable = 0;
		end
		else if (STURB) begin
			BrTaken = 0;
			Reg2Loc = 1; // reg2loc used to be 0; rerun ldurb sturb 
			RegWrite = 0;
			MemRead = 0;
			MemWrite = 1;
			UnCondBr = 0; // dont care
			xsize_loc = 1;
			ALUSrc = 3'd2;
			ALUOp = 3'd2;
			MemtoReg = 3'd0; // dont care
			ALU_first_i_sel = 2'd0;
			flag_enable = 0;
		end
		else if (SUBS) begin
			BrTaken = 0;
			Reg2Loc = 0;
			RegWrite = 1;
			MemRead = 0;
			MemWrite = 0; // dont care
			UnCondBr = 0; // dont care
			xsize_loc = 1; // dont care
			ALUSrc = 3'd1;
			ALUOp = 3'd3;
			MemtoReg = 3'd0;
			ALU_first_i_sel = 2'd0;
			flag_enable = 1;
		end
		else begin
			BrTaken = 0; // dont care
			Reg2Loc = 0; // dont care
			RegWrite = 0; // dont care
			MemRead = 0; // dont care
			MemWrite = 0; // dont care
			UnCondBr = 0; // dont care
			xsize_loc = 1; // dont care
			ALUSrc = 3'd0; // dont care
			ALUOp = 3'd0; // dont care
			MemtoReg = 3'd0; // dont care
			ALU_first_i_sel = 2'd0; // dont care
			flag_enable = 0;
		end
	end

	
endmodule


module control_path_tb();
	logic clk, reset;
	logic negativef, overflowf, zerof, carryf, flag_enable, zero_comparator;
	logic [31:0] instruct_bits;
	logic [1:0] ALU_first_i_sel;
	logic BrTaken, Reg2Loc, RegWrite,MemRead, MemWrite, UnCondBr, RdLoc, xsize_loc;
	logic [2:0] ALUSrc, ALUOp, MemtoReg;

	
	control_path dut1(.*);
	
	parameter clock_period = 100;
	
	initial begin
		clk <= 0;
		forever #(clock_period / 2) clk <= ~clk;
	end
	
	initial begin
		reset <= 1; 
				#100; @(posedge clk);
		reset <= 0; overflowf <= 1; negativef <= 0; zerof <= 1; carryf <= 1;
		instruct_bits = 32'b10010001000000000000001111100000; // testing addi
				#100; @(posedge clk);
		instruct_bits = 32'b11101011000000000000001111100001; // testing subs
				#100; @(posedge clk);
		instruct_bits = 32'b10110100000000000000001010011111; // testing cbz
				#100; @(posedge clk);
		instruct_bits = 32'b11111000010000000101000010000111; // testing ldur
				#200; @(posedge clk);
		instruct_bits = 32'b11111000000000001000000001100010; // testing stur
				#100; @(posedge clk);
		instruct_bits = 32'b01010100000000000000000100001011; // testing BLT
				#100; @(posedge clk);
		instruct_bits = 32'b11110010110110111101010110100001; // testing MOVK
				#100; @(posedge clk);
		instruct_bits = 32'b11010010101101111101110111100000; // testing MOVZ
				#100; @(posedge clk);
		instruct_bits = 32'b00111000010000001000001111101000; // testing LDURB
				#100; @(posedge clk);
		instruct_bits = 32'b00111000000000000010001111100000; // testing STURB
				#100; @(posedge clk);
		instruct_bits = 32'b00010100000000000000000000000000; // testing B
				#100; @(posedge clk);
		instruct_bits = 32'b10101011000000010000000000000110; // testing ADDS
				#100; @(posedge clk);
		$stop;
	end
endmodule
