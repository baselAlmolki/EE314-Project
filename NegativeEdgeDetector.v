module NegativeEdgeDetector (
    input clk,           // System clock
    input rst,           // Reset (active high)
    input button_in,     // Raw button input (after debouncing)
    output neg_edge      // Single pulse output on negative edge
);

    // Internal registers to store current and previous button states
    reg button_sync1, button_sync2;
    
    // Synchronize button input and create delayed version
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            button_sync1 <= 1'b0;
            button_sync2 <= 1'b0;
        end
        else begin
            button_sync1 <= button_in;    // Current state
            button_sync2 <= button_sync1; // Previous state (delayed by 1 clock)
        end
    end
    
    // Detect negative edge: previous state was 0, current state is 1
    assign neg_edge = button_sync1 & ~button_sync2;
    
endmodule