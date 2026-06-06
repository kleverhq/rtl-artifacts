# SCR1 artifact pipeline

This project builds waveform artifacts from the pinned SCR1 upstream source tree. It is isolated from the repository root: the project owns its Docker image, source download cache, prepared work tree, and generated artifacts.

## Source and tools

Version pins live in `versions.mk`:

- `SCR1_URL` and `SCR1_COMMIT` select the upstream RTL source.
- `VERILATOR_VERSION` selects the Verilator release built into the project image.
- `RISCV_XPACK_VERSION` selects the RISC-V cross-toolchain used for SCR1 tests.

Generated state is ignored by Git:

- `downloads/` stores the upstream clone cache.
- `work/` stores the prepared source tree and build outputs.
- `.build/` stores Make stamp files.
- `../../artifacts/scr1/` stores collected waveform artifacts when run through the root Makefile.

## Commands

Build the project image:

```bash
make image
```

Fetch the pinned SCR1 source and submodules:

```bash
make download
```

Prepare a writable work tree from the download cache:

```bash
make prepare
```

Collect all default SCR1 artifacts:

```bash
make collect
```

List artifact targets:

```bash
make list
```

Open a debug shell inside the project image:

```bash
make shell
```

## Artifact scope

Default collection builds SCR1 `MAX` configuration waveforms for both AXI and AHB buses:

- `artifacts/scr1/max/axi/{isr_sample,riscv_arch,riscv_compliance,riscv_isa,hello,coremark,dhrystone21}.fst`
- `artifacts/scr1/max/ahb/{isr_sample,riscv_arch,riscv_compliance,riscv_isa,hello,coremark,dhrystone21}.fst`

The project serializes artifact targets because the upstream SCR1 flow reuses shared build output paths.
