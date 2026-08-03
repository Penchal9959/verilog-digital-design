# RAM

Synchronous memory in Verilog — the original 2021 design, plus a corrected true dual-port
implementation.

## Files

| File | Description |
|------|-------------|
| `rtl/memorydesign.v` | `Dualport_RAM` — 256 × 4-bit synchronous RAM, chip-select gated |
| `rtl/true_dual_port_ram.v` | **Added** — parameterised true dual-port RAM |
| `tb/memorytestbench.v` | Original testbench, with `$finish` and read-back checks added |
| `tb/true_dual_port_ram_tb.v` | **Added** — self-checking testbench |

## The naming problem

`memorydesign.v` is named `Dualport_RAM`, but it is not a dual-port RAM:

```verilog
module Dualport_RAM(clk, cs, wr, rd, addr, data_in, data_out);
input clk, cs, wr, rd;
input  [3:0] data_in;
input  [7:0] addr;        // <-- one address bus
output reg [3:0] data_out;
```

There is **one** address bus, **one** clock and **one** data input. Read and write have separate
enables but share the address, so only one location can be reached in any given cycle. That is a
**single-port RAM with read/write enables**.

A true dual-port RAM has two independent ports — each with its own clock, address, data in, data out
and enables — so two *different* addresses can be accessed simultaneously. This is what block RAM
primitives on Xilinx and Intel FPGAs provide, and what makes clock-domain-crossing FIFOs and
multi-master buffers possible.

[`true_dual_port_ram.v`](rtl/true_dual_port_ram.v) implements that properly: parameterised width and
depth, write-first behaviour on both ports, and a note on the write-write collision case, which is
undefined in hardware and must be arbitrated externally.

## Simulation

```bash
make ram                 # from the repository root
```

Original single-port design:

```
read  addr=1 -> data_out=0001 (expected 0001)
read  addr=2 -> data_out=0010 (expected 0010)
```

True dual-port — both ports hitting different addresses in the same cycle:

```
ok   port A reads addr 20 = 0101
ok   port B reads addr 10 = 1010

PASS - all checks passed
```

## Note on the original testbench

`memorytestbench.v` had **no `$finish`**. Its stimulus block ran out but the clock generator kept
toggling, so the simulation never terminated — it had to be killed manually. A `$finish` and two
read-back `$display` checks have been added.
