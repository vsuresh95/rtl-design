module external_memory(
	input clk,
	input rstn,
	input [31:0] m_addr,
	input [31:0] m_wdata,
	output reg [31:0] m_rdata,
	input m_awvalid,
	input m_arvalid,
	input m_wvalid,
	output reg m_rvalid,
	input [11:0] m_wsize,
	input [11:0] m_rsize,
	output reg [1:0] m_w_resp,
	output reg [1:0] m_r_resp
);

reg [31:0] memory_array [(1 << 18)-1:0];

integer i;

always @ (posedge clk) begin
	m_rdata = 32'h0;
	m_w_resp <= 2'b00;
	m_r_resp <= 2'b00;
	m_rvalid <= 1'b0;

	if (!rstn) begin
		for (i = 0; i < (1 << 18); i++) begin 
			memory_array[i][31:0] = 32'h0;
		end	
	end else if (m_awvalid == 1'b1) begin 
		for (i = 0; i < (m_wsize>>2); i++) begin 
			memory_array[m_addr + i] = m_wdata;
		end	
		m_w_resp[0] <= 1'b1;
	end else if (m_arvalid == 1'b1) begin
		for (i = 0; i < (m_rsize>>2); i++) begin 
			m_rdata = memory_array[m_addr + i];
			m_rvalid <= 1'b1;
		end	
		m_r_resp[0] <= 1'b1;
	end
end

endmodule
