`include "simple_dma.v"
`include "external_memory.v"

module simple_dma_tb ();

reg clk;
reg rstn;
reg [31:0] paddr;
reg [31:0] pwdata;
wire [31:0] prdata;
reg pwenable;
reg prenable;
wire [1:0] perr;
wire [31:0] m_addr;
wire [31:0] m_wdata;
reg [31:0] m_rdata;
wire m_wenable;
wire m_renable;
wire [11:0] m_wsize;
wire [11:0] m_rsize;
reg [1:0] m_err;
reg [31:0] read_data;

simple_dma dut (
	.clk (clk),
	.rstn (rstn),
	.paddr (paddr),
	.pwdata (pwdata),
	.prdata (prdata),
	.pwenable (pwenable),
	.prenable (prenable),
	.perr (perr),
	.m_addr (m_addr),
	.m_wdata (m_wdata),
	.m_rdata (m_rdata),
	.m_wenable (m_wenable),
	.m_renable (m_renable),
	.m_wsize (m_wsize),
	.m_rsize (m_rsize),	
	.m_err (m_err)
);

task write_word;
	input[31:0] local_addr;
	input[31:0] local_data;

	$display("Starting write to 0x%x", local_addr);
	@(posedge clk);
	paddr <= local_addr;
	pwdata <= local_data;
	pwenable <= 1'b1;
	@(posedge clk);
	pwenable <= 1'b0;

	wait(perr[0] == 1'b1);
	if (perr[1] == 1'b1) begin
		$display("Error received for write to 0x%x", local_addr);
	end/* else begin
		$display("Write to 0x%x successful", local_addr);
	end*/
endtask

task read_word;
	input[31:0] local_addr;
	output[31:0] local_data;
	
	$display("Starting read from 0x%x", local_addr);
	@(posedge clk);
	paddr <= local_addr;
	prenable <= 1'b1;
	@(posedge clk);
	prenable <= 1'b0;
	wait(perr[0] == 1'b1);		
	local_data = prdata;
	if (perr[1] == 1'b1) begin
		$display("Error received for read from 0x%x", local_addr);
	end/* else begin
		$display("Read from 0x%x successful, read data = 0x%x", local_addr, local_data);
	end*/
endtask

initial begin
	$fsdbDumpvars(0, simple_dma_tb, "+fsdbfile+simple_dma.fsdb");

	$display("Test started");
	rstn = 0; #5; 
	rstn = 1; #5;

	$readmemh("tb/random_memory.hex", mem_inst.memory_array);

	#5 write_word(DMA_READ_SOURCE, 32'h8000_0000);
	#5 write_word(DMA_WRITE_DEST, 32'h3E00_0000);
	#5 write_word(DMA_BURST_SIZE, 32'h0000_0800);
	#5 write_word(DMA_START, 32'h0000_0001);

	#5;
	forever begin
		read_word(DMA_READ_STATUS, read_data);
		if (read_data == 32'h0)
			break;
	end 
	$display("Read finished");
	#5;
	forever begin
		read_word(DMA_WRITE_STATUS, read_data);
		if (read_data == 32'h0)
			break;
	end
	$display("Write finished");

	$display("Test completed, time = %0t", $time);
	$finish;
end

initial begin 
	clk = 1'b0;
	rstn = 1'b0;
	paddr = 32'h0;
	pwdata = 32'h0;
	pwenable = 1'b0;
	prenable = 1'b0;
	read_data = 32'h0;
	#2000;
	$finish;
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
	.m_addr (m_addr),
	.m_wdata (m_wdata),
	.m_rdata (m_rdata),
	.m_wenable (m_wenable),
	.m_renable (m_renable),
	.m_wsize (m_wsize),
	.m_rsize (m_rsize),
	.m_err (m_err)
);

endmodule
