module display_counter_down_player(correct, resetn, clk, ended, q0, q1);
  input correct; // enable when the signal correct is high, player clicks the correct key
  input resetn;  // game reset
  input clk;
  output reg ended;	 // signal for the game is ended
  output reg [3:0]q0; // 4 bit counting (in this case hex4)
  output reg [3:0]q1; // 4 bit counting (in this case hex5)
  
  // asynchrnously handle reset_n signals
  always @(posedge clk)
  begin
    if(resetn == 1'b0)   // begin the score from 32 boxes
    begin
      q0 <= 4'b0011;
      q1 <= 4'b0010;
		ended <= 1'b0;
    end
    else if(correct == 1'b1)
    begin
      if (q0 == 4'b0000) // if first digit is zero, check second digit
      begin
        if (q1 == 4'b0000) // if the second digit is zero, end game give signal
          ended <= 1'b1;
        else
          q1 <= q1 - 1'b1; // else second digit minus 1
      end
      else
        q0 <= q0 - 1'b1; // plus one if q0 (first digit is not 9)
    end
  end

endmodule