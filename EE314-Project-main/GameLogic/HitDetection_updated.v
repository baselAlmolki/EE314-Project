module HitDetection_updated (
		input clk,
		input [9:0] x1, // of top left corner 
		input [9:0] x2,

		input [3:0] state1,
		input [3:0] state2,
		
		input [2:0] shield1,
		input [2:0] shield2,

		output reg [1:0] p1_stunmode,
		output reg [1:0] p2_stunmode

);

    localparam 
		SCREEN_WIDTH 			= 10'd640,
		SCREEN_HEIGHT        = 10'd480,

		neutral_HITBOX_WIDTH = 10'd56,
    	dir_HITBOX_WIDTH     = 10'd45,
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
		
		HITSTUN 			      = 2'b01,
		BLOCKSTUN   			= 2'b10,
		WHIFF  					= 2'b11,
		NEUTRAL   				= 2'b00;


	// stunmode: 00 = neutral, 01 = hitstun, 10 = blockstun, 11 = whiff
	// if player is in whiff mode their hurtbox becomes the combined neutral hurt box and the attack_hitbox
	// i dont really need to indicate whiff mode but its there just in case we need it

	wire p1_blocking, p2_blocking, p1_recov, p2_recov, p1_atkA, p2_atkA, p2_dir_attack, p1_dir_attack;
	wire p1_instun, p2_instun, noshield1, noshield2;
	wire [1:0] attack_case;
	wire [9:0] attack_width, p1Hrtbox, p2Hrtbox;

	reg withinp1range, withinp2range;
	
	assign p1_dir_attack = state1 == S_DAttack_active;
	assign p2_dir_attack = state2 == S_DAttack_active;
	assign p1_atkA = (state1 == S_DAttack_active) | (state1 == S_IAttack_active);
	assign p2_atkA= (state2 == S_DAttack_active) | (state2 == S_IAttack_active);
	assign p1_instun = state1 == S_HITSTUN | state1 == S_BLOCKSTUN;
	assign p2_instun = state2 == S_HITSTUN | state2 == S_BLOCKSTUN;
	
	assign attack_case  = {p2_atkA, p1_atkA};
	assign attack_width = (p2_dir_attack | p1_dir_attack) ? dir_HITBOX_WIDTH : neutral_HITBOX_WIDTH;
	assign p1_blocking  = state1 == S_BACKWARD;
	assign p2_blocking  = state2 == S_BACKWARD;
	assign p1_recov     = (state1 == S_DAttack_recovery) | (state1 == S_IAttack_recovery);
	assign p2_recov     = (state2 == S_DAttack_recovery) | (state2 == S_IAttack_recovery);
	
	assign noshield1    = shield1 == 3'b0;
	assign noshield2    = shield2 == 3'b0;
	
	assign p1Hrtbox     = p1_recov ? x1 + BASE_WIDTH + attack_width : x1 + BASE_WIDTH;
	assign p2Hrtbox     = p2_recov ? x2 - attack_width : x2;


	initial begin
		p1_stunmode          = NEUTRAL;
		p2_stunmode          = NEUTRAL;
		withinp1range 	      = 1'b0;
		withinp2range 	      = 1'b0;
	end

	
	always @(*) begin	
		case(attack_case)
			
			2'b01: begin // p1 attack
				// check if p2 is within p1's attack hitbox
				if (x1 + BASE_WIDTH + attack_width > p2Hrtbox) begin
					
					withinp1range = 1'b1;
					if ((~p2_blocking & ~p2_instun) | noshield2) begin 
						p1_stunmode = NEUTRAL; // p1's attack connnected
						p2_stunmode = HITSTUN; // p2 in hitstun						
				
					end else if (p2_blocking & ~p2_instun & ~ noshield2) begin
						p1_stunmode = NEUTRAL; // p1's attack connnected
						p2_stunmode = BLOCKSTUN;
					end else begin
						p1_stunmode = NEUTRAL; //p1's attack connected
						// leave p2 stunmode as-is
					end
					
				end else begin p1_stunmode = WHIFF; p2_stunmode = NEUTRAL; withinp1range = 1'b0;// p1 players whiffed
				end
			end
			
			2'b10: begin //p2 attack
				if (x2 - attack_width < p1Hrtbox) begin // attack connected
					withinp2range = 1'b1;
						if ((~p1_blocking & ~p1_instun) | noshield1) begin 
							p2_stunmode = NEUTRAL; // atk connected
							p1_stunmode = HITSTUN; // p1 in hitsun
						end else if (p1_blocking & ~p1_instun & ~noshield1) begin
							p2_stunmode = NEUTRAL; // p2's atk connnected
							p1_stunmode = BLOCKSTUN; // 10 blockstun
						end else begin
							p2_stunmode = NEUTRAL; // p2's attack connected
							// leave p1_stunmode as-is
						end
				end else begin p1_stunmode = NEUTRAL; p2_stunmode = WHIFF; withinp2range = 1'b0;// p2 player whiffed
				end
			end
			
			2'b11: begin // both attacking simultaneously
				if (x1 + BASE_WIDTH + attack_width > x2 - attack_width) begin
					withinp1range = 1'b1;
					withinp2range = 1'b1;
					// in this case both attacks connect and both players get damage
					p1_stunmode = HITSTUN;
					p2_stunmode = HITSTUN;
				end else begin p1_stunmode = WHIFF; p2_stunmode = WHIFF; withinp1range = 1'b0; withinp2range = 1'b0; // both whiffed
				end	
			end
			default: begin 
				p1_stunmode = NEUTRAL;
				p2_stunmode = NEUTRAL;
			end
		endcase
	end
		
endmodule
