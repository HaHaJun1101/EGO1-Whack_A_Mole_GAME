`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Science and Technology Beijing
// Engineer: Steven Yang
// 
// Create Date: 
// Design Name: 
// Module Name: game_start
// Project Name: Whack_A_Mole_GAME
// Target Devices: 
// Tool Versions: 
// Description:  The fifth invoked module of the game
// 
// The fifth module is responsible for displaying the animation 
// of the game settlement process and presenting the final score.
// 
// Dependencies: 
// 
// Revision:
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module game_over(
    	input clk,
        input rst,
        input loop_game,
        input [6:0] score,
        output reg [7:0] dig_display,
        output reg [7:0] seg_code_1,
        output reg [7:0] seg_code_2,
        output reg [7:0] diff_led_show,
        output reg [7:0] state_led_show,
        output reg end_game
	    );

        // 模块总定时器:15s, 其中分别包含两个任务:5s、10s
        parameter T5S = 31'd500000000;
        parameter T15S = 31'd1500000000;
        reg [30:0] cnt;
        reg cnt_sig;
        reg cnt_m1_sig;
        reg cnt_m2_sig;
	    always @( posedge clk or posedge rst )
	        if( rst )
                begin cnt <= 31'd0; cnt_sig <= 1'b0; cnt_m1_sig <= 1'b0; cnt_m2_sig <= 1'b0; end_game <= 1'b0; end
            else if( !cnt_sig && loop_game && !end_game)
                begin cnt_sig <= 1'b1; cnt_m1_sig <= 1'b1; end
            else if( cnt_sig && cnt != T15S  )
                begin
	                cnt <= cnt + 31'b1;
	                if( cnt == T5S )
                        begin cnt_m1_sig <= 1'b0; cnt_m2_sig <= 1'b1; end
                end
	        else if( cnt_sig && cnt == T15S )
                begin cnt <= 31'd0; cnt_sig <= 1'b0; cnt_m2_sig <= 1'b0; end_game <= 1'b1; end
	        else
	            cnt <= 31'd0;
        
        // 第一个任务每步定时0.2s, 共25步, 总耗时5s
        parameter T02S = 25'd20000000;
        reg [24:0] cnt_02;
	    always @( posedge clk or posedge rst )
	        if( rst )
	            cnt_02 <= 25'd0;
	        else if( cnt_02 == T02S )
	            cnt_02 <= 25'd0;
	        else if( cnt_m1_sig )
	            cnt_02 <= cnt_02 + 25'b1;
	        else
	            cnt_02 <= 25'd0;
        
        // 第二个任务每步定时0.5s, 共20步, 总耗时10s
        parameter T05S = 26'd50000000;
        reg [25:0] cnt_05;
	    always @( posedge clk or posedge rst )
	        if( rst )
	            cnt_05 <= 26'd0;
	        else if( cnt_05 == T05S )
	            cnt_05 <= 26'd0;
	        else if( cnt_m2_sig )
	            cnt_05 <= cnt_05 + 26'b1;
	        else
	            cnt_05 <= 26'd0;
        
        // 控制任务一: 分数结算计算ing
        reg [4:0] m1_num;
        always @( posedge clk or posedge rst )
	        if( rst )
	            m1_num <= 5'd0;
	        else if( cnt_m1_sig && cnt_02 == T02S )
	            m1_num <= m1_num + 1'b1;
            else if( cnt_m1_sig && cnt_02 != T02S )
                m1_num <= m1_num;
            else
	            m1_num <= 5'd0;

        // 控制任务二: 分数结算展示ing
        reg [4:0] m2_num;
        always @( posedge clk or posedge rst )
	        if( rst )
	            m2_num <= 5'd0;
	        else if( cnt_m2_sig && cnt_05 == T05S )
                if ( m2_num != 5'd16 )    // 停留在最终界面, 减少重复代码
	                m2_num <= m2_num + 1'b1;
                else
                    m2_num <= m2_num;
            else if( cnt_m2_sig && cnt_05 != T05S )
                m2_num <= m2_num;
            else
	            m2_num <= 5'd0;
        
        // 定时0.001s, 提供频闪功能
        parameter T0001S = 17'd100000;
        reg [16:0] cnt_0001;
	    always @( posedge clk or posedge rst )
	        if( rst )
                cnt_0001 <= 17'd0;
	        else if( cnt_0001 == T0001S )
                cnt_0001 <= 17'd0;
	        else if( cnt_m2_sig )
	            cnt_0001 <= cnt_0001 + 17'b1;
	        else
                cnt_0001 <= 17'd0;
        
        // 控制显示频闪位置
        reg [2:0] dis_pos;
        always @( posedge clk or posedge rst )
	        if( rst )
	            dis_pos <= 3'd0;
	        else if( dis_pos == 3'd4 )
	            dis_pos <= 3'd0;
	        else if( cnt_0001 == T0001S )
	            dis_pos <= dis_pos + 1'b1;
            else
                dis_pos <= dis_pos;
        
        parameter _0 = 8'hc0, _1 = 8'hf9, _2 = 8'ha4, _3 = 8'hb0,
	              _4 = 8'h99, _5 = 8'h92, _6 = 8'h82, _7 = 8'hf8,
	              _8 = 8'h80, _9 = 8'h90, _S = 8'h92, _C = 8'hc6, _R = 8'h88, _E = 8'h06;

        // 按照每个步骤进行展示输出
        always @( posedge clk or posedge rst )
            if( rst )
                begin
                    dig_display <= 8'b00000000;
                    seg_code_1 <= 8'b00000000;
                    seg_code_2 <= 8'b00000000;
                    diff_led_show <= 8'b00000000;
                    state_led_show <= 8'b00000000;
                end
	        else if( loop_game && !end_game )
                if( cnt_m1_sig && !cnt_m2_sig )
                    case( m1_num )
                        5'd0:begin dig_display <= 8'b11111111; seg_code_1 <= 8'b00000001; seg_code_2 <= 8'b00000001; diff_led_show <= 8'b00000000; state_led_show <= 8'b00000000; end
                        5'd1:begin dig_display <= 8'b11111111; seg_code_1 <= 8'b00000010; seg_code_2 <= 8'b00000010; diff_led_show <= 8'b00000001; state_led_show <= 8'b00000000; end
                        5'd2:begin dig_display <= 8'b11111111; seg_code_1 <= 8'b01000000; seg_code_2 <= 8'b01000000; diff_led_show <= 8'b00000011; state_led_show <= 8'b00000000; end
                        5'd3:begin dig_display <= 8'b11111111; seg_code_1 <= 8'b00010000; seg_code_2 <= 8'b00010000; diff_led_show <= 8'b00000111; state_led_show <= 8'b00000000; end
                        5'd4:begin dig_display <= 8'b11111111; seg_code_1 <= 8'b00001000; seg_code_2 <= 8'b00001000; diff_led_show <= 8'b00001111; state_led_show <= 8'b00000000; end
                        5'd5:begin dig_display <= 8'b11111111; seg_code_1 <= 8'b00000100; seg_code_2 <= 8'b00000100; diff_led_show <= 8'b00011111; state_led_show <= 8'b00000000; end
                        5'd6:begin dig_display <= 8'b11111111; seg_code_1 <= 8'b01000000; seg_code_2 <= 8'b01000000; diff_led_show <= 8'b00111111; state_led_show <= 8'b00000000; end
                        5'd7:begin dig_display <= 8'b11111111; seg_code_1 <= 8'b00100000; seg_code_2 <= 8'b00100000; diff_led_show <= 8'b01111111; state_led_show <= 8'b00000000; end
                        5'd8:begin dig_display <= 8'b11111111; seg_code_1 <= 8'b00000001; seg_code_2 <= 8'b00000001; diff_led_show <= 8'b11111111; state_led_show <= 8'b00000000; end
                        5'd9:begin dig_display <= 8'b11111111; seg_code_1 <= 8'b00000010; seg_code_2 <= 8'b00000010; diff_led_show <= 8'b11111111; state_led_show <= 8'b10000000; end
                        5'd10:begin dig_display <= 8'b11111111; seg_code_1 <= 8'b01000000; seg_code_2 <= 8'b01000000; diff_led_show <= 8'b11111111; state_led_show <= 8'b11000000; end
                        5'd11:begin dig_display <= 8'b11111111; seg_code_1 <= 8'b00010000; seg_code_2 <= 8'b00010000; diff_led_show <= 8'b11111111; state_led_show <= 8'b11100000; end
                        5'd12:begin dig_display <= 8'b11111111; seg_code_1 <= 8'b00001000; seg_code_2 <= 8'b00001000; diff_led_show <= 8'b11111111; state_led_show <= 8'b11110000; end
                        5'd13:begin dig_display <= 8'b11111111; seg_code_1 <= 8'b00000100; seg_code_2 <= 8'b00000100; diff_led_show <= 8'b11111111; state_led_show <= 8'b11111000; end
                        5'd14:begin dig_display <= 8'b11111111; seg_code_1 <= 8'b01000000; seg_code_2 <= 8'b01000000; diff_led_show <= 8'b11111111; state_led_show <= 8'b11111100; end
                        5'd15:begin dig_display <= 8'b11111111; seg_code_1 <= 8'b00100000; seg_code_2 <= 8'b00100000; diff_led_show <= 8'b11111111; state_led_show <= 8'b11111110; end
                        5'd16:begin dig_display <= 8'b11111111; seg_code_1 <= 8'b00000001; seg_code_2 <= 8'b00000001; diff_led_show <= 8'b11111111; state_led_show <= 8'b11111111; end
                        5'd17:begin dig_display <= 8'b11111111; seg_code_1 <= 8'b00000010; seg_code_2 <= 8'b00000010; diff_led_show <= 8'b11111111; state_led_show <= 8'b11111100; end
                        5'd18:begin dig_display <= 8'b11111111; seg_code_1 <= 8'b01000000; seg_code_2 <= 8'b01000000; diff_led_show <= 8'b11111111; state_led_show <= 8'b11110000; end
                        5'd19:begin dig_display <= 8'b11111111; seg_code_1 <= 8'b00010000; seg_code_2 <= 8'b00010000; diff_led_show <= 8'b11111111; state_led_show <= 8'b11000000; end
                        5'd20:begin dig_display <= 8'b11111111; seg_code_1 <= 8'b00001000; seg_code_2 <= 8'b00001000; diff_led_show <= 8'b11111111; state_led_show <= 8'b00000000; end
                        5'd21:begin dig_display <= 8'b11111111; seg_code_1 <= 8'b00000100; seg_code_2 <= 8'b00000100; diff_led_show <= 8'b00111111; state_led_show <= 8'b00000000; end
                        5'd22:begin dig_display <= 8'b11111111; seg_code_1 <= 8'b01000000; seg_code_2 <= 8'b01000000; diff_led_show <= 8'b00001111; state_led_show <= 8'b00000000; end
                        5'd23:begin dig_display <= 8'b11111111; seg_code_1 <= 8'b00100000; seg_code_2 <= 8'b00100000; diff_led_show <= 8'b00000011; state_led_show <= 8'b00000000; end
                        5'd24:begin dig_display <= 8'b11111111; seg_code_1 <= 8'b00000001; seg_code_2 <= 8'b00000001; diff_led_show <= 8'b00000000; state_led_show <= 8'b00000000; end
                    endcase
                else if ( !cnt_m1_sig && cnt_m2_sig )
                    case( m2_num )
                        5'd0:
                            begin
                                diff_led_show <= 8'b00000000;
                                state_led_show <= 8'b00000000;
                                case( dis_pos )
                                    3'd0:begin seg_code_1 <= ~_S; seg_code_2 <= 8'h00; dig_display <= 8'b10001000; end
                                    3'd1:begin seg_code_1 <= 8'h00; seg_code_2 <= 8'h00; dig_display <= 8'b01000100; end
                                    3'd2:begin seg_code_1 <= 8'h00; seg_code_2 <= 8'h00; dig_display <= 8'b00100010; end
                                    3'd3:begin seg_code_1 <= 8'h00; seg_code_2 <= 8'h00; dig_display <= 8'b00010001; end
                                endcase
                            end
                        5'd1:
                            begin
                                diff_led_show <= 8'b11111111;
                                state_led_show <= 8'b11111111;
                                case( dis_pos )
                                    3'd0:begin seg_code_1 <= ~_S; seg_code_2 <= 8'h00; dig_display <= 8'b10001000; end
                                    3'd1:begin seg_code_1 <= ~_C; seg_code_2 <= 8'h00; dig_display <= 8'b01000100; end
                                    3'd2:begin seg_code_1 <= 8'h00; seg_code_2 <= 8'h00; dig_display <= 8'b00100010; end
                                    3'd3:begin seg_code_1 <= 8'h00; seg_code_2 <= 8'h00; dig_display <= 8'b00010001; end
                                endcase
                            end
                        5'd2:
                            begin
                                diff_led_show <= 8'b00000000;
                                state_led_show <= 8'b00000000;
                                case( dis_pos )
                                    3'd0:begin seg_code_1 <= ~_S; seg_code_2 <= 8'h00; dig_display <= 8'b10001000; end
                                    3'd1:begin seg_code_1 <= ~_C; seg_code_2 <= 8'h00; dig_display <= 8'b01000100; end
                                    3'd2:begin seg_code_1 <= ~_0; seg_code_2 <= 8'h00; dig_display <= 8'b00100010; end
                                    3'd3:begin seg_code_1 <= 8'h00; seg_code_2 <= 8'h00; dig_display <= 8'b00010001; end
                                endcase
                            end
                        5'd3:
                            begin
                                diff_led_show <= 8'b11111111;
                                state_led_show <= 8'b11111111;
                                case( dis_pos )
                                    3'd0:begin seg_code_1 <= ~_S; seg_code_2 <= 8'h00; dig_display <= 8'b10001000; end
                                    3'd1:begin seg_code_1 <= ~_C; seg_code_2 <= 8'h00; dig_display <= 8'b01000100; end
                                    3'd2:begin seg_code_1 <= ~_0; seg_code_2 <= 8'h00; dig_display <= 8'b00100010; end
                                    3'd3:begin seg_code_1 <= ~_R; seg_code_2 <= 8'h00; dig_display <= 8'b00010001; end
                                endcase
                            end
                        5'd4:
                            begin
                                diff_led_show <= 8'b00000000;
                                state_led_show <= 8'b00000000;
                                case( dis_pos )
                                    3'd0:begin seg_code_1 <= ~_S; seg_code_2 <= ~_E; dig_display <= 8'b10001000; end
                                    3'd1:begin seg_code_1 <= ~_C; seg_code_2 <= 8'h00; dig_display <= 8'b01000100; end
                                    3'd2:begin seg_code_1 <= ~_0; seg_code_2 <= 8'h00; dig_display <= 8'b00100010; end
                                    3'd3:begin seg_code_1 <= ~_R; seg_code_2 <= 8'h00; dig_display <= 8'b00010001; end
                                endcase
                            end
                        5'd5:
                            begin
                                diff_led_show <= 8'b00000001;    // 60+
                                state_led_show <= 8'b00000000;
                                case( dis_pos )
                                    3'd0:begin seg_code_1 <= ~_S; seg_code_2 <= ~_E; dig_display <= 8'b10001000; end
                                    3'd1:begin seg_code_1 <= ~_C; seg_code_2 <= 8'h00; dig_display <= 8'b01000100; end
                                    3'd2:begin seg_code_1 <= ~_0; seg_code_2 <= 8'h00; dig_display <= 8'b00100010; end
                                    3'd3:begin seg_code_1 <= ~_R; seg_code_2 <= 8'h00; dig_display <= 8'b00010001; end
                                endcase
                            end
                        5'd6:
                            begin
                                if( score > 14 )    // 65+
                                    begin diff_led_show <= 8'b00000011; state_led_show <= 8'b00000000; end
                                else
                                    begin diff_led_show <= diff_led_show; state_led_show <= state_led_show; end
                                case( dis_pos )
                                    3'd0:begin seg_code_1 <= ~_S; seg_code_2 <= ~_E; dig_display <= 8'b10001000; end
                                    3'd1:begin seg_code_1 <= ~_C; seg_code_2 <= 8'h00; dig_display <= 8'b01000100; end
                                    3'd2:begin seg_code_1 <= ~_0; seg_code_2 <= 8'h00; dig_display <= 8'b00100010; end
                                    3'd3:begin seg_code_1 <= ~_R; seg_code_2 <= 8'h00; dig_display <= 8'b00010001; end
                                endcase
                            end
                        5'd7:
                            begin
                                if( score > 15 )    // 70+
                                    begin diff_led_show <= 8'b00000111; state_led_show <= 8'b00000000; end
                                else
                                    begin diff_led_show <= diff_led_show; state_led_show <= state_led_show; end
                                case( dis_pos )
                                    3'd0:begin seg_code_1 <= ~_S; seg_code_2 <= ~_E; dig_display <= 8'b10001000; end
                                    3'd1:begin seg_code_1 <= ~_C; seg_code_2 <= 8'h00; dig_display <= 8'b01000100; end
                                    3'd2:begin seg_code_1 <= ~_0; seg_code_2 <= 8'h00; dig_display <= 8'b00100010; end
                                    3'd3:begin seg_code_1 <= ~_R; seg_code_2 <= 8'h00; dig_display <= 8'b00010001; end
                                endcase
                            end
                        5'd8:
                            begin
                                if( score > 16 )    // 75+
                                    begin diff_led_show <= 8'b00001111; state_led_show <= 8'b00000000; end
                                else
                                    begin diff_led_show <= diff_led_show; state_led_show <= state_led_show; end
                                case( dis_pos )
                                    3'd0:begin seg_code_1 <= ~_S; seg_code_2 <= ~_E; dig_display <= 8'b10001000; end
                                    3'd1:begin seg_code_1 <= ~_C; seg_code_2 <= 8'h00; dig_display <= 8'b01000100; end
                                    3'd2:begin seg_code_1 <= ~_0; seg_code_2 <= 8'h00; dig_display <= 8'b00100010; end
                                    3'd3:begin seg_code_1 <= ~_R; seg_code_2 <= 8'h00; dig_display <= 8'b00010001; end
                                endcase
                            end
                        5'd9:
                            begin
                                if( score > 17 )    // 80+
                                    begin diff_led_show <= 8'b00011111; state_led_show <= 8'b00000000; end
                                else
                                    begin diff_led_show <= diff_led_show; state_led_show <= state_led_show; end
                                case( dis_pos )
                                    3'd0:begin seg_code_1 <= ~_S; seg_code_2 <= ~_E; dig_display <= 8'b10001000; end
                                    3'd1:begin seg_code_1 <= ~_C; seg_code_2 <= 8'h00; dig_display <= 8'b01000100; end
                                    3'd2:begin seg_code_1 <= ~_0; seg_code_2 <= 8'h00; dig_display <= 8'b00100010; end
                                    3'd3:begin seg_code_1 <= ~_R; seg_code_2 <= 8'h00; dig_display <= 8'b00010001; end
                                endcase
                            end
                        5'd10:
                            begin
                                if( score > 18 )    // 85+
                                    begin diff_led_show <= 8'b00111111; state_led_show <= 8'b00000000; end
                                else
                                    begin diff_led_show <= diff_led_show; state_led_show <= state_led_show; end
                                case( dis_pos )
                                    3'd0:begin seg_code_1 <= ~_S; seg_code_2 <= ~_E; dig_display <= 8'b10001000; end
                                    3'd1:begin seg_code_1 <= ~_C; seg_code_2 <= 8'h00; dig_display <= 8'b01000100; end
                                    3'd2:begin seg_code_1 <= ~_0; seg_code_2 <= 8'h00; dig_display <= 8'b00100010; end
                                    3'd3:begin seg_code_1 <= ~_R; seg_code_2 <= 8'h00; dig_display <= 8'b00010001; end
                                endcase
                            end
                        5'd11:
                            begin
                                if( score > 19 )    // 90+
                                    begin diff_led_show <= 8'b01111111; state_led_show <= 8'b00000000; end
                                else
                                    begin diff_led_show <= diff_led_show; state_led_show <= state_led_show; end
                                case( dis_pos )
                                    3'd0:begin seg_code_1 <= ~_S; seg_code_2 <= ~_E; dig_display <= 8'b10001000; end
                                    3'd1:begin seg_code_1 <= ~_C; seg_code_2 <= 8'h00; dig_display <= 8'b01000100; end
                                    3'd2:begin seg_code_1 <= ~_0; seg_code_2 <= 8'h00; dig_display <= 8'b00100010; end
                                    3'd3:begin seg_code_1 <= ~_R; seg_code_2 <= 8'h00; dig_display <= 8'b00010001; end
                                endcase
                            end
                        5'd12:
                            begin
                                if( score > 20 )    // 95+
                                    begin diff_led_show <= 8'b11111111; state_led_show <= 8'b00000000; end
                                else
                                    begin diff_led_show <= diff_led_show; state_led_show <= state_led_show; end
                                case( dis_pos )
                                    3'd0:begin seg_code_1 <= ~_S; seg_code_2 <= ~_E; dig_display <= 8'b10001000; end
                                    3'd1:begin seg_code_1 <= ~_C; seg_code_2 <= 8'h00; dig_display <= 8'b01000100; end
                                    3'd2:begin seg_code_1 <= ~_0; seg_code_2 <= 8'h00; dig_display <= 8'b00100010; end
                                    3'd3:begin seg_code_1 <= ~_R; seg_code_2 <= 8'h00; dig_display <= 8'b00010001; end
                                endcase
                            end
                        5'd13:
                            begin
                                if( score > 21 )    // 100!!!
                                    begin diff_led_show <= 8'b11111111; state_led_show <= 8'b11111111; end
                                else
                                    begin diff_led_show <= diff_led_show; state_led_show <= state_led_show; end
                                case( dis_pos )
                                    3'd0:begin seg_code_1 <= ~_S; seg_code_2 <= ~_E; dig_display <= 8'b10001000; end
                                    3'd1:begin seg_code_1 <= ~_C; seg_code_2 <= 8'h00; dig_display <= 8'b01000100; end
                                    3'd2:begin seg_code_1 <= ~_0; seg_code_2 <= 8'h00; dig_display <= 8'b00100010; end
                                    3'd3:begin seg_code_1 <= ~_R; seg_code_2 <= 8'h00; dig_display <= 8'b00010001; end
                                endcase
                            end
                        5'd14:
                            begin
                                diff_led_show <= diff_led_show;
                                state_led_show <= state_led_show;
                                if( score < 22 )    // 95-
                                    case( dis_pos )
                                        3'd0:begin seg_code_1 <= ~_S; seg_code_2 <= ~_E; dig_display <= 8'b10001000; end
                                        3'd1:begin seg_code_1 <= ~_C; seg_code_2 <= ~_0; dig_display <= 8'b01000100; end
                                        3'd2:begin seg_code_1 <= ~_0; seg_code_2 <= 8'h00; dig_display <= 8'b00100010; end
                                        3'd3:begin seg_code_1 <= ~_R; seg_code_2 <= 8'h00; dig_display <= 8'b00010001; end
                                    endcase
                                else if( score > 21 )    // 100
                                    case( dis_pos )
                                        3'd0:begin seg_code_1 <= ~_S; seg_code_2 <= ~_E; dig_display <= 8'b10001000; end
                                        3'd1:begin seg_code_1 <= ~_C; seg_code_2 <= ~_1; dig_display <= 8'b01000100; end
                                        3'd2:begin seg_code_1 <= ~_0; seg_code_2 <= 8'h00; dig_display <= 8'b00100010; end
                                        3'd3:begin seg_code_1 <= ~_R; seg_code_2 <= 8'h00; dig_display <= 8'b00010001; end
                                    endcase
                            end
                        5'd15:
                            begin
                                diff_led_show <= diff_led_show;
                                state_led_show <= state_led_show;
                                if( score < 16 )    // 70-
                                    case( dis_pos )
                                        3'd0:begin seg_code_1 <= ~_S; seg_code_2 <= ~_E; dig_display <= 8'b10001000; end
                                        3'd1:begin seg_code_1 <= ~_C; seg_code_2 <= ~_0; dig_display <= 8'b01000100; end
                                        3'd2:begin seg_code_1 <= ~_0; seg_code_2 <= ~_6; dig_display <= 8'b00100010; end
                                        3'd3:begin seg_code_1 <= ~_R; seg_code_2 <= 8'h00; dig_display <= 8'b00010001; end
                                    endcase
                                else if( score == 16 | score == 17 )    // 70/75
                                    case( dis_pos )
                                        3'd0:begin seg_code_1 <= ~_S; seg_code_2 <= ~_E; dig_display <= 8'b10001000; end
                                        3'd1:begin seg_code_1 <= ~_C; seg_code_2 <= ~_0; dig_display <= 8'b01000100; end
                                        3'd2:begin seg_code_1 <= ~_0; seg_code_2 <= ~_7; dig_display <= 8'b00100010; end
                                        3'd3:begin seg_code_1 <= ~_R; seg_code_2 <= 8'h00; dig_display <= 8'b00010001; end
                                    endcase
                                else if( score == 18 | score == 19 )    // 80/85
                                    case( dis_pos )
                                        3'd0:begin seg_code_1 <= ~_S; seg_code_2 <= ~_E; dig_display <= 8'b10001000; end
                                        3'd1:begin seg_code_1 <= ~_C; seg_code_2 <= ~_0; dig_display <= 8'b01000100; end
                                        3'd2:begin seg_code_1 <= ~_0; seg_code_2 <= ~_8; dig_display <= 8'b00100010; end
                                        3'd3:begin seg_code_1 <= ~_R; seg_code_2 <= 8'h00; dig_display <= 8'b00010001; end
                                    endcase
                                else if( score == 20 | score == 21 )    // 90/95
                                    case( dis_pos )
                                        3'd0:begin seg_code_1 <= ~_S; seg_code_2 <= ~_E; dig_display <= 8'b10001000; end
                                        3'd1:begin seg_code_1 <= ~_C; seg_code_2 <= ~_0; dig_display <= 8'b01000100; end
                                        3'd2:begin seg_code_1 <= ~_0; seg_code_2 <= ~_9; dig_display <= 8'b00100010; end
                                        3'd3:begin seg_code_1 <= ~_R; seg_code_2 <= 8'h00; dig_display <= 8'b00010001; end
                                    endcase
                                else if( score > 21 )    // 100
                                    case( dis_pos )
                                        3'd0:begin seg_code_1 <= ~_S; seg_code_2 <= ~_E; dig_display <= 8'b10001000; end
                                        3'd1:begin seg_code_1 <= ~_C; seg_code_2 <= ~_1; dig_display <= 8'b01000100; end
                                        3'd2:begin seg_code_1 <= ~_0; seg_code_2 <= ~_0; dig_display <= 8'b00100010; end
                                        3'd3:begin seg_code_1 <= ~_R; seg_code_2 <= 8'h00; dig_display <= 8'b00010001; end
                                    endcase
                            end
                        5'd16:
                            begin
                                diff_led_show <= diff_led_show;
                                state_led_show <= state_led_show;
                                if( score < 15 )    // 60
                                    case( dis_pos )
                                        3'd0:begin seg_code_1 <= ~_S; seg_code_2 <= ~_E; dig_display <= 8'b10001000; end
                                        3'd1:begin seg_code_1 <= ~_C; seg_code_2 <= ~_0; dig_display <= 8'b01000100; end
                                        3'd2:begin seg_code_1 <= ~_0; seg_code_2 <= ~_6; dig_display <= 8'b00100010; end
                                        3'd3:begin seg_code_1 <= ~_R; seg_code_2 <= ~_0; dig_display <= 8'b00010001; end
                                    endcase
                                else if( score == 15 )    // 65
                                    case( dis_pos )
                                        3'd0:begin seg_code_1 <= ~_S; seg_code_2 <= ~_E; dig_display <= 8'b10001000; end
                                        3'd1:begin seg_code_1 <= ~_C; seg_code_2 <= ~_0; dig_display <= 8'b01000100; end
                                        3'd2:begin seg_code_1 <= ~_0; seg_code_2 <= ~_6; dig_display <= 8'b00100010; end
                                        3'd3:begin seg_code_1 <= ~_R; seg_code_2 <= ~_5; dig_display <= 8'b00010001; end
                                    endcase
                                else if( score == 16 )    // 70
                                    case( dis_pos )
                                        3'd0:begin seg_code_1 <= ~_S; seg_code_2 <= ~_E; dig_display <= 8'b10001000; end
                                        3'd1:begin seg_code_1 <= ~_C; seg_code_2 <= ~_0; dig_display <= 8'b01000100; end
                                        3'd2:begin seg_code_1 <= ~_0; seg_code_2 <= ~_7; dig_display <= 8'b00100010; end
                                        3'd3:begin seg_code_1 <= ~_R; seg_code_2 <= ~_0; dig_display <= 8'b00010001; end
                                    endcase
                                else if( score == 17 )    // 75
                                    case( dis_pos )
                                        3'd0:begin seg_code_1 <= ~_S; seg_code_2 <= ~_E; dig_display <= 8'b10001000; end
                                        3'd1:begin seg_code_1 <= ~_C; seg_code_2 <= ~_0; dig_display <= 8'b01000100; end
                                        3'd2:begin seg_code_1 <= ~_0; seg_code_2 <= ~_7; dig_display <= 8'b00100010; end
                                        3'd3:begin seg_code_1 <= ~_R; seg_code_2 <= ~_5; dig_display <= 8'b00010001; end
                                    endcase
                                else if( score == 18 )    // 80
                                    case( dis_pos )
                                        3'd0:begin seg_code_1 <= ~_S; seg_code_2 <= ~_E; dig_display <= 8'b10001000; end
                                        3'd1:begin seg_code_1 <= ~_C; seg_code_2 <= ~_0; dig_display <= 8'b01000100; end
                                        3'd2:begin seg_code_1 <= ~_0; seg_code_2 <= ~_8; dig_display <= 8'b00100010; end
                                        3'd3:begin seg_code_1 <= ~_R; seg_code_2 <= ~_0; dig_display <= 8'b00010001; end
                                    endcase
                                else if( score == 19 )    // 85
                                    case( dis_pos )
                                        3'd0:begin seg_code_1 <= ~_S; seg_code_2 <= ~_E; dig_display <= 8'b10001000; end
                                        3'd1:begin seg_code_1 <= ~_C; seg_code_2 <= ~_0; dig_display <= 8'b01000100; end
                                        3'd2:begin seg_code_1 <= ~_0; seg_code_2 <= ~_8; dig_display <= 8'b00100010; end
                                        3'd3:begin seg_code_1 <= ~_R; seg_code_2 <= ~_5; dig_display <= 8'b00010001; end
                                    endcase
                                else if( score == 20 )    // 90
                                    case( dis_pos )
                                        3'd0:begin seg_code_1 <= ~_S; seg_code_2 <= ~_E; dig_display <= 8'b10001000; end
                                        3'd1:begin seg_code_1 <= ~_C; seg_code_2 <= ~_0; dig_display <= 8'b01000100; end
                                        3'd2:begin seg_code_1 <= ~_0; seg_code_2 <= ~_9; dig_display <= 8'b00100010; end
                                        3'd3:begin seg_code_1 <= ~_R; seg_code_2 <= ~_0; dig_display <= 8'b00010001; end
                                    endcase
                                else if( score == 21 )    // 95
                                    case( dis_pos )
                                        3'd0:begin seg_code_1 <= ~_S; seg_code_2 <= ~_E; dig_display <= 8'b10001000; end
                                        3'd1:begin seg_code_1 <= ~_C; seg_code_2 <= ~_0; dig_display <= 8'b01000100; end
                                        3'd2:begin seg_code_1 <= ~_0; seg_code_2 <= ~_9; dig_display <= 8'b00100010; end
                                        3'd3:begin seg_code_1 <= ~_R; seg_code_2 <= ~_5; dig_display <= 8'b00010001; end
                                    endcase
                                else if( score > 21 )    // 100
                                    case( dis_pos )
                                        3'd0:begin seg_code_1 <= ~_S; seg_code_2 <= ~_E; dig_display <= 8'b10001000; end
                                        3'd1:begin seg_code_1 <= ~_C; seg_code_2 <= ~_1; dig_display <= 8'b01000100; end
                                        3'd2:begin seg_code_1 <= ~_0; seg_code_2 <= ~_0; dig_display <= 8'b00100010; end
                                        3'd3:begin seg_code_1 <= ~_R; seg_code_2 <= ~_0; dig_display <= 8'b00010001; end
                                    endcase
                            end
                    endcase
	        else
                begin
                    dig_display <= 8'b00000000;
                    seg_code_1 <= 8'b00000000;
                    seg_code_2 <= 8'b00000000;
                    diff_led_show <= 8'b00000000;
                    state_led_show <= 8'b00000000;
                end
endmodule