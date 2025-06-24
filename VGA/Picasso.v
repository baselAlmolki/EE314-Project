// top level picaso
module Picasso (
    input clk,
    input reset,
    
	 input [9:0] player_x,
    input [3:0] player_state,
    input [9:0] player2_x,
    input [3:0] player2_state,
    input [7:0] time_elapsed,
	 input [2:0] p1_health, p2_health,
	 input [2:0] p1_shield, p2_shield,
    
	 output reg[7:0] r, g, b,
	 
    output       hsync,
    output       vsync
);

    wire clk_25mhz;
    wire [9:0] h_count, v_count;
    wire display_area;

    wire [7:0] r_game, g_game, b_game;
    wire       draw_game;

    wire [7:0] r_timer, g_timer, b_timer;
    wire       draw_timer;
    
    wire [7:0] r_stats, g_stats, b_stats;
    wire       draw_stats;

    Vga_Driver driver (
        .clk(clk), .reset(reset),
        .h_count(h_count), .v_count(v_count),
        .hsync(hsync), .vsync(vsync),
        .display_area(display_area)
    );

    Player_Renderer game_renderer (
        .h_count(h_count), .v_count(v_count),
        .display_area(display_area),
        .player_x(player_x), .player_state(player_state),
        .player2_x(player2_x), .player2_state(player2_state),
        .r(r_game), .g(g_game), .b(b_game), .draw(draw_game)
    );

    Timer_Renderer timer_renderer (
        .h_count(h_count), .v_count(v_count),
        .display_area(display_area),
        .time_seconds(time_elapsed),
        .r(r_timer), .g(g_timer), .b(b_timer), .draw(draw_timer)
    );

     Status_renderer status_renderer(
         .h_count(h_count), .v_count(v_count),
         .display_area(display_area),
         .p1_health(p1_health), .p2_health(p2_health),
         .p1_shield(p1_shield), .p2_shield(p2_shield),
         .r(r_stats), .g(g_stats), .b(b_stats),
         .draw(draw_stats)
     );

    // Composite renderers with priority
    always @(*) begin
       if (draw_stats) begin
           r = r_stats;
           g = g_stats;
           b = b_stats;
			  
       end else if (draw_timer) begin
            r = r_timer;
            g = g_timer;
            b = b_timer;

		 end else if (draw_game) begin
            r = r_game;
            g = g_game;
            b = b_game;

       end else begin
            r = 8'h00;
            g = 8'h00;
            b = 8'h00;
        end
    end

endmodule