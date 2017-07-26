module plot(
  input clk,
  input enable,
  input ended,
  input resetn,
  input correctkey_posedge,
  input cpu_counter,
  output reg [7:0] x,
  output reg [6:0] y,
  output reg [2:0] colour
);

  wire [7:0] player_x;
  wire [6:0] player_y;
  wire [2:0] player_colour;

  wire [7:0] cpu_x;
  wire [6:0] cpu_y;
  wire [2:0] cpu_colour;

  wire [7:0] reset_x;
  wire [6:0] reset_y;
  wire [2:0] reset_colour;

  assign reset = resetn;

  plot_player player_plot(  // plots on vga adapter for player
    .clk(correctkey_posedge),
    .enable(enable),
    .ended(ended),
    .reset_en(reset),
    .x(player_x),
    .y(player_y),
    .colour(player_colour)
  );

  plot_cpu cpu_plot(  // plots on vga adapter for cpu
    .clk(cpu_counter),
    .enable(enable),
    .ended(ended),
    .reset_en(reset),
    .x(cpu_x),
    .y(cpu_y),
    .colour(cpu_colour)
  );

  reset reset_plot(  // plots on vga adapter when reset
    .clk(clk),
    .reset_en(resetn),
    .x(reset_x),
    .y(reset_y),
    .colour(reset_colour)
  );

  always@(posedge resetn, posedge correctkey_posedge, posedge cpu_counter) begin
    if (resetn) begin
      x <= reset_x;
      y <= reset_y;
      colour <= reset_colour;
    end
    else if (correctkey_posedge) begin
      x <= player_x;
      y <= player_y;
      colour <= player_colour;
    end
    else if (cpu_counter) begin
      x <= cpu_x;
      y <= cpu_y;
      colour <= cpu_colour;
    end
    else begin
      x <= x;
      y <= y;
      colour <= colour;
    end
  end

endmodule

