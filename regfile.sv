`timescale 1ns/10ps

module regfile (ReadRegister1, ReadRegister2, WriteRegister
					, WriteData, RegWrite, clk, ReadData1,
					ReadData2);
					
	input logic [4:0] WriteRegister;
	input logic RegWrite, clk;
	input logic [63:0] WriteData;
	output logic [63:0] ReadData1, ReadData2;
	input logic [4:0] ReadRegister1, ReadRegister2;
	//64 bits , 32 copies
	logic [31:0]numb_reg;
	logic [31:0][63:0] reg_bit;
	
	assign reg_bit[31] = 64'b0;
	
	combination dut1(.inA(WriteRegister[4]), .inB(WriteRegister[3]), .inC(WriteRegister[2]), .inD(WriteRegister[1]), .inE(WriteRegister[0]), .clk(clk), .dec_2_i(numb_reg)
					,.enable(RegWrite)); //decoder

	//generate 32 times
	genvar f;
	generate
		for (f=0; f<31; f++) begin: eachffp
			gen_d_FF dut2(.q(reg_bit[f]),.d(WriteData),.reset(1'b0),.clk(clk), .enable(numb_reg[f])); // registers
		end
	endgenerate

	// 32 copies, 64 bits
	logic [63:0][31:0] temp;
	
	genvar k,l;
	
	generate
		for (k=0; k<64; k++) begin: array1
			for(l=0; l<32; l++) begin: array2
				assign temp[k][l] = reg_bit[l][k]; 
			end
		end
		
	endgenerate
	
	muxr_loop_regfile dut3(.mux_input(temp), .S4(ReadRegister1[4]), .S3(ReadRegister1[3]), .S2(ReadRegister1[2]), .S1(ReadRegister1[1]), .S0(ReadRegister1[0]), .fi_out(ReadData1));
	muxr_loop_regfile dut4(.mux_input(temp), .S4(ReadRegister2[4]), .S3(ReadRegister2[3]), .S2(ReadRegister2[2]), .S1(ReadRegister2[1]), .S0(ReadRegister2[0]), .fi_out(ReadData2));
	
	endmodule

