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
// Description:  The first invoked module of the game
// 
// The first module is responsible for setting the game difficulty and displaying the difficulty level.
// 
// Dependencies: 
//  
// Revision:
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module game_start(
	    input clk,
	    input rst,
	    input [7:0] diff_choice,
        output reg [7:0] dig_display,
        output reg [7:0] seg_code_1,
        output reg [7:0] seg_code_2,
        output reg [7:0] diff_led_show,
	    output reg [7:0] difficulty,
        output reg start_game
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

        // 定时5s
        parameter T5S = 30'd500000000;
        reg [29:0] cnt_5;
	    always @( posedge clk or posedge rst )
	        if( rst )
                begin
	                cnt_5 <= 30'd0;
                    cnt_sig <= 1'b0;
                    start_game <= 1'b0;
                end
            else if( |diff_led_show && !cnt_sig && !start_game)
	            cnt_sig <= 1'b1;
	        else if( cnt_5 == T5S )
                begin
	                cnt_5 <= 30'd0;
                    cnt_sig <= 1'b0;
                    start_game <= 1'b1;
                end
	        else if( cnt_sig )
	            cnt_5 <= cnt_5 + 30'b1;
	        else
	            cnt_5 <= 30'd0;

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
	              _8 = 8'h80, _d = 8'ha1, _I = 8'hf9, _F = 8'h8e, __ = 8'h7f;

        always @( posedge clk or posedge rst )
	        if( rst )
	            begin
                    difficulty <= 8'b00000000;
                    dig_display <= 8'b00000000;
                    diff_led_show <= 8'b00000000;
                    seg_code_1 <= 8'b00000000;
                    seg_code_2 <= 8'b00000000;
                end
	        else if( !start_game )
	            case( difficulty )
	                8'd0:
	                    begin
	                        difficulty <= diff_choice;
                            diff_led_show <= 8'b00000000;
                            dig_display <= 8'b00000000;
	                    end
	                8'd1:
	                    begin
                            diff_led_show <= 8'b00000001;
                            case( dis_pos )
                                3'd0:begin seg_code_1 <= ~_d; seg_code_2 <= ~__; dig_display <= 8'b10001000; end
                                3'd1:begin seg_code_1 <= ~_I; seg_code_2 <= ~_0; dig_display <= 8'b01000100; end
                                3'd2:begin seg_code_1 <= ~_F; seg_code_2 <= ~_1; dig_display <= 8'b00100010; end
                                3'd3:begin seg_code_1 <= ~_F; seg_code_2 <= ~__; dig_display <= 8'b00010001; end
                            endcase
	                    end
                    8'd2:
                    	begin
                            diff_led_show <= 8'b00000011;
                            case( dis_pos )
                                3'd0:begin seg_code_1 <= ~_d; seg_code_2 <= ~__; dig_display <= 8'b10001000; end
                                3'd1:begin seg_code_1 <= ~_I; seg_code_2 <= ~_0; dig_display <= 8'b01000100; end
                                3'd2:begin seg_code_1 <= ~_F; seg_code_2 <= ~_2; dig_display <= 8'b00100010; end
                                3'd3:begin seg_code_1 <= ~_F; seg_code_2 <= ~__; dig_display <= 8'b00010001; end
                            endcase
	                    end
                    8'd4:
	                    begin
                            diff_led_show <= 8'b00000111;
                            case( dis_pos )
                                3'd0:begin seg_code_1 <= ~_d; seg_code_2 <= ~__; dig_display <= 8'b10001000; end
                                3'd1:begin seg_code_1 <= ~_I; seg_code_2 <= ~_0; dig_display <= 8'b01000100; end
                                3'd2:begin seg_code_1 <= ~_F; seg_code_2 <= ~_3; dig_display <= 8'b00100010; end
                                3'd3:begin seg_code_1 <= ~_F; seg_code_2 <= ~__; dig_display <= 8'b00010001; end
                            endcase
	                    end
                    8'd8:
	                    begin
                            diff_led_show <= 8'b00001111;
                            case( dis_pos )
                                3'd0:begin seg_code_1 <= ~_d; seg_code_2 <= ~__; dig_display <= 8'b10001000; end
                                3'd1:begin seg_code_1 <= ~_I; seg_code_2 <= ~_0; dig_display <= 8'b01000100; end
                                3'd2:begin seg_code_1 <= ~_F; seg_code_2 <= ~_4; dig_display <= 8'b00100010; end
                                3'd3:begin seg_code_1 <= ~_F; seg_code_2 <= ~__; dig_display <= 8'b00010001; end
                            endcase
	                    end
                    8'd16:
	                    begin
                            diff_led_show <= 8'b00011111;
                            case( dis_pos )
                                3'd0:begin seg_code_1 <= ~_d; seg_code_2 <= ~__; dig_display <= 8'b10001000; end
                                3'd1:begin seg_code_1 <= ~_I; seg_code_2 <= ~_0; dig_display <= 8'b01000100; end
                                3'd2:begin seg_code_1 <= ~_F; seg_code_2 <= ~_5; dig_display <= 8'b00100010; end
                                3'd3:begin seg_code_1 <= ~_F; seg_code_2 <= ~__; dig_display <= 8'b00010001; end
                            endcase
	                    end
                    8'd32:
	                    begin
                            diff_led_show <= 8'b00111111;
                            case( dis_pos )
                                3'd0:begin seg_code_1 <= ~_d; seg_code_2 <= ~__; dig_display <= 8'b10001000; end
                                3'd1:begin seg_code_1 <= ~_I; seg_code_2 <= ~_0; dig_display <= 8'b01000100; end
                                3'd2:begin seg_code_1 <= ~_F; seg_code_2 <= ~_6; dig_display <= 8'b00100010; end
                                3'd3:begin seg_code_1 <= ~_F; seg_code_2 <= ~__; dig_display <= 8'b00010001; end
                            endcase
	                    end
                    8'd64:
	                    begin
                            diff_led_show <= 8'b01111111;
                            case( dis_pos )
                                3'd0:begin seg_code_1 <= ~_d; seg_code_2 <= ~__; dig_display <= 8'b10001000; end
                                3'd1:begin seg_code_1 <= ~_I; seg_code_2 <= ~_0; dig_display <= 8'b01000100; end
                                3'd2:begin seg_code_1 <= ~_F; seg_code_2 <= ~_7; dig_display <= 8'b00100010; end
                                3'd3:begin seg_code_1 <= ~_F; seg_code_2 <= ~__; dig_display <= 8'b00010001; end
                            endcase
	                    end
                    8'd128:
	                    begin
                            diff_led_show <= 8'b11111111;
                            case( dis_pos )
                                3'd0:begin seg_code_1 <= ~_d; seg_code_2 <= ~__; dig_display <= 8'b10001000; end
                                3'd1:begin seg_code_1 <= ~_I; seg_code_2 <= ~_0; dig_display <= 8'b01000100; end
                                3'd2:begin seg_code_1 <= ~_F; seg_code_2 <= ~_8; dig_display <= 8'b00100010; end
                                3'd3:begin seg_code_1 <= ~_F; seg_code_2 <= ~__; dig_display <= 8'b00010001; end
                            endcase
	                    end
                    default:
	                    difficulty <= 8'h00;
	            endcase
	        else
	            begin
                    dig_display <= 8'b00000000;
                    diff_led_show <= 8'b00000000;
                    seg_code_1 <= 8'b00000000;
                    seg_code_2 <= 8'b00000000;
                end
endmodule