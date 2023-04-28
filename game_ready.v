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
// Description:  The second invoked module of the game
// 
// The second module is responsible for providing preparation prompts "READY" for the game.
// 
// Dependencies: 
//  
// Revision:
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module game_ready(
    	input clk,
        input rst,
        input start_game,
        output reg [7:0] dig_display,
        output reg [7:0] seg_code_1,
        output reg [7:0] seg_code_2,
        output reg [7:0] state_led_show,
        output reg ready_game
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

        // 定时0.33s
        parameter T033S = 25'd33000000;
        reg [24:0] cnt_033;
	    always @( posedge clk or posedge rst )
	        if( rst )
	            cnt_033 <= 25'd0;
	        else if( cnt_033 == T033S )
	            cnt_033 <= 25'd0;
	        else if( cnt_sig )
	            cnt_033 <= cnt_033 + 25'b1;
	        else
	            cnt_033 <= 25'd0;

        // 定时3s
        parameter T3S = 29'd300000000;
        reg [28:0] cnt_3;
	    always @( posedge clk or posedge rst )
	        if( rst )
                begin
	                cnt_3 <= 29'd0;
                    cnt_sig <= 1'b0;
                    ready_game <= 1'b0;
                end
            else if( !cnt_sig && start_game && !ready_game )
	            cnt_sig <= 1'b1;
	        else if( cnt_3 == T3S )
                begin
	                cnt_3 <= 29'd0;
                    cnt_sig <= 1'b0;
                    ready_game <= 1'b1;
                end
	        else if( cnt_sig )
	            cnt_3 <= cnt_3 + 29'b1;
	        else
	            cnt_3 <= 29'd0;

        // 控制显示频闪位置
        reg [2:0] dis_pos;
        always @( posedge clk or posedge rst )
	        if( rst )
	            dis_pos <= 3'd0;
	        else if( dis_pos == 3'd5 )
	            dis_pos <= 3'd0;
	        else if( cnt_0001 == T0001S )
	            dis_pos <= dis_pos + 1'b1;
            else
                dis_pos <= dis_pos;

        parameter _R = 8'h88, _E = 8'h86, _A = 8'h88, _D = 8'hc0, _Y = 8'h91;

        always @( posedge clk )
	        if( start_game && !ready_game )
                case( dis_pos )
                    3'd0:begin seg_code_1 <= ~_R; dig_display <= 8'b01000000; end
                    3'd1:begin seg_code_1 <= ~_E; dig_display <= 8'b00100000; end
                    3'd2:begin seg_code_1 <= ~_A; dig_display <= 8'b00010000; end
                    3'd3:begin seg_code_2 <= ~_D; dig_display <= 8'b00001000; end
                    3'd4:begin seg_code_2 <= ~_Y; dig_display <= 8'b00000100; end
                endcase
	        else
                dig_display <= 8'b00000000;
        
        // 控制LED灯逐渐亮起
        reg [2:0] led_num;
        always @( posedge clk or posedge rst )
	        if( rst )
	            led_num <= 3'd0;
	        else if( led_num == 3'd7 )
	            led_num <= 3'd7;
	        else if( cnt_033 == T033S )
	            led_num <= led_num + 1'b1;
            else
                led_num <= led_num;

        always @( posedge clk or posedge rst )
            if( rst )
                state_led_show <= 8'b00000000;
	        else if( start_game && !ready_game )
                case( led_num )
                    3'd0:state_led_show <= 8'b10000000;
                    3'd1:state_led_show <= 8'b11000000;
                    3'd2:state_led_show <= 8'b11100000;
                    3'd3:state_led_show <= 8'b11110000;
                    3'd4:state_led_show <= 8'b11111000;
                    3'd5:state_led_show <= 8'b11111100;
                    3'd6:state_led_show <= 8'b11111110;
                    3'd7:state_led_show <= 8'b11111111;
                endcase
	        else
                state_led_show <= 8'b00000000;
endmodule