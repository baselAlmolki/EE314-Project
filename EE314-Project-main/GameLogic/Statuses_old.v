// The original statuses for the timer branch before renovating it

module Statuses_old(
	input clk,
	input reset,
	input instun1, instun2,
	input [1:0] p1_stunmode,
   input [1:0] p2_stunmode,
	output p1_loose_health,
	output p1_loose_block,
	output p2_loose_health,
	output p2_loose_block,
	
	output [2:0] p1_current_health,
	output [2:0] p1_current_block,
	output [2:0] p2_current_health,
	output [2:0] p2_current_block,
	
	output reg p1wins,p2wins
);

	wire [1:0] p1_hurt, p1_block, p2_hurt, p2_block;
	reg le;
	
	assign p1_hurt  = {1'b1, (p1_stunmode == 2'b01 & ~instun1)};
	assign p1_block = {1'b1, (p1_stunmode == 2'b10)};
	assign p2_hurt  = {1'b1, (p2_stunmode == 2'b01 & ~instun2)};
	assign p2_block = {1'b1, (p2_stunmode == 2'b10)};

	initial begin
		le = 1'b1;
		p1wins = 1'b0;
		p2wins = 1'b0;
	end
	
	always @(posedge clk or posedge reset) begin
		if (reset) le<=1'b1;
		else if (le) le <= 1'b0;
	end
	
	always @(*) begin
		if (p1_current_health == 3'b0) p2wins = 1'b1;
		else if (p2_current_health == 3'b0) p1wins = 1'b1;
		else begin
			p1wins = 1'b0;
			p2wins = 1'b0;
		end
 
	end

	Shift_Register health_shift_p1(
		.serial_in(1'b0),
		.parallel_in(3'b111),
		.shift_control(p1_hurt), // 00 -> shift right, 11-> shift left, 01-> hold
		.load_enable(le), 
		.clk(clk),
		.OUT(p1_current_health),
		.serial_out(p1_loose_health)
		);

	Shift_Register block_shift_p1(
		.serial_in(1'b0),
		.parallel_in(3'b111),
		.shift_control(p1_block), // 00 -> shift right, 11-> shift left, 01-> hold
		.load_enable(le), 
		.clk(clk),
		.OUT(p1_current_block),
		.serial_out(p1_loose_block)
		);
		
		
	Shift_Register health_shift_p2(
		.serial_in(1'b0),
		.parallel_in(3'b111),
		.shift_control(p2_hurt), // 00 -> shift right, 11-> shift left, 01-> hold
		.load_enable(le), 
		.clk(clk),
		.OUT(p2_current_health),
		.serial_out(p2_loose_health)
		);

	Shift_Register block_shift_p2(
		.serial_in(1'b0),
		.parallel_in(3'b111),
		.shift_control(p2_block), // 00 -> shift right, 11-> shift left, 01-> hold
		.load_enable(le), 
		.clk(clk),
		.OUT(p2_current_block),
		.serial_out(p2_loose_block)
		);
	
endmodule
