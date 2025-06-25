module negative_edge_detector (
	input I,
	input reset,
	output reg out);
	
	always @ (negedge I or posedge reset) begin
		if (reset) out <= 1'b0;
		else out <= 1'b1;
	end
endmodule		