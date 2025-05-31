module LFSR(
	 input [15:0] seed,
	 input load_enable, 
	 input clk,
	 output [15:0] OUT
);

wire taps;

assign taps = OUT[0] ^ OUT[2] ^ OUT[3] ^ OUT[5];

Shift_Register shift_reg(
	.serial_in(taps),
	.parallel_in(seed),
	.shift_control(1),
	.load_enable(load_enable), 
	.clk(clk),
	.OUT(OUT)
);


endmodule