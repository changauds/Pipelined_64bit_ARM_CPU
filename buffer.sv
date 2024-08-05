`timescale 1ns/10ps

// module for the select bit 000: buffer resulting in output = B
// overflow and carryout does not matter

// should I move to the top level module ?? because
// calculations are done regardless of select bits
module bit_1_buff (A, B, select, out, clk);
	input logic A, B;
	input logic clk;
	input logic [2:0] select; // only carry about select[2:1]
	output logic out;
	
	// mux to use B as an output only when select bits 2 and 1 are both zero
	not #0.05 S2_not(not_S2, select[2]);
	not #0.05 S1_not(not_S1, select[1]);
	
	and #0.05 and1(t0, not_S2, not_S1, B);
	and #0.05 and2(t1, not_S2, S1, 0);
	and #0.05 and3(t2, S2, not_S1, 0);
	and #0.05 and4(t3, S2, S1, 0);
	
	or #0.05 orgate_mux(out, t0, t1, t2, t3);
	
endmodule

module buffer #(parameter LENGTH = 64)(A, B, select, out, overflow, negative, zero, carry_flag);
	input logic [LENGTH-1:0] A, B;
	input logic [2:0] select;
	output logic [LENGTH-1:0] out;
	output logic overflow, negative, zero, carry_flag;
	
	genvar i;
	genvar j,k;
	
	generate
		for (i=0; i<LENGTH; i++) begin: eachBit
			bit_1_buff dut2(.A(A[i]), .B(B[i]), .select(select), .out(out[i]), .clk(clk));
		end
	endgenerate
	
	logic [15:0] zero_check;
	logic [3:0] zero_check2;
	logic zero_check3;
	
	// to trigger the zero flag, we need to use iterate through all 64 bits using OR gate then a NOT gate
	generate
		for (j=0; j<16; j++) begin: eachOrGate1
			or #0.05(zero_check[j], out[j*4], out[j*4+1], out[j*4+2], out[j*4+3]);
		end
		for (k=0; k<4; k++) begin: eachNotGate1
			or #0.05(zero_check2[k], zero_check[k*4], zero_check[k*4+1], zero_check[k*4+2], zero_check[k*4+3]);
		end
		or #0.05(zero_check3, zero_check2[0], zero_check2[1], zero_check2[2], zero_check2[3]);
		not #0.05(zero, zero_check3);
	endgenerate
	
	and #0.05(negative, out[63], 1'b1);
	// at the 63rd bit of the full adder, we need to XOR the 62nd Cout and 63rd Cout to signal overflow flag
	assign overflow = 0;
	assign carry_flag = 0;

endmodule


module buffer_tb#(parameter LENGTH = 64)();
	logic [LENGTH-1:0] A, B;
	logic [2:0] select;
	logic [LENGTH-1:0] out;
	logic clock;
	
	parameter clock_period = 100;
		
	initial begin
		clock <= 0;
		forever #(clock_period /2) clock <= ~clock;
	end //initial
	
	buffer dut3(.A(A), .B(B), .select(select), .out(out), .clk(clock));
	
	initial begin
		A = 64'd4; B = 64'd3; select = 3'b010;
					#50; @(posedge clock);
									select = 3'b000;
					#50; @(posedge clock);
		A = 64'd11; B = 64'd9; select = 3'b000;
					#50; @(posedge clock);
									select = 3'b010;
					#50; @(posedge clock);
		$stop;
	end
	
	

endmodule

