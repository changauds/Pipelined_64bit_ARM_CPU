`timescale 1ns/10ps

module alu#(parameter LENGTH = 64)(A, B, cntrl, result, negative, zero, overflow, carry_out);
	input logic [LENGTH-1:0] A, B;
	input logic [2:0] cntrl;
	output logic [LENGTH-1:0] result;
	output logic negative, zero, overflow, carry_out;
	logic [7:0]zero_flag, negative_flag, overflow_flag, carry_flag;
	
	logic [LENGTH-1:0] buffer_result, adder_result, and_result, or_result, xor_result;
	logic [LENGTH-1:0] hard_code001, hard_code111;
	assign hard_code001 = 0;
	assign hard_code111 = 0;
	
	logic [LENGTH-1:0] Cout, Cin;
	
	

	full_adder dut1(.A(A), .B(B), .Cin(Cin), .Sum(adder_result), .Cout(Cout), .overflow(overflow_flag[3:2]),
						.select(cntrl), .negative(negative_flag[3:2]), .zero(zero_flag[3:2]), .carry_flag(carry_flag[3:2]));
	
	buffer dut2(.A(A), .B(B), .select(cntrl), .out(buffer_result), .overflow(overflow_flag[0]), .negative(negative_flag[0]), .zero(zero_flag[0]), .carry_flag(carry_flag[0]));
	
	and_ dut3(.A(A), .B(B), .result(and_result), .select(cntrl), .overflow(overflow_flag[4]), .negative(negative_flag[4]), .zero(zero_flag[4]), .carry_flag(carry_flag[4]));
	
	or_ dut4(.A(A), .B(B), .result(or_result), .select(cntrl), .overflow(overflow_flag[5]), .negative(negative_flag[5]), .zero(zero_flag[5]), .carry_flag(carry_flag[5]));
	
	xor_ dut5(.A(A), .B(B), .result(xor_result), .select(cntrl), .overflow(overflow_flag[6]), .negative(negative_flag[6]), .zero(zero_flag[6]), .carry_flag(carry_flag[6]));	
	
	muxr_loop_alu dut6(.S2(cntrl[2]),.S1(cntrl[1]),.S0(cntrl[0]), .D0(buffer_result), .D1(hard_code001), .D2(adder_result), 
					.D3(adder_result), .D4(and_result), .D5(or_result), .D6(xor_result), .D7(hard_code111), 
					.mux_output(result));
	
	assign zero_flag[1] = 0;
	assign zero_flag[7] = 0;
	assign overflow_flag[1] = 0;
	assign overflow_flag[7] = 0;
	assign carry_flag[1] = 0;
	assign carry_flag[7] = 0;
	assign negative_flag[1] = 0;
	assign negative_flag[7] = 0;
	
	mux_8_1 dut7(.S2(cntrl[2]), .S1(cntrl[1]), .S0(cntrl[0]), .D0(zero_flag[0]), .D1(zero_flag[1]), .D2(zero_flag[2]), .D3(zero_flag[3]), .D4(zero_flag[4]), .D5(zero_flag[5]), .D6(zero_flag[6]), .D7(zero_flag[7]), . out_mux(zero));
	mux_8_1 dut8(.S2(cntrl[2]), .S1(cntrl[1]), .S0(cntrl[0]), .D0(negative_flag[0]), .D1(negative_flag[1]), .D2(negative_flag[2]), .D3(negative_flag[2]), .D4(negative_flag[4]), .D5(negative_flag[5]), .D6(negative_flag[6]), .D7(negative_flag[7]), . out_mux(negative));
	mux_8_1 dut9(.S2(cntrl[2]), .S1(cntrl[1]), .S0(cntrl[0]), .D0(carry_flag[0]), .D1(carry_flag[1]), .D2(carry_flag[2]), .D3(carry_flag[3]), .D4(carry_flag[4]), .D5(carry_flag[5]), .D6(carry_flag[6]), .D7(carry_flag[7]), . out_mux(carry_out));
	mux_8_1 dut10(.S2(cntrl[2]), .S1(cntrl[1]), .S0(cntrl[0]), .D0(overflow_flag[0]), .D1(overflow_flag[1]), .D2(overflow_flag[2]), .D3(overflow_flag[3]), .D4(overflow_flag[4]), .D5(overflow_flag[5]), .D6(overflow_flag[6]), .D7(overflow_flag[7]), . out_mux(overflow));

	
endmodule
