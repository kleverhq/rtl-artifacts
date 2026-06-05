# tb_complex_types

SystemVerilog compatibility testbench for comparing how different simulators
dump simple and complex SV types into waveform databases.

## Why this exists

This directory grew out of a sequence of practical questions:

- what actually happens to complex SystemVerilog types in VCD/FST dumps
- can we build one small testbench with a clock and signals ranging from
  scalars to nested structs, arrays, and unions
- can we run the same source on the major simulators, one target per simulator,
  each in its own isolated run directory
- can we expand that further so each simulator is exercised in every dump
  format it supports

The result is a small cross-simulator probe for waveform dump behavior rather
than a polished verification environment.

## What it covers

`tb.sv` initializes every object and then updates it across 5 stimulus steps.
The testbench includes:

- scalar and vector integral types
- `real`, `shortreal`, and `string`
- enums
- packed and unpacked structs
- packed unions
- nested structs and struct-with-union payloads
- packed and unpacked arrays, including multidimensional arrays
- arrays of structs
- structs with unpacked array fields
- dynamic arrays, queues, associative arrays, class handles, and events

Some of these constructs are expected to be represented inconsistently across
simulators and dump formats, which is the main point of the fixture.

## Files

- `tb.sv` - standalone testbench with top module `tb_complex_types`
- `Makefile` - one target per simulator and dump-format combination

## Targets

Run commands from `projects/tb_complex_types/`.

There are also umbrella targets per simulator that build every dump format that
simulator supports.

Questa:

```sh
make questa
make questa-wlf
make questa-vcd
make questa-fsdb
```

VCS:

```sh
make vcs
make vcs-vpd
make vcs-vcd
make vcs-fsdb
```

Xcelium:

```sh
make xcelium
make xcelium-shm
make xcelium-vcd
make xcelium-fsdb
```

Verilator:

```sh
make verilator
make verilator-vcd
make verilator-fst
```

Icarus:

```sh
make icarus
make icarus-vcd
make icarus-fst
```

To remove generated work directories and selected artifacts:

```sh
make clean
```

## Notes

- Each target writes into its own `work/run-*` directory so outputs can be compared
  side by side.
- Vendor-native formats are used where available: WLF for Questa, VPD for VCS,
  SHM for Xcelium, and FST where the simulator supports it.
- FSDB targets require Verdi/Novas integration via `NOVAS_HOME`.
- Runtime-only constructs such as dynamic containers, class internals, and
  events may not appear uniformly in generated dumps.
- Icarus excludes a few unsupported probe shapes from this fixture, notably
  unpacked structs, structs with unpacked array fields, string associative
  arrays, and arrays of structs.
- `make all` is only useful in environments where every simulator is installed;
  most users will run individual targets.
