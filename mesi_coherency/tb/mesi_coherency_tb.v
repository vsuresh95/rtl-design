`include "mesi_coherency.v"

module mesi_coherency_tb ();

reg clk;
reg rstn;
reg [19:0] data_addr;
reg [31:0] wdata;
reg awvalid;
reg arvalid;
reg wvalid;
wire rvalid;
wire [31:0] rdata;
wire w_hit;
wire r_hit;
wire [1:0] w_resp;
wire [1:0] r_resp;

mesi_coherency dut (
	.clk (clk),
	.rstn (rstn),
	.data_addr (data_addr),
	.wdata (wdata),
	.awvalid (awvalid),
	.arvalid (arvalid),
	.wvalid (wvalid),
	.rvalid (rvalid),
	.rdata (rdata),
	.w_hit (w_hit),
	.r_hit (r_hit),
	.w_resp (w_resp),
	.r_resp (r_resp)
);

initial begin
	$fsdbDumpvars(0, mesi_coherency_tb, "+fsdbfile+mesi_coherency.fsdb");

	$display("Test started");

	#5 rstn = 1;

	$display("Test completed");
end

initial begin 
	clk = 1'b0;
	rstn = 1'b0;
	data_addr = 20'h0;
	wdata = 32'h0;
	awvalid = 1'b0;
	arvalid = 1'b0;
	wvalid = 1'b0;
	#10000;
	$finish;
end

initial begin
	forever begin
		#3;
		clk = ~clk;
	end
end

endmodule
