module LFSR(
	 input clk,
	 input [15:0] seed,
	 input le,
	 output reg [15:0] OUT
);

	wire taps = OUT[15] ^ OUT[13] ^ OUT[12] ^ OUT[10];
	
	always @(posedge clk) begin
		if (le) begin
			OUT <= seed; // load the seed value
		end else begin
			OUT <= {OUT[14:0], taps}; // shift left and insert taps
		end
	end


endmodule