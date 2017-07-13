module player(
    input clk,
    input resetn,
    input enable,
    input left, right,
    input playernumber,
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

    if (playernumber == 1'b0) begin // check if it's player one
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
                    state <= 5'd1; // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0110_0100; // 100
                end
                else score <= score + 1'b1; // add to accuracy score because incorrect answer
            end
            else if (state == 5'd1) begin
                if (left) begin
                    state <= 5'd2; // go to next box because correct answer
                end
                else score <= score + 1'b1; // add to accuracy score because incorrect answer
            end
            else if (state == 5'd2) begin
                if (left) begin
                    state <= 5'd3; // go to next box because correct answer
                end
                else score <= score + 1'b1; // add to accuracy score because incorrect answer
            end
            else if (state == 5'd3) begin
                if (right) begin
                    state <= 5'd4; // go to next box because correct answer
                end
                else score <= score + 1'b1; // add to accuracy score because incorrect answer
            end
            else if (state == 5'd4) begin
                if (left) begin
                    state <= 5'd5; // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0101_1000; // 88
                end
                else score <= score + 1'b1; // add to accuracy score because incorrect answer
            end
            else if (state == 5'd5) begin
                if (left) begin
                    state <= 5'd6; // go to next box because correct answer
                end
                else score <= score + 1'b1; // add to accuracy score because incorrect answer
            end
            else if (state == 5'd6) begin
                if (left) begin
                    state <= 5'd7; // go to next box because correct answer
                end
                else score <= score + 1'b1; // add to accuracy score because incorrect answer
            end
            else if (state == 5'd7) begin
                if (right) begin
                    state <= 5'd8; // go to next box because correct answer
                end
                else score <= score + 1'b1; // add to accuracy score because incorrect answer
            end
            else if (state == 5'd8) begin
                if (left) begin
                    state <= 5'd9; // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0100_1100; // 76
                end
                else score <= score + 1'b1; // add to accuracy score because incorrect answer
            end
            else if (state == 5'd9) begin
                if (right) begin
                    state <= 5'd10; // go to next box because correct answer
                end
                else score <= score + 1'b1; // add to accuracy score because incorrect answer
            end
            else if (state == 5'd10) begin
                if (right) begin
                    state <= 5'd11; // go to next box because correct answer
                end
                else score <= score + 1'b1; // add to accuracy score because incorrect answer
            end
            else if (state == 5'd11) begin
                if (left) begin
                    state <= 5'd12; // go to next box because correct answer
                end
                else score <= score + 1'b1; // add to accuracy score because incorrect answer
            end
            else if (state == 5'd12) begin
                if (right) begin
                    state <= 5'd13; // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0100_0000; // 64
                end
                else score <= score + 1'b1; // add to accuracy score because incorrect answer
            end
            else if (state == 5'd13) begin
                if (left) begin
                    state <= 5'd14; // go to next box because correct answer
                end
                else score <= score + 1'b1; // add to accuracy score because incorrect answer
            end
            else if (state == 5'd14) begin
                if (left) begin
                    state <= 5'd15; // go to next box because correct answer
                end
                else score <= score + 1'b1; // add to accuracy score because incorrect answer
            end
            else if (state == 5'd15) begin
                if (right) begin
                    state <= 5'd16; // go to next box because correct answer
                end
                else score <= score + 1'b1; // add to accuracy score because incorrect answer
            end
            else if (state == 5'd16) begin
                if (right) begin
                    state <= 5'd17; // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0011_0100; // 52
                end
                else score <= score + 1'b1; // add to accuracy score because incorrect answer
            end

            else if (state == 5'd17) begin
                if (left) begin
                    state <= 5'd18; // go to next box because correct answer
                end
                else score <= score + 1'b1; // add to accuracy score because incorrect answer
            end
            else if (state == 5'd18) begin
                if (right) begin
                    state <= 5'd19; // go to next box because correct answer
                end
                else score <= score + 1'b1; // add to accuracy score because incorrect answer
            end
            else if (state == 5'd19) begin
                if (right) begin
                    state <= 5'd20; // go to next box because correct answer
                end
                else score <= score + 1'b1; // add to accuracy score because incorrect answer
            end
            else if (state == 5'd20) begin
                if (right) begin
                    state <= 5'd21; // go to next box because correct answer
                    // draw in box
                    x <= rightx;
                    y <= 8'b0010_1000; // 40
                end
                else score <= score + 1'b1; // add to accuracy score because incorrect answer
            end
            else if (state == 5'd21) begin
                if (left) begin
                    state <= 5'd22; // go to next box because correct answer
                end
                else score <= score + 1'b1; // add to accuracy score because incorrect answer
            end
            else if (state == 5'd22) begin
                if (right) begin
                    state <= 5'd23; // go to next box because correct answer
                end
                else score <= score + 1'b1; // add to accuracy score because incorrect answer
            end
            else if (state == 5'd23) begin
                if (left) begin
                    state <= 5'd24; // go to next box because correct answer
                end
                else score <= score + 1'b1; // add to accuracy score because incorrect answer
            end
            else if (state == 5'd24) begin
                if (right) begin
                    state <= 5'd25; // go to next box because correct answer
                end
                else score <= score + 1'b1; // add to accuracy score because incorrect answer
            end
            else if (state == 5'd25) begin
                if (left) begin
                    state <= 5'd26; // go to next box because correct answer
                    // draw in box
                    x <= leftx;
                    y <= 8'b0001_1001; // 25
                end
                else score <= score + 1'b1; // add to accuracy score because incorrect answer
            end
            else if (state == 5'd26) begin
                if (left) begin
                    state <= 5'd27; // go to next box because correct answer
                end
                else score <= score + 1'b1; // add to accuracy score because incorrect answer
            end
            else if (state == 5'd27) begin
                if (left) begin
                    state <= 5'd28; // go to next box because correct answer
                end
                else score <= score + 1'b1; // add to accuracy score because incorrect answer
            end
            else if (state == 5'd28) begin
                if (right) begin
                    state <= 5'd29; // go to next box because correct answer
                end
                else score <= score + 1'b1; // add to accuracy score because incorrect answer
            end
            else if (state == 5'd29) begin
                if (left) begin
                    state <= 5'd30; // go to next box because correct answer
                end
                else score <= score + 1'b1; // add to accuracy score because incorrect answer
            end
            else if (state == 5'd30) begin
                if (right) begin
                    state <= 5'd31; // go to next box because correct answer
                end
                else score <= score + 1'b1; // add to accuracy score because incorrect answer
            end
            else if (state == 5'd31) begin
                if (right) begin
                    state <= 5'd32; // go to next box because correct answer
                end
                else score <= score + 1'b1; // add to accuracy score because incorrect answer
            end
            else if (state == 5'd32) begin
                if (left) begin
                    // draw in box
                    x <= leftx;
                    y <= 8'b0000_0100; // 4
                    // check the player reach the top
                    finish <= 1'b1;
                end
                else score <= score + 1'b1; // add to accuracy score because incorrect answer
            end
        end
	 end

endmodule