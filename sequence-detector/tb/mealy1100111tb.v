`timescale 1ns / 1ps

module melay1100111test;
reg in;
reg clk;
reg rst;

wire out;

// NOTE: this originally instantiated `mealy1100111design`, which does not exist —
// the module in mealy1100111.v is named `mealydesign`, so the testbench never elaborated.
mealydesign DUT(.in(in), .clk(clk), .rst(rst), .out(out));

initial 
begin
in = 0;
clk = 0;
rst = 0;
#10;

rst = 1;
#10;

rst = 0;
#10;
//////////////////////////////
in = 0;
#10;

in = 0;
#10;

in = 1;
#10;

in = 1;
#10;

in = 0;
#10;

in = 0;
#10;

in = 1;
#10;

in = 1;
#10;

in = 1;
#10;

in = 0;
#10;

in = 0;
#10;

in = 1;
#10;

in = 1;
#10;

in = 1;
#10;

in = 0;
#10;

in = 1;
#10;

in = 1;
#10;

in = 0;
#10;

in = 0;
#10;

in = 1;
#10;

in = 1;
#10;

in = 1;
#10;

#500 $finish;
end

always #5 clk = ~clk;
endmodule
