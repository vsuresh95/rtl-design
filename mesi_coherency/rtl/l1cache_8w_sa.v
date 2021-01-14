// 8-way set associative cache
// cache replacement policy chosen is a 'least recently used' scheme
// 
// address space = 1MB == 0x100000, 20 bits to represent the full address map
// cache size = 4kB == 0x1000
// if each set has 8 ways, and each block is 4B, each set = 32B
// this gives us 4096/32 = 128 sets mapped in 8 ways
// we need 7 bits to represent 128 sets and 2 bits to represent a block
// therefore 20 - 7 - 2 = 11 tag bits.
//
// if valid bit for that cache block is 1 and its tag matches address[19:9], we
// have a cache hit.
//
// to implement LRU, we will use the Clock algorithm which requires only 1 bit 
// per cache with reasonable accuracy (originally intended to a page replacement algorithm.
// Reference: F. J. Corbato, ”A Paging Experiment with the Multics System”,
// MIT Project MAC Report MAC-M-384, May, 1968.
module l1cache_8w_sa #(
	parameter BLOCK_SIZE=32, // the horizontal width of each line in the cache data RAM memory
	parameter NUM_BLOCK=1024, // the number of lines in the cache data RAM memory = tag RAM = valid RAM
	parameter TAG_SIZE=11, // the horizontal width of each line in the cache tag RAM memory
	parameter NUM_WAYS=8 // number of ways in each set
)(
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

// cache format is as below:
// 
//  {    0    {0 ... 0}    {0 ... 0}   } , x8 per set, x128 for entire cache
//       ^        ^            ^
//     valid   tag[11]      data[32]
//
reg [BLOCK_SIZE-1:0] data_array [NUM_BLOCK-1:0]; // data RAM
reg [TAG_SIZE-1:0] tag_array [NUM_BLOCK-1:0]; // tag RAM 
reg valid_array [NUM_BLOCK-1:0]; // valid for each block RAM 

reg [6:0] set_id; // 128 sets in total, therefore, 7 bits
reg [10:0] tag_id; // 128 sets in total, therefore, 7 bits

// holds the one-hot encoding of the Clock status of each block in a set
reg [NUM_WAYS-1:0] clock_set [NUM_BLOCK-1:0]; 
integer curr_clock_block;

integer i;

reg [31:0] wdata_ff;

always @ (posedge clk or negedge rstn) begin
	rvalid <= 1'b0;
	rdata <= 32'h0;
	w_hit <= 1'b0;
	r_hit <= 1'b0;
	w_resp <= 2'h0;
	r_resp <= 2'h0;

	if (!rstn) begin
		i = 0;
		curr_clock_block = 0;
		set_id = 7'h0;
		tag_id = 11'h0;
		wdata_ff = 0;

		for (i = 0; i < NUM_BLOCK; i++) begin
			data_array[i] <= 'h0;
			tag_array[i] <= 'h0;
			valid_array[i] <= 'h0;
			clock_set[i] <= 'h0;
		end
	end 
	else if (awvalid == 1'b1) begin 
		// get set ID and store in a reg
		set_id <= data_addr[8:2];

		// get the tag and store in a reg
		tag_id <= data_addr[19:9];

		// get the data to be written and store in a reg
		wdata_ff <= wdata;

		for (i = 0; i < 8; i++) begin
			// check if tag matches any of 8 blocks in the set, it doesn't
			// matter if the block is valid or not
			if (tag_id == tag_array[(set_id*NUM_WAYS)+i]) begin
				w_hit <= 1'b1;
				if (wvalid == 1'b1) begin
					data_array[(set_id*NUM_WAYS)+i] <= wdata_ff;
				end
				valid_array[(set_id*NUM_WAYS)+i] <= 1'b1;
			end
		end

		// write miss case: invoke Clock cache replacement policy
		if (w_hit == 1'b0) begin
			// iterate through all the elements of the set and find the first
			// block which has clock_set = 0
		end		
	end
	else if (arvalid == 1'b1) begin 
	end
end

endmodule
