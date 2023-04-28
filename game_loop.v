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
// Description:  The fourth invoked module of the game
// 
// The fourth module is responsible for the random appearance of moles 
// during the game, the judgment of hits, and the recording of game scores.
// 
// Dependencies: 
// 
// Revision:
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module game_loop(
    	input clk,
        input rst,
        input count_down_game,
        input [7:0] difficulty,
        input [4:0] hammer,
        output reg [7:0] dig_display,
        output reg [7:0] seg_code_1,
        output reg [7:0] seg_code_2,
        output reg [7:0] state_led_show,
        output reg [6:0] score,
        output reg loop_game
	    );

        // �����Ѷ��趨ÿ����Ϸʱ��
        reg [29:0] loop_time;
        always @( posedge clk or posedge rst )
	        if( rst )
                loop_time <= 30'd0;
	        else if( count_down_game && |difficulty && !loop_game)
                if( difficulty == 8'b00000001 )
                    loop_time <= 30'd200000000;    // 2s
                else if( difficulty == 8'b00000010 )
                    loop_time <= 30'd150000000;    // 1.5s
                else if( difficulty == 8'b00000100 )
                    loop_time <= 30'd120000000;    // 1.2s
                else if( difficulty == 8'b00001000 )
                    loop_time <= 30'd100000000;    // 1s
                else if( difficulty == 8'b00010000 )
                    loop_time <= 30'd80000000;     // 0.8s
                else if( difficulty == 8'b00100000 )
                    loop_time <= 30'd60000000;     // 0.6s
                else if( difficulty == 8'b01000000 )
                    loop_time <= 30'd50000000;     // 0.5s
                else if( difficulty == 8'b10000000 )
                    loop_time <= 30'd40000000;     // 0.4s
	        else
                loop_time <= 30'd0;

        // ÿ����Ϸ�ļ�ʱ��
        reg [29:0] cnt;
        reg cnt_sig;
	    always @( posedge clk or posedge rst )
	        if( rst )
	            cnt <= 30'd0;
	        else if( cnt == loop_time && |loop_time )
	            cnt <= 30'd0;
	        else if( cnt_sig )
	            cnt <= cnt + 30'b1;
	        else
	            cnt <= 30'd0;        
        
        // ��Ϸ����Ϊ25��,ÿ����������,��һ�͵������ڵ����ڶ���,�ڶ����ڵ���̽ͷ
        reg [6:0] loop_num;
        always @( posedge clk or posedge rst )
	        if( rst )
                begin
	                loop_num <= 7'd0;
                    cnt_sig <= 1'b0;
                    loop_game <= 1'b0;
                end
            else if( !cnt_sig && count_down_game && !loop_game && |loop_time)
	            cnt_sig <= 1'b1;
	        else if( loop_num == 7'd75 )
                begin
	                loop_num <= 7'd0;
                    cnt_sig <= 1'b0;
                    loop_game <= 1'b1;
                end
	        else if( cnt == loop_time && |loop_time)
	            loop_num <= loop_num + 1'b1;
            else
                loop_num <= loop_num;

        reg [2:0] rand_pos;    // ������ֵ����λ��
        reg out;    // �жϵ����Ƿ�������̽ͷ
        reg hit;    // �ж��Ƿ����е���

        // ���Ƶ������λ�õ�ģ��
        always @( posedge clk or posedge rst )
	        if( rst )
                rand_pos <= 3'd0;
	        else if( count_down_game && !loop_game )
	            case( loop_num % 3 )
                    7'd0:rand_pos <= 3'd0;
                    7'd1:
                        begin 
                            if( out && !hit && !(|rand_pos) )    // ���˵���ó�����ʱ��,����û�б��������λ��
                                    rand_pos <= ((cnt % loop_num) % 5) + 1'b1;    // α�����
                            else if( out && !hit && |rand_pos )    // ����ȷʵ��������,���һ�û�б���,����λ�ò���
                                rand_pos <= rand_pos;
                            else
                                rand_pos <= 3'd0;
                        end
                    7'd2:rand_pos <= 3'd0;
                endcase
            else
                rand_pos <= 3'd0;

        // ���Ƶ����Ƿ�����Լ��Ʒֵ�ģ��
        always @( posedge clk or posedge rst )
	        if( rst )
                begin
                    out <= 1'b0;
                    hit <= 1'b0;
                    score <= 7'd0;
                end
	        else if( count_down_game && !loop_game )    // ����ѭ����Ϸ�׶�
	            case( loop_num % 3 )
                    7'd0:begin out <= 1'b0; hit <= 1'b0; end
                    7'd1:
                        begin 
                            if( !out && !hit && !(|rand_pos) )    // ���˵���ó�����ʱ��,����û�г���
                                out <= 1'd1;
                            else if( out && !hit && |rand_pos )    // ����������,���һ�û�б���
                                begin
                                    case( hammer )
                                    5'b00001:
                                        if ( rand_pos == 3'd1 )    // ���е�����!
                                            begin
                                                out <= 1'b0;
                                                hit <= 1'b1;
                                                score <= score + 1'b1;
                                            end
                                    5'b00010:
                                        if ( rand_pos == 3'd2 )    // ���е�����!
                                            begin
                                                out <= 1'b0;
                                                hit <= 1'b1;
                                                score <= score + 1'b1;
                                            end
                                    5'b00100:
                                        if ( rand_pos == 3'd3 )    // ���е�����!
                                            begin
                                                out <= 1'b0;
                                                hit <= 1'b1;
                                                score <= score + 1'b1;
                                            end
                                    5'b01000:
                                        if ( rand_pos == 3'd4 )    // ���е�����!
                                            begin
                                                out <= 1'b0;
                                                hit <= 1'b1;
                                                score <= score + 1'b1;
                                            end
                                    5'b10000:
                                        if ( rand_pos == 3'd5 )    // ���е�����!
                                            begin
                                                out <= 1'b0;
                                                hit <= 1'b1;
                                                score <= score + 1'b1;
                                            end
                                    endcase
                                end
                        end
                    7'd2:out <= 1'b0;    // hit����LED��չʾ�������н�����ж�Ҫ��
                endcase
            else
                begin out <= 1'b0; hit <= 1'b0; end

        parameter _r = 8'hf9, _d = 8'hf7, _m = 8'hbf, _l = 8'hcf, _u = 8'hfe;    // �ֱ��Ӧ�ҡ��¡��С����ϵ�λ��

        // ���Ƶ��������ʾ��ģ��
        always @( posedge clk or posedge rst )
	        if( rst )
                begin dig_display <= 8'b00000000; seg_code_1 <= 8'b00000000; seg_code_2 <= 8'b00000000; end
	        else if( count_down_game && !loop_game )
	            case( loop_num % 3 )
                    7'd0:begin dig_display <= 8'b00000000; seg_code_1 <= 8'b00000000; seg_code_2 <= 8'b00000000; end
                    7'd1:
                        begin 
                            if( out && |rand_pos )
                                case( rand_pos )
                                    3'd1:begin dig_display <= 8'b00001111; seg_code_1 <= ~_r; seg_code_2 <= ~_r; end
                                    3'd2:begin dig_display <= 8'b11111111; seg_code_1 <= ~_d; seg_code_2 <= ~_d; end
                                    3'd3:begin dig_display <= 8'b11111111; seg_code_1 <= ~_m; seg_code_2 <= ~_m; end
                                    3'd4:begin dig_display <= 8'b11110000; seg_code_1 <= ~_l; seg_code_2 <= ~_l; end
                                    3'd5:begin dig_display <= 8'b11111111; seg_code_1 <= ~_u; seg_code_2 <= ~_u; end
                                endcase
                            else
                                begin dig_display <= 8'b00000000; seg_code_1 <= 8'b00000000; seg_code_2 <= 8'b00000000; end
                        end
                    7'd2:begin dig_display <= 8'b00000000; seg_code_1 <= 8'b00000000; seg_code_2 <= 8'b00000000; end
                endcase
            else
                begin dig_display <= 8'b00000000; seg_code_1 <= 8'b00000000; seg_code_2 <= 8'b00000000; end

        // ����LED��ʾ���е�ģ��
        always @( posedge clk or posedge rst )
	        if( rst )
                state_led_show <= 8'b00000000;
	        else if( count_down_game && !loop_game )
	            case( loop_num % 3 )
                    7'd0:state_led_show <= 8'b00000000;
                    7'd1:
                        begin 
                            if( hit )
                                state_led_show <= 8'b11111111;
                            else
                                state_led_show <= 8'b00000000;
                        end
                    7'd2:
                        begin 
                            if( hit )
                                state_led_show <= 8'b11111111;
                            else
                                state_led_show <= 8'b00000000;
                        end
                endcase
            else
                state_led_show <= 8'b00000000;
endmodule