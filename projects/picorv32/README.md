# PicoRV32 artifact pipeline

This project builds waveform artifacts from the pinned PicoRV32 upstream source tree. It is isolated from the repository root: the project owns its Docker image, source download cache, prepared work tree, and generated artifacts.

## Source and tools

Version pins live in `versions.mk`:

- `PICORV32_URL` and `PICORV32_COMMIT` select the upstream RTL source.
- `RISCV_XPACK_VERSION` selects the RISC-V cross-toolchain used for firmware builds.

Generated state is ignored by Git:

- `downloads/` stores the upstream clone cache.
- `work/` stores the prepared source tree and build outputs.
- `.build/` stores Make stamp files.
- `../../artifacts/picorv32/` stores collected waveform artifacts when run through the root Makefile.

## Commands

Build the project image:

```bash
make image
```

Fetch the pinned PicoRV32 source:

```bash
make download
```

Prepare a writable work tree from the download cache:

```bash
make prepare
```

Collect all default PicoRV32 artifacts:

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

Default collection builds these waveform artifacts:

- `artifacts/picorv32/test_vcd.fst`
- `artifacts/picorv32/test_wb_vcd.fst`
- `artifacts/picorv32/test_ez_vcd.fst`

The project serializes artifact targets because the upstream PicoRV32 flow reuses shared output filenames such as `testbench.vcd`.
