module vga_image_display_cd (
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
    wire [7:0] pixel_data0;

    // Calculate image-relative coordinates
    wire [9:0] img_x0 = next_x - 160; // center horizontally (640 - 200)/2
    wire [9:0] img_y0 = next_y - 100; // not center vertically   (480 - 200)/2

    // Determine if coordinates are within image bounds
    wire inside_image0 = (next_x >= 160 && next_x < 480 &&
								  next_y >= 100 && next_y < 240);

    // Compute address only if inside image bounds
    wire [15:0] read_address0 = img_y0 * 320 + img_x0;
	 


    // RAM2tea instantiation (ROM-like read-only usage)
    small_menu image_rom0 (
        .clock(clk),
        .data(8'd0),               // not writing
        .wraddress(16'd0),
        .wren(1'b0),               // disable write
        .rdaddress(inside_image0 ? read_address0 : 16'd0 ),
        .q(pixel_data0)
    );
	 
	 // Output from RAM
    wire [7:0] pixel_data1;

    // Calculate image-relative coordinates
    wire [9:0] img_x1 = next_x - 160; // center horizontally (640 - 200)/2
    wire [9:0] img_y1 = next_y - 240; // not center vertically   (480 - 200)/2

    // Determine if coordinates are within image bounds
    wire inside_image1 = (next_x >= 160 && next_x < 480 &&
								  next_y >= 240 && next_y < 380);

    // Compute address only if inside image bounds
    wire [15:0] read_address1 = img_y1 * 320 + img_x1;
	 
	 // RAM2tea instantiation (ROM-like read-only usage)
    small_P1_select image_rom1 (
        .clock(clk),
        .data(8'd0),               // not writing
        .wraddress(16'd0),
        .wren(1'b0),               // disable write
        .rdaddress(inside_image1 ? read_address1 : 16'd0 ),
        .q(pixel_data1)
    );
	 
	 wire [7:0] pixel_data2;
	 
	 // RAM2tea instantiation (ROM-like read-only usage)
    small_P2_select image_rom2 (
        .clock(clk),
        .data(8'd0),               // not writing
        .wraddress(16'd0),
        .wren(1'b0),               // disable write
        .rdaddress(inside_image1 ? read_address1 : 16'd0 ),
        .q(pixel_data2)
    );

    // Calculate image-relative coordinates
    wire [9:0] img_x = next_x - 200; // center horizontally (640 - 240)/2
    wire [9:0] img_y = next_y - 120; // not center vertically   (480 - 240)/2

    // Determine if coordinates are within image bounds
    wire inside_image = (next_x >= 200 && next_x < 440 &&
								  next_y >= 120 && next_y < 360);

    // Compute address only if inside image bounds
    wire [15:0] read_address = img_y * 240 + img_x;
	 

    // Output from RAM
    wire [7:0] pixel_data00;
    // RAM2tea instantiation (ROM-like read-only usage)
    Square3 image_rom00 (
        .clock(clk),
        .data(8'd0),               // not writing
        .wraddress(16'd0),
        .wren(1'b0),               // disable write
        .rdaddress(inside_image ? read_address : 16'd0 ),
        .q(pixel_data00)
    );
	 
	 // Output from RAM
    wire [7:0] pixel_data11;
    // RAM2tea instantiation (ROM-like read-only usage)
    Square2 image_rom11 (
        .clock(clk),
        .data(8'd0),               // not writing
        .wraddress(16'd0),
        .wren(1'b0),               // disable write
        .rdaddress(inside_image ? read_address : 16'd0 ),
        .q(pixel_data11)
    );
	 
	 // Output from RAM
    wire [7:0] pixel_data22;
    // RAM2tea instantiation (ROM-like read-only usage)
    Square1 image_rom22 (
        .clock(clk),
        .data(8'd0),               // not writing
        .wraddress(16'd0),
        .wren(1'b0),               // disable write
        .rdaddress(inside_image ? read_address : 16'd0 ),
        .q(pixel_data22)
    );
	 
	 
    // VGA driver instantiation
    vga_driver vga (
        .clock(clk),
        .reset(rst),
//		  .color_in(inside_image ? pixel_data: 8'd0),
        .color_in((inside_image0 & (state == 3'b000 | state == 3'b001)) ? pixel_data0 :
						(inside_image1 & state == 3'b000) ? pixel_data1 :
						(inside_image1 & state == 3'b001) ? pixel_data2 :
						(inside_image & state == 3'b011) ? pixel_data00 :
						(inside_image & state == 3'b100) ? pixel_data11 :
						(inside_image & state == 3'b101) ? pixel_data22 :
						8'd0),
        .next_x(next_x),
        .next_y(next_y),
        .hsync(hsync),
        .vsync(vsync),
        .red(red),
        .green(green),
        .blue(blue),
        .sync(sync),
        .clk(clk_out),
        .blank(blank)
    );

endmodule