`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/23 20:39:28
// Design Name: 
// Module Name: game_count_down
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module game_count_down(
    	input clk,
        input rst,
        input ready_game,
        output reg [7:0] dig_display,
        output reg [7:0] seg_code_1,
        output reg [7:0] seg_code_2,
        output reg [7:0] state_led_show,
        output reg count_down_game
	    );

        // 定时0.001s
        parameter T0001S = 17'd100000;
        reg [16:0] cnt_0001;
	    reg cnt_sig;
	    always @( posedge clk or posedge rst )
	        if( rst )
                cnt_0001 <= 17'd0;
	        else if( cnt_0001 == T0001S )
                cnt_0001 <= 17'd0;
	        else if( cnt_sig )
	            cnt_0001 <= cnt_0001 + 17'b1;
	        else
                cnt_0001 <= 17'd0;

        // 定时1s
        parameter T1S = 27'd100000000;
        reg [26:0] cnt_1;
	    always @( posedge clk or posedge rst )
	        if( rst )
	            cnt_1 <= 27'd0;
	        else if( cnt_1 == T1S )
	            cnt_1 <= 27'd0;
	        else if( cnt_sig )
	            cnt_1 <= cnt_1 + 27'b1;
	        else
	            cnt_1 <= 27'd0;

        // 定时6s
        parameter T6S = 30'd600000000;
        reg [29:0] cnt_6;
	    always @( posedge clk or posedge rst )
	        if( rst )
                begin
	                cnt_6 <= 30'd0;
                    cnt_sig <= 1'b0;
                    count_down_game <= 1'b0;
                end
            else if( !cnt_sig && ready_game && !count_down_game)
	            cnt_sig <= 1'b1;
	        else if( cnt_6 == T6S )
                begin
	                cnt_6 <= 30'd0;
                    cnt_sig <= 1'b0;
                    count_down_game <= 1'b1;
                end
	        else if( cnt_sig )
	            cnt_6 <= cnt_6 + 30'b1;
	        else
	            cnt_6 <= 30'd0;

        // 控制显示频闪位置
        reg dis_pos;
        always @( posedge clk or posedge rst )
	        if( rst )
	            dis_pos <= 1'b0;
	        else if( cnt_0001 == T0001S )
	            dis_pos <= !dis_pos;
            else
                dis_pos <= dis_pos;
        
        // 控制倒计时
        reg [2:0] cnt_down;
        always @( posedge clk or posedge rst )
	        if( rst )
	            cnt_down <= 3'd5;
	        else if( cnt_1 == T1S )
	            cnt_down <= cnt_down - 1'b1;

        parameter _0 = 8'hc0, _1 = 8'hf9, _2 = 8'ha4, _3 = 8'hb0, _4 = 8'h99, _5 = 8'h92, _G = 8'h82;

        always @( posedge clk or posedge rst )
            if( rst )
                begin
                    dig_display <= 8'b00000000;
                    state_led_show <= 8'b00000000;
                    seg_code_1 <= 8'b00000000;
                    seg_code_2 <= 8'b00000000;
                end
	        else if( ready_game && !count_down_game )
                case( cnt_down )
                    3'd5:
                        case( dis_pos )
                            1'b0:begin seg_code_1 <= ~_0; dig_display <= 8'b00010000; state_led_show <= 8'b11111111; end
                            1'b1:begin seg_code_2 <= ~_5; dig_display <= 8'b00001000; state_led_show <= 8'b11111111; end
                        endcase
                    3'd4:
                        case( dis_pos )
                            1'b0:begin seg_code_1 <= ~_0; dig_display <= 8'b00010000; state_led_show <= 8'b11111110; end
                            1'b1:begin seg_code_2 <= ~_4; dig_display <= 8'b00001000; state_led_show <= 8'b11111110; end
                        endcase
                    3'd3:
                        case( dis_pos )
                            1'b0:begin seg_code_1 <= ~_0; dig_display <= 8'b00010000; state_led_show <= 8'b11111000; end
                            1'b1:begin seg_code_2 <= ~_3; dig_display <= 8'b00001000; state_led_show <= 8'b11111000; end
                        endcase
                    3'd2:
                        case( dis_pos )
                            1'b0:begin seg_code_1 <= ~_0; dig_display <= 8'b00010000; state_led_show <= 8'b11100000; end
                            1'b1:begin seg_code_2 <= ~_2; dig_display <= 8'b00001000; state_led_show <= 8'b11100000; end
                        endcase
                    3'd1:
                        case( dis_pos )
                            1'b0:begin seg_code_1 <= ~_0; dig_display <= 8'b00010000; state_led_show <= 8'b10000000; end
                            1'b1:begin seg_code_2 <= ~_1; dig_display <= 8'b00001000; state_led_show <= 8'b10000000; end
                        endcase
                    3'd0:
                        case( dis_pos )
                            1'b0:begin seg_code_1 <= ~_G; dig_display <= 8'b00010000; state_led_show <= 8'b00000000; end
                            1'b1:begin seg_code_2 <= ~_0; dig_display <= 8'b00001000; state_led_show <= 8'b00000000; end
                        endcase
                endcase
	        else
                begin
                    dig_display <= 8'b00000000;
                    state_led_show <= 8'b00000000;
                end
endmodule