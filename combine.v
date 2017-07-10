// this is the simple score counter. add one when a button is clicked

//SW[0] is enable and start the game (counter will start too)
//SW[1] synchronous reset when pressed
//KEY[3:0] go signal (Here just KEY[0] and KEY[1])

//HEX4,5,6,7 also displays result (Here just HEX4 and HEX5)


module top_pyonpyon(SW, KEY, HEX...........)

    //.........

    wire [3:0] Q1;
    wire [3:0] Q2;

    counter counter(
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

    dec_decoder H4(
        .hex_digit(score21[3:0]), 
        .segments(HEX4)
        );
        
    dec_decoder H5(
        .hex_digit(score22[3:0]), 
        .segments(HEX5)
        );

    dec_decoder H6(
        .hex_digit(score11[3:0]),
        .segments(HEX6)
        );

    dec_decoder H7(
        .hex_digit(score12[3:0]),
        .segments(HEX7)
        );

endmodule


module pyonpyon(
    input clk,
    input resetn,
    input start,
    output enable,
    input leftone,
    input rightone,
    input lefttwo,
    input righttwo,
    output [3:0] q11,
    output [3:0] q12,
    output [3:0] q21,
    output [3:0] q22,

    // and some x, y , etc...
    );

    wire resetn;
    wire finish;
    wire [7:0] scoreone;
    wire [7:0] scoretwo;
    wire [3:0] score11;
    wire [3:0] score12;
    wire [3:0] score21;
    wire [3:0] score22;

    assign resetn = SW[1];
    assign finish = 1'b0;

    control my_control(
        .clk(CLOCK_50),
        .resetn(resetn),
        .start(SW[0]),
        .finish(finish)
    );

    datapath my_path(
        .clk(CLOCK_50),
        .resetn(resetn),
        .enable(),
        .leftone(~KEY[3]), 
        .rightone(~KEY[2]),
        .lefttwo(~KEY[1]),
        .righttwo(~KEY[0]),
        .reset_en(),
        .finish(finish),
        .[7:0] x(),
        .[6:0] y(),
        .[2:0] colour(),
        .[7:0] time,
        .scoreone(scoreone[7:0]),
        .scoretwo(scoretwo[7:0])
    );

    process_number pnum1(
        .number(scoreone[7:0])
        .q11(score11[3:0])
        .q12(score12[3:0])
        );
    process_number pnum2(
        .number(scoreone[7:0])
        .q21(score21[3:0])
        .q22(score22[3:0])
        );


endmodule

module precess_number(number);
    input [7:0] number;
    output [3:0] q0;
    output [3:0] q1;

    if (number < 7'b1010)
    begin
        assign q0 = number[3:0];
        assign q1 = 0;
    end
    else
    begin
        assign q0 = number % 10;
        assign q1 = number / 10;
    end


module control(
    // --- signals ---
    input clk,
    input resetn,   //reset
    input start,    //start - when the game start with SW[0] on
    input finish,       // signal to end the game (getting from datapath)
    );

    reg current_state, next_state; 
    
    localparam  START           = 2'd0,
                S_LOAD_CLICK    = 2'd1,
                RESTART_WAIT    = 2'd2,
    
    // state table FSM
    always@(*)
    begin: state_table 
            case (current_state)
                START: next_state = start ? S_LOAD_CLICK : START; // start the game and enter the state loop
                S_LOAD_CLICK: next_state = finish ? RESTART : S_LOAD_CLICK // Loop in current state until value is input
                RESTART_WAIT = next_state = resetn ? RESTART_WAIT : START;
            default:     next_state = START;
        endcase
    end // state_table
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!start)
            current_state <= START;
        else
            current_state <= next_state;
    end // state_FFS
endmodule




// datapath
module datapath(
    input clk,
    input resetn,
    input enable,
    input leftone, rightone,
    input lefttwo, righttwo,
    output reset_en,
    output finish,
    output reg [7:0] x,
    output reg [6:0] y,
    output reg [2:0] colour,
    output reg [7:0] time,
    output reg [7:0] scoreone,
    output reg [7:0] scoretwo
    );

    player p1( // to fill in
        .clk(clk),
        .resetn(resetn),
        .enable()
        .left
        .right
        .end
        .x
        .y
        .colour
        .score
        .finish)

    always@(posedge clk) begin
        if (resetn) reset_en <= 1'b1;
        else reset_en <= 1'b0;
    end

endmodule

module player(
    input clk,
    input resetn,
    input enable,
    input left, right,
    output end,
    output reg [7:0] x,
    output reg [6:0] y,
    output reg [2:0] colour,
    output reg [3:0] score0,
    output reg [3:0] score1,
    output reg finish
    );

    reg [4:0] state

    always@(posedge clk) begin
        if (resetn) state <= 5'd0; // before game starts
        else if (enable) begin // check if game started
            if (state == 5'd0) begin // this is when game first starts
                if (right) begin
                    state <= 5'd1 // go to next box because correct answer
                    // draw in box
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd1) begin
                if (left) begin
                    state <= 5'd2 // go to next box because correct answer
                    // draw in box
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd2) begin
                if (left) begin
                    state <= 5'd3 // go to next box because correct answer
                    // draw in box
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd3) begin
                if (right) begin
                    state <= 5'd4 // go to next box because correct answer
                    // draw in box
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd4) begin
                if (left) begin
                    state <= 5'd5 // go to next box because correct answer
                    // draw in box
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd5) begin
                if (left) begin
                    state <= 5'd6 // go to next box because correct answer
                    // draw in box
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd6) begin
                if (left) begin
                    state <= 5'd7 // go to next box because correct answer
                    // draw in box
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd7) begin
                if (right) begin
                    state <= 5'd8 // go to next box because correct answer
                    // draw in box
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd8) begin
                if (left) begin
                    state <= 5'd9 // go to next box because correct answer
                    // draw in box
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd9) begin
                if (right) begin
                    state <= 5'd10 // go to next box because correct answer
                    // draw in box
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd10) begin
                if (right) begin
                    state <= 5'd11 // go to next box because correct answer
                    // draw in box
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd11) begin
                if (left) begin
                    state <= 5'd12 // go to next box because correct answer
                    // draw in box
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd12) begin
                if (right) begin
                    state <= 5'd13 // go to next box because correct answer
                    // draw in box
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd13) begin
                if (left) begin
                    state <= 5'd14 // go to next box because correct answer
                    // draw in box
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd14) begin
                if (left) begin
                    state <= 5'd15 // go to next box because correct answer
                    // draw in box
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd15) begin
                if (right) begin
                    state <= 5'd16 // go to next box because correct answer
                    // draw in box
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd16) begin
                if (right) begin
                    state <= 5'd17 // go to next box because correct answer
                    // draw in box
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end

            else if (state == 5'd17) begin
                if (left) begin
                    state <= 5'd18 // go to next box because correct answer
                    // draw in box
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd18) begin
                if (right) begin
                    state <= 5'd19 // go to next box because correct answer
                    // draw in box
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd19) begin
                if (right) begin
                    state <= 5'd20 // go to next box because correct answer
                    // draw in box
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd20) begin
                if (right) begin
                    state <= 5'd21 // go to next box because correct answer
                    // draw in box
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd21) begin
                if (left) begin
                    state <= 5'd22 // go to next box because correct answer
                    // draw in box
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd22) begin
                if (right) begin
                    state <= 5'd23 // go to next box because correct answer
                    // draw in box
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd23) begin
                if (left) begin
                    state <= 5'd24 // go to next box because correct answer
                    // draw in box
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd24) begin
                if (right) begin
                    state <= 5'd25 // go to next box because correct answer
                    // draw in box
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd25) begin
                if (left) begin
                    state <= 5'd26 // go to next box because correct answer
                    // draw in box
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd26) begin
                if (left) begin
                    state <= 5'd27 // go to next box because correct answer
                    // draw in box
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd27) begin
                if (left) begin
                    state <= 5'd28 // go to next box because correct answer
                    // draw in box
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd28) begin
                if (right) begin
                    state <= 5'd29 // go to next box because correct answer
                    // draw in box
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd29) begin
                if (left) begin
                    state <= 5'd30 // go to next box because correct answer
                    // draw in box
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd30) begin
                if (right) begin
                    state <= 5'd31 // go to next box because correct answer
                    // draw in box
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd31) begin
                if (right) begin
                    state <= 5'd32 // go to next box because correct answer
                    // draw in box
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd32) begin
                if (left) begin
                    // draw in box
                    // check the player reach the top
                    finish <= 1'b1;
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end

        end
    end

endmodule
