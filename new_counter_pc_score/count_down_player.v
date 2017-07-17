wire correctkey;

wire[3:0] player_score_out_1;
wire[3:0] player_score_out_2;

module display_counter_down_player(correctkey, resetn, clk, ended, q0, q1);
  input correctkey; // enable when the signal correct is high, player clicks the correct key
  input resetn;  // game reset
  output reg ended;	 // signal for the game is ended
  output reg [3:0]q0; // 4 bit counting (in this case hex4)
  output reg [3:0]q1; // 4 bit counting (in this case hex5)
  
  // asynchrnously handle reset_n signals
  always @(posedge correctkey)
  begin
    if(resetn == 1'b0)   // begin the score from 32 boxes
    begin
      q0 <= 4'b0010;
      q1 <= 4'b0011;
		ended <= 1'b0;
    end
    else if(correct == 1'b1)
    begin
      if (q0 == 4'b0000) // if first digit is zero, check second digit
      begin
        if (q1 == 4'b0000) // if the second digit is zero, end game give signal
          ended <= 1'b1;
        else
		  begin
			 q0 <= 4'b0101;	// change the first digit to 9
          q1 <= q1 - 1'b1; // second digit minus 1
		  end
      end
      else
        q0 <= q0 - 1'b1; // plus one if q0 (first digit is not 0)
    end
  end

endmodule

