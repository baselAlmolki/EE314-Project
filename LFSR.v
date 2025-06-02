module LFSR(
	 input clk,
	 input [2:0] seed,
	 input le, 
	 output [2:0] OUT
);

	parameter W = 3; // for 3 inputs
	wire taps;

	assign taps = OUT[0] ^ OUT[2];

	Shift_Register #(W) shift_reg(
		.serial_in(taps),
		.parallel_in(seed),
		.shift_control(2'b11), // shift left cuz why not
		.load_enable(le), 
		.clk(clk),
		.OUT(OUT)
	);


endmodule