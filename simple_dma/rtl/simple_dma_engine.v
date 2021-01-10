`include "dma_register_defines.vh"

module simple_dma_engine (
	input clk,
	input rstn,
	
	// register configurations
	input [31:0] dma_read_source,
	input [31:0] dma_write_dest,
	input [11:0] dma_burst_size, 
	output reg [1:0] dma_write_status,
	output reg [1:0] dma_read_status, 
	input dma_start,

	// output data interface
	output reg [31:0] m_addr,
	output reg [31:0] m_wdata,
	input [31:0] m_rdata,
	output reg m_wenable,
	output reg m_renable,
	output reg [11:0] m_wsize,
	output reg [11:0] m_rsize,
	input [1:0] m_err
);

typedef enum reg [1:0] { 
	DMA_IDLE = 2'b00,
	DMA_BUSY_READ = 2'b01,
	DMA_BUSY_WRITE = 2'b10,
	DMA_ERR = 2'b11
} dma_state;

dma_state dma_state_ff;

reg [31:0] write_buffer [127:0];

integer i;

always @ (posedge clk) begin
	if (!rstn) begin
		dma_write_status = 2'b00;
		dma_read_status = 2'b00; 
		m_addr = 32'h0;
		m_wdata = 32'h0;
		m_wenable = 1'b0;
		m_renable = 1'b0;
		m_wsize = 12'h0;
		m_rsize = 12'h0;
		dma_state_ff = DMA_IDLE;
	end

	unique case (dma_state_ff)
		DMA_IDLE: begin 
			// if start has been triggered
			if (dma_start == 1'b1) begin
			 	dma_state_ff <= DMA_BUSY_READ;
			end else begin
			 	dma_state_ff <= DMA_IDLE;
			end
		end

		DMA_BUSY_READ: begin 
			// starting read packet
			if (m_renable == 1'b0) begin
				dma_read_status[0] <= 1'b1; 
				m_addr <= dma_read_source;
				m_rsize <= dma_burst_size;
				m_renable <= 1'b1;
				i = 0;
			end else begin
				// generating each transaction of the burst
				if (i < dma_burst_size >> 5) begin
					write_buffer[i++][31:0] = m_rdata;
				end else begin
					dma_read_status[0] <= 1'b0; 
					m_renable <= 1'b0;
					if (m_err[0] == 1'b1 && m_err[1] == 1'b1) begin
			 			dma_state_ff <= DMA_ERR; 
					end else if (m_err[0] == 1'b0) begin
			 			dma_state_ff <= DMA_BUSY_READ; 
					end else begin
			 			dma_state_ff <= DMA_BUSY_WRITE;
					end
				end
			end
		end

		DMA_BUSY_WRITE: begin
			// starting write packet
			if (m_wenable == 1'b0) begin
				dma_write_status[0] <= 1'b1; 
				m_addr <= dma_write_dest;
				m_wsize <= dma_burst_size;
				m_wenable <= 1'b1;
				i = 0;
			end else begin
				// generating each transaction of the burst
				if (i < dma_burst_size >> 5) begin
					m_wdata = write_buffer[i++][31:0];
				end else begin
					dma_write_status[0] <= 1'b0; 
					m_wenable <= 1'b0;
					if (m_err[0] == 1'b1 && m_err[1] == 1'b1) begin
			 			dma_state_ff <= DMA_ERR; 
					end else if (m_err[0] == 1'b0) begin
			 			dma_state_ff <= DMA_BUSY_WRITE; 
					end else begin
			 			dma_state_ff <= DMA_IDLE;
					end
				end
			end
		end

		// in case of an error, DMA will hang and needs to be reset
		DMA_ERR: begin 
		end
	endcase
end

endmodule
