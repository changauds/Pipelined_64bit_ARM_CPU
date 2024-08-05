`timescale 1ns/10ps
// S2S1S0
// this module corresponds to ALU opcode : 010, 011 for full adders
module full_add_sub(A,B, Cin, select, Sum, Cout);
	input logic A,B, Cin;
	input logic [2:0] select;
	output logic Sum, Cout;
	
	//logic use_this_B, A_B, first_op, sec_op;
	logic use_this_B, sec_op_SUM, first_op, sec_op, third_op;
	/*
	// logic to enable addition or subtraction full adder
	not #0.05(S2_not, select[2]);
	and #0.05(enable, S2_not, select[1]);*/
	
	// MUX to choose which B to use to add/subtract w/
	xor #0.05(use_this_B, select[0], B);
	
	// to calculate the SUM
	xor #0.05(sec_op_SUM, A, use_this_B);
	xor #0.05(Sum, Cin, sec_op_SUM);
	// to calculate the Cout
	and #0.05(first_op, A, use_this_B);
	and #0.05(sec_op, use_this_B, Cin);
	and #0.05(third_op, Cin, A);
	or #0.05(Cout, first_op, sec_op, third_op);

endmodule


// module used to test
module full_adder #(parameter LENGTH = 64)(A, B, Cin, Sum, Cout, overflow, select, negative, zero, carry_flag);
	input logic [LENGTH-1:0] A, B, Cin;
	output logic [LENGTH-1:0] Sum, Cout;
	output logic [1:0]overflow, negative, zero, carry_flag;
	input logic [2:0] select;
		
	genvar i;
	
	// to connect select bits to the first full adder operation
	full_add_sub dut1(.A(A[0]), .B(B[0]), .Cin(select[0]), .select(select),.Sum(Sum[0]), .Cout(Cout[0]));

	// generate 63 more full adders for each bit, connecting Cin to the previous Cout, Cout to the next Cin
	generate
	for (i=1; i<64; i++) begin:eachFullAdder
		full_add_sub dut1(.A(A[i]),.B(B[i]), .Cin(Cout[i-1]), .select(select), .Sum(Sum[i]), .Cout(Cout[i]));
	end
	endgenerate
	
	// at the 63rd bit of the full adder, we need to XOR the 62nd Cout and 63rd Cout to signal overflow flag
	xor #0.05(overflow[0], Cout[62], Cout[63]);
	buf #0.05(carry_flag[0], Cout[63]);
	xor #0.05(overflow[1], Cout[62], Cout[63]);
	buf #0.05(carry_flag[1], Cout[63]);
	
	genvar j,k;
	
	logic [15:0] zero_check;
	logic [3:0] zero_check2;
	logic zero_check3;
	
	// to trigger the zero flag, we need to use iterate through all 64 bits using OR gate then a NOT gate
	generate
		for (j=0; j<16; j++) begin: eachOrGate
			or #0.05(zero_check[j], Sum[j*4], Sum[j*4+1], Sum[j*4+2], Sum[j*4+3]);
		end
		for (k=0; k<4; k++) begin: eachNotGate
			or #0.05(zero_check2[k], zero_check[k*4], zero_check[k*4+1], zero_check[k*4+2], zero_check[k*4+3]);
		end
		or #0.05(zero_check3, zero_check2[0], zero_check2[1], zero_check2[2], zero_check2[3]);
		not #0.05(zero[0], zero_check3);
		not #0.05(zero[1], zero_check3);
	endgenerate
	
	// to trigger the negative flag, the most significant bit has to be 1
	and #0.05(negative[0], Sum[63], 1'b1);
	and #0.05(negative[1], Sum[63], 1'b1);

endmodule
