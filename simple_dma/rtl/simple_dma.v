`include "dma_register_defines.vh"
`include "simple_dma_engine.v"

module simple_dma (
	input clk,
	input rstn,

	// input config interface
	input [31:0] paddr,
	input [31:0] pwdata,
	output reg [31:0] prdata,
	input pwenable,
	input prenable,
	output reg [1:0] perr,

	// output data interface
	output [31:0] m_addr,
	output [31:0] m_wdata,
	input [31:0] m_rdata,
	output m_wenable,
	output m_renable,
	output [11:0] m_wsize,
	output [11:0] m_rsize,
	input [1:0] m_err 
);

reg [31:0] dma_read_source;
reg [31:0] dma_write_dest;
reg [11:0] dma_burst_size; // max size is 4k

wire [1:0] dma_write_status;
wire [1:0] dma_read_status;

reg dma_start;

wire [31:0] m_addr_sync;
wire [31:0] m_wdata_sync;
wire [31:0] m_rdata_sync;
wire m_wenable_sync;
wire m_renable_sync;
wire [11:0] m_wsize_sync;
wire [11:0] m_rsize_sync;
wire [1:0] m_err_sync;

// assign the data interface
assign m_addr = m_addr_sync;
assign m_wdata = m_wdata_sync;
assign m_rdata_sync = m_rdata;
assign m_wenable = m_wenable_sync;
assign m_renable = m_renable_sync;
assign m_wsize = m_wsize_sync;
assign m_rsize = m_rsize_sync;
assign m_err_sync = m_err;

typedef enum reg [1:0] { 
	CONFIG_IDLE = 2'b00,
	CONFIG_READ = 2'b01,
	CONFIG_WRITE = 2'b10
} config_state;

config_state state;

// config interface logic
always @ (posedge clk) begin

	if (!rstn) begin
		prdata <= 32'h0;
		perr <= 2'b00; 
		dma_read_source <= 32'h0;
		dma_write_dest <= 32'h0;
		dma_burst_size <= 12'h0;
		dma_start <= 1'b0;
		state <= CONFIG_IDLE;
	end else begin 
		unique case (state)

			CONFIG_IDLE: begin
				prdata <= 32'h0;
				perr <= 2'b00; 
				dma_start <= 1'b0;
	
				if (prenable == 1'b1) begin
					state <= CONFIG_READ;
				end else if (pwenable == 1'b1) begin
					state <= CONFIG_WRITE;
				end else begin
					state <= CONFIG_IDLE;
				end
			end
	
			CONFIG_READ: begin
				unique case (paddr[7:0])
					DMA_READ_SOURCE[7:0]  : prdata <= dma_read_source;
					DMA_WRITE_DEST[7:0]	  : prdata <= dma_write_dest;
					DMA_BURST_SIZE[7:0]	  : prdata[11:0] <= dma_burst_size;
					DMA_WRITE_STATUS[7:0] : prdata[1:0] <= dma_write_status;
					DMA_READ_STATUS[7:0]  : prdata[1:0] <= dma_read_status;
					default               : perr[1] <= 1'b1;
				endcase
				perr[0] <= 1'b1;
				state <= CONFIG_IDLE;
			end
	
			CONFIG_WRITE: begin
				unique case (paddr[7:0])
					DMA_READ_SOURCE[7:0]  : dma_read_source <= pwdata;
					DMA_WRITE_DEST[7:0]	  : dma_write_dest <= pwdata;
					DMA_BURST_SIZE[7:0]	  : dma_burst_size <= pwdata[11:0];
					DMA_START[7:0]        : dma_start <= pwdata[0];
					default               : perr[1] <= 1'b1;
				endcase
				perr[0] <= 1'b1;
				state <= CONFIG_IDLE;
			end 

			default: begin
			end

		endcase
	end
end

simple_dma_engine dma_engine (
	.clk (clk),
	.rstn (rstn),
	.dma_read_source (dma_read_source),
	.dma_write_dest (dma_write_dest),
	.dma_burst_size (dma_burst_size),
	.dma_write_status (dma_write_status),
	.dma_read_status (dma_read_status),
	.dma_start (dma_start),
	.m_addr (m_addr_sync),
	.m_wdata (m_wdata_sync),
	.m_rdata (m_rdata_sync),
	.m_wenable (m_wenable_sync),
	.m_renable (m_renable_sync),
	.m_wsize (m_wsize_sync),
	.m_rsize (m_rsize_sync),
	.m_err (m_err_sync)
);

endmodule
