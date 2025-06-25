module vga_image_display (
    input wire clk,         // 25 MHz
    input wire rst,         // active high
	 input [2:0] state,
    output wire hsync,
    output wire vsync,
    output wire [7:0] red,
    output wire [7:0] green,
    output wire [7:0] blue,
    output wire sync,
    output wire blank,
    output wire clk_out
);

    // Pixel coordinate from VGA driver (next cycle)
    wire [9:0] next_x;
    wire [9:0] next_y;
	 
	 
	 // Output from RAM
    wire pixel_data;

    // Calculate image-relative coordinates
    wire [9:0] img_x = next_x - 240; // center horizontally (640 - 200)/2
    wire [9:0] img_y = next_y - 140; // not center vertically   (480 - 200)/2

    // Determine if coordinates are within image bounds
    wire inside_image = (next_x >= 240 && next_x < 400 &&
								  next_y >= 140 && next_y < 340);

    // Compute address only if inside image bounds
    wire [15:0] read_address = img_y * 160 + img_x;
	 


    // RAM2tea instantiation (ROM-like read-only usage)
    Cropped3 image_rom0 (
        .clock(clk),
        .address(inside_image ? read_address : 16'd0 ),
        .q(pixel_data)
    );
	 
	 wire [7:0] color;
	 assign color = pixel_data ? 8'hFF : 8'h00;
//    // Output from RAM
//    wire [7:0] pixel_data0;
//
//    // Calculate image-relative coordinates
//    wire [9:0] img_x0 = next_x - 160; // center horizontally (640 - 200)/2
//    wire [9:0] img_y0 = next_y - 100; // not center vertically   (480 - 200)/2
//
//    // Determine if coordinates are within image bounds
//    wire inside_image0 = (next_x >= 160 && next_x < 480 &&
//								  next_y >= 100 && next_y < 240);
//
//    // Compute address only if inside image bounds
//    wire [15:0] read_address0 = img_y0 * 320 + img_x0;
//	 
//
//
//    // RAM2tea instantiation (ROM-like read-only usage)
//    small_menu image_rom0 (
//        .clock(clk),
//        .data(8'd0),               // not writing
//        .wraddress(16'd0),
//        .wren(1'b0),               // disable write
//        .rdaddress(inside_image0 ? read_address0 : 16'd0 ),
//        .q(pixel_data0)
//    );
//	 
//	 // Output from RAM
//    wire [7:0] pixel_data1;
//
//    // Calculate image-relative coordinates
//    wire [9:0] img_x1 = next_x - 160; // center horizontally (640 - 200)/2
//    wire [9:0] img_y1 = next_y - 240; // not center vertically   (480 - 200)/2
//
//    // Determine if coordinates are within image bounds
//    wire inside_image1 = (next_x >= 160 && next_x < 480 &&
//								  next_y >= 240 && next_y < 380);
//
//    // Compute address only if inside image bounds
//    wire [15:0] read_address1 = img_y1 * 320 + img_x1;
//	 
//	 // RAM2tea instantiation (ROM-like read-only usage)
//    small_P1_select image_rom1 (
//        .clock(clk),
//        .data(8'd0),               // not writing
//        .wraddress(16'd0),
//        .wren(1'b0),               // disable write
//        .rdaddress(inside_image1 ? read_address1 : 16'd0 ),
//        .q(pixel_data1)
//    );
//	 
//	 wire [7:0] pixel_data2;
//	 
//	 // RAM2tea instantiation (ROM-like read-only usage)
//    small_P2_select image_rom2 (
//        .clock(clk),
//        .data(8'd0),               // not writing
//        .wraddress(16'd0),
//        .wren(1'b0),               // disable write
//        .rdaddress(inside_image1 ? read_address1 : 16'd0 ),
//        .q(pixel_data2)
//    );

wire [7:0] vga_red, vga_green, vga_blue;
    // VGA driver instantiation
    vga_driver vga (
        .clock(clk),
        .reset(rst),
		  .color_in(inside_image ? color: 8'd0),
//        .color_in(inside_image0 ? pixel_data0 : (state == 3'b0 & inside_image1) ? pixel_data1 :
//																(state == 3'b1 & inside_image1) ? pixel_data2 :
//																8'd0), // blank if outside image
        .next_x(next_x),
        .next_y(next_y),
        .hsync(hsync),
        .vsync(vsync),
        .red(vga_red),
        .green(vga_green),
        .blue(vga_blue),
        .sync(sync),
        .clk(clk_out),
        .blank(blank)
    );
	 
assign red = (color == 8'hFF) ? 8'hFF: vga_red;
assign green = (color == 8'hFF) ? 8'hFF: vga_green;
assign blue = (color == 8'hFF) ? 8'hFF: vga_blue;

endmodule