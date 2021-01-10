module four_bit_adder (
	input clk,
	input rstn,
	input[3:0] a,
    input[3:0] b,
    output reg [4:0] c
);

always @ (posedge clk) begin
	if (!rstn) begin
		c[4:0] = 'b00000;
	end
	else begin
		c[4:0] = a[3:0] + b[3:0];
	end
end

endmodule
