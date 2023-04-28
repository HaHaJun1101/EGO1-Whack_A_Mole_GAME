`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Science and Technology Beijing
// Engineer: Steven Yang
// 
// Create Date: 
// Design Name: 
// Module Name: Whack_a_mole
// Project Name: Whack_A_Mole_GAME
// Target Devices: 
// Tool Versions: 
// Description: The outermost module of the game
// 
// The outermost module of the game is responsible for
// controlling the execution order of various game modules over time,
// while utilizing a shared bus to output information on both digital displays and LEDs.
// 
// Dependencies: 
// 
// Revision:
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Whack_a_mole(
input clk,
input rst_n,
input [7:0] diff_choice,
input [4:0] hammer,
output reg [7:0] dig_display,
output reg [7:0] seg_code_1,
output reg [7:0] seg_code_2,
output reg [7:0] diff_led_show,
output reg [7:0] state_led_show
);

wire rst = ~rst_n;

wire [7:0] dig_display_m1;
wire [7:0] seg_code_1_m1;
wire [7:0] seg_code_2_m1;
wire [7:0] diff_led_show_m1;
wire [7:0] difficulty;
wire start_game;

game_start game_start(
    .clk( clk ),
    .rst( rst ),
    .diff_choice ( diff_choice ),
    .dig_display ( dig_display_m1 ),
    .seg_code_1 ( seg_code_1_m1 ),
    .seg_code_2 ( seg_code_2_m1 ),
    .diff_led_show ( diff_led_show_m1 ),
    .difficulty ( difficulty ),
    .start_game ( start_game )
);

wire [7:0] dig_display_m2;
wire [7:0] seg_code_1_m2;
wire [7:0] seg_code_2_m2;
wire [7:0] state_led_show_m2;
wire ready_game;

game_ready game_ready(
    .clk( clk ),
    .rst( rst ),
    .start_game ( start_game ),
    .dig_display ( dig_display_m2 ),
    .seg_code_1 ( seg_code_1_m2 ),
    .seg_code_2 ( seg_code_2_m2 ),
    .state_led_show ( state_led_show_m2 ),
    .ready_game ( ready_game )
);

wire [7:0] dig_display_m3;
wire [7:0] seg_code_1_m3;
wire [7:0] seg_code_2_m3;
wire [7:0] state_led_show_m3;
wire count_down_game;

game_count_down game_count_down(
    .clk( clk ),
    .rst( rst ),
    .ready_game ( ready_game ),
    .dig_display ( dig_display_m3 ),
    .seg_code_1 ( seg_code_1_m3 ),
    .seg_code_2 ( seg_code_2_m3 ),
    .state_led_show ( state_led_show_m3 ),
    .count_down_game ( count_down_game )
);

wire [7:0] dig_display_m4;
wire [7:0] seg_code_1_m4;
wire [7:0] seg_code_2_m4;
wire [7:0] state_led_show_m4;
wire [6:0] score;
wire loop_game;

game_loop game_loop(
    .clk( clk ),
    .rst( rst ),
    .count_down_game ( count_down_game ),
    .difficulty ( difficulty ),
    .hammer ( hammer ),
    .dig_display ( dig_display_m4 ),
    .seg_code_1 ( seg_code_1_m4 ),
    .seg_code_2 ( seg_code_2_m4 ),
    .state_led_show ( state_led_show_m4 ),
    .score ( score ),
    .loop_game ( loop_game )
);

wire [7:0] dig_display_m5;
wire [7:0] seg_code_1_m5;
wire [7:0] seg_code_2_m5;
wire [7:0] diff_led_show_m5;
wire [7:0] state_led_show_m5;
wire end_game;

game_over game_over(
    .clk( clk ),
    .rst( rst ),
    .loop_game ( loop_game ),
    .score ( score ),
    .dig_display ( dig_display_m5 ),
    .seg_code_1 ( seg_code_1_m5 ),
    .seg_code_2 ( seg_code_2_m5 ),
    .diff_led_show ( diff_led_show_m5 ),
    .state_led_show ( state_led_show_m5 ),
    .end_game ( end_game )
);


always @( posedge clk or posedge rst )
    if( rst )
        begin
            dig_display <= 8'b00000000;
            seg_code_1 <=  8'b00000000;
            seg_code_2 <=  8'b00000000;
            diff_led_show <=  8'b00000000;
            state_led_show <=  8'b00000000;
        end
    else if( !start_game && !ready_game && !count_down_game && !loop_game && !end_game)
        begin
            dig_display = dig_display_m1;
            seg_code_1 <= seg_code_1_m1;
            seg_code_2 <= seg_code_2_m1;
            diff_led_show <= diff_led_show_m1;
        end
    else if( start_game && !ready_game && !count_down_game && !loop_game && !end_game )
        begin
            dig_display <= dig_display_m2;
            seg_code_1 <= seg_code_1_m2;
            seg_code_2 <= seg_code_2_m2;
            diff_led_show <= diff_led_show_m1;
            state_led_show <= state_led_show_m2;
        end
    else if( start_game && ready_game && !count_down_game && !loop_game && !end_game )
        begin
            dig_display <= dig_display_m3;
            seg_code_1 <= seg_code_1_m3;
            seg_code_2 <= seg_code_2_m3;
            diff_led_show <= diff_led_show_m1;
            state_led_show <= state_led_show_m3;
        end
    else if( start_game && ready_game && count_down_game && !loop_game && !end_game )
        begin
            dig_display <= dig_display_m4;
            seg_code_1 <= seg_code_1_m4;
            seg_code_2 <= seg_code_2_m4;
            diff_led_show <= diff_led_show_m1;
            state_led_show <= state_led_show_m4;
        end
    else if( start_game && ready_game && count_down_game && loop_game && !end_game )
        begin
            dig_display <= dig_display_m5;
            seg_code_1 <= seg_code_1_m5;
            seg_code_2 <= seg_code_2_m5;
            diff_led_show <= diff_led_show_m5;
            state_led_show <= state_led_show_m5;
        end
    else if( end_game )
        begin
            dig_display <= 8'b00000000;
            seg_code_1 <=  8'b00000000;
            seg_code_2 <=  8'b00000000;
            diff_led_show <=  8'b00000000;
            state_led_show <=  8'b00000000;
        end
endmodule