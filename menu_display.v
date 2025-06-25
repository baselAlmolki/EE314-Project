module menu_display (
    input wire clk,         // 25 MHz
    input wire rst,         // active high
	 input [2:0] state,
	 input P1win,
	 input P2win,
	 input draw,
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
	 


    // Calculate image-relative coordinates
    wire [9:0] img_x0 = next_x - 200; // center horizontally (640 - 240)/2
    wire [9:0] img_y0 = next_y - 120; // not center vertically   (480 - 120)/2

    // Determine if coordinates are within image bounds
    wire inside_image0 = (next_x >= 200 && next_x < 440 &&
								  next_y >= 120 && next_y < 240);

    // Compute address only if inside image bounds
    wire [15:0] read_address0 = img_y0 * 240 + img_x0;

	 // Output from RAM
    wire pixel_data0;
    // RAM2tea instantiation (ROM-like read-only usage)
    CroppedMenu image_rom0 (
        .clock(clk),
        .address(inside_image0 ? read_address0 : 16'd0 ),
        .q(pixel_data0)
    );
	 
	 
	 // Output from RAM
    wire pixel_data1;

    // Calculate image-relative coordinates
    wire [9:0] img_x1 = next_x - 200; // center horizontally (640 - 240)/2
    wire [9:0] img_y1 = next_y - 240; // not center vertically   (480 - 200)/2

    // Determine if coordinates are within image bounds
    wire inside_image1 = (next_x >= 200 && next_x < 440 &&
								  next_y >= 240 && next_y < 360);

    // Compute address only if inside image bounds
    wire [15:0] read_address1 = img_y1 * 240 + img_x1;
	 
	 // RAM2tea instantiation (ROM-like read-only usage)
    CroppedM1P image_rom1 (
        .clock(clk),
		  .address(inside_image1 ? read_address1 : 16'd0 ),
        .q(pixel_data1)
    );
	 
	 wire pixel_data2;
	 
	 // RAM2tea instantiation (ROM-like read-only usage)
    CroppedM2P image_rom2 (
        .clock(clk),
		  .address(inside_image1 ? read_address1 : 16'd0 ),
        .q(pixel_data2)
    );
	 
	 // Output from RAM
    wire pixel_data33;

    // Calculate image-relative coordinates
    wire [9:0] img_x33 = next_x - 240; // center horizontally (640 - 160)/2
    wire [9:0] img_y33 = next_y - 140; // not center vertically   (480 - 200)/2

    // Determine if coordinates are within image bounds
    wire inside_image33 = (next_x >= 240 && next_x < 400 &&
								  next_y >= 140 && next_y < 340);

    // Compute address only if inside image bounds
    wire [15:0] read_address33 = img_y33 * 160 + img_x33;
	 


    // RAM2tea instantiation (ROM-like read-only usage)
    Cropped3 image_rom33 (
        .clock(clk),
        .address(inside_image33 ? read_address33 : 16'd0 ),
        .q(pixel_data33)
    );
	 
	 //Countdown1 Case
	 wire pixel_data11;
	 // RAM2tea instantiation (ROM-like read-only usage)
    Cropped1 image_rom11 (
        .clock(clk),
		  .address(inside_image33 ? read_address33 : 16'd0 ),
        .q(pixel_data11)
    );
	 
	 // Output from RAM
    wire pixel_data22;

    // Calculate image-relative coordinates
    wire [9:0] img_x22 = next_x - 238; // center horizontally (640 - 160)/2
    wire [9:0] img_y22 = next_y - 140; // not center vertically   (480 - 200)/2

    // Determine if coordinates are within image bounds
    wire inside_image22 = (next_x >= 238 && next_x < 402 &&
								  next_y >= 140 && next_y < 337);

    // Compute address only if inside image bounds
    wire [15:0] read_address22 = img_y22 * 164 + img_x22;
	 


    // RAM2tea instantiation (ROM-like read-only usage)
    Cropped2 image_rom22 (
        .clock(clk),
        .address(inside_image22 ? read_address22 : 16'd0 ),
        .q(pixel_data22)
    );
	 
	 
	
	// Output from RAM
    wire pixel_datas;

    // Calculate image-relative coordinates
    wire [9:0] img_xs = next_x - 200; // center horizontally (640 - 240)/2
    wire [9:0] img_ys = next_y - 180; // not center vertically   (480 - 120)/2

    // Determine if coordinates are within image bounds
    wire inside_images = (next_x >= 200 && next_x < 440 &&
								  next_y >= 180 && next_y < 300);

    // Compute address only if inside image bounds
    wire [15:0] read_addresss = img_ys * 240 + img_xs;
	 
    // RAM2tea instantiation (ROM-like read-only usage)
    CroppedStart image_roms (
        .clock(clk),
        .address(inside_images ? read_addresss : 16'd0 ),
        .q(pixel_datas)
    );
	

    // Calculate image-relative coordinates
    wire [9:0] img_xGO = next_x - 200; // center horizontally (640 - 240)/2
    wire [9:0] img_yGO = next_y - 80;

    // Determine if coordinates are within image bounds
    wire inside_imageGO = (next_x >= 200 && next_x < 440 &&
									next_y >= 80 && next_y < 200);

    // Compute address only if inside image bounds
    wire [15:0] read_addressGO = img_yGO * 240 + img_xGO;
	 
	 // Output from RAM
    wire pixel_dataT;

    
    CTieR image_romT (
        .clock(clk),
        .address(inside_imageGO ? read_addressGO : 16'd0 ),
        .q(pixel_dataT)
    );
	 
	 // Output from RAM
    wire pixel_dataP1;

    
    CP1WR image_romP1 (
        .clock(clk),
        .address(inside_imageGO ? read_addressGO : 16'd0 ),
        .q(pixel_dataP1)
    );
	 
	 // Output from RAM
    wire pixel_dataP2;

    
    CP2WR image_romP2 (
        .clock(clk),
        .address(inside_imageGO ? read_addressGO : 16'd0 ),
        .q(pixel_dataP2)
    );
	 
	 

wire [7:0] vga_red, vga_green, vga_blue;

wire [7:0] color;
assign color = (inside_image0 & (state == 3'b000 | state == 3'b001) & pixel_data0) ? 8'hFF :
					(inside_image1 & state == 3'b000 & pixel_data1) ? 8'hFF:
					(inside_image1 & state == 3'b001 & pixel_data2) ? 8'hFF:
					(inside_image33 & state == 3'b010 & pixel_data33) ? 8'hFF:
					(inside_image22 & state == 3'b011 & pixel_data22) ? 8'hFF:
					(inside_image33 & state == 3'b100 & pixel_data11) ? 8'hFF:
					(inside_images & state == 3'b101 & pixel_datas) ? 8'hFF:
					(inside_imageGO & state == 3'b111 & draw & pixel_dataT) ? 8'hFF:
					(inside_imageGO & state == 3'b111 & P1win & ~draw & pixel_dataP1) ? 8'hFF:
					(inside_imageGO & state == 3'b111 & P2win & ~draw & pixel_dataP2) ? 8'hFF:
					8'd0;
	 
    // VGA driver instantiation
    vga_driver vga (
        .clock(clk),
        .reset(rst),
//		  .color_in(inside_image ? pixel_data: 8'd0),
        .color_in(color),
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