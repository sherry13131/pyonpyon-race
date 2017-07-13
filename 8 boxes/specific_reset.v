module reset(
	input clk,
	input reset_en,
	output reg [7:0] x,
	output reg [6:0] y,
	output reg [2:0] colour
	);

	reg [4:0] curr, next;

	localparam 	D0 = 5'd0;
				D1 = 5'd1;
				D2 = 5'd2;
				D3 = 5'd3;
				D4 = 5'd4;
				D5 = 5'd5;
				D6 = 5'd6;
				D7 = 5'd7;
				D8 = 5'd8;
				D9 = 5'd9;
				D10 = 5'd10;
				D11 = 5'd11;
				D12 = 5'd12;
				D13 = 5'd13;
				D14 = 5'd14;
				D15 = 5'd15;
				WAIT = 5'd16;
				WAIT_RESET = 5'd17;

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
			D15: next = WAIT_RESET;
			WAIT_RESET: next = reset_en ? WAIT_RESET : WAIT; // stay here so that it doesn't keep cycling
			default: next = WAIT;
		endcase
	end

	// get the boxes to reset to white
	always@(*) begin
		case(curr)
			D0: begin // return player one to original state
				x <= 8'b0010_1011; // 43
				y <= 8'b0000_0111; // 7
			end
			D1: begin
				x <= 8'b0010_0110; // 38
				y <= 8'b0001_0011; // 19
			end
			D2: begin
				x <= 8'b0010_0110; // 38
				y <= 8'b0001_1111; // 31
			end
			D3: begin
				x <= 8'b0010_1011; // 43
				y <= 8'b0010_1000; // 40
			end
			D4: begin
				x <= 8'b0010_1011; // 43
				y <= 8'b0010_1110; // 46
			end
			D5: begin
				x <= 8'b0010_1011; // 43
				y <= 8'b0100_0000; // 64
			end
			D6: begin
				x <= 8'b0010_0110; // 38
				y <= 8'b0101_0010; // 82
			end
			D7: begin
				x <= 8'b0010_0110; // 38
				y <= 8'b0110_0001; // 97
			end
			D8: begin // return player two to original state
				x <= 8'b0111_1011; // 123
				y <= 8'b0000_0111; // 7
			end
			D9: begin
				x <= 8'b0111_0110; // 118
				y <= 8'b0001_0011; // 19
			end
			D10: begin
				x <= 8'b0111_0110; // 118
				y <= 8'b0001_1111; // 31
			end
			D11: begin
				x <= 8'b0111_1011; // 123
				y <= 8'b0010_1000; // 40
			end
			D12: begin
				x <= 8'b0111_1011; // 123
				y <= 8'b0010_1110; // 46
			end
			D13: begin
				x <= 8'b0111_1011; // 123
				y <= 8'b0010_1110; // 46
			end
			D14: begin
				x <= 8'b0111_0110; // 118
				y <= 8'b0010_1110; // 46
			end
			D15: begin
				x <= 8'b0111_0110; // 118
				y <= 8'b0010_1110; // 46
			end
		endcase
	end
	
	always@(*) begin
		if (!reset_en) curr <= WAIT; // stay in wait if reset is off
		else begin
			curr <= next; // otherwise go to next state
			colour <= 3'b111; // colour of reset box
		end
	end

endmodule