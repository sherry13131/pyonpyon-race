// this is the simple score counter. add one when a button is clicked

//SW[3] synchronous reset when pressed
//KEY[3:0] go signal (Here just KEY[0] and KEY[1])

//HEX4,5,6,7 also displays result (Here just HEX4 and HEX5)

module score_adder(SW, KEY, CLOCK_50, HEX4, HEX5);
    input [9:0] SW;
    input [3:0] KEY;
    input CLOCK_50;
    output [6:0] HEX4, HEX5;

    wire resetn;
    wire go;

    wire [3:0] data_result_0;
    wire [3:0] data_result_1;
    assign go = (~KEY[1] | ~KEY[0]);         // not sure will it works or not
    assign resetn = SW[3];

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
    input clk,
    input resetn,
    input go,

    output reg  [3:0]counter0,  // first digit
    output reg  [3:0]counter1,  // second digit
    output reg  ld_a
    );

    reg current_state, next_state; 
    
    localparam  S_LOAD_CLICK    = 1'd0,
                S_LOAD_CLICK_WAIT   = 1'd1,
                S_CYCLE_0       = 1'd2,
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                S_LOAD_CLICK: next_state = go ? S_LOAD_CLICK_WAIT : S_LOAD_CLICK; // Loop in current state until value is input
                S_LOAD_CLICK_WAIT: next_state = go ? S_LOAD_CLICK_WAIT : S_CYCLE_0; // Loop in current state until go signal goes low
                S_CYCLE_0: next_state = S_LOAD_CLICK; // we will be done our four operations, start over after
            default:     next_state = S_LOAD_CLICK;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        ld_a = 1'b0;

        case (current_state)
            S_LOAD_CLICK:
                ld_a = 1'b1;
            S_CYCLE_0: begin // Do counter + 1
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
            end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_LOAD_CLICK;
        else
            current_state <= next_state;
    end // state_FFS
endmodule

module datapath(
    input clk,
    input resetn,
    input [3:0] data_in_0,
    input [3:0] data_in_1,
    input ld_a,
    output reg [3:0] data_result_0,
    output reg [3:0] data_result_1
    );
    
    // input registers
    reg [3:0] a;
    reg [3:0] b;
    
    // Registers a, set 0 if reset, else set to data_in(counter) then output
    always@(posedge clk) begin
        if(!resetn) begin
            a <= 4'b0;
            b <= 4'b0;
            data_result_0 <= 4'b0;
            data_result_1 <= 4'b0;
        end
        else
            if(ld_a)
                a <= data_in_0;
                b <= data_in_1;
                data_result_0 <= a;
                data_result_1 <= b;
    end
    
endmodule
