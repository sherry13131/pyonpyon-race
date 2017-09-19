module plot_cpu(
  input clk,  // cpu counter
  input enable,  // check if game started
  input ended,  // whether either cpu or player finished the game
  input reset_en,  // resets to bottom of pole
  output reg [7:0] x,
  output reg [6:0] y,
  output reg [2:0] colour
);

  reg [5:0] curr, next;

  localparam 	D0 = 6'd0,
  D1 = 6'd1,
  D2 = 6'd2,
  D3 = 6'd3,
  D4 = 6'd4,
  D5 = 6'd5,
  D6 = 6'd6,
  D7 = 6'd7,
  D8 = 6'd8,
  D9 = 6'd9,
  D10 = 6'd10,
  D11 = 6'd11,
  D12 = 6'd12,
  D13 = 6'd13,
  D14 = 6'd14,
  D15 = 6'd15,
  D16 = 6'd16,
  D17 = 6'd17,
  D18 = 6'd18,
  D19 = 6'd19,
  D20 = 6'd20,
  D21 = 6'd21,
  D22 = 6'd22,
  D23 = 6'd23,
  D24 = 6'd24,
  D25 = 6'd25,
  D26 = 6'd26,
  D27 = 6'd27,
  D28 = 6'd28,
  D29 = 6'd29,
  D30 = 6'd30,
  D31 = 6'd31,
  D32 = 6'd32,
  WAIT = 6'd33,
  WAIT_RESET = 6'd34;

  always@(posedge clk) begin: state_table
    case(curr)
      WAIT: next = enable ? D0 : WAIT; // stay in wait mode until the game starts and cpu advances
      D0: next = D1;
      D1: next = D2;
      D2: next = D3;
      D3: next = D4;
      D4: next = D5;
      D5: next = D6;
      D6: next = D7;
      D7: next = D8;
      D8: next = D9;
      D9: next = D10;
      D10: next = D11;
      D11: next = D12;
      D12: next = D13;
      D13: next = D14;
      D14: next = D15;
      D15: next = D16;
      D16: next = D17;
      D17: next = D18;
      D18: next = D19;
      D19: next = D20;
      D20: next = D21;
      D21: next = D22;
      D22: next = D23;
      D23: next = D24;
      D24: next = D25;
      D25: next = D26;
      D26: next = D27;
      D27: next = D28;
      D28: next = D29;
      D29: next = D30;
      D30: next = D31;
      D31: next = D32;
      D32: next = WAIT_RESET;
      WAIT_RESET: next = reset_en ? WAIT : WAIT_RESET; // stay here so that it doesn't keep cycling
      default: next = WAIT;
    endcase
  end

  // get the boxes to plot to blue
  always@(*) begin
    case(curr)
      D0: begin // start plotting the boxes from the bottom
        x <= 8'b0111_1011; // 123
        y <= 7'b110_0100; // 100
      end
      D1: begin
        x <= 8'b0111_0110; // 118
        y <= 7'b110_0001; // 97
      end
      D2: begin
        x <= 8'b0111_0110; // 118
        y <= 7'b101_1110; // 94
      end
      D3: begin
        x <= 8'b0111_1011; // 123
        y <= 7'b101_1011; // 91
      end
      D4: begin
        x <= 8'b0111_0110; // 118
        y <= 7'b101_1000; // 88
      end
      D5: begin
        x <= 8'b0111_0110; // 118
        y <= 7'b101_0101; // 85
      end
      D6: begin
        x <= 8'b0111_0110; // 118
        y <= 7'b101_0010; // 82
      end
      D7: begin
        x <= 8'b0111_1011; // 123
        y <= 7'b100_1111; // 79
      end
      D8: begin
        x <= 8'b0111_0110; // 118
        y <= 7'b100_1100; // 76
      end
      D9: begin
        x <= 8'b0111_1011; // 123
        y <= 7'b100_1001; // 73
      end
      D10: begin
        x <= 8'b0111_1011; // 123
        y <= 7'b100_0110; // 70
      end
      D11: begin
        x <= 8'b0111_0110; // 118
        y <= 7'b100_0011; // 67
      end
      D12: begin
        x <= 8'b0111_1011; // 123
        y <= 7'b100_0000; // 64
      end
      D13: begin
        x <= 8'b0111_0110; // 118
        y <= 7'b011_1101; // 61
      end
      D14: begin
        x <= 8'b0111_0110; // 118
        y <= 7'b011_1010; // 58
      end
      D15: begin
        x <= 8'b0111_1011; // 123
        y <= 7'b011_0111; // 55
      end
      D16: begin
        x <= 8'b0111_1011; // 123
        y <= 7'b011_0100; // 52
      end
      D17: begin
        x <= 8'b0111_0110; // 118
        y <= 7'b011_0001; // 49
      end
      D18: begin
        x <= 8'b0111_1011; // 123
        y <= 7'b010_1110; // 46
      end
      D19: begin
        x <= 8'b0111_1011; // 123
        y <= 7'b010_1011; // 43
      end
      D20: begin
        x <= 8'b0111_1011; // 123
        y <= 7'b010_1000; // 40
      end
      D21: begin
        x <= 8'b0111_0110; // 118
        y <= 7'b010_0101; // 37
      end
      D22: begin
        x <= 8'b0111_1011; // 123
        y <= 7'b010_0010; // 34
      end
      D23: begin
        x <= 8'b0111_0110; // 118
        y <= 7'b001_1111; // 31
      end
      D24: begin
        x <= 8'b0111_1011; // 123
        y <= 7'b001_1100; // 28
      end
      D25: begin
        x <= 8'b0111_0110; // 118
        y <= 7'b001_1001; // 25
      end
      D26: begin
        x <= 8'b0111_0110; // 118
        y <= 7'b001_0110; // 22
      end
      D27: begin
        x <= 8'b0111_0110; // 118
        y <= 7'b001_0011; // 19
      end
      D28: begin
        x <= 8'b0111_1011; // 123
        y <= 7'b001_0000; // 16
      end
      D29: begin
        x <= 8'b0111_0110; // 118
        y <= 7'b000_1101; // 13
      end
      D30: begin
        x <= 8'b0111_1011; // 123
        y <= 7'b000_1010; // 10
      end
      D31: begin
        x <= 8'b0111_1011; // 123
        y <= 7'b000_0111; // 7
      end
      D32: begin
        x <= 8'b0111_0110; // 118
        y <= 7'b000_0100; // 4
      end
    endcase
  end

  always@(*) begin
    if (reset_en) curr <= WAIT; // stay in wait if reset is off
    else if (ended) curr <= WAIT; // if either player or cpu finished then go back to the start
    else begin
      curr <= next; // otherwise go to next state
      colour <= 3'b001; // colour of cpu box
    end
  end

endmodule