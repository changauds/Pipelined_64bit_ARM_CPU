`timescale 1ns/10ps

module D_FF (q, d, reset, clk);
	output reg q;
	input d, reset, clk;
	
	always_ff @(posedge clk) begin //the given code is missing begin and end, it's ok to add right ? ask
		if (reset)
			q <= 0; // On reset, set to 0
		else
			q <= d; // Otherwise out = d
	end
	
endmodule

module mux_ff(d_, enable, q_, reset, clk);
	input logic d_, enable;
	output logic q_;
	input logic reset, clk;
	
	logic not_en, and_old_noten, and_new_en, temp;
	// need esentially a 2:1 mux to coordinate the corresponding input to the clock signal 
	not #0.05(not_en, enable);
	and #0.05(and_old_noten, q_, not_en);
	and #0.05(and_new_en, d_, enable);
	or #0.05(temp, and_old_noten, and_new_en);
	
	D_FF dut0(.q(q_), .d(temp), .reset(reset), .clk(clk));
	
endmodule

module mux_ff_tb();
	logic d_, enable;
	logic q_;
	logic reset, clk;
	mux_ff dut_ff(.d_, .enable, .q_, .reset, .clk);
	
	parameter clock_period = 100;
	
	initial begin
		clk <= 0;
		forever #(clock_period / 2) clk <= ~clk;
	end
	
	initial begin
		reset <= 1;
					#10; @(posedge clk);
		reset <= 0; d_<= 1; enable <= 1;
					#10; @(posedge clk);
		d_<= 2; enable <= 0;
					#10; @(posedge clk);
		d_<= 3; enable <= 1;
					#10; @(posedge clk);
		$stop;
	end
endmodule

module gen_d_FF #(parameter WIDTH = 64)(q,d,clk,reset, enable);
	output logic  [WIDTH-1:0] q;
	input logic [WIDTH-1:0] d;
	input logic clk, reset;
	input logic enable;

	initial assert(WIDTH>0);
	
	genvar i;
	
	generate
		for (i=0; i<WIDTH; i++) begin : eachDff
			mux_ff dut1(.d_(d[i]), .enable(enable), .q_(q[i]), .reset(reset), .clk(clk));
		end
	endgenerate

endmodule

module gen_d_FF_9bit #(parameter WIDTH = 9)(q,d,clk,reset, enable);
	output logic  [WIDTH-1:0] q;
	input logic [WIDTH-1:0] d;
	input logic clk, reset;
	input logic enable;

	initial assert(WIDTH>0);
	
	genvar i;
	
	generate
		for (i=0; i<WIDTH; i++) begin : eachDff
			mux_ff dut1(.d_(d[i]), .enable(enable), .q_(q[i]), .reset(reset), .clk(clk));
		end
	endgenerate

endmodule

module gen_d_FF_16bit #(parameter WIDTH = 16)(q,d,clk,reset, enable);
	output logic  [WIDTH-1:0] q;
	input logic [WIDTH-1:0] d;
	input logic clk, reset;
	input logic enable;

	initial assert(WIDTH>0);
	
	genvar i;
	
	generate
		for (i=0; i<WIDTH; i++) begin : eachDff
			mux_ff dut1(.d_(d[i]), .enable(enable), .q_(q[i]), .reset(reset), .clk(clk));
		end
	endgenerate

endmodule

module gen_d_FF_3bit #(parameter WIDTH = 3)(q,d,clk,reset, enable);
	output logic  [WIDTH-1:0] q;
	input logic [WIDTH-1:0] d;
	input logic clk, reset;
	input logic enable;

	initial assert(WIDTH>0);
	
	genvar i;
	
	generate
		for (i=0; i<WIDTH; i++) begin : eachDff
			mux_ff dut1(.d_(d[i]), .enable(enable), .q_(q[i]), .reset(reset), .clk(clk));
		end
	endgenerate

endmodule

module gen_d_FF_32bit #(parameter WIDTH = 32)(q,d,clk,reset, enable);
	output logic  [WIDTH-1:0] q;
	input logic [WIDTH-1:0] d;
	input logic clk, reset;
	input logic enable;

	initial assert(WIDTH>0);
	
	genvar i;
	
	generate
		for (i=0; i<WIDTH; i++) begin : eachDff
			mux_ff dut1(.d_(d[i]), .enable(enable), .q_(q[i]), .reset(reset), .clk(clk));
		end
	endgenerate

endmodule

module gen_d_FF_4bit #(parameter WIDTH = 4)(q,d,clk,reset, enable);
	output logic  [WIDTH-1:0] q;
	input logic [WIDTH-1:0] d;
	input logic clk, reset;
	input logic enable;

	initial assert(WIDTH>0);
	
	genvar i;
	
	generate
		for (i=0; i<WIDTH; i++) begin : eachDff
			mux_ff dut1(.d_(d[i]), .enable(enable), .q_(q[i]), .reset(reset), .clk(clk));
		end
	endgenerate

endmodule

module gen_d_FF_5bit #(parameter WIDTH = 5)(q,d,clk,reset, enable);
	output logic  [WIDTH-1:0] q;
	input logic [WIDTH-1:0] d;
	input logic clk, reset;
	input logic enable;

	initial assert(WIDTH>0);
	
	genvar i;
	
	generate
		for (i=0; i<WIDTH; i++) begin : eachDff
			mux_ff dut1(.d_(d[i]), .enable(enable), .q_(q[i]), .reset(reset), .clk(clk));
		end
	endgenerate

endmodule

module gen_d_FF_2bit #(parameter WIDTH = 2)(q,d,clk,reset, enable);
	output logic  [WIDTH-1:0] q;
	input logic [WIDTH-1:0] d;
	input logic clk, reset;
	input logic enable;

	initial assert(WIDTH>0);
	
	genvar i;
	
	generate
		for (i=0; i<WIDTH; i++) begin : eachDff
			mux_ff dut1(.d_(d[i]), .enable(enable), .q_(q[i]), .reset(reset), .clk(clk));
		end
	endgenerate

endmodule

module gen_d_FF1 #(parameter WIDTH = 64)(q,d,clk, reset, enable);
	output logic  [WIDTH-1:0] q;
	input logic [WIDTH-1:0] d;
	input logic clk, reset;
	input logic enable;

	initial assert(WIDTH>0);
	
	genvar i;
	
	generate
		for (i=0; i<WIDTH; i++) begin : eachDff
			mux_ff dut1(.d_(d[i]), .enable(enable), .q_(q[i]), .reset(reset), .clk(clk));
		end
	endgenerate

endmodule

module zero_flag_ff (q,d,clk, reset,enable);
	input logic d, clk, reset, enable;
	output logic q;
	
	mux_ff dut3(.d_(d), .enable(enable), .q_(q), .reset(reset), .clk(clk));
endmodule

module negative_flag_ff (q,d,clk, reset,enable);
	input logic d, clk, reset, enable;
	output logic q;
	
	mux_ff dut4(.d_(d), .enable(enable), .q_(q), .reset(reset), .clk(clk));
endmodule

module overflow_flag_ff (q,d,clk, reset,enable);
	input logic d, clk, reset, enable;
	output logic q;
	
	mux_ff dut5(.d_(d), .enable(enable), .q_(q), .reset(reset), .clk(clk));
endmodule


module carry_flag_ff (q,d, clk, reset,enable);
	input logic d, clk, reset, enable;
	output logic q;
	
	mux_ff dut6(.d_(d), .enable(enable), .q_(q), .reset(reset), .clk(clk));

endmodule

