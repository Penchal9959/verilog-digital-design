`timescale 1ns / 1ps

// 256 x 4-bit synchronous RAM with chip select.
//
// The name is wrong, and it is worth being clear about why rather than leaving
// someone to work it out.
//
// This module has ONE address bus, ONE clock and ONE data input. Read and
// write have separate enables, but they share the address, so only one
// location can be reached in any given cycle. That is a single-port RAM.
//
// A true dual-port RAM has two independent ports, each with its own clock,
// address, data in, data out and enables, so two different addresses can be
// accessed simultaneously. That is what block RAM primitives on Xilinx and
// Intel FPGAs give you, and what makes clock-domain-crossing FIFOs possible.
//
// See rtl/true_dual_port_ram.v for an implementation that actually is one.
//
// Behaviour here: when cs is low the output is forced to zero. Otherwise a
// write stores data_in at addr, and a read returns mem[addr] on the next edge.
// Asserting wr and rd together writes and returns the OLD contents, since both
// use non-blocking assignment - read-first behaviour, though that looks more
// like an accident of coding style than a decision.

module Dualport_RAM(clk,cs,wr,rd,addr,data_in,data_out);
input clk,cs,wr,rd;
input[3:0] data_in;  
input [7:0] addr; 
output reg[3:0]data_out;  
reg [3:0] mem[255:0]; 

always@(posedge clk)
begin
if(~cs)
data_out <= 4'b0000;
else
begin 
if(wr)
mem[addr] <= data_in;
if(rd)
data_out <= mem[addr];
end
end
endmodule


