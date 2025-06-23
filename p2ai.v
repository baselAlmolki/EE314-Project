module p2ai #(parameter SEED = 5)(
	input clk,
	input reset,
	output [2:0] action
);

wire [15:0] lfsr_out;


assign action = lfsr_out[10:8]; // middle 3 bit slice

// seed: any number between 1 - 65535
// for more randomness stay away from powers of two

LFSR p2_action (
	.clk(clk),
	.seed(SEED),
	.le(reset),
	.OUT(action)
);

endmodule