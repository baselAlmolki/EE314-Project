//module MasterContorller(
//	
//	 input clk,
//	 output can_move1,
//	 output can_move2,
//    input key_clk,
//    input switch,
//    input reset,
//    input in_left1,
//    input in_right1,
//    input attack1,
//	 input in_left2,
//    input in_right2,
//    input attack2,	 
//	 
//    input [9:0] screen_left_bound,
//    input [9:0] screen_right_bound,
//    output reg [9:0] player1_pos_x,
//    output reg [9:0] player2_pos_x,
//    output reg [2:0] player1_state,
//    output reg [2:0] player2_state,
//
//
//    // Output flags
//    output reg is_directional_attack1,
//    output move_flag1,
//    output attack_flag1,
//	 output reg is_directional_attack2,
//    output move_flag2,
//    output attack_flag2
//);
//
//GameplayControllerP1 p1(
//	 .clk_60Hz(clk),
//    .key_clk(key_clk),
//    .switch(switch),
//    .reset(reset),
//    .in_left(in_left1),
//    .in_right(in_right1),
//    .attack(attack1),
//	 .player_pos_x(player1_pos_x),
//    .screen_left_bound(screen_left_bound),
//    .screen_right_bound(screen_right_bound),
//    .player_state(player1_state),
//
//    // Output flags
//    .is_directional_attack(is_directional_attack1),
//    .move_flag(move_flag1),
//    .attack_flag(attack_flag1)
//);
//
// GameplayControllerP2 p2(
//    .clk_60Hz(clk),
//    .key_clk(key_clk),
//    .switch(switch),
//    .reset(reset),
//    .in_left(in_left2),
//    .in_right(in_right2),
//    .attack(attack2),
//	 .player_pos_x(player2_pos_x),
//    .screen_left_bound(screen_left_bound),
//    .screen_right_bound(screen_right_bound),
//    .player_state(player2_state),
//
//    // Output flags
//    .is_directional_attack(is_directional_attack2),
//    .move_flag(move_flag2),
//    .attack_flag(attack_flag2)
// );
// 
// assign can_move1 = player1_pos_x < player2_pos_x;
// assign can_move2 = player2_pos_x > player1_pos_x;
// 
// endmodule