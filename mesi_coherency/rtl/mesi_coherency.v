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
	output reg [1:0] r_resp, 
	output reg [19:0] ext_data_addr,
	output reg [31:0] ext_wdata,
	output reg ext_awvalid,
	output reg ext_arvalid,
	output reg ext_wvalid,
	input ext_rvalid,
	input [31:0] ext_rdata,
	input [1:0] ext_w_resp,
	input [1:0] ext_r_resp	
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
	.r_resp (r_resp), 
	.ext_data_addr (ext_data_addr),
	.ext_wdata (ext_wdata),
	.ext_awvalid (ext_awvalid),
	.ext_arvalid (ext_arvalid),
	.ext_wvalid (ext_wvalid),
	.ext_rvalid (ext_rvalid),
	.ext_rdata (ext_rdata),
	.ext_w_resp (ext_w_resp),
	.ext_r_resp (ext_r_resp) 
);

coherency_controller mesi_00 (
);

endmodule
