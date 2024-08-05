`timescale 1ns/10ps

module mux_2_1(S0, D0, D1, out_mux);
	input logic S0, D0, D1;
	output logic out_mux;
	
	logic t0,t1;
	
	not #0.05 s0_not(S0_not, S0);
	
	and #0.05 and1(t0, S0_not, D0);
	and #0.05 and2(t1, S0, D1);
	
	or #0.05 or1(out_mux, t0, t1);
	
endmodule

module mux_reg2loc(S0, D0, D1, out_mux);
	input logic S0;
	input logic [4:0] D0, D1;
	output logic [4:0] out_mux;
	
	genvar i;
	generate
		for (i=0; i<5; i++) begin: each_bit_reg2loc
			mux_2_1 dut1(.S0(S0), .D0(D0[i]), .D1(D1[i]), .out_mux(out_mux[i]));
		end
	endgenerate
	
endmodule

module mux_3bit(S0, D0, D1, out_mux);
	input logic S0;
	input logic [3:0] D0, D1;
	output logic [3:0] out_mux;
	
	genvar i;
	generate
		for (i=0; i<4; i++) begin: each_bit_reg2loc
			mux_2_1 dut1(.S0(S0), .D0(D0[i]), .D1(D1[i]), .out_mux(out_mux[i]));
		end
	endgenerate
	
endmodule

module mux_xsize_loc(S0, D0, D1, out_mux);
	input logic S0;
	input logic [3:0] D0, D1;
	output logic [3:0] out_mux;
	
	genvar i;
	generate
		for (i=0; i<4; i++) begin: each_bit_xsize_loc
			mux_2_1 dut3(.S0(S0), .D0(D0[i]), .D1(D1[i]), .out_mux(out_mux[i]));
		end
	endgenerate

endmodule

module mux_2_1_brtaken_uncondbr(S0, D0, D1, out_mux);
	input logic S0;
	input logic [63:0] D0, D1;
	output logic [63:0] out_mux;
	
	genvar i;
	generate
		for (i=0; i<64; i++) begin: each_bit_brtaken
			mux_2_1 dut4(.S0(S0), .D0(D0[i]), .D1(D1[i]), .out_mux(out_mux[i]));
		end
	endgenerate
endmodule

module mux_64_bit(S0, D0, D1, out_mux);
	input logic S0;
	input logic [63:0] D0, D1;
	output logic [63:0] out_mux;
	
	genvar i;
	generate
		for (i=0; i<64; i++) begin: each_bit_brtaken
			mux_2_1 dut4(.S0(S0), .D0(D0[i]), .D1(D1[i]), .out_mux(out_mux[i]));
		end
	endgenerate
endmodule

module mux_32_bit(S0, D0, D1, out_mux);
	input logic S0;
	input logic [31:0] D0, D1;
	output logic [31:0] out_mux;
	
	genvar i;
	generate
		for (i=0; i<32; i++) begin: each_bit_brtaken
			mux_2_1 mux_32_bit(.S0(S0), .D0(D0[i]), .D1(D1[i]), .out_mux(out_mux[i]));
		end
	endgenerate
endmodule
module mux_4_1(S0, S1, D0,D1,D2,D3, out_mux);
	input logic S0, S1, D0, D1,D2, D3;
	output logic out_mux;
	
	logic t0,t1,t2, t3;
	
	not #0.05 s0_not(S0_not, S0);
	not #0.05 s1_not(S1_not, S1);
	
	and #0.05 and3(t0, S1_not, S0_not, D0);
	and #0.05 and4(t1, S1_not, S0, D1);
	and #0.05 and5(t2, S1, S0_not, D2);
	and #0.05 and6(t3, S1, S0, D3);
	
	or #0.05 orgate_mux(out_mux, t0,t1,t2,t3);
endmodule

module mux_4_1_alusrc_memtoreg(S0, S1, D0, D1, D2, D3, out_mux);
	input logic S0, S1;
	input logic [63:0] D0, D1, D2, D3;
	output logic [63:0] out_mux;
	
	genvar i;
	generate
		for (i=0; i<64; i++) begin: each_bit_alusrc
			mux_4_1 dut2(.S0(S0), .S1(S1), .D0(D0[i]),.D1(D1[i]),.D2(D2[i]),.D3(D3[i]), .out_mux(out_mux[i]));
		end
	endgenerate
endmodule

module mux_4_1_mask(S0, S1, D0, D1, D2, D3, out_mux);
	input logic S0, S1;
	input logic [15:0] D0, D1, D2, D3;
	output logic [15:0] out_mux;
	
	genvar i;
	generate
		for (i=0; i<16; i++) begin: each_bit_alusrc
			mux_4_1 dut5(.S0(S0), .S1(S1), .D0(D0[i]),.D1(D1[i]),.D2(D2[i]),.D3(D3[i]), .out_mux(out_mux[i]));
		end
	endgenerate
	
endmodule


module mux_8_1(S2, S1, S0, D0, D1, D2, D3, D4, D5, D6, D7, out_mux);
	input logic S2, S1, S0;
	input logic D0, D1, D2, D3, D4, D5, D6, D7;
	output logic out_mux;
	
	logic t0, t1, t2, t3, t4, t5, t6, t7;
	logic y0, y1;
	
	not #0.05 s2_not(S2_not, S2);
	not #0.05 s1_not(S1_not, S1);
	not #0.05 s0_not(S0_not, S0);
	
	and #0.05 and4(t0, S2_not, S1_not, S0_not, D0);
	and #0.05 and5(t1, S2_not, S1_not, S0, D1);
	and #0.05 and6(t2, S2_not, S1, S0_not, D2);
	and #0.05 and7(t3, S2_not, S1, S0, D3);
	and #0.05 and8(t4, S2, S1_not, S0_not, D4);
	and #0.05 and9(t5, S2, S1_not, S0, D5);
	and #0.05 and10(t6, S2, S1, S0_not, D6);
	and #0.05 and11(t7, S2, S1, S0, D7);
	
	or #0.05 orgate_mux0(y0, t0, t1, t2, t3);
	or #0.05 orgate_mux1(y1, t4, t5, t6, t7);
	
	or #0.05 orgate_muxf(out_mux, y0, y1);
	
endmodule

// module to loop through 1 bit muxes 64 times for each bit
module muxr_loop_alu(S2,S1,S0, D0, D1, D2, D3, D4, D5, D6, D7, mux_output);
	input logic [63:0]D0, D1, D2, D3, D4, D5, D6, D7;
	input logic S2,S1,S0;
	output logic [63:0]mux_output;
	
	genvar i;
	generate
		for (i = 0; i<64; i++) begin : eachBitofInputs
			mux_8_1 dut1(.S2(S2), .S1(S1), .S0(S0), .D0(D0[i]), .D1(D1[i]), .D2(D2[i]), .D3(D3[i]), 
							.D4(D4[i]), .D5(D5[i]), .D6(D6[i]), .D7(D7[i]), .out_mux(mux_output[i]));
		end
	endgenerate
endmodule
