# Chipyard artifact pipeline

This project builds waveform artifacts from the pinned Chipyard upstream source tree. It is isolated from the repository root: the project owns its Docker image, source download cache, prepared work tree, and generated artifacts.

Chipyard setup is expensive. Expect first-time `make prepare` and `make collect` runs to take much longer than SCR1 or PicoRV32.

## Source and tools

Version pins live in `versions.mk`:

- `CHIPYARD_URL`, `CHIPYARD_VERSION`, and `CHIPYARD_COMMIT` select the upstream source.
- `MINIFORGE_VERSION` selects the Conda bootstrap used by Chipyard setup.
- `VERILATOR_VERSION` selects the Verilator release built into the project image.

Generated state is ignored by Git:

- `downloads/` stores the upstream clone cache.
- `work/` stores the prepared source tree, Chipyard setup output, and simulator build output.
- `.build/` stores Make stamp files.
- `../../artifacts/chipyard/` stores collected waveform artifacts when run through the root Makefile.

## Commands

Build the project image:

```bash
make image
```

Fetch the pinned Chipyard source:

```bash
make download
```

Prepare a writable work tree and run Chipyard setup:

```bash
make prepare
```

Collect all default Chipyard artifacts:

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

Default collection builds FST waveforms for two Chipyard configs:

- `artifacts/chipyard/DualRocketConfig/{dhrystone,towers,qsort,memcpy,mt-memcpy,mt-vvadd}.fst`
- `artifacts/chipyard/ClusteredRocketConfig/{dhrystone,towers,qsort,memcpy,mt-memcpy,mt-vvadd}.fst`

The project serializes artifact targets because the upstream Chipyard Verilator flow reuses shared simulator output paths.
