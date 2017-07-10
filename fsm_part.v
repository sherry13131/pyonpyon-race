// this is the simple score counter. add one when a button is clicked

//SW[0] is enable and start the game (counter will start too)
//SW[1] synchronous reset when pressed
//KEY[3:0] go signal (Here just KEY[0] and KEY[1])

//HEX4,5,6,7 also displays result (Here just HEX4 and HEX5)

module score_adder(SW, KEY, CLOCK_50, HEX4, HEX5);
    input [9:0] SW;
    input [3:0] KEY;
    input CLOCK_50;
    output [6:0] HEX4, HEX5;

    wire resetn;
    wire go1;
    wire go2;

    wire [3:0] data_result_0;
    wire [3:0] data_result_1;
    //assign go = (~KEY[1] ^ ~KEY[0]);         // not sure will it works or not
    assign go1 = ~KEY[1];                      // left key
    assign go2 = ~KEY[0];                      // right key
    assign resetn = SW[1];

    adder u0(
        .clk(CLOCK_50),
        .resetn(resetn),
        .go(go),
        .data_result_0(data_result_0),
        .data_result_1(data_result_1)
    );

    hex_decoder H4(
        .hex_digit(data_result_0), 
        .segments(HEX4)
        );
        
    hex_decoder H5(
        .hex_digit(data_result_1), 
        .segments(HEX5)
        );

endmodule

// control
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
                RESTART         = 2'd3;
    
    // state table FSM
    always@(*)
    begin: state_table 
            case (current_state)
                START: next_state = (start&&~resetn) ? S_LOAD_CLICK : START; // start the game if not in reset and enter the state loop
                S_LOAD_CLICK: next_state = finish ? RESTART_WAIT : S_LOAD_CLICK // loop in current state until game finishes
                RESTART_WAIT: next_state = resetn ? START : RESTART_WAIT; // stay until player resets game
            default: next_state = START;
        endcase
    end // state_table

    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!start) current_state <= START; // if start switch is down then start from the beginning
        else current_state <= next_state; // go to next state
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

    player p1( // player one module
        .clk(clk),
        .resetn(resetn),
        .enable(enable),
        .left(leftone),
        .right(rightone),
        .player(1'b0),
        .x(x),
        .y(y),
        .colour(colour),
        .score(scoreone),
        .finish(finish));

    player p1( // player two module
        .clk(clk),
        .resetn(resetn),
        .enable(enable),
        .left(lefttwo),
        .right(righttwo),
        .player(1'b0),
        .x(x),
        .y(y),
        .colour(colour),
        .score(scoretwo),
        .finish(finish));

    always@(posedge clk) begin
        if (resetn) reset_en <= 1'b1; // send reset signal if user resets
        else reset_en <= 1'b0;
    end

endmodule

module player(
    input clk,
    input resetn,
    input enable,
    input left, right,
    input player,
    output reg [7:0] x,
    output reg [6:0] y,
    output reg [2:0] colour,
    output reg [7:0] score,
    output reg finish
    );

    reg [4:0] state;
    wire [2:0] boxcolour;
    wire [7:0] leftx;
    wire [7:0] rightx;

    if (player == 1'b0) begin // check if it's player one
        boxcolour = 3'b100; // box colour is red
        leftx = 8'b0010_0110; // left boxes' coordinate is 38
        rightx = 8'b0010_1011; // right boxes' coordinate is 43
    end
    else begin // otherwise it's player two
        boxcolour = 3'b001; // box colour is blue
        leftx = 8'b0111_0110; // left boxes' coordinate is 118
        rightx = 8'b0111_1011; // right boxes' coordinate is 123
    end

    always@(posedge clk) begin
        colour <= boxcolour;
    end

    always@(posedge clk) begin
        if (resetn) state <= 5'd0; // before game starts
        else if (enable) begin // check if game started
            if (state == 5'd0) begin // this is when game first starts
                if (right) begin
                    state <= 5'd1 // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0110_0100; // 100
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd1) begin
                if (left) begin
                    state <= 5'd2 // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0110_0001; // 97
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd2) begin
                if (left) begin
                    state <= 5'd3 // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0101_1110; // 94
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd3) begin
                if (right) begin
                    state <= 5'd4 // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0101_1011; // 91
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd4) begin
                if (left) begin
                    state <= 5'd5 // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0101_1000; // 88
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd5) begin
                if (left) begin
                    state <= 5'd6 // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0101_0101; // 85
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd6) begin
                if (left) begin
                    state <= 5'd7 // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0101_0010; // 82
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd7) begin
                if (right) begin
                    state <= 5'd8 // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0100_1111; // 79
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd8) begin
                if (left) begin
                    state <= 5'd9 // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0100_1100; // 76
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd9) begin
                if (right) begin
                    state <= 5'd10 // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0100_1001; // 73
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd10) begin
                if (right) begin
                    state <= 5'd11 // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0100_0110; // 70
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd11) begin
                if (left) begin
                    state <= 5'd12 // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0100_0011; // 67
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd12) begin
                if (right) begin
                    state <= 5'd13 // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0100_0000; // 64
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd13) begin
                if (left) begin
                    state <= 5'd14 // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0011_1101; // 61
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd14) begin
                if (left) begin
                    state <= 5'd15 // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0011_1010; // 58
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd15) begin
                if (right) begin
                    state <= 5'd16 // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0011_0111; // 55
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd16) begin
                if (right) begin
                    state <= 5'd17 // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0011_0100; // 52
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end

            else if (state == 5'd17) begin
                if (left) begin
                    state <= 5'd18 // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0011_0001; // 49
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd18) begin
                if (right) begin
                    state <= 5'd19 // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0010_1110; // 46
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd19) begin
                if (right) begin
                    state <= 5'd20 // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0010_1011; // 43
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd20) begin
                if (right) begin
                    state <= 5'd21 // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0010_1000; // 40
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd21) begin
                if (left) begin
                    state <= 5'd22 // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0010_0101; // 37
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd22) begin
                if (right) begin
                    state <= 5'd23 // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0010_0010; // 34
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd23) begin
                if (left) begin
                    state <= 5'd24 // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0001_1111; // 31
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd24) begin
                if (right) begin
                    state <= 5'd25 // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0001_1100; // 28
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd25) begin
                if (left) begin
                    state <= 5'd26 // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0001_1001; // 25
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd26) begin
                if (left) begin
                    state <= 5'd27 // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0001_0110; // 22
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd27) begin
                if (left) begin
                    state <= 5'd28 // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0001_0011; // 19
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd28) begin
                if (right) begin
                    state <= 5'd29 // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0010_0000; // 16
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd29) begin
                if (left) begin
                    state <= 5'd30 // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0000_1101; // 13
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd30) begin
                if (right) begin
                    state <= 5'd31 // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0000_1010; // 10
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd31) begin
                if (right) begin
                    state <= 5'd32 // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0000_0111; // 7
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end
            else if (state == 5'd32) begin
                if (left) begin
                    // draw in box
                    x <= leftx;
                    y <= 8'b0000_0100; // 4
                    // check the player reach the top
                    finish <= 1'b1;
                end
                else score <= score + 1'b1 // add to accuracy score because incorrect answer
            end

        end
    end

endmodule
