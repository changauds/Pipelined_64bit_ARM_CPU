module sign_extender(input logic [18:0] Imm19_old,
							input logic [25:0] Imm26_old, 
							input logic [11:0] Imm12_old,
							input logic [8:0] Imm9_old,
							input logic [15:0] Imm16_old,
							input logic clk,
							output logic [63:0] Imm19,
							output logic [63:0] Imm26, 
							output logic [63:0] Imm12,
							output logic [63:0] Imm9,
							output logic [63:0] Imm16);
					
	assign Imm19 = {{45{Imm19_old[18]}}, Imm19_old};
	assign Imm12 = {52'd0, Imm12_old};
	assign Imm26 = {{38{Imm26_old[25]}}, Imm26_old};
	assign Imm9 = {{55{Imm9_old[8]}},Imm9_old};
	assign Imm16 = {{48{Imm16_old[15]}}, Imm16_old};
	//mux_2_1_brtaken_uncondbr dut4(.S0(Imm9_old[8]), .D0({55'd0, Imm9_old}), .D1({55'h7FFFFFFFFFFFFF, Imm9_old}), .out_mux(Imm9));

	
endmodule
