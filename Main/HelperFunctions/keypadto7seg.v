module keypadto7seg (input [3:0] keypresses, output [6:0] seg1, seg2, seg3, seg4 );
	// debugging outputs to display each pressed btn on a 7seg display
	// supports multiple inputs

	assign seg1 = keypresses[0] ? 7'b111_1001 : 7'b111_1111;
	assign seg2 = keypresses[1] ? 7'b010_0100 : 7'b111_1111;
	assign seg3 = keypresses[2] ? 7'b011_0000 : 7'b111_1111;
	assign seg4 = keypresses[3] ? 7'b000_1000 : 7'b111_1111;
	
endmodule
