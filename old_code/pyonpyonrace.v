// Part 2 skeleton

module pyonpyonrace
	(
		CLOCK_50,						
      KEY,
      SW,
		HEX0, HEX1, HEX4, HEX5, HEX6, HEX7,

		VGA_CLK,   						
		VGA_HS,							
		VGA_VS,						
		VGA_BLANK_N,					
		VGA_SYNC_N,					
		VGA_R,   					
		VGA_G,	 						
		VGA_B   						
	);

	input			CLOCK_50;				
	input   [9:0]   SW;
	input   [3:0]   KEY;
	input   [6:0]   HEX0, HEX1, HEX4, HEX5, HEX6, HEX7;

	output			VGA_CLK;   				
	output			VGA_HS;					
	output			VGA_VS;					
	output			VGA_BLANK_N;			
	output			VGA_SYNC_N;				
	output	[9:0]	VGA_R;   				
	output	[9:0]	VGA_G;	 				
	output	[9:0]	VGA_B;   				
	
	wire resetn; // resets the board to original
	assign resetn = ~SW[1];

	wire enable; // game starts
	assign enable = SW[0];
	
	wire finish;
	wire [7:0] timer;
	wire [7:0] score1;
	wire [7:0] score2;
	wire [3:0] score11;
	wire [3:0] score12;
	wire [3:0] score21;
	wire [3:0] score22;
	
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	
	wire [3:0] Q1;
   wire [3:0] Q2;

	wire reset_en;
	wire leftone, rightone; // player one controls
	assign leftone = ~KEY[3];
	assign rightone = ~KEY[2];

	wire lefttwo, righttwo; // player two controls
	assign lefttwo = ~KEY[1];
	assign righttwo = ~KEY[0];

	vga_adapter VGA(
			.resetn(1'b1),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(1'b1),
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK)
			);
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "background.mif";
		
	control c(
		.clk(CLOCK_50),
		.resetn(resetn),
		.start(enable),
		.finish(finish)
		);
		
	datapath d(
        .clk(CLOCK_50),
        .resetn(resetn),
        .enable(enable),
        .leftone(~KEY[3]), 
        .rightone(~KEY[2]),
        .lefttwo(~KEY[1]),
        .righttwo(~KEY[0]),
        .reset_en(reset_en),
        .finish(finish),
        .x(x),
        .y(y),
        .colour(colour),
        .timer(timer),
        .score1(score1),
		    .score2(score2)
    );

    counter counter(
        .enable(enable),
        .clk_default(CLOCK_50),
        .reset_n(resetn), 
        .hex_out_one(Q1),
        .hex_out_two(Q2)
        );
		  
    process_number pnum1(
        .number(score1),
        .q0(score11),
        .q1(score12)
        );
	
	 process_number pnum2(
        .number(score2),
        .q0(score21),
        .q1(score22)
        );
		  
    dec_decoder h0(
        .dec_digit(Q1),
        .segments(HEX0)
      );
      
    dec_decoder h1(
        .dec_digit(Q2),
        .segments(HEX1)
      );

    dec_decoder h4(
        .dec_digit(score21), 
        .segments(HEX4)
        );
        
    dec_decoder h5(
        .dec_digit(score22), 
        .segments(HEX5)
        );

    dec_decoder h6(
        .dec_digit(score11),
        .segments(HEX6)
        );

    dec_decoder h7(
        .dec_digit(score12),
        .segments(HEX7)
        );
			
endmodule

module process_number(number, q0, q1);
    input [7:0] number;
    output reg [3:0] q0;
    output reg [3:0] q1;

	 always@(*) begin
		 if (number < 7'b1010)
		 begin
			  q0 <= number[3:0];
			  q1 <= 4'b0;
		 end
		 else
		 begin
			  q0 <= number % 10;
			  q1 <= number / 10;
		 end
    end
endmodule

// control
module control(
    // --- signals ---
    input clk,
    input resetn,   //reset
    input start,    //start - when the game start with SW[0] on
    input finish       // signal to end the game (getting from datapath)
    );

    reg current_state, next_state; 
    
    localparam  START           = 2'd0,
                S_LOAD_CLICK    = 2'd1,
                RESTART_WAIT    = 2'd2,
                RESTART         = 2'd3;
    
    // state table FSM
    always@(*)
    begin: state_table 
            case (current_state)
                START: next_state = (start&&~resetn) ? S_LOAD_CLICK : START; // start the game if not in reset and enter the state loop
                S_LOAD_CLICK: next_state = finish ? RESTART_WAIT : S_LOAD_CLICK; // loop in current state until game finishes
                RESTART_WAIT: next_state = resetn ? START : RESTART_WAIT; // stay until player resets game
            default: next_state = START;
        endcase
    end // state_table

    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!start) current_state <= START; // if start switch is down then start from the beginning
        else current_state <= next_state; // go to next state
    end // state_FFS
endmodule

// datapath
module datapath(
    input clk,
    input resetn,
    input enable,
    input leftone, rightone,
    input lefttwo, righttwo,
    output reg reset_en,
    output finish,
    output [7:0] x,
    output [6:0] y,
    output [2:0] colour,
    output [7:0] timer,
    output [7:0] score1,
	 output [7:0] score2
    );
	 
	 reg playernumber;
	 reg left;
	 reg right;
	 
	 always@(*) begin
		if(leftone || rightone) begin
			playernumber <= 1'b0;
			left <= leftone;
			right <= rightone;
		end
		else if (lefttwo || righttwo) begin
			playernumber <= 1'b1;
			left <= lefttwo;
			right <= righttwo;
		end
	 end

    player p12( // player one/two module
        .clk(clk),
        .resetn(resetn),
        .enable(enable),
        .left(left),
        .right(right),
        .playernumber(playernumber),
        .x(x),
        .y(y),
        .colour(colour),
        .score1(score1),
	  	  .score2(score2),
        .finish(finish));

    always@(posedge clk) begin
        if (resetn) reset_en <= 1'b1; // send reset signal if user resets
        else reset_en <= 1'b0;
    end

endmodule

module player(
    input clk,
    input resetn,
    input enable,
    input left,
	 input right,
    input playernumber,
    output reg [7:0] x,
    output reg [6:0] y,
    output reg [2:0] colour,
    output reg [7:0] score1,
	 output reg [7:0] score2,
    output reg finish
    );

    reg [4:0] state;
    reg [2:0] boxcolour;
    reg [7:0] leftx;
    reg [7:0] rightx;
	 
	 always@(*) begin
		 if(playernumber == 1'b0) begin // check if it's player one
			  boxcolour <= 3'b100; // box colour is red
			  leftx <= 8'b0010_0110; // left boxes' coordinate is 38
			  rightx <= 8'b0010_1011; // right boxes' coordinate is 43
		 end
		 else begin // otherwise it's player two
		 
			  boxcolour <= 3'b001; // box colour is blue
			  leftx <= 8'b0111_0110; // left boxes' coordinate is 118
			  rightx <= 8'b0111_1011; // right boxes' coordinate is 123
		 end
	 end
	
    always@(posedge clk) begin
        colour <= boxcolour;
    end

    always@(posedge clk) begin
	 
        if (resetn) state <= 5'd0; // before game starts
		  
        else if (enable) begin // check if game started
		  
            if (state == 5'd0) begin // this is when game first starts
                if (right) begin
                    state <= 5'd1; // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0110_0100; // 100
                end
                else if (playernumber == 1'b0)
						score1 <= score1 + 1'b1; // add to accuracy score because incorrect answer
					 else if (playernumber == 1'b1)
						score2 <= score2 + 1'b1; // add to accuracy score because incorrect answer
            end
				
            else if (state == 5'd1) begin
                if (left) begin
                    state <= 5'd2; // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0110_0001; // 97
                end
                else if (playernumber == 1'b0)
						score1 <= score1 + 1'b1; // add to accuracy score because incorrect answer
					 else if (playernumber == 1'b1)
						score2 <= score2 + 1'b1; // add to accuracy score because incorrect answer
            end
				
            else if (state == 5'd2) begin
                if (left) begin
                    state <= 5'd3; // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0101_1110; // 94
                end
                else if (playernumber == 1'b0)
						score1 <= score1 + 1'b1; // add to accuracy score because incorrect answer
					 else if (playernumber == 1'b1)
						score2 <= score2 + 1'b1; // add to accuracy score because incorrect answer
            end
				
            else if (state == 5'd3) begin
                if (right) begin
                    state <= 5'd4; // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0101_1011; // 91
                end
                else if (playernumber == 1'b0)
						score1 <= score1 + 1'b1; // add to accuracy score because incorrect answer
					 else if (playernumber == 1'b1)
						score2 <= score2 + 1'b1; // add to accuracy score because incorrect answer
            end
				
            else if (state == 5'd4) begin
                if (left) begin
                    state <= 5'd5; // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0101_1000; // 88
                end
                else if (playernumber == 1'b0)
						score1 <= score1 + 1'b1; // add to accuracy score because incorrect answer
					 else if (playernumber == 1'b1)
						score2 <= score2 + 1'b1; // add to accuracy score because incorrect answer
            end
				
            else if (state == 5'd5) begin
                if (left) begin
                    state <= 5'd6; // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0101_0101; // 85
                end
                else if (playernumber == 1'b0)
						score1 <= score1 + 1'b1; // add to accuracy score because incorrect answer
					 else if (playernumber == 1'b1)
						score2 <= score2 + 1'b1; // add to accuracy score because incorrect answer
            end
				
            else if (state == 5'd6) begin
                if (left) begin
                    state <= 5'd7; // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0101_0010; // 82
                end
                else if (playernumber == 1'b0)
						score1 <= score1 + 1'b1; // add to accuracy score because incorrect answer
					 else if (playernumber == 1'b1)
						score2 <= score2 + 1'b1; // add to accuracy score because incorrect answer
            end
				
            else if (state == 5'd7) begin
                if (right) begin
                    state <= 5'd8; // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0100_1111; // 79
                end
                else if (playernumber == 1'b0)
						score1 <= score1 + 1'b1; // add to accuracy score because incorrect answer
					 else if (playernumber == 1'b1)
						score2 <= score2 + 1'b1; // add to accuracy score because incorrect answer
            end
				
            else if (state == 5'd8) begin
                if (left) begin
                    state <= 5'd9; // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0100_1100; // 76
                end
                else if (playernumber == 1'b0)
						score1 <= score1 + 1'b1; // add to accuracy score because incorrect answer
					 else if (playernumber == 1'b1)
						score2 <= score2 + 1'b1; // add to accuracy score because incorrect answer
            end
				
            else if (state == 5'd9) begin
                if (right) begin
                    state <= 5'd10; // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0100_1001; // 73
                end
                else if (playernumber == 1'b0)
						score1 <= score1 + 1'b1; // add to accuracy score because incorrect answer
					 else if (playernumber == 1'b1)
						score2 <= score2 + 1'b1; // add to accuracy score because incorrect answer
            end
				
            else if (state == 5'd10) begin
                if (right) begin
                    state <= 5'd11; // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0100_0110; // 70
                end
                else if (playernumber == 1'b0)
						score1 <= score1 + 1'b1; // add to accuracy score because incorrect answer
					 else if (playernumber == 1'b1)
						score2 <= score2 + 1'b1; // add to accuracy score because incorrect answer
            end
				
            else if (state == 5'd11) begin
                if (left) begin
                    state <= 5'd12; // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0100_0011; // 67
                end
                else if (playernumber == 1'b0)
						score1 <= score1 + 1'b1; // add to accuracy score because incorrect answer
					 else if (playernumber == 1'b1)
						score2 <= score2 + 1'b1; // add to accuracy score because incorrect answer
            end
				
            else if (state == 5'd12) begin
                if (right) begin
                    state <= 5'd13; // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0100_0000; // 64
                end
                else if (playernumber == 1'b0)
						score1 <= score1 + 1'b1; // add to accuracy score because incorrect answer
					 else if (playernumber == 1'b1)
						score2 <= score2 + 1'b1; // add to accuracy score because incorrect answer
            end
				
            else if (state == 5'd13) begin
                if (left) begin
                    state <= 5'd14; // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0011_1101; // 61
                end
                else if (playernumber == 1'b0)
						score1 <= score1 + 1'b1; // add to accuracy score because incorrect answer
					 else if (playernumber == 1'b1)
						score2 <= score2 + 1'b1; // add to accuracy score because incorrect answer
            end
				
            else if (state == 5'd14) begin
                if (left) begin
                    state <= 5'd15; // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0011_1010; // 58
                end
                else if (playernumber == 1'b0)
						score1 <= score1 + 1'b1; // add to accuracy score because incorrect answer
					 else if (playernumber == 1'b1)
						score2 <= score2 + 1'b1; // add to accuracy score because incorrect answer
            end
				
            else if (state == 5'd15) begin
                if (right) begin
                    state <= 5'd16; // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0011_0111; // 55
                end
                else if (playernumber == 1'b0)
						score1 <= score1 + 1'b1; // add to accuracy score because incorrect answer
					 else if (playernumber == 1'b1)
						score2 <= score2 + 1'b1; // add to accuracy score because incorrect answer
            end
				
            else if (state == 5'd16) begin
                if (right) begin
                    state <= 5'd17; // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0011_0100; // 52
                end
                else if (playernumber == 1'b0)
						score1 <= score1 + 1'b1; // add to accuracy score because incorrect answer
					 else if (playernumber == 1'b1)
						score2 <= score2 + 1'b1; // add to accuracy score because incorrect answer
            end

            else if (state == 5'd17) begin
                if (left) begin
                    state <= 5'd18; // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0011_0001; // 49
                end
                else if (playernumber == 1'b0)
						score1 <= score1 + 1'b1; // add to accuracy score because incorrect answer
					 else if (playernumber == 1'b1)
						score2 <= score2 + 1'b1; // add to accuracy score because incorrect answer
            end
				
            else if (state == 5'd18) begin
                if (right) begin
                    state <= 5'd19; // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0010_1110; // 46
                end
                else if (playernumber == 1'b0)
						score1 <= score1 + 1'b1; // add to accuracy score because incorrect answer
					 else if (playernumber == 1'b1)
						score2 <= score2 + 1'b1; // add to accuracy score because incorrect answer
            end
				
            else if (state == 5'd19) begin
                if (right) begin
                    state <= 5'd20; // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0010_1011; // 43
                end
                else if (playernumber == 1'b0)
						score1 <= score1 + 1'b1; // add to accuracy score because incorrect answer
					 else if (playernumber == 1'b1)
						score2 <= score2 + 1'b1; // add to accuracy score because incorrect answer
            end
				
            else if (state == 5'd20) begin
                if (right) begin
                    state <= 5'd21; // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0010_1000; // 40
                end
                else if (playernumber == 1'b0)
						score1 <= score1 + 1'b1; // add to accuracy score because incorrect answer
					 else if (playernumber == 1'b1)
						score2 <= score2 + 1'b1; // add to accuracy score because incorrect answer
            end
				
            else if (state == 5'd21) begin
                if (left) begin
                    state <= 5'd22; // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0010_0101; // 37
                end
                else if (playernumber == 1'b0)
						score1 <= score1 + 1'b1; // add to accuracy score because incorrect answer
					 else if (playernumber == 1'b1)
						score2 <= score2 + 1'b1; // add to accuracy score because incorrect answer
            end
				
            else if (state == 5'd22) begin
                if (right) begin
                    state <= 5'd23; // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0010_0010; // 34
                end
                else if (playernumber == 1'b0)
						score1 <= score1 + 1'b1; // add to accuracy score because incorrect answer
					 else if (playernumber == 1'b1)
						score2 <= score2 + 1'b1; // add to accuracy score because incorrect answer
            end
				
            else if (state == 5'd23) begin
                if (left) begin
                    state <= 5'd24; // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0001_1111; // 31
                end
                else if (playernumber == 1'b0)
						score1 <= score1 + 1'b1; // add to accuracy score because incorrect answer
					 else if (playernumber == 1'b1)
						score2 <= score2 + 1'b1; // add to accuracy score because incorrect answer
            end
				
            else if (state == 5'd24) begin
                if (right) begin
                    state <= 5'd25; // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0001_1100; // 28
                end
                else if (playernumber == 1'b0)
						score1 <= score1 + 1'b1; // add to accuracy score because incorrect answer
					 else if (playernumber == 1'b1)
						score2 <= score2 + 1'b1; // add to accuracy score because incorrect answer
            end
				
            else if (state == 5'd25) begin
                if (left) begin
                    state <= 5'd26; // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0001_1001; // 25
                end
                else if (playernumber == 1'b0)
						score1 <= score1 + 1'b1; // add to accuracy score because incorrect answer
					 else if (playernumber == 1'b1)
						score2 <= score2 + 1'b1; // add to accuracy score because incorrect answer
            end
				
            else if (state == 5'd26) begin
                if (left) begin
                    state <= 5'd27; // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0001_0110; // 22
                end
                else if (playernumber == 1'b0)
						score1 <= score1 + 1'b1; // add to accuracy score because incorrect answer
					 else if (playernumber == 1'b1)
						score2 <= score2 + 1'b1; // add to accuracy score because incorrect answer
            end
				
            else if (state == 5'd27) begin
                if (left) begin
                    state <= 5'd28; // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0001_0011; // 19
                end
                else if (playernumber == 1'b0)
						score1 <= score1 + 1'b1; // add to accuracy score because incorrect answer
					 else if (playernumber == 1'b1)
						score2 <= score2 + 1'b1; // add to accuracy score because incorrect answer
            end
				
            else if (state == 5'd28) begin
                if (right) begin
                    state <= 5'd29; // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0010_0000; // 16
                end
                else if (playernumber == 1'b0)
						score1 <= score1 + 1'b1; // add to accuracy score because incorrect answer
					 else if (playernumber == 1'b1)
						score2 <= score2 + 1'b1; // add to accuracy score because incorrect answer
            end
				
            else if (state == 5'd29) begin
                if (left) begin
                    state <= 5'd30; // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0000_1101; // 13
                end
                else if (playernumber == 1'b0)
						score1 <= score1 + 1'b1; // add to accuracy score because incorrect answer
					 else if (playernumber == 1'b1)
						score2 <= score2 + 1'b1; // add to accuracy score because incorrect answer
            end
				
            else if (state == 5'd30) begin
                if (right) begin
                    state <= 5'd31; // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0000_1010; // 10
                end
                else if (playernumber == 1'b0)
						score1 <= score1 + 1'b1; // add to accuracy score because incorrect answer
					 else if (playernumber == 1'b1)
						score2 <= score2 + 1'b1; // add to accuracy score because incorrect answer
            end
				
            else if (state == 5'd31) begin
                if (right) begin
                    state <= 5'd32; // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0000_0111; // 7
                end
                else if (playernumber == 1'b0)
						score1 <= score1 + 1'b1; // add to accuracy score because incorrect answer
					 else if (playernumber == 1'b1)
						score2 <= score2 + 1'b1; // add to accuracy score because incorrect answer
            end
				
            else if (state == 5'd32) begin
                if (left) begin
                    // draw in box
                    x <= leftx;
                    y <= 8'b0000_0100; // 4
                    // check the player reach the top
                    finish <= 1'b1;
                end
                else if (playernumber == 1'b0)
						score1 <= score1 + 1'b1; // add to accuracy score because incorrect answer
					 else if (playernumber == 1'b1)
						score2 <= score2 + 1'b1; // add to accuracy score because incorrect answer
            end
				
        end
	 end

endmodule


module counter(enable, clk_default, reset_n, hex_out_one, hex_out_two);
  input enable; // signal given from user to allow clocks to continue counting
  input clk_default; // normal 50mz clock speed given from de2 board
  input reset_n; // reset signal given from user to reset values of clocks
  output [3:0] hex_out_one; // output of counter based on clock preferences (first digit)
  output [3:0] hex_out_two; // output of counter based on clock (second digit)
  
  reg display_counter_enable; // select this based on the period of the rate dividers
  
  wire [27:0] rd_1hz_out; // store value of the output
  
  rate_divider rd_1hz(
    .enable(enable),
    .countdown_start(28'b10111110101111000001111111), // 49,999,999 in decimal
    .clock(clk_default),
    .reset_n(reset_n),
    .q(rd_1hz_out)
  );

  // give enable value whenever the rd_1hz_out is countdown to 0
  always @(*)
  begin
    display_counter_enable = (rd_1hz_out == 28'b0) ? 1 : 0;    // 1 Hz, approx 1 second
  end
  
  // this is being shown to the user at the 1Hz speed
  display_counter display(
    .enable(display_counter_enable),
    .reset_n(reset_n),
    .clock(clk_default),
    .q0(hex_out_one),
    .q1(hex_out_two)
  );  
  
endmodule

module rate_divider(enable, countdown_start, clock, reset_n, q);
  input enable; // enable signal given from user
  input reset_n; // reset signal given by user
  input clock; // clock signal given from CLOCK_50
  input [27:0]countdown_start; // value that this counter should start counting down from
  output reg [27:0]q; // output register we're outputting current count for this rate divider

  // start counting down from count_down_start all the way to 0
  always @(posedge clock)
  begin
    if(reset_n == 1'b0) // when clear_b is 0
      q <= countdown_start;
    else if(enable == 1'b1) // decrement q only when enable is high
    q <= (q == 0) ? countdown_start : q - 1'b1; // if we get to 0, then we loop back
  end
  
endmodule


module display_counter(enable, reset_n, clock, q0, q1);
  input enable; // one bit enable signal given from rate dividers
  input reset_n; // reset signal given from user
  input clock; // normal 50mhz speed given from de2 board
  output reg [3:0]q0; // 4 bit value to do counting on (in this case hex0)
  output reg [3:0]q1; // 4 bit value to do counting on (in theis case hex1)
  
  // asynchrnously handle reset_n signals
  always @(posedge clock)
  begin
    if(reset_n == 1'b0)
    begin
      q0 <= 4'b0000;
      q1 <= 4'b0000;
    end
    else if(enable == 1'b1)
    begin
      if (q0 == 4'b1001) // if first digit is 9, go back to zero (X9->X0)
      begin
        q0 <= 0;
        if (q1 == 4'b1001) // if the second digit is 9, go back to zero (99->00)
          q1 <= 0;
        else
          q1 <= q1 + 1'b1; // else just add one to the second digit (19->20)
      end
      else
        q0 <= q0 + 1'b1; // plus one if q0 (first digit is not 9)
    end
  end

endmodule

module dec_decoder(dec_digit, segments);
   input [3:0] dec_digit;
   output reg [6:0] segments;
   always @(*)
     case (dec_digit)
       4'h0: segments = 7'b100_0000;
       4'h1: segments = 7'b111_1001;
       4'h2: segments = 7'b010_0100;
       4'h3: segments = 7'b011_0000;
       4'h4: segments = 7'b001_1001;
       4'h5: segments = 7'b001_0010;
       4'h6: segments = 7'b000_0010;
       4'h7: segments = 7'b111_1000;
       4'h8: segments = 7'b000_0000;
       4'h9: segments = 7'b001_0000; //orignal code: 7'b001_1000
       default: segments = 7'h7f;
     endcase
endmodule



/*module reset(
	input clk,
	input reset_en,
	output reg [7:0] x,
	output reg [6:0] y,
	output reg [2:0] colour
	);
	reg [3:0] curr, next;
	localparam 	D0 = 7'd0,
				D1 = 7'd1,
				D2 = 7'd2,
				D3 = 7'd3,
				D4 = 7'd4,
				D5 = 7'd5,
				D6 = 7'd6,
				D7 = 7'd7,
				D8 = 7'd8,
				D9 = 7'd9,
				D10 = 7'd10,
				D11 = 7'd11,
				D12 = 7'd12,
				D13 = 7'd13,
				D14 = 7'd14,
				D15 = 7'd15,
				D16 = 7'd16,
				D17 = 7'd17,
				D18 = 7'd18,
				D19 = 7'd19,
				D20 = 7'd20,
				D21 = 7'd21,
				D22 = 7'd22,
				D23 = 7'd23,
				D24 = 7'd24,
				D25 = 7'd25,
				D26 = 7'd26,
				D27 = 7'd27,
				D28 = 7'd28,
				D29 = 7'd29,
				D30 = 7'd30,
				D31 = 7'd31,
				D32 = 7'd32,
				D33 = 7'd33,
				D34 = 7'd34,
				D35 = 7'd35,
				D36 = 7'd36,
				D37 = 7'd37,
				D38 = 7'd38,
				D39 = 7'd39,
				D40 = 7'd40,
				D41 = 7'd41,
				D42 = 7'd42,
				D43 = 7'd43,
				D44 = 7'd44,
				D45 = 7'd45,
				D46 = 7'd46,
				D47 = 7'd47,
				D48 = 7'd48,
				D49 = 7'd49,
				D50 = 7'd50,
				D51 = 7'd51,
				D52 = 7'd52,
				D53 = 7'd53,
				D54 = 7'd54,
				D55 = 7'd55,
				D56 = 7'd56,
				D57 = 7'd57,
				D58 = 7'd58,
				D59 = 7'd59,
				D60 = 7'd60,
				D61 = 7'd61,
				D62 = 7'd62,
				D63 = 7'd63,
				D64 = 7'd64,
				D65 = 7'd65,
				WAIT = 7'd66;
	always@(posedge clk) begin: state_table
		case(curr)
			WAIT: next = reset_en ? D0 : WAIT; // stay in wait mode until we need to reset the colour of the boxes
			D0: next = D1;
			D1: next = D2;
			D2: next = D3;
			D3: next = D4;
			D4: next = D5;
			D5: next = D6;
			D6: next = D7;
			D7: next = D8;
			D8: next = D9;
			D9: next = D10;
			D10: next = D11;
			D11: next = D12;
			D12: next = D13;
			D13: next = D14;
			D14: next = D15;
			D15: next = D16;
			D16: next = D17;
			D17: next = D18;
			D18: next = D19;
			D19: next = D20;
			D20: next = D21;
			D21: next = D22;
			D22: next = D23;
			D23: next = D24;
			D24: next = D25;
			D25: next = D26;
			D26: next = D27;
			D27: next = D28;
			D28: next = D29;
			D29: next = D30;
			D30: next = D31;
			D31: next = D32;
			D32: next = D33;
			D33: next = D34;
			D34: next = D35;
			D35: next = D36;
			D36: next = D37;
			D37: next = D38;
			D38: next = D39;
			D39: next = D40;
			D40: next = D41;
			D41: next = D42;
			D42: next = D43;
			D43: next = D44;
			D44: next = D45;
			D45: next = D46;
			D46: next = D47;
			D47: next = D48;
			D48: next = D49;
			D49: next = D50;
			D50: next = D51;
			D51: next = D52;
			D52: next = D53;
			D53: next = D54;
			D54: next = D55;
			D55: next = D56;
			D56: next = D57;
			D57: next = D58;
			D58: next = D59;
			D59: next = D60;
			D60: next = D61;
			D61: next = D62;
			D62: next = D63;
			D63: next = D64;
			D64: next = D65;
			D65: next = WAIT;
			default: next = WAIT;
		endcase
	end
	// get the boxes to reset to white
	always@(*) begin
		case(curr)
			D0: begin // return left side of player one to original state
				x <= 8'b0010_0110; // 38
				y <= 8'b0000_0100; // 4
			end
			D1: begin
				x <= 8'b0010_0110; // 38
				y <= 8'b0000_1101; // 13
			end
			D2: begin
				x <= 8'b0010_0110; // 38
				y <= 8'b0001_0011; // 19
			end
			D3: begin
				x <= 8'b0010_0110; // 38
				y <= 8'b0001_0110; // 22
			end
			D4: begin
				x <= 8'b0010_0110; // 38
				y <= 8'b0001_1001; // 25
			end
			D5: begin
				x <= 8'b0010_0110; // 38
				y <= 8'b0001_1111; // 31
			end
			D6: begin
				x <= 8'b0010_0110; // 38
				y <= 8'b0010_0101; // 37
			end
			D7: begin
				x <= 8'b0010_0110; // 38
				y <= 8'b0011_0001; // 49
			end
			D8: begin
				x <= 8'b0010_0110; // 38
				y <= 8'b0011_1010; // 58
			end
			D9: begin
				x <= 8'b0010_0110; // 38
				y <= 8'b0011_1101; // 61
			end
			D10: begin
				x <= 8'b0010_0110; // 38
				y <= 8'b0100_0011; // 67
			end
			D11: begin
				x <= 8'b0010_0110; // 38
				y <= 8'b0100_1100; // 76
			end
			D12: begin
				x <= 8'b0010_0110; // 38
				y <= 8'b0101_0010; // 82
			end
			D13: begin
				x <= 8'b0010_0110; // 38
				y <= 8'b0101_0101; // 85
			end
			D14: begin
				x <= 8'b0010_0110; // 38
				y <= 8'b0101_1000; // 88
			end
			D15: begin
				x <= 8'b0010_0110; // 38
				y <= 8'b0101_1110; // 94
			end
			D16: begin
				x <= 8'b0010_0110; // 38
				y <= 8'b0110_0001; // 97
			end
			D17: begin // return right side of player one to original state
				x <= 8'b0010_1011; // 43
				y <= 8'b0000_0111; // 7
			end
			D18: begin
				x <= 8'b0010_1011; // 43
				y <= 8'b0000_1010; // 10
			end
			D19: begin
				x <= 8'b0010_1011; // 43
				y <= 8'b0010_0000; // 16
			end
			D20: begin
				x <= 8'b0010_1011; // 43
				y <= 8'b0001_1100; // 28
			end
			D21: begin
				x <= 8'b0010_1011; // 43
				y <= 8'b0010_0010; // 34
			end
			D22: begin
				x <= 8'b0010_1011; // 43
				y <= 8'b0010_1000; // 40
			end
			D23: begin
				x <= 8'b0010_1011; // 43
				y <= 8'b0010_1011; // 43
			end
			D24: begin
				x <= 8'b0010_1011; // 43
				y <= 8'b0010_1110; // 46
			end
			D25: begin
				x <= 8'b0010_1011; // 43
				y <= 8'b0011_0100; // 52
			end
			D26: begin
				x <= 8'b0010_1011; // 43
				y <= 8'b0011_0111; // 55
			end
			D27: begin
				x <= 8'b0010_1011; // 43
				y <= 8'b0100_0000; // 64
			end
			D28: begin
				x <= 8'b0010_1011; // 43
				y <= 8'b0100_0110; // 70
			end
			D29: begin
				x <= 8'b0010_1011; // 43
				y <= 8'b0100_1001; // 73
			end
			D30: begin
				x <= 8'b0010_1011; // 43
				y <= 8'b0100_1111; // 79
			end
			D31: begin
				x <= 8'b0010_1011; // 43
				y <= 8'b0101_1011; // 91
			end
			D32: begin
				x <= 8'b0010_1011; // 43
				y <= 8'b0110_0100; // 100
			end
			D33: begin // return left side of player two to original state
				x <= 8'b0111_0110; // 118
				y <= 8'b0000_0100; // 4
			end
			D34: begin
				x <= 8'b0111_0110; // 118
				y <= 8'b0000_1101; // 13
			end
			D35: begin
				x <= 8'b0111_0110; // 118
				y <= 8'b0001_0011; // 19
			end
			D36: begin
				x <= 8'b0111_0110; // 118
				y <= 8'b0001_0110; // 22
			end
			D37: begin
				x <= 8'b0111_0110; // 118
				y <= 8'b0001_1001; // 25
			end
			D38: begin
				x <= 8'b0111_0110; // 118
				y <= 8'b0001_1111; // 31
			end
			D39: begin
				x <= 8'b0111_0110; // 118
				y <= 8'b0010_0101; // 37
			end
			D40: begin
				x <= 8'b0111_0110; // 118
				y <= 8'b0011_0001; // 49
			end
			D41: begin
				x <= 8'b0111_0110; // 118
				y <= 8'b0011_1010; // 58
			end
			D42: begin
				x <= 8'b0111_0110; // 118
				y <= 8'b0011_1101; // 61
			end
			D43: begin
				x <= 8'b0111_0110; // 118
				y <= 8'b0100_0011; // 67
			end
			D44: begin
				x <= 8'b0111_0110; // 118
				y <= 8'b0100_1100; // 76
			end
			D45: begin
				x <= 8'b0111_0110; // 118
				y <= 8'b0101_0010; // 82
			end
			D46: begin
				x <= 8'b0111_0110; // 118
				y <= 8'b0101_0101; // 85
			end
			D47: begin
				x <= 8'b0111_0110; // 118
				y <= 8'b0101_1000; // 88
			end
			D48: begin
				x <= 8'b0111_0110; // 118
				y <= 8'b0101_1110; // 94
			end
			D49: begin
				x <= 8'b0111_0110; // 118
				y <= 8'b0110_0001; // 97
			end
			D50: begin // return right side of player two to original state
				x <= 8'b0111_1011; // 123
				y <= 8'b0000_0111; // 7
			end
			D51: begin
				x <= 8'b0111_1011; // 123
				y <= 8'b0000_1010; // 10
			end
			D52: begin
				x <= 8'b0111_1011; // 123
				y <= 8'b0010_0000; // 16
			end
			D53: begin
				x <= 8'b0111_1011; // 123
				y <= 8'b0001_1100; // 28
			end
			D54: begin
				x <= 8'b0111_1011; // 123
				y <= 8'b0010_0010; // 34
			end
			D55: begin
				x <= 8'b0111_1011; // 123
				y <= 8'b0010_1000; // 40
			end
			D56: begin
				x <= 8'b0111_1011; // 123
				y <= 8'b0010_1011; // 43
			end
			D57: begin
				x <= 8'b0111_1011; // 123
				y <= 8'b0010_1110; // 46
			end
			D58: begin
				x <= 8'b0111_1011; // 123
				y <= 8'b0011_0100; // 52
			end
			D59: begin
				x <= 8'b0111_1011; // 123
				y <= 8'b0011_0111; // 55
			end
			D60: begin
				x <= 8'b0111_1011; // 123
				y <= 8'b0100_0000; // 64
			end
			D61: begin
				x <= 8'b0111_1011; // 123
				y <= 8'b0100_0110; // 70
			end
			D62: begin
				x <= 8'b0111_1011; // 123
				y <= 8'b0100_1001; // 73
			end
			D63: begin
				x <= 8'b0111_1011; // 123
				y <= 8'b0100_1111; // 79
			end
			D64: begin
				x <= 8'b0111_1011; // 123
				y <= 8'b0101_1011; // 91
			end
			D65: begin
				x <= 8'b0111_1011; // 123
				y <= 8'b0110_0100; // 100
			end
		endcase
	end
	always@(*) begin
		if (reset_en) colour <= 3'b000;
	end
	
	always@(*) begin
		if (!reset_en) curr <= WAIT;
		else curr <= next;
	end
endmodule*/

// control

// draw 3x3 square
/*module draw(
	input clk,
	input resetn,
	input go,
	output reg [1:0] xoff,
	output reg [1:0] yoff
	);
	reg [3:0] curr, next;
	localparam 	D0 = 3'd0;
				D1 = 3'd1;
				D2 = 3'd2;
				D3 = 3'd3;
				D4 = 3'd4;
				D5 = 3'd5;
				D6 = 3'd6;
				D7 = 3'd7;
				D8 = 3'd8;
				WAIT = 3'd10;
	always@(posedge clk) begin: state_table
		case(curr)
			WAIT: next = go ? D0 : WAIT; // stay in wait mode until we need the offset for the box
			D0: next = D1;
			D1: next = D2;
			D2: next = D3;
			D3: next = D4;
			D4: next = D5;
			D5: next = D6;
			D6: next = D7;
			D7: next = D8;
			D8: next = WAIT;
			default: WAIT;
		endcase
	end
	// get the offset for the box
	always@(*) begin
		case(curr)
			D0: begin // normal coordinates
				xoff <= 2'b00;
				yoff <= 2'b00;
			end
			D1: begin // go one down
				xoff <= 2'b00;
				yoff <= 2'b01;
			end
			D2: begin // go two down
				xoff <= 2'b00;
				yoff <= 2'b10;
			end
			D3: begin // go one across
				xoff <= 2'b01;
				yoff <= 2'b00;
			end
			D4: begin // go two across
				xoff <= 2'b10;
				yoff <= 2'b00;
			end
			D5: begin // go one down, one across
				xoff <= 2'b01;
				yoff <= 2'b01;
			end
			D6: begin // go two down, one across
				xoff <= 2'b01;
				yoff <= 2'b10;
			end
			D7: begin // go one down, two across
				xoff <= 2'b10;
				yoff <= 2'b01;
			end
			D8: begin // go two down, two across
				xoff <= 2'b10;
				yoff <= 2'b10;
			end
			default: begin
				xoff <= 2'b00;
				yoff <= 2'b00;
			end
		endcase
	end
endmodule*/

// reset
/* right now this just changes the top left corner of the box to white. i'll have to
figure out a shorter way to reset the board to its original mode rather than writing
500+ lines of code*/
/*module reset(
	input clk,
	input reset_en,
	output reg [7:0] x,
	output reg [6:0] y,
	output reg [2:0] colour
	);
	always@(posedge clk) begin
		if (reset_en) begin
			// if reset is switched then we have to return the board to its original state
			colour <= 3'b111;
			// first return left side of player one to original state
			x <= 8'b0010_0101; // 37
			y <= 8'b0000_0011; // 3
			y <= 8'b0000_1100; // 12
			y <= 8'b0001_0010; // 18
			y <= 8'b0001_0101; // 21
			y <= 8'b0001_1000; // 24
			y <= 8'b0001_1110; // 30
			y <= 8'b0010_0100; // 36
			y <= 8'b0011_0000; // 48
			y <= 8'b0011_1001; // 57
			y <= 8'b0100_0010; // 66
			y <= 8'b0100_1011; // 75
			y <= 8'b0101_0001; // 81
			y <= 8'b0101_0100; // 84
			y <= 8'b0101_0111; // 87
			y <= 8'b0101_1101; // 93
			y <= 8'b0110_0000; // 96
			// return right side of player one to original state
			x <= 8'b0010_1010; // 42
			y <= 8'b0000_0110; // 6
			y <= 8'b0000_1001; // 9
			y <= 8'b0001_1111; // 15
			y <= 8'b0001_1011; // 27
			y <= 8'b0010_0001; // 33
			y <= 8'b0010_0111; // 39
			y <= 8'b0010_1010; // 42
			y <= 8'b0010_1101; // 45
			y <= 8'b0011_0011; // 51
			y <= 8'b0011_0110; // 54
			y <= 8'b0011_1111; // 63
			y <= 8'b0100_0110; // 70
			y <= 8'b0100_1000; // 72
			y <= 8'b0100_1110; // 78
			y <= 8'b0101_1010; // 90
			y <= 8'b0110_0011; // 99
			// return left side of player two to original state
			x <= 8'b0111_0101; // 117
			y <= 8'b0000_0011; // 3
			y <= 8'b0000_1100; // 12
			y <= 8'b0001_0010; // 18
			y <= 8'b0001_0101; // 21
			y <= 8'b0001_1000; // 24
			y <= 8'b0001_1110; // 30
			y <= 8'b0010_0100; // 36
			y <= 8'b0011_0000; // 48
			y <= 8'b0011_1001; // 57
			y <= 8'b0100_0010; // 66
			y <= 8'b0100_1011; // 75
			y <= 8'b0101_0001; // 81
			y <= 8'b0101_0100; // 84
			y <= 8'b0101_0111; // 87
			y <= 8'b0101_1101; // 93
			y <= 8'b0110_0000; // 96
			// return right side of player two to original state
			x <= 8'b0111_1010; // 122
			y <= 8'b0000_0110; // 6
			y <= 8'b0000_1001; // 9
			y <= 8'b0001_1111; // 15
			y <= 8'b0001_1011; // 27
			y <= 8'b0010_0001; // 33
			y <= 8'b0010_0111; // 39
			y <= 8'b0010_1010; // 42
			y <= 8'b0010_1101; // 45
			y <= 8'b0011_0011; // 51
			y <= 8'b0011_0110; // 54
			y <= 8'b0011_1111; // 63
			y <= 8'b0100_0110; // 70
			y <= 8'b0100_1000; // 72
			y <= 8'b0100_1110; // 78
			y <= 8'b0101_1010; // 90
			y <= 8'b0110_0011; // 99
		end
	end
endmodule*/
