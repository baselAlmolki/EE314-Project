module Timer_Renderer (
    input  [9:0] h_count,
    input  [9:0] v_count,
    input        display_area,
    input  [7:0] time_seconds, // range: 0 to 99
    output [7:0] r,
    output [7:0] g,
    output [7:0] b,
    output       draw
);

    localparam 
		DIGIT_WIDTH  = 8'd24,
		DIGIT_HEIGHT = 8'd32,
		DIGIT_SPACING = 8'd8,

		SCREEN_WIDTH = 10'd640,

		DIGIT_TOP    = DIGIT_HEIGHT >> 1'b1; // top spacing measured from center???

    // get left and right digits. If time_elapsed exceeds 99 then stay at 99
    wire [3:0] left_digit  = time_seconds < 7'd100 ?  time_seconds / 4'd10: 4'd9;
    wire [3:0] right_digit = time_seconds < 7'd100 ?  time_seconds % 4'd10: 4'd9;

    localparam total_width = (2 * DIGIT_WIDTH) + DIGIT_SPACING;
    localparam digit_left_x = (SCREEN_WIDTH - total_width) / 2;
    localparam digit_right_x = digit_left_x + DIGIT_WIDTH + DIGIT_SPACING;

    // Character ROM: 10-digit 24x32 font
    reg [23:0] digit_rom [0:9][0:31];

    integer i;
    integer k;
    initial begin
        // reset rom first
        for (i = 0; i < 10; i = i + 1) begin
            for(k=0; k<32; k = k+1) begin
                digit_rom[i][k] = 24'b0;
			end
        end
        // define a map of the digits in rom
        // Digit 0 (centered)
        digit_rom[0][0]  = 24'b000000000111111100000000;
        digit_rom[0][1]  = 24'b000000001100000110000000;
        digit_rom[0][2]  = 24'b000000010000001001000000;
        digit_rom[0][3]  = 24'b000000110000010011000000;
        digit_rom[0][4]  = 24'b000000110000100011000000;
        digit_rom[0][5]  = 24'b000000110001000011000000;
        digit_rom[0][6]  = 24'b000000110010000011000000;
        digit_rom[0][7]  = 24'b000000110100000011000000;
        digit_rom[0][8]  = 24'b000000111000000001000000;
        digit_rom[0][9]  = 24'b000000001100000110000000;
        digit_rom[0][10] = 24'b000000000111111100000000;

        // Digit 1 (centered)
        digit_rom[1][0]  = 24'b000000000001100000000000;
        digit_rom[1][1]  = 24'b000000000011100000000000;
        digit_rom[1][2]  = 24'b000000000111100000000000;
        digit_rom[1][3]  = 24'b000000001101100000000000;
        digit_rom[1][4]  = 24'b000000000001100000000000;
        digit_rom[1][5]  = 24'b000000000001100000000000;
        digit_rom[1][6]  = 24'b000000000001100000000000;
        digit_rom[1][7]  = 24'b000000000001100000000000;
        digit_rom[1][8]  = 24'b000000000001100000000000;
        digit_rom[1][9]  = 24'b000000000001100000000000;
        digit_rom[1][10] = 24'b000000011111111110000000;

        // Digit 2 (centered)
        digit_rom[2][0]  = 24'b000000001111111000000000;
        digit_rom[2][1]  = 24'b000000011000001100000000;
        digit_rom[2][2]  = 24'b000000110000000110000000;
        digit_rom[2][3]  = 24'b000000000000000110000000;
        digit_rom[2][4]  = 24'b000000000000011000000000;
        digit_rom[2][5]  = 24'b000000000000110000000000;
        digit_rom[2][6]  = 24'b000000000001100000000000;
        digit_rom[2][7]  = 24'b000000000011000000000000;
        digit_rom[2][8]  = 24'b000000000110000000000000;
        digit_rom[2][9]  = 24'b000000001100000000000000;
        digit_rom[2][10] = 24'b000000011000000000000000;
        digit_rom[2][11] = 24'b00000011111111110000000;

        // Digit 3 (centered)
        digit_rom[3][0]  = 24'b000000001111111000000000;
        digit_rom[3][1]  = 24'b000000011000001100000000;
        digit_rom[3][2]  = 24'b000000000000001100000000;
        digit_rom[3][3]  = 24'b000000000000001100000000;
        digit_rom[3][4]  = 24'b000000000111111000000000;
        digit_rom[3][5]  = 24'b000000000111110000000000;
        digit_rom[3][6]  = 24'b000000000000001100000000;
        digit_rom[3][7]  = 24'b000000000000000110000000;
        digit_rom[3][8]  = 24'b000000110000000110000000;
        digit_rom[3][9]  = 24'b000000011000001100000000;
        digit_rom[3][10] = 24'b000000001111111000000000;

        // Digit 4 (centered)
        digit_rom[4][0]  = 24'b000000000000011000000000;
        digit_rom[4][1]  = 24'b000000000000111000000000;
        digit_rom[4][2]  = 24'b000000000001111000000000;
        digit_rom[4][3]  = 24'b000000000011011000000000;
        digit_rom[4][4]  = 24'b000000000110011000000000;
        digit_rom[4][5]  = 24'b000000001100011000000000;
        digit_rom[4][6]  = 24'b000000011000011000000000;
        digit_rom[4][7]  = 24'b000000111111111110000000;
        digit_rom[4][8]  = 24'b000000000000011000000000;
        digit_rom[4][9]  = 24'b000000000000011000000000;
        digit_rom[4][10]  = 24'b000000000000011000000000;
        
        digit_rom[5][0]  = 24'b000000011111111110000000;
        digit_rom[5][1]  = 24'b000000011000000000000000;
        digit_rom[5][2]  = 24'b000000011000000000000000;
        digit_rom[5][3]  = 24'b000000011111111000000000;
        digit_rom[5][4]  = 24'b000000011000001100000000;
        digit_rom[5][5]  = 24'b000000000000000110000000;
        digit_rom[5][6]  = 24'b000000000000000110000000;
        digit_rom[5][7]  = 24'b000000000000000110000000;
        digit_rom[5][8]  = 24'b000000011000001100000000;
        digit_rom[5][9]  = 24'b000000001111111000000000;

        // Digit 6 (centered)
        digit_rom[6][0]  = 24'b00000001111111100000000;
        digit_rom[6][1]  = 24'b000000110000000110000000;
        digit_rom[6][2]  = 24'b000001100000000000000000;
        digit_rom[6][3]  = 24'b000001100000000000000000;
        digit_rom[6][4]  = 24'b000001111111111000000000;
        digit_rom[6][5]  = 24'b000001100000001100000000;
        digit_rom[6][6]  = 24'b000001100000000110000000;
        digit_rom[6][7]  = 24'b000001100000000110000000;
        digit_rom[6][8]  = 24'b000000110000001100000000;
        digit_rom[6][9]  = 24'b000000011111111000000000;

        // Digit 7 (centered)
        digit_rom[7][0]  = 24'b000000111111111100000000;
        digit_rom[7][1]  = 24'b000000000000001100000000;
        digit_rom[7][2]  = 24'b000000000000011000000000;
        digit_rom[7][3]  = 24'b000000000000110000000000;
        digit_rom[7][4]  = 24'b000000000001100000000000;
        digit_rom[7][5]  = 24'b000000000011000000000000;
        digit_rom[7][6]  = 24'b000000000110000000000000;
        digit_rom[7][7]  = 24'b000000001100000000000000;
        digit_rom[7][8]  = 24'b000000011000000000000000;
        digit_rom[7][9]  = 24'b000000110000000000000000;

        // Digit 8 (centered)
        digit_rom[8][0]  = 24'b000000001111111000000000;
        digit_rom[8][1]  = 24'b000000011000001100000000;
        digit_rom[8][2]  = 24'b000000011000001100000000;
        digit_rom[8][3]  = 24'b000000001111111000000000;
        digit_rom[8][4]  = 24'b000000011000001100000000;
        digit_rom[8][5]  = 24'b000000110000000110000000;
        digit_rom[8][6]  = 24'b000000110000000110000000;
        digit_rom[8][7]  = 24'b000000011000001100000000;
        digit_rom[8][8]  = 24'b000000001111111000000000;

        // Digit 9 (centered)
        digit_rom[9][0]  = 24'b000000001111111000000000;
        digit_rom[9][1]  = 24'b000000011000001100000000;
        digit_rom[9][2]  = 24'b000000110000000110000000;
        digit_rom[9][3]  = 24'b000000110000000110000000;
        digit_rom[9][4]  = 24'b000000011000001110000000;
        digit_rom[9][5]  = 24'b000000001111111100000000;
        digit_rom[9][6]  = 24'b000000000000001100000000;
        digit_rom[9][7]  = 24'b000000000000011000000000;
        digit_rom[9][8]  = 24'b000000000000110000000000;
        digit_rom[9][9]  = 24'b000000000001100000000000;
        digit_rom[9][10]  = 24'b00000000011000000000000;
    end

    wire in_left_digit = (h_count >= digit_left_x) && (h_count < digit_left_x + DIGIT_WIDTH) &&
                         (v_count >= DIGIT_TOP) && (v_count < DIGIT_TOP + DIGIT_HEIGHT);

    wire in_right_digit = (h_count >= digit_right_x) && (h_count < digit_right_x + DIGIT_WIDTH) &&
                          (v_count >= DIGIT_TOP) && (v_count < DIGIT_TOP + DIGIT_HEIGHT);

    wire [4:0] row = v_count - DIGIT_TOP;
    wire [4:0] col_left = h_count - digit_left_x;
    wire [4:0] col_right = h_count - digit_right_x;

    wire pixel_on_left = in_left_digit && row < 32 ? digit_rom[left_digit][row][23 - col_left] : 1'b0;
    wire pixel_on_right = in_right_digit && row < 32 ? digit_rom[right_digit][row][23 - col_right] : 1'b0;


    assign draw = (pixel_on_left | pixel_on_right) && display_area;

    assign r = (pixel_on_left | pixel_on_right) ? 8'hFF : 8'h10;
    assign g = (pixel_on_left | pixel_on_right) ? 8'hFF : 8'h10;
    assign b = (pixel_on_left | pixel_on_right) ? 8'hFF : 8'h10;

endmodule
