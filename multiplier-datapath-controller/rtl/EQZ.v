`timescale 1ns / 1ps

// Zero comparator.
//
// Raises eqz when the down-counter reaches zero. This is the only status
// signal the datapath sends back to the controller - everything else flows
// one way, from control to data.

module EQZ (eqz,data);
input [31:0] data;
output eqz;

assign eqz = (data == 0);

endmodule