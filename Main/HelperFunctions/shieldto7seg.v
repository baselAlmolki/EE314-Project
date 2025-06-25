module shieldto7seg(input [2:0] p1, p2, output reg [6:0] seg1, seg2);


	always @(*) begin
		case(p1) 
			3'b111 : seg1 = 7'b0110000; // 3
			3'b110 : seg1 = 7'b0100100; // 2
			3'b100 : seg1 = 7'b1111001; // 1
			3'b000 : seg1 = 7'b1000000; // 0
			default: seg1 = 7'b1111111; // all off for safety
		endcase

		case(p2) 
			3'b111 : seg2 = 7'b0110000; // 3
			3'b110 : seg2 = 7'b0100100; // 2
			3'b100 : seg2 = 7'b1111001; // 1
			3'b000 : seg2 = 7'b1000000; // 0
			default: seg2 = 7'b1111111; // all off for safety
		endcase
	
	end

endmodule