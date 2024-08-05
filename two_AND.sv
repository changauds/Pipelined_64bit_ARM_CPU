`timescale 1ns/10ps

module dec2to4(inA, inB, out, enable);
	input logic inA, inB, enable;
	output logic [3:0] out;
	
	not #0.05 notGate_A(notA, inA);
	not #0.05 notGate_B(notB, inB);
	
	and #0.05 d1(out[0], notA, notB, enable);
	and #0.05 d2(out[1], notA, inB, enable);
	and #0.05 d3(out[2], inA, notB, enable);
	and #0.05 d4(out[3], inA, inB, enable);

endmodule

module dec3to8(inC, inD, inE, out2, enable);
	input logic inC, inD, inE, enable;
	output logic [7:0] out2;
	
	not #0.05 notGate_C(notC, inC);
	not #0.05 notGate_D(notD, inD);
	not #0.05 notGate_E(notE, inE);
	
	and #0.05 dec_and0(out2[0], notC, notD, notE, enable);
	and #0.05 dec_and1(out2[1], notC, notD, inE, enable);
	and #0.05 dec_and2(out2[2], notC, inD, notE, enable);
	and #0.05 dec_and3(out2[3], notC, inD, inE, enable);
	and #0.05 dec_and4(out2[4], inC, notD, notE, enable);
	and #0.05 dec_and5(out2[5], inC, notD, inE, enable);
	and #0.05 dec_and6(out2[6], inC, inD, notE, enable);
	and #0.05 dec_and7(out2[7], inC, inD, inE, enable);
	
endmodule

// module to connect the 2to4 and 3to8 decoders
module combination(inA, inB, inC, inD, inE, clk, dec_2_i, enable);
	input logic clk, inA, inB, inC, inD, inE;
	input logic enable;
	output logic [31:0] dec_2_i;
	//output logic [31:0] decoder_o;
	
	logic [3:0]dec_1_i;

	dec2to4 dut0(.inA, .inB, .out(dec_1_i), .enable(enable));
	
	dec3to8 dut1(.inC, .inD, .inE, .enable(dec_1_i[3]), .out2(dec_2_i[31:24]));
	dec3to8 dut2(.inC, .inD, .inE, .enable(dec_1_i[2]), .out2(dec_2_i[23:16]));
	dec3to8 dut3(.inC, .inD, .inE, .enable(dec_1_i[1]), .out2(dec_2_i[15:8]));
	dec3to8 dut4(.inC, .inD, .inE, .enable(dec_1_i[0]), .out2(dec_2_i[7:0]));
	

endmodule

