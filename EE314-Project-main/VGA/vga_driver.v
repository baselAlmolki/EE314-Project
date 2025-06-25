module Vga_Driver (
    input        clk,
    input        reset,
    output reg [9:0] h_count, v_count,
    output [7:0] r,
    output [7:0] g,
    output [7:0] b,
    output       hsync,
    output       vsync,
    output       display_area

);

    // === VGA Timing Parameters ===
    localparam H_VISIBLE_AREA = 10'd640;
    localparam H_FRONT_PORCH  = 10'd16;
    localparam H_SYNC_PULSE   = 10'd96;
    localparam H_BACK_PORCH   = 10'd48;
    localparam H_TOTAL        = 10'd800;

    localparam V_VISIBLE_AREA = 10'd480;
    localparam V_FRONT_PORCH  = 10'd10;
    localparam V_SYNC_PULSE   = 10'd2;
    localparam V_BACK_PORCH   = 10'd33;
    localparam V_TOTAL        = 10'd525;

    // === VGA Counters ===
    // reg [9:0] h_count = 1'b0;
    // reg [9:0] v_count = 1'b0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            h_count <= 1'b0;
            v_count <= 1'b0;
        end else begin
            if (h_count == H_TOTAL - 1'b1) begin
                h_count <= 1'b0;
                v_count <= (v_count == V_TOTAL - 1'b1) ? 1'b0 : v_count + 1'b1;
            end else begin
                h_count <= h_count + 1'b1;
            end
        end
    end

    // === Sync Signals ===
    assign hsync = ~((h_count >= (H_VISIBLE_AREA + H_FRONT_PORCH)) &&
                     (h_count <  (H_VISIBLE_AREA + H_FRONT_PORCH + H_SYNC_PULSE)));
    assign vsync = ~((v_count >= (V_VISIBLE_AREA + V_FRONT_PORCH)) &&
                     (v_count <  (V_VISIBLE_AREA + V_FRONT_PORCH + V_SYNC_PULSE)));

    assign display_area = (h_count < H_VISIBLE_AREA) && (v_count < V_VISIBLE_AREA);

endmodule