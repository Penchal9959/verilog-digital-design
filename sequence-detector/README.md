# Sequence Detector — `1100111`

Non-overlapping detector for the bit pattern **`1100111`**, implemented twice: once as a **Mealy**
machine and once as a **Moore** machine.

Non-overlapping means the state machine returns to the start after a hit rather than reusing the
tail of the match as the head of the next one.

## State graph

Seven states track how much of the target has been matched so far. On a mismatch the machine falls
back to the state matching the longest suffix of the input that is still a prefix of the target.

| State | Matched so far | on `1` | on `0` |
|-------|----------------|--------|--------|
| S0 | — | S1 | S0 |
| S1 | `1` | S2 | S0 |
| S2 | `11` | S2 | S3 |
| S3 | `110` | S1 | S4 |
| S4 | `1100` | S5 | S0 |
| S5 | `11001` | S6 | S0 |
| S6 | `110011` | **S0, out = 1** | S0 |

The fallback edges are the interesting part — e.g. from S3 (`110`) a `1` gives `1101`, whose longest
useful suffix is `1`, so the machine goes to S1 rather than all the way back to S0.

## Files

| File | Contents |
|------|----------|
| `rtl/mealy1100111.v` | Mealy implementation (`mealydesign`) |
| `rtl/moorey1100111.v` | Moore implementation |
| `tb/mealy1100111tb.v` | Original directed-stimulus testbench |
| `tb/moorey1100111tb.v` | Original directed-stimulus testbench |
| `tb/sequence_detector_selfcheck_tb.v` | **Added** — self-checking testbench |

## Simulation

```bash
make seqdet              # from the repository root
```

The self-checking testbench streams `1100111 0 1100111` — two non-overlapping occurrences — and
asserts that the detector fires exactly twice:

```
bit 6:  in=1 out=1
bit 14: in=1 out=1

detections = 2 (expected 2)
PASS
```

## Notes on the original code

- **`mealy1100111tb.v` never elaborated.** It instantiated `mealy1100111design`, but the module in
  `mealy1100111.v` is named `mealydesign`. Fixed.

- **Neither original testbench printed anything** — no `$display`, no comparison — so the only way
  to judge them was to inspect a waveform by hand. Hence the added self-checking bench.

- **`out` is assigned inside the clocked block with blocking assignments**, so this "Mealy" machine
  actually presents a registered output, giving it Moore-like timing. It also means a testbench
  sampling `out` on `posedge` races against the DUT and reads a stale value — the self-checking
  bench samples on `negedge` for this reason.

- The design uses a single `always @(posedge clk)` block driving `cst`, `nst` and `out` with
  blocking assignments. The conventional structure is three blocks: a clocked state register using
  non-blocking assignment, a combinational next-state block, and a separate output block.

**The state graph itself is correct** — all seven states and every fallback edge check out, and the
machine detects the target with no false positives across the test stream.
