module p2ai #(parameter SEED = 5)(
	input clk,
	input reset,
	output [2:0] action
);
	reg le;
	wire [15:0] lfsr_out;
	assign action = lfsr_out[10:8]; // middle 3 bit slice

	initial begin
		le = 1'b1;
	end

	always @(posedge clk or posedge reset) begin
		if (reset) le<=1'b1;
		else if (le) le <= 1'b0;
	end

	// seed: any number between 1 - 65535
	// for more randomness stay away from powers of two

	LFSR p2_action (
		.clk(clk),
		.seed(SEED),
		.le(le),
		.OUT(lfsr_out)
	);

endmodule