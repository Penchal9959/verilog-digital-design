`timescale 1ns / 1ps

// Datapath - the arithmetic half of the design.
//
// Structural only: this module wires the pieces together and contains no logic
// of its own. Everything is driven by the control signals coming from the FSM.
//
//        data_in
//           |
//           v
//    +-------------+
//    |  CNTR (B)   |---> Bout ---> EQZ ---> eqz  (back to the controller)
//    +-------------+
//
//    +-------------+
//    |  PIPO1 (A)  |---> X ---+
//    +-------------+          |
//           ^                 +--> ADD ---> Z ---+
//           |                 |                  |
//           |          +------+                  |
//           |          |                         |
//    +-------------+   |                         |
//    |  PIPO2 (P)  |---> Y                       |
//    +-------------+                             |
//           ^                                    |
//           +------------------------------------+
//                    Z feeds back into A
//
// The feedback from Z into A is what makes this a multiplier: each pass round
// the loop adds P to the running total, and B counts the passes.

module MUL_datapath(eqz, LdA, LdB, LdP, clrP,clrA, decB, data_in,clk,X,Y,Z,Bout);

input  LdA, LdB, LdP, clrP,clrA, decB,clk;
input [31:0] data_in;
//input [15:0] pdata_in;
output eqz;
output [31:0] X,Y,Z,Bout;


PIPO1 A (Z,LdA,clrA,clk,X);		// Register for A //
PIPO2 P (Z,LdP,clrP,clk,Y);	
//PIPO2 P (Z,LdP,pdata_in,clk,Y);       // Register for P //
CNTR B  (data_in,LdB,decB,clk,Bout);	     // Down counter for B //
ADD AD  (Z,X,Y);			   // Adder Module //
EQZ COMP (eqz,Bout);	         // A comparator ,that checks if B = zero or not //



endmodule