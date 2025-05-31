//module Statuses(
//	input clk,
//	input reset,
//	input [1:0] p1_stunmode,
//   input [1:0] p2_stunmode,
//	output loose_health,
//	output loose_block
//);
//
//wire hurt, block;
//
//assign hurt = {1'b1, (p1_stunmode == 2'b01)};
//assign block = (p1_stunmode == 2'b10);
//
//
//
//Shift_Register health_shift(
//	.serial_in(0),
//	.parallel_in(3'b111),
//	.shift_control(hurt), // 00 -> shift right, 11-> shift left, 01-> hold
//	.load_enable(reset), 
//	.clk(clk),
//	.OUT(current_health),
//	.serial_out(loose_health)
//	);
//	
//endmodule