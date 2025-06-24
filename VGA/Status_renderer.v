module Status_renderer (
    input  [9:0] h_count,
    input  [9:0] v_count,
    input        display_area,
    input  [2:0] p1_health, p2_health,
    input  [2:0] p1_shield, p2_shield,
    output [7:0] r, g, b,
    output       draw
);

    localparam
		BOX_WIDTH  = 8'd32,
		BOX_HEIGHT = 8'd32,
		BOX_SPACING = 8'd4,

		SCREEN_WIDTH = 10'd640;
 
	 
    // get shape index for each stat block (heart or shield)
    wire [1:0] p1_health_shape [0:2];
    wire [1:0] p1_shield_shape [0:2];
    wire [1:0] p2_health_shape [0:2];
    wire [1:0] p2_shield_shape [0:2];

    genvar i;
    generate
        for (i = 0; i < 3; i = i + 1) begin : shape_assign
            assign p1_health_shape[i] = (p1_health[i])  ? 2'd0 : 2'd1;
            assign p1_shield_shape[i] = (p1_shield[i])  ? 2'd2 : 2'd3;
            assign p2_health_shape[i] = (p2_health[i])  ? 2'd0 : 2'd1;
            assign p2_shield_shape[i] = (p2_shield[i])  ? 2'd2 : 2'd3;
        end
    endgenerate
	  
	  
    localparam
        TOTAL_WIDTH    = (3 * BOX_WIDTH + 2 * BOX_SPACING), 
        P1_STATS_X     = (SCREEN_WIDTH - TOTAL_WIDTH)/6, // x-cord of leftmost stat box for p1
        STATS_GAP      = BOX_HEIGHT + 8'd4,
        // x-coord of leftmost stat box for p2 : Screen width - (total width + p1_stats_box_x)
        P2_STATS_X     = SCREEN_WIDTH - P1_STATS_X - TOTAL_WIDTH, 
        SHAPE_TOP      = 10'd4; // Y-position of shape row

// Character ROM: 4 shapes 64x64 font
    reg [31:0] shape_rom [0:3][0:31];

    integer m;
    integer k;
    initial begin
        // reset rom first
        for (m = 0; m < 4; m = m + 1) begin
            for (k = 0; k<32; k = k + 1) begin
                shape_rom[i][k]  = 32'b0;
            end 
        end
        // define a map of the shapes in rom
        // heart
        shape_rom[0][0]  = 32'b00000000000000000000000000000000;
        shape_rom[0][1]  = 32'b00000000000000000000000000000000;
        shape_rom[0][2]  = 32'b00000000000000000000000000000000;
        shape_rom[0][3]  = 32'b00000000000000000000000000000000;
        shape_rom[0][4]  = 32'b00000000000000000000000000000000;
        shape_rom[0][5]  = 32'b00000000000000000000000000000000;
        shape_rom[0][6]  = 32'b00000000001111000011110000000000;
        shape_rom[0][7]  = 32'b00000000011111111111111000000000;
        shape_rom[0][8]  = 32'b00000000111111111111111100000000;
        shape_rom[0][9]  = 32'b00000001111111111111111110000000;
        shape_rom[0][10] = 32'b00000001111111111111111110000000;
        shape_rom[0][11] = 32'b00000001111111111111111110000000;
        shape_rom[0][12] = 32'b00000001111111111111111110000000;
        shape_rom[0][13] = 32'b00000001111111111111111110000000;
        shape_rom[0][14] = 32'b00000001111111111111111110000000;
        shape_rom[0][15] = 32'b00000000111111111111111100000000;
        shape_rom[0][16] = 32'b00000000111111111111111100000000;
        shape_rom[0][17] = 32'b00000000011111111111111000000000;
        shape_rom[0][18] = 32'b00000000001111111111110000000000;
        shape_rom[0][19] = 32'b00000000000111111111100000000000;
        shape_rom[0][20] = 32'b00000000000011111111000000000000;
        shape_rom[0][21] = 32'b00000000000001111110000000000000;
        shape_rom[0][22] = 32'b00000000000000111100000000000000;
        shape_rom[0][23] = 32'b00000000000000011000000000000000;
        shape_rom[0][24] = 32'b00000000000000000000000000000000;
        shape_rom[0][25] = 32'b00000000000000000000000000000000;
        shape_rom[0][26] = 32'b00000000000000000000000000000000;
        shape_rom[0][27] = 32'b00000000000000000000000000000000;
        shape_rom[0][28] = 32'b00000000000000000000000000000000;
        shape_rom[0][29] = 32'b00000000000000000000000000000000;
        shape_rom[0][30] = 32'b00000000000000000000000000000000;
        shape_rom[0][31] = 32'b00000000000000000000000000000000;
        
        // heart break
        shape_rom[1][0]  = 32'b00000000000000000000000000000000;
        shape_rom[1][1]  = 32'b00000000000000000000000000000000;
        shape_rom[1][2]  = 32'b00000000000000000000000000000000;
        shape_rom[1][3]  = 32'b00000000000000000000000000000000;
        shape_rom[1][4]  = 32'b00000000000000000000000000000000;
        shape_rom[1][5]  = 32'b00000000000000000000000000000000;
        shape_rom[1][6]  = 32'b00000000001111000011110000000000;
        shape_rom[1][7]  = 32'b00000000011111110111111100000000;
        shape_rom[1][8]  = 32'b00000000111111100011111110000000;
        shape_rom[1][9]  = 32'b00000001111111110011111111000000;
        shape_rom[1][10] = 32'b00000001111111111001111111000000;
        shape_rom[1][11] = 32'b00000001111111111100111111000000;
        shape_rom[1][12] = 32'b00000001111111111100111111000000;
        shape_rom[1][13] = 32'b00000001111111111101111111000000;
        shape_rom[1][14] = 32'b00000001111111110011111111000000;
        shape_rom[1][15] = 32'b00000000111111100111111110000000;
        shape_rom[1][16] = 32'b00000000111111001111111110000000;
        shape_rom[1][17] = 32'b00000000011110011111111100000000;
        shape_rom[1][18] = 32'b00000000001111001111111000000000;
        shape_rom[1][19] = 32'b00000000000111110011110000000000;
        shape_rom[1][20] = 32'b00000000000011111001110000000000;
        shape_rom[1][21] = 32'b00000000000001111100000000000000;
        shape_rom[1][22] = 32'b00000000000000111110000000000000;
        shape_rom[1][23] = 32'b00000000000000011100000000000000;
        shape_rom[1][24] = 32'b00000000000000000000000000000000;
        shape_rom[1][25] = 32'b00000000000000000000000000000000;
        shape_rom[1][26] = 32'b00000000000000000000000000000000;
        shape_rom[1][27] = 32'b00000000000000000000000000000000;
        shape_rom[1][28] = 32'b00000000000000000000000000000000;
        shape_rom[1][29] = 32'b00000000000000000000000000000000;
        shape_rom[1][30] = 32'b00000000000000000000000000000000;
        shape_rom[1][31] = 32'b00000000000000000000000000000000;

        // shield 
        shape_rom[2][0]   = 32'b00000000000000000000000000000000;
        shape_rom[2][1]   = 32'b00000000000000000000000000000000;
        shape_rom[2][2]   = 32'b00000000000000000000000000000000;
        shape_rom[2][3]   = 32'b00000000000000000000000000000000;
        shape_rom[2][4]   = 32'b00000000000000000000000000000000;
        shape_rom[2][5]   = 32'b00000000000000000000000000000000;
        shape_rom[2][6]   = 32'b00000000000000000000000000000000;
        shape_rom[2][7]   = 32'b00000000000000000000000000000000;
        shape_rom[2][8]   = 32'b00000000000000111100000000000000;
        shape_rom[2][9]   = 32'b00000011100011111111000111000000;
        shape_rom[2][10]  = 32'b00000011111111111111111111000000;
        shape_rom[2][11]  = 32'b00000011111111111111111111000000;
        shape_rom[2][12]  = 32'b00000011111111111111111111000000;
        shape_rom[2][13]  = 32'b00000011111111111111111111000000;
        shape_rom[2][14]  = 32'b00000011111111111111111111000000;
        shape_rom[2][15]  = 32'b00000011111111111111111111000000;
        shape_rom[2][16]  = 32'b00000001111111111111111110000000;
        shape_rom[2][17]  = 32'b00000001111111111111111110000000;
        shape_rom[2][18]  = 32'b00000001111111111111111110000000;
        shape_rom[2][19]  = 32'b00000001111111111111111110000000;
        shape_rom[2][20]  = 32'b00000001111111111111111110000000;
        shape_rom[2][21]  = 32'b00000000111111111111111100000000;
        shape_rom[2][22]  = 32'b00000000111111111111111100000000;
        shape_rom[2][23]  = 32'b00000000011111111111111000000000;
        shape_rom[2][24]  = 32'b00000000001111111111110000000000;
        shape_rom[2][25]  = 32'b00000000000111111111100000000000;
        shape_rom[2][26]  = 32'b00000000000011111111000000000000;
        shape_rom[2][27]  = 32'b00000000000000111100000000000000;
        shape_rom[2][28]  = 32'b00000000000000000000000000000000;
        shape_rom[2][29]  = 32'b00000000000000000000000000000000;
        shape_rom[2][30]  = 32'b00000000000000000000000000000000;
        shape_rom[2][31]  = 32'b00000000000000000000000000000000;
        
        // Broken shield
        shape_rom[3][0]   = 32'b00000000000000000000000000000000;
        shape_rom[3][1]   = 32'b00000000000000000000000000000000;
        shape_rom[3][2]   = 32'b00000000000000000000000000000000;
        shape_rom[3][3]   = 32'b00000000000000000000000000000000;
        shape_rom[3][4]   = 32'b00000000000000000000000000000000;
        shape_rom[3][5]   = 32'b00000000000000000000000000000000;
        shape_rom[3][6]   = 32'b00000000000000000000000000000000;
        shape_rom[3][7]   = 32'b00000000000000000000000000000000;
        shape_rom[3][8]   = 32'b00000000000000111100000000000000;
        shape_rom[3][9]   = 32'b00000011100011111111000011000000;
        shape_rom[3][10]  = 32'b00000011111111111111000111000000;
        shape_rom[3][11]  = 32'b00000011111111111110001111000000;
        shape_rom[3][12]  = 32'b00000011111111111110011111000000;
        shape_rom[3][13]  = 32'b00000011111111111100111111000000;
        shape_rom[3][14]  = 32'b00000011111111111101111111000000;
        shape_rom[3][15]  = 32'b00000011111111111011111111000000;
        shape_rom[3][16]  = 32'b00000001111111110111111110000000;
        shape_rom[3][17]  = 32'b00000001111111101111111110000000;
        shape_rom[3][18]  = 32'b00000001111111100111111110000000;
        shape_rom[3][19]  = 32'b00000001111111110011111110000000;
        shape_rom[3][20]  = 32'b00000001111111111000111100000000;
        shape_rom[3][21]  = 32'b00000000111111111100011100000000;
        shape_rom[3][22]  = 32'b00000000111111111000111100000000;
        shape_rom[3][23]  = 32'b00000000011111110011111000000000;
        shape_rom[3][24]  = 32'b00000000001111100111110000000000;
        shape_rom[3][25]  = 32'b00000000000111001111100000000000;
        shape_rom[3][26]  = 32'b00000000000010111100000000000000;
        shape_rom[3][27]  = 32'b00000000000000111100000000000000;
        shape_rom[3][28]  = 32'b00000000000000000000000000000000;
        shape_rom[3][29]  = 32'b00000000000000000000000000000000;
        shape_rom[3][30]  = 32'b00000000000000000000000000000000;
        shape_rom[3][31]  = 32'b00000000000000000000000000000000;       
    end

    wire pixel_on;
    reg pixel_accum;
    reg [1:0] current_shape_id;
    reg pixel_found;
    integer j, row, shape_y;
	 integer p1h_x, p1s_x, p2h_x, p2s_x;

always @(*) begin
    pixel_accum = 1'b0;
    pixel_found = 1'b0;
    current_shape_id = 2'b00;

    for (j = 0; j < 3; j = j + 1) begin
        p1h_x = P1_STATS_X + j * (BOX_WIDTH + BOX_SPACING);
        p1s_x = p1h_x;
        p2h_x = P2_STATS_X + j * (BOX_WIDTH + BOX_SPACING);
        p2s_x = p2h_x;

        shape_y = SHAPE_TOP;
        row = v_count - shape_y;

        // HEARTS
        if (v_count >= shape_y && v_count < shape_y + BOX_HEIGHT) begin
            if (!pixel_found && h_count >= p1h_x && h_count < p1h_x + BOX_WIDTH &&
                shape_rom[p1_health_shape[j]][row][31 - (h_count - p1h_x)]) begin
                pixel_accum = 1'b1;
                pixel_found = 1'b1;
                current_shape_id = p1_health_shape[j];
            end

            if (!pixel_found && h_count >= p2h_x && h_count < p2h_x + BOX_WIDTH &&
                shape_rom[p2_health_shape[j]][row][31 - (h_count - p2h_x)]) begin
                pixel_accum = 1'b1;
                pixel_found = 1'b1;
                current_shape_id = p2_health_shape[j];
            end
        end

        // SHIELDS
        else if (v_count >= shape_y + BOX_HEIGHT &&
                 v_count < shape_y + BOX_HEIGHT + STATS_GAP) begin

            if (!pixel_found && h_count >= p1s_x && h_count < p1s_x + BOX_WIDTH &&
                shape_rom[p1_shield_shape[j]][row][31 - (h_count - p1s_x)]) begin
                pixel_accum = 1'b1;
                pixel_found = 1'b1;
                current_shape_id = p1_shield_shape[j];
            end

            if (!pixel_found && h_count >= p2s_x && h_count < p2s_x + BOX_WIDTH &&
                shape_rom[p2_shield_shape[j]][row][31 - (h_count - p2s_x)]) begin
                pixel_accum = 1'b1;
                pixel_found = 1'b1;
                current_shape_id = p2_shield_shape[j];
            end
        end
    end
end

    assign draw = pixel_accum && display_area;
    assign r = draw ? ((current_shape_id <= 2'd1) ? 8'hDC : 8'h11) : 8'h00;
    assign g = 8'h00;
    assign b = draw ? ((current_shape_id >= 2'd2) ? 8'hEE : 8'h33) : 8'h00;

endmodule




