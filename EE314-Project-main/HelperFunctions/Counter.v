module Counter#(parameter W=4)(
	 input [1:0] control, // 01 -> Count Up, 10 -> Count down, 00 -> Hold
	 input clk,
	 output reg [W-1:0] count
);

	initial begin
		count = {W{1'b0}};
	end


	always@(posedge clk) begin
		case(control)
			2'b00: count = count;
			2'b01: count = count + 1'b1;
			2'b10: count = count - 1'b1;
			2'b11: count = {W{1'b0}}; // sync resets
		default: count = count;
		endcase
	end 

endmodule