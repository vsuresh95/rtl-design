module external_memory(
	input clk,
	input rstn,
	input [31:0] m_addr,
	input [31:0] m_wdata,
	output reg [31:0] m_rdata,
	input m_wenable,
	input m_renable,
	input [11:0] m_wsize,
	input [11:0] m_rsize,
	output reg [1:0] m_err
);

reg [31:0] memory_array [1023:0];

always @ (posedge clk) begin
	integer i;
	m_rdata = 32'h0;
	m_err <= 2'b00;

	if (!rstn) begin
		for (i = 0; i < 1024; i++) begin 
			memory_array[i][31:0] = 32'h0;
		end	
	end
end

always @ (posedge clk) begin
	integer i;
	integer local_addr;
	
	@ (posedge m_wenable);

	local_addr = m_addr[14:0] >> 5;
	for (i = 0; i < (m_wsize>>5); i++) begin 
		@(posedge clk);
		memory_array[local_addr + i][31:0] = m_wdata;
	end	
	m_err[0] <= 1'b1;
end

always @ (posedge clk) begin
	integer i;
	integer local_addr;
	
	@ (posedge m_renable);

	local_addr = m_addr[14:0] >> 5;
	for (i = 0; i < (m_rsize>>5); i++) begin 
		@(posedge clk);
		m_rdata = memory_array[local_addr + i][31:0];
	end	
	m_err[0] <= 1'b1;
end

endmodule
