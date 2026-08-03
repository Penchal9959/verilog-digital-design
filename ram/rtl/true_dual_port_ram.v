`timescale 1ns / 1ps

// true_dual_port_ram.v
//
// A genuine dual-port RAM, provided as the corrected counterpart to
// `memorydesign.v`.
//
// `memorydesign.v` is named "Dualport_RAM" but exposes a single address bus
// shared by the read and write paths, and a single clock. That is a single-port
// RAM with separate read/write enables — only one location can be reached per
// cycle.
//
// A true dual-port RAM has two fully independent ports, each with its own
// clock, address, data and enables, so two different locations can be accessed
// in the same cycle. That is what this module implements.

module true_dual_port_ram #(
    parameter DATA_WIDTH = 4,
    parameter ADDR_WIDTH = 8
) (
    // Port A
    input                       clk_a,
    input                       en_a,
    input                       we_a,
    input      [ADDR_WIDTH-1:0] addr_a,
    input      [DATA_WIDTH-1:0] din_a,
    output reg [DATA_WIDTH-1:0] dout_a,

    // Port B
    input                       clk_b,
    input                       en_b,
    input                       we_b,
    input      [ADDR_WIDTH-1:0] addr_b,
    input      [DATA_WIDTH-1:0] din_b,
    output reg [DATA_WIDTH-1:0] dout_b
);

    reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

    // Port A — write-first
    always @(posedge clk_a) begin
        if (en_a) begin
            if (we_a) begin
                mem[addr_a] <= din_a;
                dout_a      <= din_a;
            end else begin
                dout_a <= mem[addr_a];
            end
        end
    end

    // Port B — write-first
    always @(posedge clk_b) begin
        if (en_b) begin
            if (we_b) begin
                mem[addr_b] <= din_b;
                dout_b      <= din_b;
            end else begin
                dout_b <= mem[addr_b];
            end
        end
    end

    // Note: simultaneous writes to the same address from both ports are a
    // collision. The result is undefined in hardware; arbitrate externally.

endmodule
