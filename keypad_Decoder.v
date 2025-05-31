module keypad_Decoder (
	input clk,
	input [3:0] col, // gpio pins connected to cols are read as input
	output reg  R1, // the gpio pins of the keypad's rows are going to be driven based on this output
	output reg state, // KEYDOWN, KEYUP
	output reg [3:0] keypresses,
	output reg [3:0] btndown_states,
	output reg [3:0] debounce_states

);


// keypresses is a 16 bit reg (truncated to first 4 bits) with each bit corresponding to a button on the keypad as follows:
//			C1	C2 C3 C4
// R1		1	2	3	A    \		0	1	2	3
// R2		4	5	6	B  ---\  	4	5	6	7	
// R3		7	8	9	C  ---/	    8	9	10	11
// R4		*	0	#	D    /		12	13	14	15

	localparam 
		BTNUP        = 1'b0, // no btn pressed
		BTNDOWN      = 1'b1, // at least one btn pressed
		DEB_DURATION = 20'd500_000; // 2^20 ~ 1 million so I set a count duration of 500k 
		
	reg NS;
	reg [19:0] debounce_timer [3:0]; // four 20 bit debounce timers for each button
//	reg [3:0] btndown_states;
	wire [3:0] btnup_states;
//	reg [3:0] debounce_states;
	
	integer i;

// IDEA: to handle multiple button inputs only multiple button presses at different coloumns can be distinguished due to keyapd's technological limitiation
// buttons on the same coloumn will all share the same Coloumn pin and so pressing any button shorts the entire column. The reverse argument applies if 
// coloumns are being driven and rows are read.

// Application: We only need to take input from one row so only first row will be driven. Input [3:0] row will be kept as is to not break old code


	assign btnup_states = ~(btndown_states | debounce_states);	
	
	initial begin
		keypresses = 4'b1;
		R1 = 0; // keep row low
		btndown_states = 4'b0;
		debounce_states = 4'b0;
	end
	
	
	always @(posedge clk) begin
		state <= NS;
	end
	
	
	always @(*) begin

		for (i = 0; i< 4; i = i+1) begin
			
			if (col[i] == R1 & ~debounce_states[i]) begin 
				keypresses[i] = 1'b1;
				debounce_states[i] = 1'b1;
				btndown_states[i] = 1'b1;
				
			end else if (debounce_states[i]) begin
				debounce_timer[i] = debounce_timer[i] + 1'b1;
				if (debounce_timer[i] >= DEB_DURATION) begin 
					debounce_timer[i] = 20'b0; // reset timer when debounce duration elapses
					debounce_states[i] =  1'b0;
					btndown_states[i] = 1'b0;
				end
		
			end else keypresses[i] = 1'b0;
		
		end
		
		NS = & keypresses[3:0];
		keypresses = ~col; // this is the actual code everythin above is bullshit

	end
	
endmodule