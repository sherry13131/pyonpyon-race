module pyonpyon(SW, HEX0, HEX1, CLOCK_50);
  input [9:0] SW; // use SW[0] as enable(start the game), and SW[1] as reset_n (reset the game)
  input CLOCK_50; // internal DE2 clock 
  output [6:0] HEX0; // Display  value of Q1[0:3] on HEX0
  output [6:0] HEX1; // Display  value of Q2[0:3] on HEX1
  
  wire [3:0]Q1; // dec value obtained from counter for first digit
  wire [3:0]Q2; // dec value obtained from counter for second digit

  counter cnt(
    .enable(SW[0]),
    .clk_default(CLOCK_50),
    .reset_n(SW[1]), 
    .hex_out_one(Q1),
    .hex_out_two(Q2)
  );

  dec_decoder h0(
    .dec_digit(Q1[3:0]),
    .segments(HEX0)
  );
  
  dec_decoder h1(
    .dec_digit(Q2[3:0]),
    .segments(HEX1)
  );
  
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
