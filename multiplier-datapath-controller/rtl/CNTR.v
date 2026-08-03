`timescale 1ns / 1ps

// Loadable down-counter - register B in the datapath.
//
// Holds the iteration count. The controller loads it from data_in in state S2,
// then asserts dec once per clock through S3. When it reaches zero the EQZ
// comparator raises eqz and the controller moves on.
//
// Note there is no reset: dout is undefined until ld is asserted. That is fine
// here because the controller always loads before it decrements, but it is why
// the value shows as x in simulation until state S2.

module CNTR (
    input [31:0] din,
    input ld,        // load din
    input dec,       // decrement by one
    input clk,
    output reg [31:0] dout
    );

always@(posedge clk)

        if(ld)
            dout<= din;

        else if(dec)
            dout <= dout-1;

endmodule