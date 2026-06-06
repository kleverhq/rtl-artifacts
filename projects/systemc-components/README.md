# SystemC-Components artifact pipeline

This project builds waveform and transaction-recording artifacts from the pinned MINRES SystemC-Components upstream source tree. It is isolated from the repository root: the project owns its Docker image, source download cache, prepared work tree, and generated artifacts.

`prepare` is intentionally heavy. It configures and builds SCC examples using CMake and Conan inside the project Docker image, and first-time runs can populate a large Conan cache.

## Source and tools

Version pins live in `versions.mk`:

- `SYSTEMC_COMPONENTS_URL`, `SYSTEMC_COMPONENTS_VERSION`, and `SYSTEMC_COMPONENTS_COMMIT` select the upstream SCC source.
- `SYSTEMC_COMPONENTS_AXI_CHI_COMMIT` and `SYSTEMC_COMPONENTS_LWTR4SC_COMMIT` verify pinned nested submodules.
- `CONAN_VERSION` selects the Conan release installed in the project image.
- `SCC_BUILD_PRESET` selects the CMake preset used for the SCC build.
- `SCC_EXAMPLE_TIMEOUT_SECONDS` controls the per-example runtime timeout.

Generated state is ignored by Git:

- `downloads/` stores the upstream clone cache.
- `work/` stores the prepared source tree, Conan cache, SCC build output, per-example run directories, logs, run summaries, conversion logs, and staging files.
- `.build/` stores Make stamp files.
- `../../artifacts/systemc-components/` stores collected VCD/FST/FTR artifacts when using the default artifact directory.

The prepared work tree applies `patches/scc-include-cxs-channel.patch` before building. The patch wires the `cxs-channel` example into the upstream example build and fixes runtime issues observed while generating artifacts.

## Commands

Build the project image:

```bash
make image
```

Fetch the pinned SystemC-Components source and submodules:

```bash
make download
```

Prepare a writable work tree, apply the local patch, and build SCC examples:

```bash
make prepare
```

Run the SCC examples and collect all default artifacts:

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

Default collection publishes only the files listed in `artifacts.list`:

- native VCD and FST waveforms under `artifacts/systemc-components/waves/`
- native SCC FTR transaction recordings under `artifacts/systemc-components/ftr/`
- successful VCD/FST conversions under `artifacts/systemc-components/converted/`

Logs, per-example run directories, run summaries, conversion logs, and staging files stay under `work/` and are not release artifacts.

The project serializes artifact targets because the SCC example run uses one shared prepared build tree and a batch runner publishes the manifest as a single validated artifact set.
