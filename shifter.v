// wire [32:0] boxes = 33’b0_1101_0001_0101_1101_1001_0110_1000_1001;

module shifter(
  input [32:0] loadval, // 33 bit structure of boxes
  input load_n,  // loads structure when user presses reset
  input shiftright, // shifts right when game is on
  input asr, // always 0
  input clk, // uses correctkey from player module to shift
  input reset_n, // same as load_n
  output q // next box to traverse, 0 = left, 1 = right
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