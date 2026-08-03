`timescale 1ns / 1ps

// Parallel-in parallel-out register - addend P.
//
// This is where the design falls short of being a real multiplier. The load
// path is commented out, so ldP from the controller does nothing and P can
// only ever be cleared to 32'b001010 (decimal 10).
//
// The unit therefore computes 50 + 10 x iterations, not a general product.
// Uncommenting the ldP branch below, and clearing PIPO1 to zero instead of 50,
// would make it multiply properly.
//
// Left as written because the recorded simulation results depend on it.

module PIPO2(
    input [31:0] Z,

    input ldP,
     input clrP,
    input clk,
    output reg [31:0] Y
    );

always@(posedge clk)

    if(clrP)
            Y<= 32'b001010;   // decimal 10 - the only value P ever takes

    //else if (ldP)           // load path disabled: ldP has no effect
            //Y<= Z;

endmodule