// Part 2 skeleton

module pyonpyonrace
	(
		CLOCK_50,						
        KEY,
        SW,
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
	
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;

	wire leftone, rightone; // player one controls
	assign leftone = ~KEY[3];
	assign rightone = ~KEY[2];

	wire lefttwo, righttwo; // player two controls
	assign lefttwo = ~KEY[1];
	assign righttwo = ~KEY[0];

	vga_adapter VGA(
			.resetn(resetn),
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
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "background.mif";
			
endmodule

// datapath
module datapath(
	input clk,
	input resetn,
	input enable,
	input leftone, rightone,
	input lefttwo, righttwo,
	output reset_en,
	output reg [7:0] x,
	output reg [6:0] y,
	output reg [2:0] colour,
	output reg [7:0] time,
	output reg [7:0] scoreone,
	output reg [7:0] scoretwo
	);

	player p1( // to fill in
		.clk
		.resetn
		.enable
		.left
		.right
		.end
		.x
		.y
		.colour
		.score)

	always@(posedge clk) begin
		if (resetn) reset_en <= 1'b1;
		else reset_en <= 1'b0;
	end

endmodule

module player(
	input clk,
	input resetn,
	input enable,
	input left, right,
	output end,
	output reg [7:0] x,
	output reg [6:0] y,
	output reg [2:0] colour,
	output reg [7:0] score
	);

	reg [4:0] state

	always@(posedge clk) begin
		if (resetn) state <= 5'd0; // before game starts
		else if (enable) begin // check if game started
			if (state == 5'd0) begin // this is when game first starts
				if (right) begin
					state <= 5'd1 // go to next box because correct answer
					// draw in box
				end
				else score <= score + 1'b1 // add to accuracy score because incorrect answer
			end
			else if (state == 5'd1) begin
				if (left) begin
					state <= 5'd2 // go to next box because correct answer
					// draw in box
				end
				else score <= score + 1'b1 // add to accuracy score because incorrect answer
			end
		end
	end

endmodule

// control

// draw 3x3 square
module draw(
	input clk,
	input resetn,
	input go,
	output reg [1:0] xoff,
	output reg [1:0] yoff,
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

endmodule

// reset
/* right now this just changes the top left corner of the box to white. i'll have to
figure out a shorter way to reset the board to its original mode rather than writing
500+ lines of code*/
module reset(
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

endmodule
