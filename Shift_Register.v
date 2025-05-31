module Shift_Register#(parameter W=3)(
	input serial_in,
	input [W-1:0] parallel_in,
	input [1:0] shift_control, // 00 -> shift right, 11 -> shift left, 01 -> hold
	input load_enable, 
	input clk,
	output reg [W-1:0] OUT,
	output serial_out
);

reg [1:0] prev_shift_control;

always @(posedge clk) begin
	if (load_enable) begin
		OUT <= parallel_in;
	end else begin
		// Only shift when shift_control changes from hold to shift
		case(shift_control)
			2'b00: if (prev_shift_control != 2'b00) OUT <= {serial_in, OUT[W-1:1]};
			2'b11: if (prev_shift_control != 2'b11) OUT <= {OUT[W-2:0], serial_in};
			2'b01: OUT <= OUT;
			default: OUT <= OUT;
		endcase
	end

	prev_shift_control <= shift_control;
end

assign serial_out = OUT[0];

endmodule
