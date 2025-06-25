module timeTo7seg (
		input [11:0] gametime,
		output [6:0] seg0,
		output [6:0] seg1
	);


	wire [3:0] sectens, secunits;
	localparam ten = 4'd10;
	
	assign sectens  = gametime/ten;
	assign secunits = gametime - ten*sectens;
	
	hexto7seg timeconv1(.hex(secunits), .hexn(seg0));
	hexto7seg timeconv2(.hex(sectens), .hexn(seg1));
		
endmodule
	
