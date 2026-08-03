# Multiplier — Datapath / Control-Path Partition

A multiply-by-repeated-addition unit, built as the textbook **datapath + control-path** split: a
finite state machine issues control signals in sequence, and a separate datapath of registers,
counter, adder and comparator does the arithmetic.

## Architecture

```
              start ─┐                      ┌─ done
                     ▼                      │
              ┌──────────────┐              │
              │  controller  │──────────────┘
              │  (5-state)   │
              └──────┬───────┘
       LdA LdB LdP   │   clrA clrP decB
       ┌─────────────┴─────────────┐
       ▼                           │  eqz
┌──────────────────────────────────┴─────┐
│            MUL_datapath                │
│                                        │
│  PIPO1 (A) ──┐                         │
│              ├── ADD ── Z ──┐          │
│  PIPO2 (P) ──┘              │          │
│      ▲──────────────────────┘          │
│                                        │
│  CNTR (B) ── EQZ ── eqz ───────────────┼──▶
└────────────────────────────────────────┘
```

| Module | Role |
|--------|------|
| `controller.v` | 5-state FSM (S0–S4) generating all control signals |
| `datapath.v` | `MUL_datapath` — structural wiring of the units below |
| `PIPO1.v` | Accumulator register **A** |
| `PIPO2.v` | Addend register **P** |
| `CNTR.v` | Loadable down-counter **B** — the loop counter |
| `ADD.v` | 32-bit combinational adder, `Z = X + Y` |
| `EQZ.v` | Zero comparator, drives `eqz` |
| `multiplier_top.v` | **Added** — top level joining controller and datapath |

## FSM

| State | Action |
|-------|--------|
| S0 | idle; wait for `start` |
| S1 | clear accumulator A |
| S2 | load counter B from `data_in`, clear P |
| S3 | accumulate: `A ← A + P`, `B ← B − 1`; loop until `eqz` |
| S4 | assert `done`, hold |

## Simulation

```bash
make multiplier          # from the repository root
```

Output:

```
  time |    B |    A |    P |    Z | done
-------+------+------+------+------+-----
 35000 |    x |   50 |    x |    x |    x
 45000 |    5 |   50 |   10 |   60 |    x
 55000 |    4 |   60 |   10 |   70 |    x
 65000 |    3 |   70 |   10 |   80 |    x
 75000 |    2 |   80 |   10 |   90 |    x
 85000 |    1 |   90 |   10 |  100 |    x
 95000 |    0 |  100 |   10 |  110 |    1

final result Z = 110 (expected 110)
PASS
```

This reproduces exactly the simulation log that was pasted into the original repository's README.

## Known quirks in the original RTL

Both are **left in place deliberately** — they are what produce the numbers above, and the original
log is the only record of how this design was meant to behave.

**1. The accumulator clears to 50, not 0** — [`PIPO1.v`](rtl/PIPO1.v):

```verilog
if (clrA)
    X <= 32'b110010;   // = decimal 50
```

**2. `P` can never be loaded** — [`PIPO2.v`](rtl/PIPO2.v) has the load path commented out:

```verilog
if (clrP)
    Y <= 32'b001010;   // = decimal 10
//else if (ldP)
//    Y <= Z;
```

So `LdP` from the controller has no effect and `P` is permanently 10. The unit therefore computes
`50 + 10 × (iterations)` rather than a general product.

To make it a general multiplier, uncomment the `ldP` branch and clear `X` to `32'd0` instead of 50.

**3. Delays inside `always` blocks** — `controller.v` uses `#1` and `#2` inside its procedural
blocks, with a comment that they were added "so as to get better simulation results". These are not
synthesisable and mask a race between the state register and the output decoder; a proper fix is to
split the FSM into a clocked state register and a combinational output block using non-blocking
assignments for state.
