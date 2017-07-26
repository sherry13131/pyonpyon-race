module pyonpyon
  (
    CLOCK_50,           
    KEY,
    SW,
    HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
    LEDR, LEDG,


    VGA_CLK,              
    VGA_HS,             
    VGA_VS,           
    VGA_BLANK_N,          
    VGA_SYNC_N,         
    VGA_R,            
    VGA_G,              
    VGA_B   
  );

  input CLOCK_50;       
  input   [17:0]  SW;
  input   [3:0]   KEY;
  output  [6:0]   HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7; 
  output  [17:0]   LEDR;
  output  [7:0] LEDG;

  output      VGA_CLK;          
  output      VGA_HS;         
  output      VGA_VS;         
  output      VGA_BLANK_N;      
  output      VGA_SYNC_N;       
  output  [9:0] VGA_R;          
  output  [9:0] VGA_G;          
  output  [9:0] VGA_B;  

  wire [2:0] colour;
  wire [7:0] x;
  wire [6:0] y;

  wire resetn;  // resets the board to original
  assign resetn = SW[8];

  wire enable;  // game starts
  assign enable = SW[7];

  wire [1:0] speed;  // speed of cpu
  assign speed = SW[10:9];

  wire [32:0] boxes = 33'b0_1101_0001_0101_1101_1001_0110_1000_1001; // structure of boxes, 0 = left, 1 = right

  wire [3:0] Q1;  // timer
  wire [3:0] Q2;
  wire [3:0] pc_score_out_1;  // cpu score
  wire [3:0] pc_score_out_2;
  wire [3:0] player_score_out_1;  // player score
  wire [3:0] player_score_out_2;
  wire [3:0] highscore1;  // current high score (aka lowest time)
  wire [3:0] highscore2;

  wire next_box;  // next box to traverse
  wire correctkey;  // if correct switch was toggled
  wire correctkey_posedge;  // pulse for positive edge of correctkey
  wire cpu_counter;  // pulse for when time changes in cpu

  wire ended, ended_player, ended_pc;  // wires for ending the game
  assign ended = (ended_player || ended_pc);  // game ends when either cpu or player ends

  wire left, right;  // player controls
  assign left = SW[17];
  assign right = SW[0];

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


  player p(  // player module
    .resetn(resetn),
    .enable(enable),
    .box(next_box),
    .left(left),
    .right(right),
    .correctkeyled_right(LEDR[0]),
    .correctkeyled_left(LEDR[17]),
    .correctkey(correctkey)
  );

  shifter s(  // shifter for boxes
    .loadval(boxes),
    .load_n(1'b1),
    .shiftright(enable),
    .asr(1'b0),
    .clk(correctkey_posedge),
    .reset_n(resetn),  
    .q0(LEDG[0]),
    .q1(LEDG[1]),
    .q2(LEDG[2]),
    .q3(LEDG[3]),
    .q4(LEDG[4]),
    .q5(LEDG[5]),
    .q6(LEDG[6]),
    .q7(LEDG[7]),
    .q(next_box)// next box to traverse
  );

  counter_time ctimer(  // timer counter
    .enable(enable),
    .clk(CLOCK_50),
    .resetn(resetn), 
    .finished(ended),   
    .timer_out_one(Q1),
    .timer_out_two(Q2)
  );

  display_counter_down_player player_score(   // player score counter
    .correctkey(correctkey_posedge),
    .resetn(resetn),
    .finished(ended),
    .clk(CLOCK_50), 
    .ended(ended_player),
    .q0(player_score_out_1),
    .q1(player_score_out_2),
  );

  pos_edge_det correctkey_det(  // detects positive edge for player correct key
    .correctkey_in(correctkey),
    .clk(CLOCK_50),
    .correctkey_out(correctkey_posedge)
  );

  pc_score_counter pc_score(   // pc score counter
    .enable(enable),
    .clk(CLOCK_50),
    .resetn(resetn),
    .speed(speed),
    .finished(ended),         
    .pc_score_one(pc_score_out_1),
    .pc_score_two(pc_score_out_2),
    .ended(ended_pc),
    .cpu_counter(cpu_counter)
  );

  highscore high_score(  // high score
    .ended_player(ended_player),
    .timer1(Q1),
    .timer2(Q2),
    .highscore1_out(highscore1),
    .highscore2_out(highscore2)
  );

  plot plotter(  // plot
    .clk(CLOCK_50),
    .enable(enable),
    .ended(ended),
    .resetn(resetn),
    .correctkey_posedge(correctkey_posedge),
    .cpu_counter(cpu_counter),
    .x(x),
    .y(y),
    .colour(colour)
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

  // high score of player
  dec_decoder h2(
    .dec_digit(highscore1),
    .segments(HEX2)
  );

  dec_decoder h3(
    .dec_digit(highscore2),
    .segments(HEX3)
  );


  // cpu score display
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
// highscore module
// --------------------
module highscore(
  input ended_player,  // checks if player was the one who finished
  input [3:0] timer1,  // enters current time
  input [3:0] timer2,
  output [3:0] highscore1_out,  // outputs current high score
  output [3:0] highscore2_out
);

  reg [3:0] highscore1;  // stores the current high score
  reg [3:0] highscore2;

  always@(*) begin
    if(ended_player) begin  // checks if player finished the game
      if (highscore1 == 4'b0 && highscore2 == 4'b0) begin  // check if high score is 0 for when game initially starts
        highscore1 <= timer1;
        highscore2 <= timer2;
      end
      else if (timer2 < highscore2) begin  // checks if tens digit of current time is lower than tens digit of current high score
        highscore1 <= timer1;
        highscore2 <= timer2;
      end
      else if (timer2 == highscore2 && timer1 < highscore1) begin // checks if digits of current time is also lower than digits of current high score
        highscore1 <= timer1;
        highscore2 <= timer2;
      end
    end
    else begin
      highscore1 <= highscore1;
      highscore2 <= highscore2;
    end
  end

  assign highscore1_out = highscore1;  // outputs the high score
  assign highscore2_out = highscore2;

endmodule

// --------------------
// player module
// --------------------
module player(
  input resetn,  // disables player from increasing score when reset = 1
  input enable,  // also disables player from increasing score when enable = 0
  input box,  // next box to advance (from shifter)
  input left,  // left switch
  input right,  // right switch
  output correctkeyled_left,  // outputs next switch to toggle on LEDR[17]
  output correctkeyled_right,  // outputs next switch to toggle on LEDR[0]
  output reg correctkey  // to decrease score and shift box when player presses correct key
);

  assign correctkeyled_right = box;  // shows whether box is on the left or right
  assign correctkeyled_left = ~box;

  always@(*) begin
    if (resetn) begin  // check if reset is on
      correctkey <= 1'b0;  // correct key is always off
    end
    else if (box && right) begin  // player presses correct key
      correctkey <= 1'b1;
    end
    else if (~box && left) begin
      correctkey <= 1'b1;
    end
    else begin
      correctkey <= 1'b0;
    end
  end

endmodule

// --------------------
// shifter module
// --------------------
module shifter(
  input [32:0] loadval,  // 33 bit structure of boxes
  input load_n,  // always 1 
  input shiftright,  // shifts right when game is on
  input asr,  // always 0
  input clk,  // uses correctkey from player module to shift
  input reset_n,  // loads 33 bit structure of boxes
  output q0, q1, q2, q3, q4, q5, q6, q7,  // shows next 8 boxes to traverse on LEDG
  output q  // indicates next box to traverse for player module 
);

  wire q32, q31, q30, q29, q28, q27, q26, q25, q24, q23, q22, q21, q20, q19, q18, q17,
  q16, q15, q14, q13, q12, q11, q10, q9, q8;

  assign q = q0;

  // shifter bit modules
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

/*** code taken from lab 3 part 2 ***/
module shifterbit(
  input load_val,
  input in,
  input shift,
  input load_n,
  input clk,
  input reset_n,
  output out
);

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
    .loadval(load_val),
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

module flipflop(D, clock, reset, loadval, qout);
  input D;
  input clock;
  input reset;
  input loadval;
  reg Q;
  output qout;

  always @(posedge clock, posedge reset)
    begin
      if (reset)  // synchronous active low reset
        Q <= loadval;
      else
        Q <= D;
    end
  assign qout = Q;
endmodule
/*** end of code taken from lab 3 part 2 ***/

// --------------------
// player score counter
// --------------------
/*** module taken from online ***/
module pos_edge_det (
  input correctkey_in,  // indicates correct key from player module
  input clk,
  output correctkey_out  // pulse indicating positive edge of correct key
);

  reg correctkey_delay;

  always @ (posedge clk) begin
    correctkey_delay <= correctkey_in;
  end

  assign correctkey_out = correctkey_in & ~correctkey_delay;

endmodule 
/*** end of module taken from online ***/

module display_counter_down_player(
  input correctkey,  // increase score when player clicks the correct key
  input resetn,  // resets game
  input clk,
  input finished,   // check if cpu or player finished the game
  output reg ended,  // signal for when the game ends
  output reg [3:0] q0,  // 4 bit counter for digits (in this case hex4)
  output reg [3:0] q1  // 4 bit counter for tens (in this case hex5)
);

  always @(posedge correctkey, posedge resetn) begin  // when player presses the correct key or switches reset
    if(resetn) begin  // begin the score from 33
      q0 <= 4'b0011;  // digits (3)
      q1 <= 4'b0011;  // tens (3)
    end
    else if (~finished) begin  // check if the game didn't finish yet
      if (q0 == 4'b0000) begin  // if first digit is zero, check second digit
        if(q1 != 4'b0000) begin
          q0 <= 4'b1001;   // change the first digit to 9
          q1 <= q1 - 1'b1; // decrement tens
        end
      end
      else
        q0 <= q0 - 1'b1; // decrement if q0 isn't 0
    end
  end

  always@(*) begin
    if (q0 == 4'b0000) begin  // if first digit is zero, check second digit
      if (q1 == 4'b0000) // if the second digit is zero, give end game signal
        ended <= 1'b1;
    end
    else ended <= 1'b0;
  end
endmodule

// --------------------
// cpu score counter
// --------------------
/*** some parts in module taken from online ***/
module pc_score_counter(
  input enable,  // when game starts
  input clk,  // CLOCK_50
  input resetn,  // when game resets
  input [1:0] speed,  // speed chosen by player
  input finished,  // checks if player of cpu finished the game
  output [3:0] pc_score_one,  // 4 bit counter for digits
  output [3:0] pc_score_two,  // 4 bit counter for tens
  output ended,  // signal for when the game ends
  output cpu_counter  // outputs signal for plotting
);

  reg display_counter_en;  // enable to decrement from the score
  assign cpu_counter = ~resetn && display_counter_en;

  // countdown of the rate divider
  wire [24:0] easy_out;
  wire [24:0] medium_out;
  wire [24:0] hard_out;
  wire [24:0] extreme_out;

  rate_divider easy(  // 1.5 Hz -- easy mode
    .enable(enable),
    .clk(clk),
    .resetn(resetn),
    .countdown_start(25'b1110010011100001101111111),  // 29,999,999 in decimal
    .q(easy_out)
  );

  rate_divider med(  // 2 Hz -- medium mode
    .enable(enable),
    .clk(clk),
    .resetn(resetn),
    .countdown_start(25'b1011111010111100000111111),  // 24,999,999 in decimal   
    .q(medium_out)
  );

  rate_divider hard( // 3 Hz -- hard mode
    .enable(enable),
    .clk(clk),
    .resetn(resetn),
    .countdown_start(25'b111111100101000000101001),  // 16,666,665 in decimal
    .q(hard_out)
  );

  rate_divider extreme( // 5 Hz -- extreme mode
    .enable(enable),
    .clk(clk),
    .resetn(resetn),
    .countdown_start(25'b100110001001011001111111),  // 9,999,999 in decimal
    .q(extreme_out)
  );

  always @(*) begin
    case(speed) // select speed for cpu, sends pulse at certain times
      2'b00: display_counter_en = (easy_out == 25'b0) ? 1 : 0;   // 1.5 Hz
      2'b01: display_counter_en = (medium_out == 25'b0) ? 1 : 0;  // 2 Hz
      2'b10: display_counter_en = (hard_out == 25'b0) ? 1 : 0;  // 3 Hz
      2'b11: display_counter_en = (extreme_out == 25'b0) ? 1 : 0;  // 5 Hz
      default: display_counter_en = 25'b0;
    endcase
  end

  display_counter_down_pc pc_score(
    .enable(display_counter_en),  
    .resetn(resetn),  
    .clk(clk),
    .finished(finished),    
    .ended(ended),  
    .q0(pc_score_one),  
    .q1(pc_score_two) 
  );

endmodule
/*** end of some parts of module taken from online ***/

module display_counter_down_pc(
  input enable, // enable for the score counter to decrement
  input resetn,  // to reset the game
  input clk,
  input finished,  // checks if game ended yet
  output reg ended,  // sends signal for when cpu reaches 0
  output reg [3:0] q0, // cpu score (digits)
  output reg [3:0] q1  // cpu score (tens)
);

  always @(posedge clk) begin
    if(resetn) begin  // begin the score from 33 boxes
      q0 <= 4'b0011;  // digits (3)
      q1 <= 4'b0011;  // tens (3)
      ended <= 1'b0;  // game didn't end
    end
    else if (enable) begin  // check if game is enabled
      if (~finished) begin  // check if the game didn't finish yet
        if (q0 == 4'b0000) begin  // if first digit is zero, check second digit
          if (q1 == 4'b0000) // if the second digit is zero, give end game signal
            ended <= 1'b1;
          else begin
            q0 <= 4'b1001;   // change the first digit to 9
            q1 <= q1 - 1'b1; // decrement tens
          end
        end
        else
          q0 <= q0 - 1'b1; // decrement if q0 isn't 0
      end
    end
  end

endmodule

// --------------------
// time counter
// --------------------
/*** some parts of module taken from online ***/
module counter_time(
  input enable,  // check if game started
  input clk,
  input resetn,  // reset signal
  input finished,  // signal to stop the timer when the game is finished
  output [3:0] timer_out_one,  // output of counter (digits)
  output [3:0] timer_out_two  // output of counter (tens)
);

  reg display_counter_en; // pulse to send to increase time

  wire [27:0] timer_out; // for 1 Hz

  rate_divider timer(
    .enable(enable),
    .clk(clk),
    .resetn(resetn),
    .countdown_start(28'b10111110101111000001111111), // 49,999,999 in decimal
    .q(timer_out)
  );

  // give enable value when timer_out reaches 0
  always @(*) begin
    if (~finished) display_counter_en = (timer_out == 28'b0) ? 1 : 0; // 1 Hz
    else display_counter_en = 1'b0;
  end

  // display the counter
  display_counter_up display_timer(
    .enable(display_counter_en),
    .resetn(resetn),
    .clk(clk),
    .finished(ended),
    .q0(timer_out_one),
    .q1(timer_out_two)
  );  

endmodule
/*** end of some parts of module taken from online ***/

module display_counter_up(
  input enable,  // enable when the timer_out reaches zero
  input resetn,  // resets
  input clk,
  input finished,  // checks if game finished yet
  output reg [3:0] q0, // 4 bit counting digits (in this case hex0)
  output reg [3:0] q1 // 4 bit counting tens (in this case hex1)
);

  always @(posedge clk) begin
    if(resetn) begin  // reset timer back to 0
      q0 <= 4'b0000;
      q1 <= 4'b0000;
    end
    else if (enable) begin  // check if game started
      if (~finished) begin  // if the game didn't finish yet
        if (q0 == 4'b1001) begin  // if digits is 9, go back to zero (X9->X0)
          q0 <= 0;
          if (q1 == 4'b1001) // if tens is 9, go back to zero (99->00)
            q1 <= 0;
          else
            q1 <= q1 + 1'b1; // else just increment to the second digit (19->20)
        end
        else
          q0 <= q0 + 1'b1; // increment if digits is not 9
      end
    end
  end

endmodule

/*** module taken from online ***/
module rate_divider(
  input enable,  // checks if game started
  input resetn,  // resets
  input clk,  // internal clock
  input [27:0] countdown_start, // countdown from the given value
  output reg [27:0] q // output register of the countdown value
);

  // start counting down until 0
  always @(posedge clk) begin
    if(resetn) // change back to original countdown if reset
      q <= countdown_start;
    else if(enable) // decrement q only when enable is high
      q <= (q == 0) ? countdown_start : q - 1'b1; // if we get to 0, set back to value given originally
  end

endmodule
/*** end of module taken from online ***/

// --------------------
// decimal decoder
// --------------------
module dec_decoder(
  input [3:0] dec_digit,
  output reg [6:0] segments
);

  always @(*) begin
    case (dec_digit)  // for decimal number only
      4'h0: segments = 7'b100_0000;  // 0
      4'h1: segments = 7'b111_1001;  // 1
      4'h2: segments = 7'b010_0100;  // 2
      4'h3: segments = 7'b011_0000;  // 3
      4'h4: segments = 7'b001_1001;  // 4
      4'h5: segments = 7'b001_0010;  // 5
      4'h6: segments = 7'b000_0010;  // 6
      4'h7: segments = 7'b111_1000;  // 7
      4'h8: segments = 7'b000_0000;  // 8
      4'h9: segments = 7'b001_0000;  // 9
      default: segments = 7'b100_0000;  // default is just 0
    endcase
  end

endmodule