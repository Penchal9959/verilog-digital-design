`timescale 1ns / 1ps

// multiplier_top.v
//
// Top level tying the FSM controller to the multiplier datapath.
// The original repository shipped `controller.v` and `datapath.v` as separate
// units with nothing connecting them, so the design could never be simulated
// end to end. This module supplies that missing top level.

module multiplier_top (
    input         clk,
    input         start,
    input  [31:0] data_in,   // multiplier: number of accumulate iterations
    output        done,
    output [31:0] X,         // accumulator A
    output [31:0] Y,         // addend P
    output [31:0] Z,         // adder result, fed back into A
    output [31:0] Bout       // down-counter B
);

    wire LdA, LdB, LdP, clrP, clrA, decB, eqz;

    controller u_ctrl (
        .LdA   (LdA),
        .LdB   (LdB),
        .LdP   (LdP),
        .clrP  (clrP),
        .clrA  (clrA),
        .decB  (decB),
        .done  (done),
        .clk   (clk),
        .eqz   (eqz),
        .start (start)
    );

    MUL_datapath u_dp (
        .eqz     (eqz),
        .LdA     (LdA),
        .LdB     (LdB),
        .LdP     (LdP),
        .clrP    (clrP),
        .clrA    (clrA),
        .decB    (decB),
        .data_in (data_in),
        .clk     (clk),
        .X       (X),
        .Y       (Y),
        .Z       (Z),
        .Bout    (Bout)
    );

endmodule
