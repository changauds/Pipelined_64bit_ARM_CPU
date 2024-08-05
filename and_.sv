`timescale 1ns/10ps

module and_function(A, B, result);
	input logic A, B;
	output logic result;
	
	and #0.05(result, A, B);
	
endmodule


module and_(A, B, result, select, overflow, negative, zero, carry_flag);
	input logic [63:0] A, B;
	input logic [2:0] select;
	output logic [63:0] result;
	output logic overflow, negative, zero, carry_flag;
	
	//logic S1_not, S0_not;
	/*
	// logic to enable and function
	not #0.05(S1_not, select[1]);
	not #0.05(S0_not, select[0]);
	and #0.05(enable, select[2], S1_not, S0_not);*/
	
	genvar i;
	genvar j,k;
	generate
		for (i=0; i<64; i++) begin: eachAndGate
			and_function dut1(.A(A[i]), .B(B[i]), .result(result[i]));
		end
	endgenerate
	
	logic [15:0] zero_check;
	logic [3:0] zero_check2;
	logic zero_check3;
	
	// to trigger the zero flag, we need to use iterate through all 64 bits using OR gate then a NOT gate
	generate
		for (j=0; j<16; j++) begin: eachOrGate2
			or #0.05(zero_check[j], result[j*4], result[j*4+1], result[j*4+2], result[j*4+3]);
		end
		for (k=0; k<4; k++) begin: eachNotGate2
			or #0.05(zero_check2[k], zero_check[k*4], zero_check[k*4+1], zero_check[k*4+2], zero_check[k*4+3]);
		end
		or #0.05(zero_check3, zero_check2[0], zero_check2[1], zero_check2[2], zero_check2[3]);
		not #0.05(zero, zero_check3);
	endgenerate
	
	and #0.05(negative, result[63], 1'b1);
	// at the 63rd bit of the full adder, we need to XOR the 62nd Cout and 63rd Cout to signal overflow flag
	assign overflow = 0;
	assign carry_flag = 0;
	
endmodule