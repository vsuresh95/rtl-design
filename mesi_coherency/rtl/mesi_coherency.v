`include "l1cache_8w_sa.v"
`include "coherency_controller.v"

// top level block that comprises 4 L1 cache and
// snooping based MESI coherency controller
module mesi_coherency (
	input clk,
	input rstn,
	input [19:0] data_addr,
	input [31:0] wdata,
	input awvalid,
	input arvalid,
	input wvalid,
	output reg rvalid,
	output reg [31:0] rdata,
	output reg w_hit,
	output reg r_hit,
	output reg [1:0] w_resp,
	output reg [1:0] r_resp
);

l1cache_8w_sa #(.NUM_BLOCK(1024)) dcache_00 (
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

coherency_controller mesi_00 (
);

endmodule
