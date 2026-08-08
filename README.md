# Verilog Digital Design

RTL exercises in Verilog — an FSM-controlled multiplier, memory, and sequence detectors — with
testbenches that actually run and self-check.

## Status

All three designs simulate cleanly under **Icarus Verilog 12.0** and pass their checks. `make`
builds and runs everything; the log is under [Results](#results).

Undergraduate coursework, cleaned up and repaired. My current research is in GNSS signal
processing and FPGA design. See my [profile](https://github.com/Penchal9959).

## Repository layout

```
verilog-digital-design/
├── multiplier-datapath-controller/
│   ├── rtl/        # synthesisable sources
│   ├── tb/         # testbenches
│   ├── run.do      # ModelSim script
│   └── README.md
├── sequence-detector/   # same four entries
├── ram/                 # same four entries
├── Makefile
└── LICENSE
```

## Requirements

- Icarus Verilog 12.0, free and cross-platform, with `make`.
- ModelSim or QuestaSim, as an alternative.

## Build and run

```bash
make            # build and run everything
make multiplier
make seqdet
make ram
make clean
```

Each design ships a `run.do` script for ModelSim or QuestaSim:

```tcl
cd multiplier-datapath-controller
vsim -do run.do
```

The original repositories contained ModelSim `.mpf` project files with absolute paths baked in
(`C:/modeltech64_10.5/examples/...`). Those were machine-specific and have been replaced with
portable `.do` scripts.

## Results

```
$ make
=== multiplier ===        final result Z = 110 (expected 110)   PASS
=== sequence-detector ===  detections = 2 (expected 2)          PASS
=== dual-port ram ===      all checks passed                    PASS
```

## How it works

| Design | Description |
|--------|-------------|
| [multiplier-datapath-controller](multiplier-datapath-controller/) | Multiply-by-repeated-addition, split into a 5-state FSM controller and a 32-bit datapath (accumulator, down-counter, adder, zero-comparator) — the classic datapath/control-path partition |
| [sequence-detector](sequence-detector/) | Non-overlapping `1100111` detector, implemented twice: Mealy and Moore |
| [ram](ram/) | Synchronous RAM — the original single-port design, plus a true dual-port implementation |

**Repairs made to the original code.** These designs were written in 2021 and published without
ever being simulated end to end. The issues below were found and fixed while consolidating the
repositories — they are listed openly because the debugging is a more useful record than the code
itself.

| Issue | Effect | Fix |
|-------|--------|-----|
| No `` `timescale `` in any RTL file | `#1`/`#2` delays in `controller.v` ran at the default 1-second unit against a 10 ns clock, so no control signal ever settled — the whole simulation stayed at `x` | Added `` `timescale 1ns / 1ps `` to every file |
| No top module joining `controller` and `MUL_datapath` | The multiplier could not be simulated as a whole; the README shipped a pasted log instead | Added [`multiplier_top.v`](multiplier-datapath-controller/rtl/multiplier_top.v) |
| No testbench for the multiplier | Untested | Added [`multiplier_tb.v`](multiplier-datapath-controller/tb/multiplier_tb.v), self-checking |
| `mealy1100111tb.v` instantiated `mealy1100111design` | No such module — the module is `mealydesign`, so the testbench never elaborated | Corrected the instantiation |
| `memorytestbench.v` had no `$finish` | Simulation ran forever | Added `$finish` and read-back checks |
| Sequence-detector testbenches had no `$display` or comparison | Pass/fail could only be judged by eye from a waveform | Added [`sequence_detector_selfcheck_tb.v`](sequence-detector/tb/sequence_detector_selfcheck_tb.v) |
| `memorydesign.v` named `Dualport_RAM` but is single-port | One shared address bus and one clock — cannot do two accesses per cycle | Documented accurately; added [`true_dual_port_ram.v`](ram/rtl/true_dual_port_ram.v) as a correct implementation |

## Known limitations

Two further quirks are **documented but deliberately left as-is**, because the original simulation
log in the old README depends on them — see
[the multiplier README](multiplier-datapath-controller/README.md):

- `PIPO1.v` clears the accumulator to `32'b110010` (decimal 50), not 0.
- `PIPO2.v` has its `ldP` load path commented out, so `P` is fixed at 10.

## Licence

[MIT](LICENSE) © Penchalanarasaiah Kuncham
