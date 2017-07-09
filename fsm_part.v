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

module adder(
    input clk,
    input resetn,
    input go,
    output [3:0] data_result_0,
    output [3:0] data_result_1,
    );

    // lots of wires to connect our datapath and control
    wire ld_a;     // ld_a will be one when button is clicked
    wire [3:0]  counter0;
    wire [3:0]  counter1;

    control C0(
        .clk(clk),
        .resetn(resetn),
        .go(go),
        
        .counter0(counter0),
        .counter1(counter1),
        .ld_a(ld_a)
    );

    datapath D0(
        .clk(clk),
        .resetn(resetn),

        .ld_a(ld_a),

        .data_in_0(counter0),
        .data_in_1(counter1),
        .data_result_0(data_result_0)
        .data_result_1(data_result_1)
    );

endmodule

module control(
    // --- signals ---
    input clk,
    input resetn,   //reset
    input go1,      //left key
    input go2,      //right key
    input start,    //start - when the game start with SW[0] on
    input [1:0]pressed,  //player pressed, left key:2'b1, right key:2'b2
    input correct_box,   //the position of the next box
    input add_box,      //signal to add box when the right box is clicked
    input another_player_end,  // check whether the another player finish the game or not

    // --- variables ---
    input total,       // total number of the player clicked the right box
    input [7:0]score,    //score of the player

    output reg  [3:0]counter0,  // first digit
    output reg  [3:0]counter1,  // second digit
    output reg  ld_a
    );

    reg current_state, next_state; 
    
    localparam  START           = 2'd0,
                S_LOAD_CLICK    = 2'd1,
                S_CLICKED_1_WAIT   = 2'd2,
                S_CLICKED_2_WAIT   = 2'd3,
                S_CHECK_ANS_1       = 2'd4,
                S_CHECK_ANS_2       = 2'd5,
                S_CHECK_ANS_1_UPDATE = 2'd6
                S_CHECK_ANS_2_UPDATE = 2'd7
                PLOT                = 2'd8,
                ADD_BOX_CLICKED     = 2'd9,
                END            = 2'd10,
                RESTART_WAIT    = 2'd11,
                RESTART         = 2'd12;
    
    // state table FSM
    always@(*)
    begin: state_table 
            case (current_state)
                START: next_state = start ? S_LOAD_CLICK : START; // start the game and enter the state loop
                S_LOAD_CLICK: // Loop in current state until value is input
                begin

                    if (another_player_end)     // if another player reach the top, end
                        next_state = END;
                    else if (go1 == 1'b1 && pressed == 2'b0)
                        next_state = S_CLICKED_1_WAIT;
                    else if (go2 == 1'b1 && pressed == 2'b0)
                        next_state = S_CLICKED_2_WAIT;
                    else
                        next_state = S_LOAD_CLICK;
                end
                S_CLICKED_1_WAIT: // Loop in current state until go signal goes low (for left)
                begin
                    if (another_player_end)     // if another player reach the top, end
                        next_state = END;
                    else if (go1 == 1'b1)
                        next_state = S_CLICKED_1_WAIT;
                    else
                        next_state = PLOT;
                end
                S_CLICKED_2_WAIT: // Loop in current state until go signal goes low (for right)
                begin
                    if (another_player_end)     // if another player reach the top, end
                        next_state = END;
                    else if (go1)
                        next_state = S_CLICKED_2_WAIT;
                    else
                        next_state = PLOT;

                // S_CHECK_ANS_1: next_state = correct_box ? S_LOAD_CLICK : S_CHECK_ANS_1_UPDATE; // if correct_box is 0 (left key) then update the signal

                //S_CHECK_ANS_2: next_state = correct_box ? S_CHECK_ANS_2_UPDATE : S_LOAD_CLICK; // if correct_box is 1 (right key) then update the signal

                //S_CHECK_ANS_1_UPDATE: next_state = PLOT;
                //S_CHECK_ANS_2_UPDATE: next_state = PLOT;

                PLOT : next_state = S_LOAD_CLICK; // might have to use this ->ADD_BOX_CLICKED;
                //ADD_BOX_CLICKED : next_state = (total == "total#OfBoxes") ? END : S_LOAD_CLICK // state to the END when the player reach the top.

                END: next_state = RESTART_WAIT;
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
        start = 1'b0;
        pressed = 1'b0;
        correct = 1'b0;
        add_box = 1'b0;
        plot = 1'b0;


        case (current_state)
            START:
                begin
                    resetn = 1'b1;
                end
            S_CLICKED_1_WAIT:
                pressed = 2'b1;
            S_CLICKED_2_WAIT:
                pressed = 2'b2;

            /* S_CHECK_ANS_1_UPDATE: begin //if the box is correct, match the key player clicked (
            left)
            begin
                correct = 1'b1; 

/*  might be putting somewhere but not here
                if (!correct_box)
                begin
                    if (counter0 == 1'd9) // if first digit counter is 9
                    begin
                        counter0 <= 0
                        if (counter1 == 1'd9) // if second digit counter is 9
                            counter1 <= 0
                        else
                            counter1 <= counter1 + 1;
                    end
                    else
                    counter0 = counter0 + 1;
                end */

            end
            S_CHECK_ANS_2_UPDATE: begin //if the box is correct, match the key player clicked (right)
            begin
                correct = 1'b1;

/*  might be putting somewhere but not here
                if (correct_box)
                begin
                    if (counter0 == 1'd9) // if first digit counter is 9
                    begin
                        counter0 <= 0
                        if (counter1 == 1'd9) // if second digit counter is 9
                            counter1 <= 0
                        else
                            counter1 <= counter1 + 1;
                    end
                    else
                    counter0 = counter0 + 1;
                end */

            end */

            PLOT: //draw the dot of the coorrdinate
                plot = 1'b1;


        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= RESTART;
        else
            current_state <= next_state;
    end // state_FFS
endmodule



module datapath(
    input clk,
    input resetn,
    input start,
    input [3:0] counter0,
    input [3:0] counter1,
    input [1:0] pressed,
    input correct_box,
    //input num_correct_box,

    output finish,
    output reg [3:0] counter0,
    output reg [3:0] counter1,
    );
    
    localparam
    // colour and coordinates parameters


    // input registers
    reg [3:0] a;
    reg [3:0] b;
    
    initial increased_score = 0;

    // Registers a, set 0 if reset, else set to data_in(counter) then output
    always@(posedge clk) begin
        // when left key is pressed
        if (pressed == 2'b1)
            begin
                if (correct_box == 1'b0 && increased_score == 1'b0)
                    begin
                        if (counter0 == 1'd9) // if first digit counter is 9
                        begin
                            counter0 <= 0
                            if (counter1 == 1'd9) // if second digit counter is 9
                                counter1 <= 0
                            else
                                counter1 <= counter1 + 1;
                        end
                        else
                            counter0 = counter0 + 1;
                        increased_score = 1'b1;
                    end

            end
        // when right key is pressed
        else if (pressed == 2'b2)
            begin
                if (correct_box == 1'b1 && increased_score == 1'b0)
                    begin
                        if (counter0 == 1'd9) // if first digit counter is 9
                        begin
                            counter0 <= 0
                            if (counter1 == 1'd9) // if second digit counter is 9
                                counter1 <= 0
                            else
                                counter1 <= counter1 + 1;
                        end
                        else
                            counter0 = counter0 + 1;
                        increased_score = 1'b1;
                    end
            end
    
endmodule
