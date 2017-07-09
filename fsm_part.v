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
                RESTART_WAIT    = 2'd3,
                RESTART         = 2'd4;
    
    // state table FSM
    always@(*)
    begin: state_table 
            case (current_state)
                START: next_state = start ? S_LOAD_CLICK : START; // start the game and enter the state loop
                S_LOAD_CLICK: // Loop in current state until value is input
                begin

                    if (finish)     // if another player reach the top, end
                        next_state = RESTART_WAIT;
                    else
                        next_state = S_LOAD_CLICK;
                end

                RESTART_WAIT = next_state = resetn ? RESTART_WAIT : RESTART;
                RESTART = next_state = start ? RESTART : S_LOAD_CLICK;
            default:     next_state = S_LOAD_CLICK;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        resetn = 1'b0;
        start = 1'b0

        case (current_state)
            START:
                resetn = 1'b1;
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
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
    output reg [7:0] x,
    output reg [6:0] y,
    output reg [2:0] colour,
    output reg [7:0] time,
    output reg [7:0] scoreone,
    output reg [7:0] scoretwo
    );

    player p1( // to fill in
        .clk
        .resetn
        .enable
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
    output reg [7:0] score,
    output reg finish
    );

    initial finish = 1'b0;
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