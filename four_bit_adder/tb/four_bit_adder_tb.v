`timescale 1ns/1ns
`include "four_bit_adder.v"

module four_bit_adder_tb();

reg clk;
reg rstn;
reg[3:0] a;
reg[3:0] b;
wire[4:0] c;

four_bit_adder dut (
	.clk (clk),
	.rstn (rstn),
	.a (a),
	.b (b),
	.c (c)
);

initial begin
	$fsdbDumpvars("+fsdbfile+four_bit_adder.fsdb");

	$display ("Test started");

	rstn = 'b0; #5;

	rstn = 'b1;

	a = 'b0000; b = 'b0000; #20;
	if (c == 'b00000)
	begin
		$display("c = 'b00000. PASSED!");
	end

	a = 'b1010; b = 'b0101; #20;
	if (c == 'b01111)
	begin
		$display("c = 'b01111. PASSED!");
	end

	a = 'b1010; b = 'b1100; #20; 
	if (c == 'b10110)
	begin
		$display("c = 'b10110. PASSED!");
	end

	rstn = 'b0;

	a = 'b0010; b = 'b1000; #20;
	if (c == 'b00000)
	begin
		$display("c = 'b00000. PASSED!");
	end

	rstn = 'b1; #20; 
	if (c == 'b01010)
	begin
		$display("c = 'b01010. PASSED!");
	end
	
	$display ("Test complete");
	$finish;
end

initial begin
	clk = 'b0;
	forever begin
		clk = ~clk;
		#3;
	end
end

endmodule
