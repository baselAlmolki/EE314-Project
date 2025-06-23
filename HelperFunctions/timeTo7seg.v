module timeTo7seg (
		input [11:0] gametime,
		output [6:0] seg0,
		output [6:0] seg1,
		output [6:0] seg2,
		output [6:0] seg3
	);


	wire [3:0] sectens, secunits, minunits, mintens;
	
	
	wire [5:0] seconds, minutes;
	localparam ten = 4'd10;
	
	assign minutes  = gametime / 6'd60;
	assign seconds  = gametime - minutes*6'd60;
//	assign seconds  = gametime % 6'd60;
	
	assign sectens  = seconds/ten;
	assign secunits = seconds - ten*sectens;
	
	assign mintens  = minutes/ten;
	assign minunits = minutes - ten*mintens;
	
	
	hexto7seg timeconv1(.hex(secunits), .hexn(seg0));
	hexto7seg timeconv2(.hex(sectens), .hexn(seg1));
	hexto7seg timeconv3(.hex(minunits), .hexn(seg2));
	hexto7seg timeconv4(.hex(mintens), .hexn(seg3));
		
endmodule
	
