# systemc-components

Builds the MINRES SystemC-Components examples and collects waveform and transaction-recording artifacts.

## What it produces

Default `make collect` runs the pinned SCC example executables and publishes only the files listed in `artifacts.list` under `artifacts/systemc-components/`:

- native VCD and FST waveforms under `waves/`
- native SCC FTR transaction recordings under `ftr/`
- successful VCD/FST conversions under `converted/`

Logs, per-example run directories, run summaries, conversion logs, and staging files stay under `projects/systemc-components/work/` and are not release artifacts.

## Version

- Upstream repository: `https://github.com/Minres/SystemC-Components.git`
- Upstream tag: `2026.05`
- Upstream commit: `b990fb032cad58478348b5bf4acd0052fc01d3f7`
- Conan version in the project image: `2.29.0`
- CMake preset: `Release`

The prepared work tree applies `patches/scc-include-cxs-channel.patch` before building. The patch wires the `cxs-channel` example into the upstream example build and fixes two runtime issues observed while generating artifacts.

## Common commands

Run from the repository root:

```sh
make image-systemc-components
make download-systemc-components
make prepare-systemc-components
make collect-systemc-components
make list-systemc-components
```

Run from this directory:

```sh
make image
make download
make prepare
make collect
make list
```

`prepare` is intentionally heavy: it configures and builds SCC examples using CMake and Conan inside the project Docker image. Conan cache and build output live under `work/`.

## Safety note

Do not use root `make artifacts-clean` when preserving existing generated artifacts. That target removes the whole root artifact tree, including expensive artifacts from other projects. Normal incremental collection for this project only writes under `artifacts/systemc-components/`.
