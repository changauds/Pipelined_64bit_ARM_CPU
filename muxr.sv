`timescale 1ns/10ps

// this file contains the 64 32:1 muxes required
// for a register file

// also, in the actual regfile (kinda like the top
// level module, there has to be 32 iterations of
// the 64 bit d flip flops to act as the 32 registers
// and then that 5 bit number acts as the selector lines
module s4s3_AND(S4, S3, andOut);
	input logic S4, S3;
	output logic [3:0]andOut;
	
	not #0.05 s4_not(S4_not, S4);
	not #0.05 s3_not(S3_not, S3);
	
	and #0.05 and0(andOut[3], S4_not, S3_not);
	and #0.05 and1(andOut[2], S4_not, S3);
	and #0.05 and2(andOut[1], S4, S3_not);
	and #0.05 and3(andOut[0], S4, S3);
	
endmodule

module s2s1s0_AND(enable, S2,S1,S0, D0, D1, D2, D3, D4, D5, D6, D7, out_mux);
	input logic enable, S2,S1,S0;
	input logic D0, D1, D2, D3, D4, D5, D6, D7;
	//output logic out_mux;
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

module muxr(mux_in, or_g, S4,S3,S2,S1,S0);
	logic [3:0] enable;
	input logic [31:0] mux_in;
	logic outd0, outd1, outd2, outd3;
	logic out_andd0, out_andd1, out_andd2, out_andd3;
	output logic or_g;
	input logic S4,S3,S2,S1,S0; // selects connect to register
	
	s4s3_AND dut3(.S4(S4), .S3(S3), .andOut(enable[3:0]));
	
	// to create 4 8:1 muxes
	s2s1s0_AND dut4(.enable(enable[3]), .S2(S2),.S1(S1),.S0(S0), .D0(mux_in[0])
	, .D1(mux_in[1]), .D2(mux_in[2]), .D3(mux_in[3]), .D4(mux_in[4]), .D5(mux_in[5]), .D6(mux_in[6]), .D7(mux_in[7]), .out_mux(outd0));
	s2s1s0_AND dut5(.enable(enable[2]), .S2(S2),.S1(S1),.S0(S0), .D0(mux_in[8])
	, .D1(mux_in[9]), .D2(mux_in[10]), .D3(mux_in[11]), .D4(mux_in[12]), .D5(mux_in[13]), .D6(mux_in[14]), .D7(mux_in[15]), .out_mux(outd1));
	s2s1s0_AND dut6(.enable(enable[1]), .S2(S2),.S1(S1),.S0(S0), .D0(mux_in[16])
	, .D1(mux_in[17]), .D2(mux_in[18]), .D3(mux_in[19]), .D4(mux_in[20]), .D5(mux_in[21]), .D6(mux_in[22]), .D7(mux_in[23]), .out_mux(outd2));
	s2s1s0_AND dut7(.enable(enable[0]), .S2(S2),.S1(S1),.S0(S0), .D0(mux_in[24])
	, .D1(mux_in[25]), .D2(mux_in[26]), .D3(mux_in[27]), .D4(mux_in[28]), .D5(mux_in[29]), .D6(mux_in[30]), .D7(mux_in[31]), .out_mux(outd3));

	and #0.05 and12(out_andd0, outd0, enable[3]);
	and #0.05 and13(out_andd1, outd1, enable[2]);
	and #0.05 and14(out_andd2, outd2, enable[1]);
	and #0.05 and15(out_andd3, outd3, enable[0]);
	
	or #0.05 or_gate(or_g, out_andd0, out_andd1, out_andd2, out_andd3);
	
endmodule

// module to loop through the 32 registers 64 times for each bit
module muxr_loop_regfile(mux_input, S4,S3,S2,S1,S0, fi_out);
	input logic [63:0][31:0]mux_input;
	input logic S4,S3,S2,S1,S0;
	output logic [63:0]fi_out;
	
	genvar m;
	generate
		for (m = 0; m<64; m++) begin : eachBitofMux
			muxr dut1(.mux_in(mux_input[m]), .or_g(fi_out[m]), .S4(S4),.S3(S3),.S2(S2),.S1(S1),.S0(S0));
		end
	endgenerate
endmodule
