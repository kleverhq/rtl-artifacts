# rtl-artifacts

This repository generates waveform artifacts for several RTL projects without depending on a devcontainer or global `/opt` source trees. The root `Makefile` is the host entry point. Each project under `projects/<name>/` owns its own Docker image, source download cache, prepared work tree, and artifact recipes.

The main user-visible result is a reproducible `artifacts/` tree containing waveform files, mostly `.fst` waveform databases plus the small VCD probes from `tb_complex_types`. A clean artifact run is:

```bash
make artifacts-clean
make collect
find artifacts -type f | sort
```

## Repository layout

- `Makefile` delegates to isolated project pipelines.
- `projects/scr1/` builds SCR1 artifacts from a pinned upstream checkout.
- `projects/picorv32/` builds PicoRV32 artifacts from a pinned upstream checkout.
- `projects/chipyard/` builds Chipyard artifacts from a pinned upstream checkout.
- `projects/tb_complex_types/` builds an internal SystemVerilog waveform fixture.
- `artifacts/` is ignored generated output.

Generated state is intentionally local to each project and ignored by Git:

- `projects/*/downloads/` contains upstream source caches.
- `projects/*/work/` contains prepared source trees and build outputs.
- `projects/*/.build/` contains Make stamp files.
- `artifacts/` contains generated release assets.

## Host prerequisites

The host must have Docker, GNU Make, Git, Bash, and standard POSIX utilities. The current user must be able to build and run Docker containers. First-time `image`, `download`, and `prepare` runs need network access to GitHub, Ubuntu package mirrors, xPack releases, Miniforge, and Chipyard-managed dependencies. GitHub CLI (`gh`) is required only for releases.

Check the host with:

```bash
make tools-check
```

## Artifact scope

Default `make collect` builds these artifacts:

| Project | Artifact paths |
| --- | --- |
| SCR1 | `artifacts/scr1/max/{axi,ahb}/{isr_sample,riscv_arch,riscv_compliance,riscv_isa,hello,coremark,dhrystone21}.fst` |
| PicoRV32 | `artifacts/picorv32/{test_vcd,test_wb_vcd,test_ez_vcd}.fst` |
| Chipyard | `artifacts/chipyard/{DualRocketConfig,ClusteredRocketConfig}/{dhrystone,towers,qsort,memcpy,mt-memcpy,mt-vvadd}.fst` |
| tb_complex_types | `artifacts/tb_complex_types/verilator/vcd/waves.vcd`, `artifacts/tb_complex_types/verilator/fst/waves.fst`, `artifacts/tb_complex_types/icarus/vcd/waves.vcd`, `artifacts/tb_complex_types/icarus/fst/waves.fst` |

## Common commands

Run all projects:

```bash
make images
make download
make prepare
make collect
```

Run a subset:

```bash
make collect PROJECTS="scr1 tb_complex_types"
```

Run one project directly:

```bash
make -C projects/scr1 collect
make -C projects/picorv32 list
make -C projects/chipyard shell
```

Remove project work directories, build stamps, and the selected project artifact subdirectories while keeping downloaded source caches:

```bash
make clean
```

Remove the whole artifact tree, including stale files not owned by current project lists:

```bash
make artifacts-clean
```

Remove project work directories, build stamps, project artifact subdirectories, and downloaded source caches:

```bash
make distclean
```

## Releases

Create a release from the current `artifacts/` tree:

```bash
make release VERSION=vX.Y.Z
```

The release script runs `make collect` incrementally before uploading. Because GitHub release assets are flat, nested artifact paths are converted into unique names by replacing `/` with `__`, for example `chipyard__DualRocketConfig__dhrystone.fst`.
