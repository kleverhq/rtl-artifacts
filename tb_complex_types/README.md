# tb_complex_types

SystemVerilog testbench and Makefile for comparing how different simulators dump
simple and complex SV data types into waveform databases.

## Goal

This directory is meant for quick cross-simulator experiments around waveform
dump support, especially for types that are often represented differently in
VCD/FST/vendor-native formats.

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

Each signal/object is initialized and then updated across 5 stimulus steps so it
is easy to compare value changes and type presentation in produced dumps.

## Files

- `tb.sv` - standalone SystemVerilog testbench
- `Makefile` - one target per simulator/dump-format combination
- `.gitignore` - ignores generated `run-*` directories

## Running

Run every target from this directory so each simulator writes into its own
dedicated run folder:

```sh
make verilator-vcd
make verilator-fst
make icarus-vcd
make icarus-fst
make questa-wlf
make questa-vcd
make questa-fsdb
make vcs-vpd
make vcs-vcd
make vcs-fsdb
make xcelium-shm
make xcelium-vcd
make xcelium-fsdb
```

To remove generated run directories:

```sh
make clean
```

## Notes

- Targets are intentionally separated by simulator and dump format to make it
  easy to compare outputs side by side.
- Vendor-native formats are used where available: WLF for Questa, VPD for VCS,
  SHM for Xcelium, and FST for tools that support it.
- FSDB targets require Verdi/Novas integration via `NOVAS_HOME`.
- Some simulators may not dump all complex runtime-only objects (for example
  dynamic containers, class internals, or events) even though the testbench
  exercises them.
- The Makefile notes several targets as not yet tested; this directory is meant
  as a compatibility probe as much as a reusable regression input.
