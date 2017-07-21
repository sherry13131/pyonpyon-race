module plot_player(
	input clk,
	input enable,
	input reset_en,
	output reg [7:0] x,
	output reg [6:0] y,
	output reg [2:0] colour
	);

	reg [6:0] curr, next;

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
				WAIT = 7'd66,
				WAIT_RESET = 7'd67;

	always@(posedge clk) begin: state_table
		case(curr)
			WAIT: next = enable ? D0 : WAIT; // stay in wait mode until we need to reset the colour of the boxes
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
			D32: next = WAIT_RESET;
			WAIT_RESET: next = reset_en ? WAIT : WAIT_RESET; // stay here so that it doesn't keep cycling
			default: next = WAIT;
		endcase
	end

	// get the boxes to reset to white
	always@(*) begin
		case(curr)
			D0: begin // return left side of player one to original state
				x <= 8'b0010_0110; // 38
				y <= 7'b000_0100; // 4
			end
			D1: begin
				x <= 8'b0010_0110; // 38
				y <= 7'b000_1101; // 13
			end
			D2: begin
				x <= 8'b0010_0110; // 38
				y <= 7'b001_0011; // 19
			end
			D3: begin
				x <= 8'b0010_0110; // 38
				y <= 7'b001_0110; // 22
			end
			D4: begin
				x <= 8'b0010_0110; // 38
				y <= 7'b001_1001; // 25
			end
			D5: begin
				x <= 8'b0010_0110; // 38
				y <= 7'b001_1111; // 31
			end
			D6: begin
				x <= 8'b0010_0110; // 38
				y <= 7'b010_0101; // 37
			end
			D7: begin
				x <= 8'b0010_0110; // 38
				y <= 7'b011_0001; // 49
			end
			D8: begin
				x <= 8'b0010_0110; // 38
				y <= 7'b011_1010; // 58
			end
			D9: begin
				x <= 8'b0010_0110; // 38
				y <= 7'b011_1101; // 61
			end
			D10: begin
				x <= 8'b0010_0110; // 38
				y <= 7'b100_0011; // 67
			end
			D11: begin
				x <= 8'b0010_0110; // 38
				y <= 7'b100_1100; // 76
			end
			D12: begin
				x <= 8'b0010_0110; // 38
				y <= 7'b101_0010; // 82
			end
			D13: begin
				x <= 8'b0010_0110; // 38
				y <= 7'b101_0101; // 85
			end
			D14: begin
				x <= 8'b0010_0110; // 38
				y <= 7'b101_1000; // 88
			end
			D15: begin
				x <= 8'b0010_0110; // 38
				y <= 7'b101_1110; // 94
			end
			D16: begin
				x <= 8'b0010_0110; // 38
				y <= 7'b110_0001; // 97
			end
			D17: begin // return right side of player one to original state
				x <= 8'b0010_1011; // 43
				y <= 7'b000_0111; // 7
			end
			D18: begin
				x <= 8'b0010_1011; // 43
				y <= 7'b000_1010; // 10
			end
			D19: begin
				x <= 8'b0010_1011; // 43
				y <= 7'b010_0000; // 16
			end
			D20: begin
				x <= 8'b0010_1011; // 43
				y <= 7'b001_1100; // 28
			end
			D21: begin
				x <= 8'b0010_1011; // 43
				y <= 7'b010_0010; // 34
			end
			D22: begin
				x <= 8'b0010_1011; // 43
				y <= 7'b010_1000; // 40
			end
			D23: begin
				x <= 8'b0010_1011; // 43
				y <= 7'b010_1011; // 43
			end
			D24: begin
				x <= 8'b0010_1011; // 43
				y <= 7'b010_1110; // 46
			end
			D25: begin
				x <= 8'b0010_1011; // 43
				y <= 7'b011_0100; // 52
			end
			D26: begin
				x <= 8'b0010_1011; // 43
				y <= 7'b011_0111; // 55
			end
			D27: begin
				x <= 8'b0010_1011; // 43
				y <= 7'b100_0000; // 64
			end
			D28: begin
				x <= 8'b0010_1011; // 43
				y <= 7'b100_0110; // 70
			end
			D29: begin
				x <= 8'b0010_1011; // 43
				y <= 7'b100_1001; // 73
			end
			D30: begin
				x <= 8'b0010_1011; // 43
				y <= 7'b100_1111; // 79
			end
			D31: begin
				x <= 8'b0010_1011; // 43
				y <= 7'b101_1011; // 91
			end
			D32: begin
				x <= 8'b0010_1011; // 43
				y <= 7'b110_0100; // 100
			end
	endcase
	end

	always@(*) begin
		if (!enable) curr <= WAIT; // stay in wait if enable is off
		else begin
			curr <= next; // otherwise go to next state
			colour <= 3'b100; // colour of reset box
		end
	end

endmodule