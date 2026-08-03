`timescale 1ns / 1ps

// Parallel-in parallel-out register - accumulator A.
//
// Takes the adder output Z when ldA is asserted, so each clock in state S3
// adds P to the running total.
//
// Note the clear value: clrA loads 32'b110010, which is decimal 50, not zero.
// That is why the multiplier's output starts at 50 and why the original
// simulation log ends at 110 rather than 60. It is preserved deliberately -
// the log in the old README is the only record of how this design was meant to
// behave, and it depends on this seed.
//
// For a general-purpose multiplier this should clear to 32'd0.

module PIPO1(
    input [31:0] Z,
    input ldA,
    input clrA,
    input clk,
    output reg [31:0] X
    );


always@(posedge clk)
if(clrA)
            X<= 32'b110010;   // decimal 50 - see note above
   else if(ldA)
            X<=Z;
endmodule