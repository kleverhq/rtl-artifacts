# rtl-artifacts

`rtl-artifacts` builds a reproducible set of waveform and transaction-recording files from several RTL and SystemC projects. It exists to provide real VCD, FST, and FTR samples for waveform viewers, converters, parsers, regression tests, and tool-behavior comparisons.

Each project is isolated under `projects/<name>/` and owns its own Docker image, source cache, build work tree, and artifact recipes. The generated files are written under `artifacts/` and are not tracked by Git.

## Prerequisites

Install these host tools:

- Docker, with permission for the current user to build and run containers
- GNU Make
- Git
- Bash
- standard POSIX command-line tools

First-time builds need network access to upstream source repositories, package mirrors, PyPI, Conan package remotes, xPack releases, Miniforge, and project-managed dependencies.

Check the host:

```bash
make tools-check
```

## Quick start

Build the default artifact set incrementally:

```bash
make collect
find artifacts -type f | sort
```

Build a subset:

```bash
make collect PROJECTS="scr1 tb_complex_types"
```

Run one project directly:

```bash
make -C projects/systemc-components collect
make -C projects/tb_complex_types list
```

Remove generated work and selected project artifact directories only when you mean it:

```bash
make clean
```

`make artifacts-clean` removes the entire `artifacts/` tree. Use it only when you intentionally want to delete existing generated files.

## Included projects

- `scr1` builds SCR1 RISC-V core waveform artifacts for AXI and AHB configurations.
- `picorv32` builds PicoRV32 testbench waveform artifacts.
- `chipyard` builds Chipyard Rocket-based simulation waveform artifacts.
- `tb_complex_types` builds a compact SystemVerilog waveform fixture for complex type dumping behavior using supported open-source simulators.
- `systemc-components` builds MINRES SystemC-Components example waveform and transaction-recording artifacts.

## VCD artifacts

VCD is Value Change Dump, a text waveform format widely supported by simulators and viewers. The default artifact set contains these VCD files:

- `artifacts/tb_complex_types/verilator/vcd/waves.vcd`
- `artifacts/tb_complex_types/icarus/vcd/waves.vcd`
- `artifacts/systemc-components/converted/transaction_recording__transaction_recording_cftr/my_db.vcd`
- `artifacts/systemc-components/converted/transaction_recording__transaction_recording_ftr/my_db.vcd`
- `artifacts/systemc-components/waves/apb_bfm__apb_bfm/apb_trace.vcd`
- `artifacts/systemc-components/waves/lwtr__lwtr_example/my_db.vcd`
- `artifacts/systemc-components/waves/transaction_recording__transaction_recording/my_db.vcd`

## FST artifacts

FST is Fast Signal Trace, a compact waveform format used by GTKWave and related tools. The default artifact set contains these FST files:

- `artifacts/scr1/max/axi/isr_sample.fst`
- `artifacts/scr1/max/axi/riscv_arch.fst`
- `artifacts/scr1/max/axi/riscv_compliance.fst`
- `artifacts/scr1/max/axi/riscv_isa.fst`
- `artifacts/scr1/max/axi/hello.fst`
- `artifacts/scr1/max/axi/coremark.fst`
- `artifacts/scr1/max/axi/dhrystone21.fst`
- `artifacts/scr1/max/ahb/isr_sample.fst`
- `artifacts/scr1/max/ahb/riscv_arch.fst`
- `artifacts/scr1/max/ahb/riscv_compliance.fst`
- `artifacts/scr1/max/ahb/riscv_isa.fst`
- `artifacts/scr1/max/ahb/hello.fst`
- `artifacts/scr1/max/ahb/coremark.fst`
- `artifacts/scr1/max/ahb/dhrystone21.fst`
- `artifacts/picorv32/test_vcd.fst`
- `artifacts/picorv32/test_wb_vcd.fst`
- `artifacts/picorv32/test_ez_vcd.fst`
- `artifacts/chipyard/DualRocketConfig/dhrystone.fst`
- `artifacts/chipyard/DualRocketConfig/towers.fst`
- `artifacts/chipyard/DualRocketConfig/qsort.fst`
- `artifacts/chipyard/DualRocketConfig/memcpy.fst`
- `artifacts/chipyard/DualRocketConfig/mt-memcpy.fst`
- `artifacts/chipyard/DualRocketConfig/mt-vvadd.fst`
- `artifacts/chipyard/ClusteredRocketConfig/dhrystone.fst`
- `artifacts/chipyard/ClusteredRocketConfig/towers.fst`
- `artifacts/chipyard/ClusteredRocketConfig/qsort.fst`
- `artifacts/chipyard/ClusteredRocketConfig/memcpy.fst`
- `artifacts/chipyard/ClusteredRocketConfig/mt-memcpy.fst`
- `artifacts/chipyard/ClusteredRocketConfig/mt-vvadd.fst`
- `artifacts/tb_complex_types/verilator/fst/waves.fst`
- `artifacts/tb_complex_types/icarus/fst/waves.fst`
- `artifacts/systemc-components/converted/apb_bfm__apb_bfm/apb_trace.fst`
- `artifacts/systemc-components/converted/lwtr__lwtr_example/my_db.fst`
- `artifacts/systemc-components/converted/transaction_recording__transaction_recording/my_db.fst`
- `artifacts/systemc-components/waves/ace-ace__ace_ace_example/ace_axi_test.fst`
- `artifacts/systemc-components/waves/ace-axi__ace_axi_example/ace_axi_test.fst`
- `artifacts/systemc-components/waves/ahb_bfm__ahb_bfm/ahb_bfm.fst`
- `artifacts/systemc-components/waves/apb_bfm__apb_bfm/apb_bfm.fst`
- `artifacts/systemc-components/waves/axi-axi__axi_axi_example/axi-axi.fst`
- `artifacts/systemc-components/waves/axi4_tlm-pin-tlm__axi4_tlm_pin_tlm_example/axi4_tlm_pin_tlm.fst`
- `artifacts/systemc-components/waves/axi4lite_tlm-pin-tlm__axi4lite_tlm_pin_tlm_example/axi4lite_tlm_pin_tlm.fst`
- `artifacts/systemc-components/waves/cxs-channel__cxs_channel/cxs_tlm.fst`
- `artifacts/systemc-components/waves/simple_system__simple_system/simple_system.fst`
- `artifacts/systemc-components/waves/transaction_recording__transaction_recording_cftr/my_db.fst`
- `artifacts/systemc-components/waves/transaction_recording__transaction_recording_ftr/my_db.fst`

## FTR artifacts

FTR is Fast Transaction Recording, a transaction-level recording format produced by SystemC-Components examples. The default artifact set contains these FTR files:

- `artifacts/systemc-components/ftr/ace-axi__ace_axi_example/ace_axi_test.ftr`
- `artifacts/systemc-components/ftr/ahb_bfm__ahb_bfm/ahb_bfm.ftr`
- `artifacts/systemc-components/ftr/apb_bfm__apb_bfm/apb_bfm.ftr`
- `artifacts/systemc-components/ftr/axi4_tlm-pin-tlm__axi4_tlm_pin_tlm_example/axi4_tlm_pin_tlm.ftr`
- `artifacts/systemc-components/ftr/axi4lite_tlm-pin-tlm__axi4lite_tlm_pin_tlm_example/axi4lite_tlm_pin_tlm.ftr`
- `artifacts/systemc-components/ftr/cxs-channel__cxs_channel/cxs_tlm.ftr`
- `artifacts/systemc-components/ftr/lwtr4axi__lwtr4axi_example/lwtr4axi.ftr`
- `artifacts/systemc-components/ftr/simple_system__simple_system/simple_system.ftr`
- `artifacts/systemc-components/ftr/transaction_recording__transaction_recording_cftr/my_db.ftr`
- `artifacts/systemc-components/ftr/transaction_recording__transaction_recording_ftr/my_db.ftr`

## Releases

GitHub releases upload every generated artifact as a separate release asset. Nested artifact paths are flattened by replacing `/` with `__`, so each file can be downloaded individually from the release page.
