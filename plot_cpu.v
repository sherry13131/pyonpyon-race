module plot(
	input clk,
	input enable,
	input reset_en,
	output reg [7:0] x,
	output reg [6:0] y,
	output reg [2:0] colour
	);

	reg [6:0] curr, next;

	localparam 	D33 = 7'd33,
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
				WAIT = 7'd66,
				WAIT_RESET = 7'd67;

	always@(posedge clk) begin: state_table
		case(curr)
			WAIT: next = enable ? D33 : WAIT; // stay in wait mode until we need to plot the colour of the boxes
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
			D65: next = WAIT_RESET;
			WAIT_RESET: next = reset_en ? WAIT : WAIT_RESET; // stay here until player resets
			default: next = WAIT;
		endcase
	end

	// get the boxes to plot to blue
	always@(*) begin
		case(curr)
			D33: begin // return left side of player two to original state
				x <= 8'b0111_0110; // 118
				y <= 7'b000_0100; // 4
			end
			D34: begin
				x <= 8'b0111_0110; // 118
				y <= 7'b000_1101; // 13
			end
			D35: begin
				x <= 8'b0111_0110; // 118
				y <= 7'b001_0011; // 19
			end
			D36: begin
				x <= 8'b0111_0110; // 118
				y <= 7'b001_0110; // 22
			end
			D37: begin
				x <= 8'b0111_0110; // 118
				y <= 7'b001_1001; // 25
			end
			D38: begin
				x <= 8'b0111_0110; // 118
				y <= 7'b001_1111; // 31
			end
			D39: begin
				x <= 8'b0111_0110; // 118
				y <= 7'b010_0101; // 37
			end
			D40: begin
				x <= 8'b0111_0110; // 118
				y <= 7'b011_0001; // 49
			end
			D41: begin
				x <= 8'b0111_0110; // 118
				y <= 7'b011_1010; // 58
			end
			D42: begin
				x <= 8'b0111_0110; // 118
				y <= 7'b011_1101; // 61
			end
			D43: begin
				x <= 8'b0111_0110; // 118
				y <= 7'b100_0011; // 67
			end
			D44: begin
				x <= 8'b0111_0110; // 118
				y <= 7'b100_1100; // 76
			end
			D45: begin
				x <= 8'b0111_0110; // 118
				y <= 7'b101_0010; // 82
			end
			D46: begin
				x <= 8'b0111_0110; // 118
				y <= 7'b101_0101; // 85
			end
			D47: begin
				x <= 8'b0111_0110; // 118
				y <= 7'b101_1000; // 88
			end
			D48: begin
				x <= 8'b0111_0110; // 118
				y <= 7'b101_1110; // 94
			end
			D49: begin
				x <= 8'b0111_0110; // 118
				y <= 7'b110_0001; // 97
			end
			D50: begin // return right side of player two to original state
				x <= 8'b0111_1011; // 123
				y <= 7'b000_0111; // 7
			end
			D51: begin
				x <= 8'b0111_1011; // 123
				y <= 7'b000_1010; // 10
			end
			D52: begin
				x <= 8'b0111_1011; // 123
				y <= 7'b010_0000; // 16
			end
			D53: begin
				x <= 8'b0111_1011; // 123
				y <= 7'b001_1100; // 28
			end
			D54: begin
				x <= 8'b0111_1011; // 123
				y <= 7'b010_0010; // 34
			end
			D55: begin
				x <= 8'b0111_1011; // 123
				y <= 7'b010_1000; // 40
			end
			D56: begin
				x <= 8'b0111_1011; // 123
				y <= 7'b010_1011; // 43
			end
			D57: begin
				x <= 8'b0111_1011; // 123
				y <= 7'b010_1110; // 46
			end
			D58: begin
				x <= 8'b0111_1011; // 123
				y <= 7'b011_0100; // 52
			end
			D59: begin
				x <= 8'b0111_1011; // 123
				y <= 7'b011_0111; // 55
			end
			D60: begin
				x <= 8'b0111_1011; // 123
				y <= 7'b100_0000; // 64
			end
			D61: begin
				x <= 8'b0111_1011; // 123
				y <= 7'b100_0110; // 70
			end
			D62: begin
				x <= 8'b0111_1011; // 123
				y <= 7'b100_1001; // 73
			end
			D63: begin
				x <= 8'b0111_1011; // 123
				y <= 7'b100_1111; // 79
			end
			D64: begin
				x <= 8'b0111_1011; // 123
				y <= 7'b101_1011; // 91
			end
			D65: begin
				x <= 8'b0111_1011; // 123
				y <= 7'b110_0100; // 100
			end
	endcase
	end

	always@(*) begin
		if (!enable) curr <= WAIT; // stay in wait if reset is off
		else begin
			curr <= next; // otherwise go to next state
			colour <= 3'b001; // colour of reset box
		end
	end

endmodule