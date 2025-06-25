module Player_Renderer (
    input vga_clk,
	input [9:0] h_count, v_count,
	 
    input [9:0] player_x,
    input [3:0] player_state,
    input [9:0] player2_x,
    input [3:0] player2_state,
    input display_area,
    output [7:0] r,
    output [7:0] g,
    output [7:0] b,
    output draw
);

    localparam BASE_WIDTH    = 10'd64;
    localparam PLAYER_HEIGHT = 10'd240;
    localparam PLAYER_Y      = 10'd220;

    localparam ATK_W         = 10'd45;
    localparam ATK_H         = 10'd50;
    localparam NATK_W        = 10'd56;
    localparam NATK_H        = 10'd62;
    localparam BORDER        = 2'd3;

    assign draw = 1'b1; // cuz it literally covers the whole display


    // Player 1 conditions
    wire p1_base = (h_count >= player_x) && (h_count < player_x + BASE_WIDTH) &&
                   (v_count >= PLAYER_Y) && (v_count < PLAYER_Y + PLAYER_HEIGHT);

    wire p1_Istart_up = (player_state == 4'd3) &&
                        (h_count >= player_x + BASE_WIDTH) &&
                        (h_count <  player_x + BASE_WIDTH + NATK_W) &&
                        (v_count >= PLAYER_Y + PLAYER_HEIGHT - NATK_H) &&
                        (v_count <  PLAYER_Y + PLAYER_HEIGHT);

    wire p1_neutral = (player_state == 4'd4) &&
                      (h_count >= player_x + BASE_WIDTH) &&
                      (h_count <  player_x + BASE_WIDTH + NATK_W) &&
                      (v_count >= PLAYER_Y + PLAYER_HEIGHT - NATK_H) &&
                      (v_count <  PLAYER_Y + PLAYER_HEIGHT);

    wire p1_Dstart_up = (player_state == 4'd6) &&
                        (h_count >= player_x + BASE_WIDTH) &&
                        (h_count <  player_x + BASE_WIDTH + ATK_W) &&
                        (v_count >= PLAYER_Y + PLAYER_HEIGHT/3 - ATK_H) &&
                        (v_count <  PLAYER_Y + PLAYER_HEIGHT/3 + ATK_H);

    wire p1_directional = (player_state == 4'd7) &&
                          (h_count >= player_x + BASE_WIDTH) &&
                          (h_count <  player_x + BASE_WIDTH + ATK_W) &&
                          (v_count >= PLAYER_Y + PLAYER_HEIGHT/3 - ATK_H) &&
                          (v_count <  PLAYER_Y + PLAYER_HEIGHT/3 + ATK_H);

    wire p1_recovery_area = ((h_count >= player_x && h_count < player_x + BASE_WIDTH) &&
                             ((v_count >= PLAYER_Y && v_count < PLAYER_Y + BORDER) ||
                              (v_count >= PLAYER_Y + PLAYER_HEIGHT - BORDER && v_count < PLAYER_Y + PLAYER_HEIGHT))) ||
                            ((v_count >= PLAYER_Y && v_count < PLAYER_Y + PLAYER_HEIGHT) &&
                             ((h_count >= player_x && h_count < player_x + BORDER) ||
                              (h_count >= player_x + BASE_WIDTH - BORDER && h_count < player_x + BASE_WIDTH)));

    wire p1_Irecovery = (player_state == 4'd5);
    wire p1_Drecovery = (player_state == 4'd8);

    wire p1_Ihurtbox = p1_Irecovery &&
                       (h_count >= player_x + BASE_WIDTH) &&
                       (h_count <  player_x + BASE_WIDTH + NATK_W) &&
                       (v_count >= PLAYER_Y + PLAYER_HEIGHT - NATK_H) &&
                       (v_count <  PLAYER_Y + PLAYER_HEIGHT);

    wire p1_Dhurtbox = p1_Drecovery &&
                       (h_count >= player_x + BASE_WIDTH) &&
                       (h_count <  player_x + BASE_WIDTH + ATK_W) &&
                       (v_count >= PLAYER_Y + PLAYER_HEIGHT/3 - ATK_H) &&
                       (v_count <  PLAYER_Y + PLAYER_HEIGHT/3 + ATK_H);

    wire p1_stun = ((h_count >= player_x && h_count < player_x + BASE_WIDTH) &&
                    ((v_count >= PLAYER_Y && v_count < PLAYER_Y + BORDER) ||
                     (v_count >= PLAYER_Y + PLAYER_HEIGHT - BORDER && v_count < PLAYER_Y + PLAYER_HEIGHT))) ||
                   ((v_count >= PLAYER_Y && v_count < PLAYER_Y + PLAYER_HEIGHT) &&
                    ((h_count >= player_x && h_count < player_x + BORDER) ||
                     (h_count >= player_x + BASE_WIDTH - BORDER && h_count < player_x + BASE_WIDTH)));

    wire p1_hitstun = (player_state == 4'd9);
    wire p1_blockstun = (player_state == 4'd10);

    // Player 2 conditions
    wire p2_base = (h_count >= player2_x) && (h_count < player2_x + BASE_WIDTH) &&
                   (v_count >= PLAYER_Y) && (v_count < PLAYER_Y + PLAYER_HEIGHT);

    wire p2_Istart_up = (player2_state == 4'd3) &&
                        (h_count >= player2_x - NATK_W) &&
                        (h_count <  player2_x) &&
                        (v_count >= PLAYER_Y + PLAYER_HEIGHT - NATK_H) &&
                        (v_count <  PLAYER_Y + PLAYER_HEIGHT);

    wire p2_neutral = (player2_state == 4'd4) &&
                      (h_count >= player2_x - NATK_W) &&
                      (h_count <  player2_x) &&
                      (v_count >= PLAYER_Y + PLAYER_HEIGHT - NATK_H) &&
                      (v_count <  PLAYER_Y + PLAYER_HEIGHT);

    wire p2_Dstart_up = (player2_state == 4'd6) &&
                        (h_count >= player2_x - ATK_W) &&
                        (h_count <  player2_x) &&
                        (v_count >= PLAYER_Y + PLAYER_HEIGHT/3 - ATK_H) &&
                        (v_count <  PLAYER_Y + PLAYER_HEIGHT/3 + ATK_H);

    wire p2_directional = (player2_state == 4'd7) &&
                          (h_count >= player2_x - ATK_W) &&
                          (h_count <  player2_x) &&
                          (v_count >= PLAYER_Y + PLAYER_HEIGHT/3 - ATK_H) &&
                          (v_count <  PLAYER_Y + PLAYER_HEIGHT/3 + ATK_H);

    wire p2_recovery_area = ((h_count >= player2_x && h_count < player2_x + BASE_WIDTH) &&
                             ((v_count >= PLAYER_Y && v_count < PLAYER_Y + BORDER) ||
                              (v_count >= PLAYER_Y + PLAYER_HEIGHT - BORDER && v_count < PLAYER_Y + PLAYER_HEIGHT))) ||
                            ((v_count >= PLAYER_Y && v_count < PLAYER_Y + PLAYER_HEIGHT) &&
                             ((h_count >= player2_x && h_count < player2_x + BORDER) ||
                              (h_count >= player2_x + BASE_WIDTH - BORDER && h_count < player2_x + BASE_WIDTH)));

    wire p2_Irecovery = (player2_state == 4'd5);
    wire p2_Drecovery = (player2_state == 4'd8);

    wire p2_Ihurtbox = p2_Irecovery &&
                       (h_count >= player2_x - NATK_W) &&
                       (h_count <  player2_x) &&
                       (v_count >= PLAYER_Y + PLAYER_HEIGHT - NATK_H) &&
                       (v_count <  PLAYER_Y + PLAYER_HEIGHT);

    wire p2_Dhurtbox = p2_Drecovery &&
                       (h_count >= player2_x - ATK_W) &&
                       (h_count <  player2_x) &&
                       (v_count >= PLAYER_Y + PLAYER_HEIGHT/3 - ATK_H) &&
                       (v_count <  PLAYER_Y + PLAYER_HEIGHT/3 + ATK_H);

    wire p2_stun = ((h_count >= player2_x && h_count < player2_x + BASE_WIDTH) &&
                    ((v_count >= PLAYER_Y && v_count < PLAYER_Y + BORDER) ||
                     (v_count >= PLAYER_Y + PLAYER_HEIGHT - BORDER && v_count < PLAYER_Y + PLAYER_HEIGHT))) ||
                   ((v_count >= PLAYER_Y && v_count < PLAYER_Y + PLAYER_HEIGHT) &&
                    ((h_count >= player2_x && h_count < player2_x + BORDER) ||
                     (h_count >= player2_x + BASE_WIDTH - BORDER && h_count < player2_x + BASE_WIDTH)));

    wire p2_hitstun = (player2_state == 4'd9);
    wire p2_blockstun = (player2_state == 4'd10);

    reg [7:0] r_reg, g_reg, b_reg;

    always @(*) begin
        if (!display_area) begin
            {r_reg, g_reg, b_reg} = 24'h000000;
        end else if (p1_Ihurtbox || p1_Dhurtbox || p2_Ihurtbox || p2_Dhurtbox) begin
            {r_reg, g_reg, b_reg} = 24'hFFFF00;
        end else if (p1_Irecovery && p1_recovery_area || p2_Irecovery && p2_recovery_area) begin
            {r_reg, g_reg, b_reg} = 24'h0B0B0B;
        end else if (p1_Drecovery && p1_recovery_area || p2_Drecovery && p2_recovery_area) begin
            {r_reg, g_reg, b_reg} = 24'h0F0F0F;
        end else if (p1_stun && p1_hitstun || p2_stun && p2_hitstun) begin
            {r_reg, g_reg, b_reg} = 24'hFF0000;
        end else if (p1_stun && p1_blockstun || p2_stun && p2_blockstun) begin
            {r_reg, g_reg, b_reg} = 24'h0000FF;
        end else if (p1_neutral || p2_neutral || p1_directional || p2_directional) begin
            {r_reg, g_reg, b_reg} = 24'hFF0000;
        end else if (p1_Istart_up || p2_Istart_up || p1_Dstart_up || p2_Dstart_up) begin
            {r_reg, g_reg, b_reg} = 24'hFFAAAA;
        end else if (p1_base) begin
            {r_reg, g_reg, b_reg} = 24'hFFFF00;
        end else if (p2_base) begin
            {r_reg, g_reg, b_reg} = 24'hFFFF00;
        end else begin
            {r_reg, g_reg, b_reg} = 24'h888888;
        end
    end

    assign r = r_reg;
    assign g = g_reg;
    assign b = b_reg;

endmodule
