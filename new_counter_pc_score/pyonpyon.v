module pyonpyon
  (
    CLOCK_50,           
    KEY,
    SW,
    HEX0, HEX1, HEX4, HEX5, HEX6, HEX7      
  );

  input CLOCK_50;       
  input   [17:0]  SW;
  input   [3:0]   KEY;
  output  [6:0]   HEX0, HEX1, HEX4, HEX5, HEX6, HEX7;       

  wire resetn;  // resets the board to original, when resetn = 0, it reset; when resetn = 1, it doesn't reset.
  assign resetn = ~SW[1];

  wire enable;  // game starts
  assign enable = SW[0];

  wire [32:0] boxes = 33'b0_1101_0001_0101_1101_1001_0110_1000_1001; // structure of boxes, 0 = left, 1 = right
  
  wire [3:0] Q1;
  wire [3:0] Q2;
  wire [3:0] pc_score_out_1;
  wire [3:0] pc_score_out_2;
  wire [3:0] player_score_out_1;
  wire [3:0] player_score_out_2;

  wire next_box;
  wire correctkey;

  wire ended, ended_player, ended_pc;  // whether either cpu or player ended
  assign ended = (ended_player | ended_pc); // **************** POTENTIAL ISSUE **************** (the game state)

  wire left, right;  // player one controls
  assign left = ~KEY[3];
  assign right = ~KEY[2];

  player p(  // player module
    .resetn(resetn),
    .enable(enable),
    .box(next_box),
    .left(left),
    .right(right),
    .correctkey(correctkey)
  );

  shifter s(  // shifter for boxes
    .loadval(boxes),
    .load_n(resetn),
    .shiftright(enable),
    .asr(1'b0),
    .clk(correctkey),
    .reset_n(resetn),
    .q(next_box)  // next box to traverse
  );

  counter_time ctimer(  // timer counter
    .enable(enable),
    .clk(CLOCK_50),
    .resetn(resetn), 
	 .finished(ended),		// the game state
    .timer_out_one(Q1),
    .timer_out_two(Q2)
  );

  display_counter_down_player player_score(   // player score counter
    .correctkey(correctkey),
    .resetn(resetn),
	 .finished(ended),				// the game state
    .ended(ended_player),
    .q0(player_score_out_1),
    .q1(player_score_out_2),
    );

  pc_score_counter pc_score(   // pc score counter
    .enable(enable),
    .clk(CLOCK_50),
    .resetn(resetn),
    .speed(SW[17:16]),
 	 .finished(ended),	      	// the game state
    .pc_score_one(pc_score_out_1),
    .pc_score_two(pc_score_out_2),
    .ended(ended_pc),
  );

  // timer display
  dec_decoder h0(
    .dec_digit(Q1),
    .segments(HEX0)
  );

  dec_decoder h1(
    .dec_digit(Q2),
    .segments(HEX1)
  );

  // pc score display
  dec_decoder h4(
    .dec_digit(pc_score_out_1), 
    .segments(HEX4)
  );

  dec_decoder h5(
    .dec_digit(pc_score_out_2), 
    .segments(HEX5)
  );

  // player score display
  dec_decoder h6(
    .dec_digit(player_score_out_1),
    .segments(HEX6)
  );

  dec_decoder h7(
    .dec_digit(player_score_out_2),
    .segments(HEX7)
  );

endmodule

// --------------------
// player module
// --------------------
module player(
  input resetn,  // disables player from increasing score when reset = 1
  input enable,  // also disables player from increasing score when enable = 0
  input box,  // next box to advance (from shifter)
  input left,  // left key
  input right,  // right key
  output reg correctkey  // to decrease score and shift box when player presses correct key
);

  always@(*) begin  // when player presses key
	 if (resetn || ~enable)  // check if reset is on or enable is off
      correctkey <= 1'b0;  // correct key is always off
    else if (box && right) begin  // box = 1 means box is on the right
      correctkey <= 1'b1;  // send signal
		correctkey <= 1'b0;
    end
    else if (~box && left) begin  // box = 0 means box is on the left
      correctkey <= 1'b1;  // send signal
		correctkey <= 1'b0;
    end
    else correctkey <= correctkey;  // none of the above applies so player didn't press right key
  end

  /*always@(posedge left or posedge right) begin  // when player presses key
    if (right && box) begin  // box = 1 means box is on the right
      correctkey <= 1'b1;  // send signal
		correctkey <= 1'b0;
    end
    else if (left && ~box) begin  // box = 0 means box is on the left
      correctkey <= 1'b1;  // send signal
		correctkey <= 1'b0;
    end
    else correctkey <= 1'b0;  // none of the above applies so player didn't press right key
  end*/
  
  /*always@(posedge left, posedge right) begin  // when player presses key
    if (box) begin  // box = 1 means box is on the right
		if (right) begin
			correctkey <= 1'b1;  // send signal
			correctkey <= 1'b0;
		end
		else correctkey <= 1'b0;
    end
    else begin  // box = 0 means box is on the left
		if (left) begin
			correctkey <= 1'b1;  // send signal
			correctkey <= 1'b0;
		end
		else correctkey <= 1'b0;
    end
  end*/

  /*always@(negedge left, negedge right) begin  // when player releases key
    correctkey <= 1'b0;  // they didn't press anything so not correctkey
  end*/
  
  /*always@(posedge left) begin  // when player presses key
    if (~box) begin  // box = 1 means box is on the right
			correctkeyleft <= 1'b1;  // send signal
	end
		else correctkeyleft <= 1'b0;
	end
	
	always@(posedge right) begin  // when player presses key
    if (box) begin  // box = 1 means box is on the right
			correctkeyright <= 1'b1;  // send signal
		end
		else correctkeyright <= 1'b0;
	end*/

  /*always@(*) begin
    if (resetn || ~enable)  // check if reset is on or enable is off
      correctkey <= 1'b0;  // correct key is always off
    else
      correctkey <= correctkey;  // default
  end*/
  
  //assign reg correctkey = correctkeyleft || correctkeyright;
endmodule

// --------------------
// shifter module
// --------------------
module shifter(
  input [32:0] loadval,  // 33 bit structure of boxes
  input load_n,  // loads structure when user presses reset
  input shiftright,  // shifts right when game is on
  input asr,  // always 0
  input clk,  // uses correctkey from player module to shift
  input reset_n,  // same as load_n
  output q  // next box to traverse, 0 = left, 1 = right
);

  wire q32, q31, q30, q29, q28, q27, q26, q25, q24, q23, q22, q21, q20, q19, q18, q17,
  q16, q15, q14, q13, q12, q11, q10, q9, q8, q7, q6, q5, q4, q3, q2, q1, q0;
  assign q = q0;

  shifterbit S32(.load_val(loadval[32]), .in(1'b0), .shift(shiftright), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(q32));
  shifterbit S31(.load_val(loadval[31]), .in(q32), .shift(shiftright), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(q31));
  shifterbit S30(.load_val(loadval[30]), .in(q31), .shift(shiftright), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(q30));
  shifterbit S29(.load_val(loadval[29]), .in(q30), .shift(shiftright), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(q29));
  shifterbit S28(.load_val(loadval[28]), .in(q29), .shift(shiftright), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(q28));
  shifterbit S27(.load_val(loadval[27]), .in(q28), .shift(shiftright), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(q27));
  shifterbit S26(.load_val(loadval[26]), .in(q27), .shift(shiftright), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(q26));
  shifterbit S25(.load_val(loadval[25]), .in(q26), .shift(shiftright), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(q25));
  shifterbit S24(.load_val(loadval[24]), .in(q25), .shift(shiftright), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(q24));
  shifterbit S23(.load_val(loadval[23]), .in(q24), .shift(shiftright), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(q23));
  shifterbit S22(.load_val(loadval[22]), .in(q23), .shift(shiftright), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(q22));
  shifterbit S21(.load_val(loadval[21]), .in(q22), .shift(shiftright), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(q21));
  shifterbit S20(.load_val(loadval[20]), .in(q21), .shift(shiftright), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(q20));
  shifterbit S19(.load_val(loadval[19]), .in(q20), .shift(shiftright), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(q19));
  shifterbit S18(.load_val(loadval[18]), .in(q19), .shift(shiftright), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(q18));
  shifterbit S17(.load_val(loadval[17]), .in(q18), .shift(shiftright), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(q17));
  shifterbit S16(.load_val(loadval[16]), .in(q17), .shift(shiftright), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(q16));
  shifterbit S15(.load_val(loadval[15]), .in(q16), .shift(shiftright), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(q15));
  shifterbit S14(.load_val(loadval[14]), .in(q15), .shift(shiftright), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(q14));
  shifterbit S13(.load_val(loadval[13]), .in(q14), .shift(shiftright), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(q13));
  shifterbit S12(.load_val(loadval[12]), .in(q13), .shift(shiftright), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(q12));
  shifterbit S11(.load_val(loadval[11]), .in(q12), .shift(shiftright), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(q11));
  shifterbit S10(.load_val(loadval[10]), .in(q11), .shift(shiftright), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(q10));
  shifterbit S9(.load_val(loadval[9]), .in(q10), .shift(shiftright), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(q9));
  shifterbit S8(.load_val(loadval[8]), .in(q9), .shift(shiftright), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(q8));
  shifterbit S7(.load_val(loadval[7]), .in(q8), .shift(shiftright), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(q7));
  shifterbit S6(.load_val(loadval[6]), .in(q7), .shift(shiftright), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(q6));
  shifterbit S5(.load_val(loadval[5]), .in(q6), .shift(shiftright), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(q5));
  shifterbit S4(.load_val(loadval[4]), .in(q5), .shift(shiftright), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(q4));
  shifterbit S3(.load_val(loadval[3]), .in(q4), .shift(shiftright), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(q3));
  shifterbit S2(.load_val(loadval[2]), .in(q3), .shift(shiftright), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(q2));
  shifterbit S1(.load_val(loadval[1]), .in(q2), .shift(shiftright), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(q1));
  shifterbit S0(.load_val(loadval[0]), .in(q1), .shift(shiftright), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(q0));

endmodule

module shifterbit(load_val, in, shift, load_n, clk, reset_n, out);
  input load_val;
  input in;
  input shift;
  input load_n;
  input clk;
  input reset_n;
  output out;
  wire shiftwire;
  wire loadwire;

  mux2to1 M0(  // instantiate 1st multiplexer
    .x(out),
    .y(in),
    .s(shift),
    .m(shiftwire)  // outputs to 2nd multiplexer
  );

  mux2to1 M1(  // instantiate 2nd multiplexer
    .x(load_val),
    .y(shiftwire),
    .s(load_n),
    .m(loadwire)  // outputs to flipflop
  );

  flipflop F0(  // instantiate flipflop
    .D(loadwire),
    .clock(clk),
    .reset(reset_n),
    .qout(out)  // output from flipflop
  );

endmodule

module mux2to1(x, y, s, m);
  input x; //selected when s is 0
  input y; //selected when s is 1
  input s; //select signal
  output m; //output

  assign m = s & y | ~s & x;
endmodule

module flipflop(D, clock, reset, qout);
  input D;
  input clock;
  input reset;
  reg Q;
  output qout;

  always @(posedge clock)
    begin
      if (reset == 1'b0)  // synchronous active low reset
        Q <= 0;
      else
        Q <= D;
    end
  assign qout = Q;
endmodule

// --------------------
// player score counter
// --------------------
module display_counter_down_player(correctkey, resetn, finished, ended, q0, q1);
  input correctkey;  // enable when the signal correct is high, player clicks the correct key
  input resetn;  // game reset
  input finished;		// check game state
  output reg ended;  // signal for the game is ended
  output reg [3:0] q0;  // 4 bit counting (in this case hex4)
  output reg [3:0] q1;  // 4 bit counting (in this case hex5)

  // asynchrnously handle reset_n signals
  always @(posedge correctkey) begin  // when player presses the correct key
    if(resetn == 1'b0) begin  // begin the score from 32 boxes
      q0 <= 4'b0010;  // 2 in digits
      q1 <= 4'b0011;  // 3 in tens
      ended <= 1'b0;
    end
    else begin
		if (finished == 1'b0) begin		// if the game not yet finish
			if (q0 == 4'b0000) begin  // if first digit is zero, check second digit
			  if (q1 == 4'b0000) // if the second digit is zero, end game give signal
				 ended <= 1'b1;
			  else begin
				 q0 <= 4'b1001; // change the first digit to 9
				 q1 <= q1 - 1'b1; // second digit minus 1
			  end
			end
			else
			  q0 <= q0 - 1'b1; // minus one if q0 (first digit is not 0)
		end
    end
  end

endmodule


// --------------------
// cpu score counter
// --------------------
module pc_score_counter(
  input enable,  // when game start
  input clk,  // CLOCK_50
  input resetn,  // when game reset
  input [1:0] speed,  // speed chosen by player
  input finished,     // the game state
  output [3:0] pc_score_one,  // first digit of pc number of box with 4 bits
  output [3:0] pc_score_two,  // second digit of pc number of box with 4 bits
  output ended  // signal for the game is ended
);

  reg display_counter_en;  // enable to decrease 1 from the score

  // countdown of the rate divider
  wire [27:0] easy_out;
  wire [27:0] medium_out;
  wire [27:0] hard_out;
  wire [27:0] extreme_out;

  rate_divider easy(  // 1.5 Hz
    .enable(enable),
    .clk(clk),
    .resetn(resetn),
    .countdown_start(28'b1111111001010000001010100),  // 33,333,332 in decimal
    .q(easy_out)
  );

  rate_divider my_medium(  // 2 Hz
    .enable(enable),
    .clk(clk),
    .resetn(resetn),
    .countdown_start(28'b1011111010111100000111111),  // 24,999,999 in decimal   
    .q(medium_out)
  );

  rate_divider hard( // 3 Hz
    .enable(enable),
    .clk(clk),
    .resetn(resetn),
    .countdown_start(28'b111111100101000000101001),  // 16,666,665 in decimal
    .q(hard_out)
  );

  rate_divider extreme( // 5 Hz
    .enable(enable),
    .clk(clk),
    .resetn(resetn),
    .countdown_start(28'b100110001001011001111111),  // 9,999,999 in decimal
    .q(extreme_out)
  );

  always @(*) begin
    case(speed) // select speed for pc
      2'b00: display_counter_en = (easy_out == 28'b0) ? 1 : 0;   // 1.5 Hz
      2'b01: display_counter_en = (medium_out == 28'b0) ? 1 : 0;  // 2 Hz
      2'b10: display_counter_en = (hard_out == 28'b0) ? 1 : 0;  // 3 Hz
      2'b11: display_counter_en = (extreme_out == 28'b0) ? 1 : 0;  // 5 Hz
      default: display_counter_en = 28'b0;
    endcase
  end

  display_counter_down_pc pc_score(
    .enable(display_counter_en),  // enable for the score counter -1
    .resetn(resetn),  // reset of the game
    .clk(clk),
    .ended(ended),  // signal for the game is ended
	 .finished(finished),    // the game state
    .q0(pc_score_one),  // score of pc (first digit)
    .q1(pc_score_two)  // score of pc (second digit)
  );

endmodule

module display_counter_down_pc(enable, resetn, clk, ended, finished, q0, q1);
  input enable; // enable when the countdown_start reach zero for pc
  input resetn;  // game reset
  input clk;
  input finished;      // the game state  
  output reg ended;  // signal for the game is ended
  output reg [3:0] q0; // 4 bit counting (in this case hex4)
  output reg [3:0] q1; // 4 bit counting (in this case hex5)

  // asynchrnously handle reset_n signals
  always @(posedge clk) begin
    if(resetn == 1'b0) begin  // begin the score from 32 boxes
      q0 <= 4'b0010;  // right
      q1 <= 4'b0011;  // left
      ended <= 1'b0;  // game didn't end
    end
    else if(enable == 1'b1) begin
		if (finished == 1'b0) begin     // if the game not yet finish
			if (q0 == 4'b0000) begin  // if first digit is zero, check second digit
			  if (q1 == 4'b0000) // if the second digit is zero, give end game signal
				 ended <= 1'b1;
			  else begin
				 q0 <= 4'b1001;   // change the first digit to 9
				 q1 <= q1 - 1'b1; // second digit minus 1
			  end
			end
			else
			  q0 <= q0 - 1'b1; // plus one if q0 (first digit is not 9)
		 end
    end
  end

endmodule

// --------------------
// time counter
// --------------------
module counter_time(enable, clk, resetn, finished, timer_out_one, timer_out_two);
  input enable; // start signal
  input clk;
  input resetn; // reset signal; reset when low
  input finished;					// signal to stop the timer when the game is finished
  output [3:0] timer_out_one; // output of counter (first digit)
  output [3:0] timer_out_two; // output of counter (second digit)

  reg display_counter_en; // select this based on the period of the rate dividers

  wire [27:0] rd_1hz_out; // for 1 Hz

  rate_divider rd_1hz(
    .enable(enable),
    .clk(clk),
    .resetn(resetn),
    .countdown_start(28'b10111110101111000001111111), // 49,999,999 in decimal
    .q(rd_1hz_out)
  );

  // give enable value when the rd_1hz_out reach 0
  always @(*)
    begin
      display_counter_en = (rd_1hz_out == 28'b0) ? 1 : 0; // 1 Hz
    end

  // display the counter
  display_counter_up displayOneHz(
    .enable(display_counter_en),
    .resetn(resetn),
    .clk(clk),
	 .finished(ended),
    .q0(timer_out_one),
    .q1(timer_out_two)
  );  

endmodule

module display_counter_up(enable, resetn, clk, finished, q0, q1);
  input enable; // enable when the countdown_start reach zero
  input resetn;
  input clk;
  input finished;
  output reg [3:0]q0; // 4 bit counting on (in this case hex0)
  output reg [3:0]q1; // 4 bit counting on (in theis case hex1)

  // asynchrnously handle reset_n signals
  always @(posedge clk) begin
    if(resetn == 1'b0) begin
      q0 <= 4'b0000;
      q1 <= 4'b0000;
    end
    else if (enable == 1'b1) begin
		if (finished == 1'b0) begin			// if the game not yet finish
			if (q0 == 4'b1001) begin  // if first digit is 9, go back to zero (X9->X0)
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
  end

endmodule

module rate_divider(enable, clk, resetn, countdown_start, q);
  input enable;
  input resetn;
  input clk;
  input [27:0]countdown_start; // countdown from the given value
  output reg [27:0]q; // output register of the countdown value

  // start counting down until 0
  always @(posedge clk) begin
    if(resetn == 1'b0) // when clear_b is 0
      q <= countdown_start;
    else if(enable == 1'b1) // decrement q only when enable is high
      q <= (q == 0) ? countdown_start : q - 1'b1; // if we get to 0, set back to value given originally
  end

endmodule

// --------------------
// decimal decoder
// --------------------
module dec_decoder(dec_digit, segments);
  input [3:0] dec_digit;
  output reg [6:0] segments;

  always @(*) begin
    case (dec_digit)  // for decimal number only
      4'h0: segments = 7'b100_0000;
      4'h1: segments = 7'b111_1001;
      4'h2: segments = 7'b010_0100;
      4'h3: segments = 7'b011_0000;
      4'h4: segments = 7'b001_1001;
      4'h5: segments = 7'b001_0010;
      4'h6: segments = 7'b000_0010;
      4'h7: segments = 7'b111_1000;
      4'h8: segments = 7'b000_0000;
      4'h9: segments = 7'b001_0000;
      default: segments = 7'b100_0000;
    endcase
  end

endmodule
