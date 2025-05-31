module HitDetection_updated (
    input [9:0] x1, // of top left corner 
    input [9:0] x2,

	
//    input p1_attack_flag,
//    input p2_attack_flag,
//		 
//    input p1_dir_attack,
//    input p2_dir_attack,
	 
	 // must input state to check if player is blocking or under recovery
	 // basel note the input changes, i am no longer taking in "blocked" but rather the player's state
	 // if its easier to get the respective flags corresponding to these states then lemme know or you can
	 // change the code appropriately I made it so it can be easily changed. Its very dynamically written so its super cool
	 
	 //combined input:
	input [3:0] state1,
	input [3:0] state2,

    output reg [1:0] p1_stunmode,
    output reg [1:0] p2_stunmode

);

    localparam 
		SCREEN_WIDTH 			= 10'd640,
		SCREEN_HEIGHT        = 10'd480,

		neutral_HITBOX_WIDTH = 10'd30,
    	dir_HITBOX_WIDTH     = 10'd48,
		HITBOX_HEIGHT        = 10'd80,
		
		BASE_WIDTH           = 10'd64, 
    	PLAYER_HEIGHT        = 10'd240,
		
		S_FORWARD            = 4'd1,
		S_IAttack_start      = 4'd3,
		S_IAttack_active     = 4'd4,
		S_IAttack_recovery   = 4'd5,
		S_DAttack_start      = 4'd6,
		S_DAttack_active     = 4'd7,
		S_DAttack_recovery   = 4'd8,
		S_HITSTUN            = 4'd9,
		S_BLOCKSTUN          = 4'd10,
		S_BACKWARD           = 4'd2,
		S_Attack_recovery    = 4'd5;


	// stunmode: 00 = neutral, 01 = hitstun, 10 = blockstun, 11 = whiff
	// if player is in whiff mode their hurtbox becomes the combined neutral hurt box and the attack_hitbox
	// i dont really need to indicate whiff mode but its there just in case we need it

	wire p1_blocking, p2_blocking, p1_recov, p2_recov, p1_atkA, p2_atkA, p2_dir_attack, p1_dir_attack;
	wire [1:0] attack_case;
	wire [9:0] attack_width, p1Hrtbox, p2Hrtbox;

	reg withinp1range, withinp2range;
	
	assign p1_dir_attack = state1 == S_DAttack_active;
	assign p2_dir_attack = state2 == S_DAttack_active;
	assign p1_atkA = (state1 == S_DAttack_active) | (state1 == S_IAttack_active);
	assign p2_atkA= (state2 == S_DAttack_active) | (state2 == S_IAttack_active);
	
//	assign attack_case  = {(p2_dir_attack | p2_attack_flag), (p1_dir_attack | p1_attack_flag)};
	assign attack_case  = {p2_atkA, p1_atkA};
	assign attack_width = (p2_dir_attack | p1_dir_attack) ? dir_HITBOX_WIDTH : neutral_HITBOX_WIDTH;
	assign p1_blocking  = state1 == S_BACKWARD;
	assign p2_blocking  = state2 == S_BACKWARD;
	assign p1_recov     = (state1 == S_Attack_recovery) | (state1 == S_IAttack_recovery);
	assign p2_recov     = (state2 == S_Attack_recovery) | (state2 == S_IAttack_recovery);
	
	assign p1Hrtbox     = p1_recov ? x1 + BASE_WIDTH + attack_width : x1 + BASE_WIDTH;
	assign p2Hrtbox     = p2_recov ? x2 - attack_width : x2;


	initial begin
		p1_stunmode          = 2'b00;
		p2_stunmode          = 2'b00;
		withinp1range 	  = 1'b0;
		withinp2range 	  = 1'b0;
	end

	
	always @(*) begin	
		
		case(attack_case)
			
			2'b01: begin // p1 attack
				// check if p2 is within p1's attack hitbox
				if (x1 + BASE_WIDTH + attack_width > p2Hrtbox) begin
					withinp1range = 1'b1;
					if (~p2_blocking) begin 
						p1_stunmode = 2'b00; // p1's attack connnected
						p2_stunmode = 2'b01; // p2 in hitstun
						
					end else begin
						p1_stunmode = 2'b00; // p1's attack connnected
						p2_stunmode = 2'b10; // p2 in blockstun
					end
				end else begin p1_stunmode = 2'b11; p2_stunmode = 2'b00; withinp1range = 1'b0;// p1 players whiffed
				end
			end
			
			2'b10: begin //p2 attack
				if (x2 - attack_width < p1Hrtbox) begin // attack connected
					withinp2range = 1'b1;
						if (~p1_blocking) begin 
							p2_stunmode = 2'b00; // atk connected
							p1_stunmode = 2'b01; // p1 in hitsun
						end else begin
							p2_stunmode = 2'b11; // p2's atk connnected
							p1_stunmode = 2'b10; // p2 in blockstun
						end
				end else begin p1_stunmode = 2'b00; p2_stunmode = 2'b11; withinp2range = 1'b0;// p2 player whiffed
				end
			end
			
			2'b11: begin // both attacking simultaneously
				if (x1 + BASE_WIDTH + attack_width > x2 - attack_width) begin
					withinp1range = 1'b1;
					withinp2range = 1'b1;
					// in this case both attacks connect and both players get damage
					p1_stunmode = 2'b01;
					p2_stunmode = 2'b01;
				end else begin p1_stunmode = 2'b11; p2_stunmode = 2'b11; withinp1range = 1'b0; withinp2range = 1'b0; // both whiffed
				end	
			end
			default: begin 
				p1_stunmode = 2'b00;
				p2_stunmode = 2'b00;
			end
		endcase
	end
		
endmodule
