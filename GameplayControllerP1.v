module GameplayControllerP1(
    input clk_60Hz,
    input key_clk,
    input switch,
    input reset,
    input in_left,
    input in_right,
    input attack,
    input [9:0] player2_pos_x,
	 input [3:0] player2_state,
    input [9:0] screen_left_bound,
    input [9:0] screen_right_bound,

    output reg [9:0] player_pos_x,
    output reg [3:0] player_state,
    output is_directional_attack,
    output move_flag,
    output attack_flag,
	 output [1:0] stunmode
);

	wire predicted_attack_flag = (next_player_state == S_IAttack_active);
	wire predicted_is_directional_attack = (player_state == S_DAttack_active);

	wire player2_attack_flag, player2_is_directional_attack;
	assign player2_attack_flag = player2_state == S_IAttack_active;
	assign player2_is_directional_attack = player2_state == S_DAttack_active;
	wire [1:0] stunmode2;
	 
HitDetection_updated hit_detec(
	.clk(clk_60Hz),
   .x1(player_pos_x),
   .x2(player2_pos_x),
   .p1_attack_flag(predicted_attack_flag),
   .p2_attack_flag(player2_attack_flag),
   .p1_dir_attack(predicted_is_directional_attack),
   .p2_dir_attack(player2_is_directional_attack),
   .state1(player_state),
   .state2(player2_state),
   .p1_stunmode(stunmode),
   .p2_stunmode(stunmode2)
);

assign stun = stunmode == 2'b10 | stunmode ==2'b01;

    parameter PLAYER_WIDTH = 10'd64;
    parameter [9:0] SPEED_FORWARD = 10'd3;
    parameter [9:0] SPEED_BACKWARD = 10'd2;

    wire logic_clk = (switch == 1'b0) ? clk_60Hz : key_clk;

    localparam S_IDLE              = 4'd0,
               S_FORWARD           = 4'd1,
               S_BACKWARD          = 4'd2,
               S_IAttack_start     = 4'd3,
               S_IAttack_active    = 4'd4,
               S_IAttack_recovery  = 4'd5,
               S_DAttack_start     = 4'd6,
               S_DAttack_active    = 4'd7,
               S_DAttack_recovery  = 4'd8,
               S_HITSTUN           = 4'd9,
               S_BLOCKSTUN         = 4'd10;

    localparam I_STARTUP_TIME   = 5'd5,
               D_STARTUP_TIME   = 5'd4,
               I_ACTIVE_TIME    = 5'd2,
               D_ACTIVE_TIME    = 5'd3,
               I_RECOVERY_TIME  = 5'd16,
               D_RECOVERY_TIME  = 5'd15;

    reg [4:0] frame_counter;
    reg [3:0] next_player_state;
    reg [9:0] tmp_result_x;

    assign move_flag = (player_state == S_FORWARD) | (player_state == S_BACKWARD);
    assign attack_flag = (player_state == S_IAttack_active);
    assign is_directional_attack = (player_state == S_DAttack_active);

    always @(posedge logic_clk or posedge reset) begin
        if (reset) begin
            player_state <= S_IDLE;
            frame_counter <= 5'd0;
            player_pos_x <= 10'd10;
        end 
		  else begin
				player_state <= next_player_state;
            player_pos_x <= tmp_result_x;
				frame_counter <= (player_state != next_player_state) ? 0 : frame_counter + 1;
        end
    end

    always @(*) begin
        next_player_state = player_state;
        tmp_result_x = player_pos_x;

        case (player_state)
            S_FORWARD: begin
					 if (stunmode == 2'b01)
						  next_player_state = S_HITSTUN;
					 else if (stunmode == 2'b10)
						  next_player_state = S_BLOCKSTUN;
					 else if (attack && (in_left || in_right))
						  next_player_state = S_DAttack_start;
					 else if (attack && ~in_left && ~in_right)
						  next_player_state = S_IAttack_start;
					 else if (in_left)
						  next_player_state = S_BACKWARD; // ← switch to backward if opposite input
					 else if (in_right &&
								 player_pos_x < screen_right_bound - PLAYER_WIDTH - SPEED_FORWARD &&
								 player_pos_x < player2_pos_x - SPEED_BACKWARD - PLAYER_WIDTH)
						  tmp_result_x = player_pos_x + SPEED_FORWARD;
					 else
						  next_player_state = S_IDLE;
				end

				S_BACKWARD: begin
					 if (stunmode == 2'b01)
						  next_player_state = S_HITSTUN;
					 else if (stunmode == 2'b10)
						  next_player_state = S_BLOCKSTUN;
					 else if (attack && (in_left || in_right))
						  next_player_state = S_DAttack_start;
					 else if (attack && ~in_left && ~in_right)
						  next_player_state = S_IAttack_start;
					 else if (in_right)
						  next_player_state = S_FORWARD; // ← switch to forward if opposite input
					 else if (in_left &&
								 player_pos_x > screen_left_bound + SPEED_BACKWARD)
						  tmp_result_x = player_pos_x - SPEED_BACKWARD;
					 else
						  next_player_state = S_IDLE;
				end

            S_IDLE: begin
                if (stunmode == 2'b01)
						  next_player_state = S_HITSTUN;
					 else if (stunmode == 2'b10)
						  next_player_state = S_BLOCKSTUN;
					 else if (attack && (in_left || in_right))
                    next_player_state = S_DAttack_start;
                else if (attack && ~in_left && ~in_right)
                    next_player_state = S_IAttack_start;
                else if (in_left && player_pos_x > screen_left_bound + SPEED_BACKWARD)
                    {tmp_result_x, next_player_state} = {player_pos_x - SPEED_BACKWARD, S_BACKWARD};
                else if (in_right && player_pos_x < screen_right_bound - PLAYER_WIDTH - SPEED_FORWARD &&
                         player_pos_x < player2_pos_x - SPEED_BACKWARD - PLAYER_WIDTH)
                    {tmp_result_x, next_player_state} = {player_pos_x + SPEED_FORWARD, S_FORWARD};
            end

            S_IAttack_start: begin
                if (frame_counter >= I_STARTUP_TIME - 1)
                    next_player_state = S_IAttack_active;
                else
                    next_player_state = S_IAttack_start;
            end

            S_IAttack_active: begin
					 if (stunmode2 == 2'b01) next_player_state = S_IAttack_recovery;
                else if (frame_counter >= I_ACTIVE_TIME - 1)
                    next_player_state = S_IAttack_recovery;
                else
                    next_player_state = S_IAttack_active;
            end

            S_DAttack_start: begin
                if (frame_counter >= D_STARTUP_TIME - 1)
                    next_player_state = S_DAttack_active;
                else
                    next_player_state = S_DAttack_start;
            end

            S_DAttack_active: begin
                if (frame_counter >= D_ACTIVE_TIME - 1)
                    next_player_state = S_DAttack_recovery;
                else
                    next_player_state = S_DAttack_active;
            end

            S_IAttack_recovery: begin
					 if (stunmode == 2'b01) next_player_state = S_HITSTUN;
                else if (frame_counter >= I_RECOVERY_TIME - 1)
                    next_player_state = S_IDLE;
                else
                    next_player_state = S_IAttack_recovery;
            end

            S_DAttack_recovery: begin
                if (stunmode == 2'b01) next_player_state = S_HITSTUN;
                else 
					 if (frame_counter >= D_RECOVERY_TIME - 1) begin
                    if (attack && (in_left || in_right))
                        next_player_state = S_DAttack_start;
                    else
                        next_player_state = S_IDLE;
                end else
                    next_player_state = S_DAttack_recovery;
            end

            S_HITSTUN: begin
					case(player2_state) 
						S_IAttack_recovery,S_IAttack_active: begin 
							if (frame_counter >= I_RECOVERY_TIME-2) next_player_state = S_IDLE;
							else next_player_state = S_HITSTUN;
						end 
						S_DAttack_recovery,S_DAttack_active: begin 
							if (frame_counter >= D_RECOVERY_TIME-1) next_player_state = S_IDLE;
							else next_player_state = S_HITSTUN;
						end
						default: next_player_state = S_IDLE;
					endcase
            end

            S_BLOCKSTUN: begin
					case(player2_state) 
						S_IAttack_recovery,S_IAttack_active: begin 
							if (frame_counter >= I_RECOVERY_TIME-3) next_player_state = S_IDLE;
							else next_player_state = S_BLOCKSTUN;
						end 
						S_DAttack_recovery,S_DAttack_active: begin 
							if (frame_counter >= D_RECOVERY_TIME-3) next_player_state = S_IDLE;
							else next_player_state = S_BLOCKSTUN;
						end 
						default: next_player_state = S_IDLE;
					endcase
				end
				
				default: begin
						  next_player_state = S_IDLE;
				end
        endcase
    end


endmodule
