`timescale 1ns / 1ps

// 32-bit adder.
//
// Purely combinational - Z follows X and Y with no clock. It sits between the
// two registers in the datapath: X is the accumulator A, Y is the addend P,
// and Z feeds back into A on the next clock edge. That feedback loop is what
// turns repeated addition into multiplication.

module ADD (Z,X,Y);
input [31:0] X,Y;

output reg [31:0] Z;
always@(*)

        Z = X + Y ;

endmodule