module player(
	input resetn, // disables player from increasing score
	input enable, // also disables player from increasing score
	input box, // next box to advance (from shifter)
	input left, // left key
	input right, // right key
	output reg correctkey // to decrease score and shift box when player presses correct key
	);

	always@(posedge left, posedge right) begin // when player presses key
		if (box && right) begin // box = 1 means box is on the right
			correctkey <= 1'b1; // send signal
		end
		else if (~box && left) begin // box = 0 means box is on the left
			correctkey <= 1'b1; // send signal
		end
		else correctkey <= 1'b0; // none of the above applies so player didn't press right key
	end

	always@(negedge left, negedge right) begin // when player releases key
		correctkey <= 1'b0; // they didn't press anything so not correctkey
	end

	always@(*) begin
		if (resetn || ~enable) // check if reset is on or enable is off
			correctkey <= 1'b0; // correct key is always off
		else
			correctkey <= correctkey; // default
	end
endmodule