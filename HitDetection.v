module HitDetection (
    input clk,
    input reset,

    input [9:0] p1_x,
    input [9:0] p1_y,
    input [9:0] p2_x,
    input [9:0] p2_y,
	
    input p1_attack_flag,
    input p2_attack_flag,

    input p1_dir_attack,
    input p2_dir_attack,

    input p1_blocking,
    input p2_blocking,

    output reg p1_hurt,
    output reg p2_hurt,

    output reg p1_block,
    output reg p2_block
);


wire [3:0] attack_type;
assign attack_type = {p2_dir_attack,p1_dir_attack,p2_attack_flag,p1_attack_flag};

    localparam neutral_HITBOX_WIDTH = 10'd30;
    localparam dir_HITBOX_WIDTH = 10'd48;
    localparam HITBOX_HEIGHT = 10'd80;
    localparam BASE_WIDTH = 10'd64;
    localparam PLAYER_HEIGHT = 10'd240;
    localparam PLAYER_Y = 10'd220;

	always @(posedge clk)
		case(attack_type)
			4'b0000: begin
				p1_hurt=0;
				p2_hurt=0;
			end
			
			4'b0001: begin
				if ((p2_x - p1_x) < (BASE_WIDTH + neutral_HITBOX_WIDTH) & ~p2_blocking) p2_hurt = 1;
				
				else if ((p2_x - p1_x) < (BASE_WIDTH + neutral_HITBOX_WIDTH) & p2_blocking) p2_block = 1;
			end
			4'b0010: begin
				if ((p2_x - p1_x) < (BASE_WIDTH + neutral_HITBOX_WIDTH) & ~p1_blocking) p1_hurt = 1;
				else if ((p2_x - p1_x) < (BASE_WIDTH + neutral_HITBOX_WIDTH) & p1_blocking) p1_block = 1;
			end
			4'b0100: begin
				if ((p2_x - p1_x) < (BASE_WIDTH + dir_HITBOX_WIDTH) & ~p2_blocking) p2_hurt = 1;
				else if ((p2_x - p1_x) < (BASE_WIDTH + dir_HITBOX_WIDTH) & p2_blocking) p2_block = 1;
			end
			4'b1000: begin
				if ((p2_x - p1_x) < (BASE_WIDTH + dir_HITBOX_WIDTH) & ~p1_blocking) p1_hurt = 1;
				else if ((p2_x - p1_x) < (BASE_WIDTH + dir_HITBOX_WIDTH) & p1_blocking) p1_block = 1;
			end
			
			default: begin 
				p1_hurt = 0;
				p2_hurt = 0;
				p1_block = 0;
				p2_block = 0;
			end
		endcase
		
		
endmodule
