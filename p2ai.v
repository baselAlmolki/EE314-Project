module p2ai (
    input clk,
    input [W-1:0] seed,
    input reset,
	 input le,
    output [W-1:0] p2_action
);
    // in case we add inputs in the future, I am keeping this part parameterized
    // so for 3 inputs we need a 3bit LFSR
		parameter W = 3; 
//		reg le;

//		initial begin
//			le = 1'b1;
//		end
//	
//	always @(posedge clk or posedge reset) begin
//		if (reset) le<=1'b1;
//		else if (le) le <= 1'b0;
//	end
	
	 	LFSR #(W) Player2_AI (
			.clk(clk),
			.seed(seed),
			.le(le),
			.OUT(p2_action)
	);

endmodule
