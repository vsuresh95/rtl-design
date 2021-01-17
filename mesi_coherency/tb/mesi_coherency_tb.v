`include "mesi_coherency.v"
`include "external_memory.v"

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
wire w_miss;
wire r_miss;
wire [1:0] w_resp;
wire [1:0] r_resp;
wire [19:0] ext_data_addr;
wire [31:0] ext_wdata;
wire ext_awvalid;
wire ext_arvalid;
wire ext_wvalid;
wire ext_rvalid;
wire [31:0] ext_rdata;
wire [1:0] ext_w_resp;
wire [1:0] ext_r_resp;


integer i, j;
reg [19:0] test_addr;
time start_time, end_time;
reg [19:0] test_offset;

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

task write_word;
	input[31:0] local_addr;
	input[31:0] local_data;

	// $display("Starting write to 0x%x", local_addr);
	@(posedge clk);
	data_addr <= local_addr;
	awvalid <= 1'b1;
	wdata <= local_data;
	wvalid <= 1'b1;
	@(posedge clk);
	awvalid <= 1'b0;
	wvalid <= 1'b0;

	wait(w_resp[0] == 1'b1);
	if (w_resp[1] == 1'b1) begin
		$display("Error received for write to 0x%x", local_addr);
	end else begin
		// $display("Write to 0x%x successful", local_addr);
	end
endtask

task read_word;
	input[31:0] local_addr;
	output[31:0] local_data;
	
	// $display("Starting read from 0x%x", local_addr);
	@(posedge clk);
	data_addr <= local_addr;
	arvalid <= 1'b1;
	@(posedge clk);
	arvalid <= 1'b0;
	wait(r_resp[0] == 1'b1);		
	local_data = rdata;
	if (r_resp[1] == 1'b1) begin
		$display("Error received for read from 0x%x", local_addr);
	end else begin
		// $display("Read from 0x%x successful, read data = 0x%x", local_addr, local_data);
	end
endtask

initial begin
`ifndef DUMP_FSDB
	$vcdplusfile("mesi_coherency.vpd");
	$vcdpluson(0, mesi_coherency_tb);
	$vcdplusmemon;
`else
	$fsdbDumpvars(0, mesi_coherency_tb, "+fsdbfile+mesi_coherency.fsdb");
`endif

	$display("Test started");

	#10 rstn = 1;

	for (j = 1; j <= 1; j++) begin
	 	start_time = $time;
		test_offset = 'h4_0000*j;
		for (i = 0; i < 10000; i++) begin
			test_addr = ($random % test_offset) * 4;
			#10 write_word(test_addr, $random);
		end
	 	end_time = $time;
	 	$display("sub-test %0d took time %0t", j, end_time - start_time);

		#10 rstn = 0; 
		#10 rstn = 1; 
	end
	

	$display("Test completed at %0t", $time);
	$finish;
end

initial begin 
	clk = 1'b0;
	rstn = 1'b0;
	data_addr = 20'h0;
	wdata = 32'h0;
	awvalid = 1'b0;
	arvalid = 1'b0;
	wvalid = 1'b0;
	// #100000;
	// $finish;
end

initial begin
	forever begin
		#3;
		clk = ~clk;
	end
end

external_memory mem_inst (
	.clk (clk),
	.rstn (rstn),
	.m_addr ({12'h0,ext_data_addr}),
	.m_wdata (ext_wdata),
	.m_rdata (ext_rdata),
	.m_awvalid (ext_awvalid),
	.m_arvalid (ext_arvalid),
	.m_wvalid (ext_wvalid),
	.m_rvalid (ext_rvalid),
	.m_wsize (12'h4),
	.m_rsize (12'h4),
	.m_w_resp (ext_w_resp),
	.m_r_resp (ext_r_resp)
);


endmodule
