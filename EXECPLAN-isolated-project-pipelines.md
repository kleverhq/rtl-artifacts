# Isolated Project Pipelines ExecPlan

This plan describes how to reshape this repository from one shared devcontainer-based RTL artifact workspace into a host-driven collection of isolated project pipelines. After this change, a user with only Docker, GNU Make, Git, and Bash on the host can run `make collect` from the repository root and get generated RTL artifacts under the ignored `artifacts/` directory. Each artifact-producing project owns its own Docker image, source download/cache area, build work area, artifact targets, and local contract. The current extension adds a new `systemc-components` project that builds the MINRES SystemC-Components examples and collects VCD, FST, and FTR artifacts without deleting the expensive existing artifact tree.

The current repository has a root `Makefile` that includes `scr1.mk`, `picorv32.mk`, and `chipyard.mk`, plus a global `.devcontainer/Dockerfile` that installs all tools and all upstream sources into `/opt`. That model couples unrelated projects together. The new model must remove that coupling. The root must orchestrate projects only; each directory under `projects/` must be able to build its own artifacts independently.


## Definitions

An artifact is a generated file that this repository exists to produce, such as a `.fst` waveform dump. Final artifacts live under the root `artifacts/` directory and are not tracked by Git.

A project is one artifact-producing directory under `projects/`. A project owns a `Makefile`, usually a `Dockerfile`, optional version pins, optional patches, an ignored `downloads/` cache, an ignored `work/` build directory, and rules that copy final outputs into the root artifact tree.

SystemC is a C++ library for hardware-like simulation. Transaction Level Modeling, abbreviated TLM, is a SystemC style where components exchange higher-level transactions instead of individual pin toggles. MINRES SystemC-Components, abbreviated SCC in upstream paths, is a C++ library of SystemC and TLM helpers plus examples. A VCD file is a Value Change Dump waveform file. An FST file is a Fast Signal Trace waveform file used by GTKWave. An FTR file is a Fast Transaction Recording file produced by SCC's transaction recording support; it is not the same thing as a signal waveform, but it is an analysis artifact produced by the same example runs.

The root orchestrator is the root `Makefile`. It must not contain simulator-specific or upstream-project-specific build commands. It only checks host tools, delegates targets to `projects/<name>/Makefile`, and runs release packaging/upload logic.

The download cache is `projects/<name>/downloads/`. It is an ignored per-project directory used for source archives, Git clones, tool archives, or other downloaded inputs. It is safe to delete; the project must be able to recreate it.

The work directory is `projects/<name>/work/`. It is an ignored per-project directory used for extracted sources, build products, run directories, and intermediate outputs. It is safe to delete; the project must be able to recreate it from tracked files and `downloads/`.


## Repository Context At Plan Start

The repository root currently contains these relevant tracked files:

    Makefile
    scr1.mk
    picorv32.mk
    chipyard.mk
    README.md
    AGENTS.md
    .gitignore
    .pre-commit-config.yaml
    .devcontainer/Dockerfile
    .devcontainer/devcontainer.json
    .devcontainer/AGENTS.md
    scripts/release.sh
    tb_complex_types/Makefile
    tb_complex_types/README.md
    tb_complex_types/tb.sv
    tb_complex_types/.gitignore

The root `Makefile` currently includes `scr1.mk`, `picorv32.mk`, and `chipyard.mk`. It has `bootstrap`, `tools-check`, `sources-check`, `pre-commit`, `check-commit`, `collect`, `release`, `clean`, and `help` targets. Those targets assume tools and sources are already installed inside the global devcontainer.

The current global Dockerfile pins these upstream versions and commits. It pins Chipyard by tag only; the `CHIPYARD_COMMIT` value below was resolved during planning from `refs/tags/1.13.0` with `git ls-remote` and must become a new project-local pin.

    RISCV_XPACK_VERSION=14.2.0-3
    VERILATOR_VERSION=v5.042
    MINIFORGE_VERSION=26.1.0-0
    CHIPYARD_VERSION=1.13.0
    CHIPYARD_COMMIT=69eba860a352343e4ac6b6df0f3638a79a86ec78
    PICORV32_COMMIT=87c89acc18994c8cf9a2311e871818e87d304568
    SCR1_COMMIT=ebb5e3551a9d93c0ee95f0b767dd878b8927e702

The current root artifact scope is:

    SCR1: MAX config on AXI and AHB buses, with isr_sample, riscv_arch, riscv_compliance, riscv_isa, hello, coremark, and dhrystone21 targets.
    PicoRV32: test_vcd, test_wb_vcd, and test_ez_vcd targets.
    Chipyard: DualRocketConfig and ClusteredRocketConfig, with dhrystone, towers, qsort, memcpy, mt-memcpy, and mt-vvadd benchmarks.
    tb_complex_types: internal testbench source under `tb_complex_types/tb.sv`; tracked source and documentation only, generated `run-*` directories ignored.

The current `.gitignore` ignores `artifacts/` and `transcript`. The new layout must continue to ignore root `artifacts/` and must also ignore per-project `downloads/`, `work/`, and `.build/` directories.


## Desired Final Layout

The final repository should have this shape:

    rtl-artifacts/
    ├── Makefile
    ├── README.md
    ├── AGENTS.md
    ├── .gitignore
    ├── scripts/
    │   └── release.sh
    ├── artifacts/                         # ignored final outputs
    └── projects/
        ├── AGENTS.md
        ├── scr1/
        │   ├── Makefile
        │   ├── Dockerfile
        │   ├── versions.mk
        │   ├── patches/                   # optional, may be empty or absent
        │   ├── downloads/                 # ignored
        │   └── work/                      # ignored
        ├── picorv32/
        │   ├── Makefile
        │   ├── Dockerfile
        │   ├── versions.mk
        │   ├── patches/                   # optional, may be empty or absent
        │   ├── downloads/                 # ignored
        │   └── work/                      # ignored
        ├── chipyard/
        │   ├── Makefile
        │   ├── Dockerfile
        │   ├── versions.mk
        │   ├── patches/                   # optional, may be empty or absent
        │   ├── downloads/                 # ignored
        │   └── work/                      # ignored
        ├── tb_complex_types/
        │   ├── Makefile
        │   ├── Dockerfile
        │   ├── versions.mk                # tracked, may contain only tool pins
        │   ├── README.md
        │   ├── tb.sv
        │   ├── downloads/                 # ignored and normally unused
        │   └── work/                      # ignored run directories
        └── systemc-components/
            ├── Makefile
            ├── Dockerfile
            ├── versions.mk
            ├── README.md
            ├── artifacts.list             # tracked list of default VCD/FST/FTR outputs
            ├── patches/
            │   └── scc-include-cxs-channel.patch
            ├── scripts/
            │   └── run_examples.sh
            ├── downloads/                 # ignored SCC source cache
            └── work/                      # ignored SCC build and example run directories

Do not add a `Justfile`. The user explicitly chose not to add one. This repository needs Make's file-target graph for incremental artifact production, not a second task-runner surface. If a future contributor wants a local convenience wrapper, it must remain outside the tracked repository or be justified in a separate design.


## Required Project Contract

Every directory under `projects/` that produces artifacts must expose the same Make targets. The exact internal recipes may differ, but the target names and meanings must not differ.

`make image` builds the Docker image for that project. It may use a stamp file such as `.build/image.stamp` so artifact targets can depend on it. The Docker image must be project-specific and must not install unrelated upstream sources.

`make download` fills or refreshes `downloads/` with external source inputs for the project. For `tb_complex_types`, this target is a no-op that still creates `downloads/` so the contract is uniform.

`make prepare` creates `work/` from tracked files and `downloads/`. It may extract archives, copy sources, clone from a cached mirror, initialize submodules, or apply patches. It must be safe to run repeatedly.

`make collect` builds all default artifacts for the project and writes them under the `ARTIFACTS_DIR` variable. Each project must define `PROJECT_NAME` and a safe standalone default such as `ARTIFACTS_DIR ?= $(abspath ../../artifacts/$(PROJECT_NAME))`, so `make -C projects/<name> collect` writes into the root artifact tree even when the root Makefile is not involved. When invoked by the root Makefile, `ARTIFACTS_DIR` will still be passed as an absolute path such as `<repo>/artifacts/scr1`.

`make list` prints the artifact targets that `make collect` would produce. This target exists so humans and release scripts can inspect scope without building.

`make shell` opens an interactive shell in the project Docker image with the same volumes used by build recipes. This is for debugging only, not part of release automation.

`make clean` removes `work/`, `.build/`, and project artifacts under the selected `ARTIFACTS_DIR`, but it must not remove `downloads/`.

`make distclean` runs `clean` and removes `downloads/` too.

`make help` prints concise project targets. It must not duplicate the README.

Project Makefiles should use actual artifact files as Make targets wherever feasible. For example, `collect` in `projects/picorv32/Makefile` should depend on `$(ARTIFACTS_DIR)/test_vcd.fst`, `$(ARTIFACTS_DIR)/test_wb_vcd.fst`, and `$(ARTIFACTS_DIR)/test_ez_vcd.fst`. This preserves incremental behavior: existing artifacts are skipped unless their dependencies are newer or the user cleans them.

Every project must use a standard dependency graph and must have a tracked `versions.mk`, even if the project is internal and the file only records tool pins or a comment that there is no upstream source. `collect` depends on artifact file targets. Artifact file targets depend on a prepare stamp, an image stamp, `Makefile`, `versions.mk`, tracked source files used by the artifact, and any patch files. The image stamp depends on `Dockerfile` and `versions.mk`. The download stamp depends on `versions.mk`, `Makefile`, and any tracked download helper files, so pin changes cannot reuse stale downloads. The prepare stamp depends on the download stamp, `versions.mk`, patches, tracked local sources, and the image stamp whenever `prepare` runs inside the project Docker image. If `versions.mk` or patches change, `prepare` must recreate the relevant `work/src` contents instead of reusing stale sources. Artifact recipes must create parent directories before writing nested outputs, such as with `mkdir -p "$(@D)"` on the host side or `mkdir -p /artifacts/<subdir>` inside the container. Artifact recipes should write through a temporary file and move it into place only after success where practical.

Do not let parallel Make jobs corrupt shared upstream outputs. If a project recipe reuses one source tree and one waveform output path, serialize that project's artifact targets with `.NOTPARALLEL`, a lock, or per-artifact isolated work directories. The first migration may use serialization for SCR1, PicoRV32, and Chipyard because their current recipes reuse shared files such as `simx.vcd`, `testbench.vcd`, and simulator output directories. Root-level projects may still run independently because each project has separate `downloads/`, `work/`, and artifact directories.


## Root Makefile Contract

The root `Makefile` must become a small orchestrator. It must not include `scr1.mk`, `picorv32.mk`, or `chipyard.mk`, and those old root `.mk` files should be removed after their logic has been migrated into project directories.

The root Makefile should define project names in one place:

    PROJECTS ?= scr1 picorv32 chipyard tb_complex_types systemc-components
    ARTIFACTS_DIR ?= artifacts

It should expose these root targets:

    make help
    make tools-check
    make images
    make image-<project>
    make download
    make download-<project>
    make prepare
    make prepare-<project>
    make collect
    make collect-<project>
    make list
    make list-<project>
    make shell-<project>
    make clean
    make clean-<project>
    make distclean
    make distclean-<project>
    make release VERSION=vX.Y.Z

`make tools-check` at the root checks only host prerequisites. It should verify `docker`, `make`, `git`, `bash`, `find`, `sort`, and `awk`. It should check `gh` only if release is being run, or it may print a clear note that `gh` is release-only. It must not check host Verilator, Icarus, RISC-V GCC, Surfer, slang-server, or any HDL tool; those belong inside project images.

`make collect` delegates to each project with an absolute artifact directory:

    $(MAKE) -C projects/scr1 collect ARTIFACTS_DIR=$(abspath $(ARTIFACTS_DIR)/scr1)

The same pattern applies to all project-specific root targets. The root should support a reduced project list by allowing `make collect PROJECTS="scr1 tb_complex_types"`.

Remove root `bootstrap`, `sources-check`, `pre-commit`, and `check-commit` targets unless there is a compelling compatibility reason to keep aliases. The user explicitly said pre-commit hooks can be removed for now. If aliases are kept temporarily, they must not install hooks and must clearly point to the new targets.


## Docker Policy

There must be no global devcontainer image. Remove `.devcontainer/Dockerfile`, `.devcontainer/devcontainer.json`, and `.devcontainer/AGENTS.md` as part of the migration.

Each artifact project that needs tools must own its own `Dockerfile`. A project Dockerfile installs only the tools needed by that project. It must not install unrelated editor tools, coding agents, pre-commit tooling, Surfer, slang-server, or other convenience packages unless the project uses them to produce artifacts.

Run project containers from project Makefiles with explicit volume mounts and writable cache locations. Recipes must create host-side bind mount directories before `docker run`; otherwise Docker may create missing directories as root-owned paths and the host-UID container will not be able to write to them. Use this pattern unless a project needs a documented variation:

    mkdir -p "$(DOWNLOADS_DIR)" "$(WORK_DIR)" "$(ARTIFACTS_DIR)" "$(BUILD_DIR)"
    test -w "$(DOWNLOADS_DIR)" && test -w "$(WORK_DIR)" && test -w "$(ARTIFACTS_DIR)"
    docker run --rm \
      --user "$$(id -u):$$(id -g)" \
      -e HOME=/work/.home \
      -e XDG_CACHE_HOME=/work/.cache \
      -e CCACHE_DIR=/work/.ccache \
      -e CONDA_PKGS_DIRS=/work/.conda/pkgs \
      -e PIP_CACHE_DIR=/work/.cache/pip \
      -v "$(abspath .):/project:ro" \
      -v "$(abspath $(DOWNLOADS_DIR)):/downloads" \
      -v "$(abspath $(WORK_DIR)):/work" \
      -v "$(abspath $(ARTIFACTS_DIR)):/artifacts" \
      -w /work \
      $(IMAGE) \
      bash -lc 'mkdir -p "$$HOME" "$$XDG_CACHE_HOME" "$$CCACHE_DIR" "$$CONDA_PKGS_DIRS" "$$PIP_CACHE_DIR" && <project command>'

Mount the project directory read-only so recipes cannot silently mutate tracked files. Mount `downloads/`, `work/`, and the artifact output path read-write. Run with the host user ID so generated files are removable from the host without `sudo`. Set `HOME` and cache directories under `/work` so Git, Conda, ccache, Python, and build tools do not try to write to `/`, to a missing passwd entry's home directory, or to the read-only project mount.

It is acceptable for `download` or `prepare` to use network access. Artifact recipes should use prepared local inputs. If a project still requires controlled network access after `prepare`, document that in the project README or a project Makefile comment and explain why it cannot be moved earlier. Chipyard setup must not be treated as optional: if `env.sh`, `$$RISCV`, or benchmark binaries are required by collection, the stamp that creates them is part of `prepare`.


## Project-Specific Design

### SCR1

Move the SCR1 artifact logic from `scr1.mk` into `projects/scr1/Makefile`. Keep the existing default artifact scope: `MAX` config on `AXI` and `AHB`, with `isr_sample`, `riscv_arch`, `riscv_compliance`, `riscv_isa`, `hello`, `coremark`, and `dhrystone21`.

Create `projects/scr1/versions.mk` with at least:

    SCR1_URL := https://github.com/syntacore/scr1.git
    SCR1_COMMIT := ebb5e3551a9d93c0ee95f0b767dd878b8927e702
    VERILATOR_VERSION := v5.042
    RISCV_XPACK_VERSION := 14.2.0-3

The SCR1 Docker image must provide Verilator, `vcd2fst`, GNU Make, Bash, Git, build-essential tooling, and the RISC-V cross compiler exposed as `riscv64-unknown-elf-*`, matching the current recipes. The upstream SCR1 source must not live in the image. It should be checked out or copied into `work/src` during `prepare`.

For submodules, use a deterministic `download` and `prepare` pair. `download` should populate `downloads/src` or an equivalent cache with a complete SCR1 checkout at `SCR1_COMMIT`, including required submodules. `prepare` should recreate `work/src` from that cache, verify `git rev-parse HEAD` matches `SCR1_COMMIT`, run or verify `git submodule update --init --recursive`, and then apply any tracked patches. Do not clone directly inside artifact recipes; that hides source setup behind collection and makes `make download` ceremonial, which is how tiny maintenance goblins get tenure.

Each SCR1 artifact target should run the upstream `make run_verilator_wf` command inside the container and copy or convert the resulting waveform into `/artifacts/<name>.fst`. Preserve the current `SCR1_COLLECT_TRACE ?= 0` and benchmark linker flags behavior. Because upstream SCR1 writes the waveform to a shared path under its build directory, serialize SCR1 artifact targets unless the implementation gives each artifact its own isolated work copy.

Suggested final artifact paths are:

    artifacts/scr1/max/axi/isr_sample.fst
    artifacts/scr1/max/axi/riscv_arch.fst
    artifacts/scr1/max/axi/riscv_compliance.fst
    artifacts/scr1/max/axi/riscv_isa.fst
    artifacts/scr1/max/axi/hello.fst
    artifacts/scr1/max/axi/coremark.fst
    artifacts/scr1/max/axi/dhrystone21.fst
    artifacts/scr1/max/ahb/isr_sample.fst
    artifacts/scr1/max/ahb/riscv_arch.fst
    artifacts/scr1/max/ahb/riscv_compliance.fst
    artifacts/scr1/max/ahb/riscv_isa.fst
    artifacts/scr1/max/ahb/hello.fst
    artifacts/scr1/max/ahb/coremark.fst
    artifacts/scr1/max/ahb/dhrystone21.fst

Because nested paths create duplicate basenames such as `hello.fst`, the release script must flatten asset names at upload time or otherwise handle uniqueness.

### PicoRV32

Move the PicoRV32 artifact logic from `picorv32.mk` into `projects/picorv32/Makefile`. Keep the existing default artifact scope: `test_vcd`, `test_wb_vcd`, and `test_ez_vcd`.

Create `projects/picorv32/versions.mk` with at least:

    PICORV32_URL := https://github.com/YosysHQ/picorv32.git
    PICORV32_COMMIT := 87c89acc18994c8cf9a2311e871818e87d304568
    RISCV_XPACK_VERSION := 14.2.0-3

The PicoRV32 Docker image must provide GNU Make, Bash, Git, Icarus or whatever the upstream Make targets require, and the RISC-V cross compiler exposed as `riscv64-unknown-elf-*`. If the upstream Make target emits VCD, install `gtkwave` or another package that provides `vcd2fst` so the project can keep producing `.fst` artifacts. Because the current upstream targets reuse `testbench.vcd`, serialize PicoRV32 artifact targets unless the implementation gives each target an isolated source/work copy.

Suggested final artifact paths are:

    artifacts/picorv32/test_vcd.fst
    artifacts/picorv32/test_wb_vcd.fst
    artifacts/picorv32/test_ez_vcd.fst

### Chipyard

Move the Chipyard artifact logic from `chipyard.mk` into `projects/chipyard/Makefile`. Keep the existing default artifact scope: `DualRocketConfig` and `ClusteredRocketConfig`, with `dhrystone`, `towers`, `qsort`, `memcpy`, `mt-memcpy`, and `mt-vvadd`.

Create `projects/chipyard/versions.mk` with at least:

    CHIPYARD_URL := https://github.com/ucb-bar/chipyard.git
    CHIPYARD_VERSION := 1.13.0
    CHIPYARD_COMMIT := 69eba860a352343e4ac6b6df0f3638a79a86ec78
    MINIFORGE_VERSION := 26.1.0-0
    VERILATOR_VERSION := v5.042

The Chipyard Docker image may be heavier than the other images, but it must be isolated to Chipyard. It should install system dependencies, Miniforge or equivalent environment support, Verilator if Chipyard does not provide an adequate one, and any packages required by `./build-setup.sh riscv-tools --skip-ctags --skip-firesim --skip-marshal`. The Chipyard source tree must live in `work/src`, not `/opt/chipyard`.

The `prepare` target must clone or copy Chipyard into `/work/src`, checkout `CHIPYARD_COMMIT`, initialize required submodules, and run `./build-setup.sh riscv-tools --skip-ctags --skip-firesim --skip-marshal` or an equivalent setup step that creates `/work/src/env.sh`, the `$$RISCV` environment, and the benchmark binaries used by collection. Because this is expensive, use stamp files under `.build/` and make them depend on `versions.mk`, `Dockerfile`, and any patch files. The stamp must represent a usable Chipyard environment, not merely a cloned source tree.

Each Chipyard artifact target should source `/work/src/env.sh`, run the existing simulation command from `/work/src/sims/verilator`, pass the full benchmark binary path, and copy the resulting `.fst` to `/artifacts/<config>/<benchmark>.fst`. The command shape should be:

    bash -lc 'set -e; source /work/src/env.sh; make -C /work/src/sims/verilator CONFIG="<config>" run-binary-debug USE_FST=1 BINARY="$$RISCV/riscv64-unknown-elf/share/riscv-tests/benchmarks/<benchmark>.riscv"'

Because Chipyard simulator output directories are shared by config and benchmark, serialize Chipyard artifact targets unless the implementation provides isolated simulator output directories.

Suggested final artifact paths are:

    artifacts/chipyard/DualRocketConfig/dhrystone.fst
    artifacts/chipyard/DualRocketConfig/towers.fst
    artifacts/chipyard/DualRocketConfig/qsort.fst
    artifacts/chipyard/DualRocketConfig/memcpy.fst
    artifacts/chipyard/DualRocketConfig/mt-memcpy.fst
    artifacts/chipyard/DualRocketConfig/mt-vvadd.fst
    artifacts/chipyard/ClusteredRocketConfig/dhrystone.fst
    artifacts/chipyard/ClusteredRocketConfig/towers.fst
    artifacts/chipyard/ClusteredRocketConfig/qsort.fst
    artifacts/chipyard/ClusteredRocketConfig/memcpy.fst
    artifacts/chipyard/ClusteredRocketConfig/mt-memcpy.fst
    artifacts/chipyard/ClusteredRocketConfig/mt-vvadd.fst

### tb_complex_types

Move the existing tracked `tb_complex_types/` directory to `projects/tb_complex_types/`. This is an internal project, not an upstream checkout. Preserve `tb.sv`, `README.md`, and the useful simulator-target logic from its Makefile.

Create `projects/tb_complex_types/versions.mk` even though there is no upstream repository. Use it to record tool pins such as the Verilator version used by the Dockerfile, or include a comment saying the project has no external source pins. The file exists so the standard stamp dependency graph is uniform across all projects.

Create `projects/tb_complex_types/Dockerfile` for the open-source default flow. It should install Verilator, Icarus Verilog, `gtkwave` or another provider of `vcd2fst`, GNU Make, Bash, and build-essential tooling. It should not install Questa, VCS, Xcelium, or Verdi because those are vendor/licensed tools and cannot be assumed in the default Docker flow.

The default `collect` target should build the open-source artifacts that can run in the project image, but do not assume Icarus works until it is smoke-tested after the move. First validate Verilator VCD and FST. Then validate Icarus VCD and FST; if Icarus fails on classes, dynamic arrays, queues, unpacked structs, or other unsupported SystemVerilog constructs, gate those constructs with `ifdef ICARUS` or keep Icarus as an optional target until the source is fixed. Once validated, default `collect` should produce:

    artifacts/tb_complex_types/verilator/vcd/waves.vcd
    artifacts/tb_complex_types/verilator/fst/waves.fst
    artifacts/tb_complex_types/icarus/vcd/waves.vcd
    artifacts/tb_complex_types/icarus/fst/waves.fst

Keep optional Make targets for Questa, VCS, Xcelium, and FSDB only if they remain clearly documented as host/vendor-tool paths outside the default Docker artifact flow. Do not include them in default `collect` until their tools are available and their source compatibility has been verified.

Change generated run directories to live under `work/`, not beside tracked source files. For example, use `WORK_DIR ?= work` and create `$(WORK_DIR)/run-verilator-fst` instead of `run-verilator-fst` at the project root. Then `projects/tb_complex_types/.gitignore` can be removed if the root ignore patterns cover all generated directories, or it can remain as a small local guard if useful.


### systemc-components

Add `projects/systemc-components/` as a new isolated project derived from the working experiment in the sibling repository at `/home/esynr3z/projects/rtl-artifacts-ws/scc-experiment`. The experiment already proved that SCC tag `2026.05` at commit `b990fb032cad58478348b5bf4acd0052fc01d3f7` can be built, patched, run, and used to generate native VCD/FST waveforms, native FTR transaction recordings, and successful VCD/FST conversions. The new project must adapt that experiment to the repository contract rather than copying the experiment repository wholesale. In particular, generated SCC artifacts must remain ignored under the root `artifacts/` tree, and the tracked repository must contain only source recipes, pins, scripts, patches, documentation, and lists.

Create `projects/systemc-components/versions.mk` with at least:

    SYSTEMC_COMPONENTS_URL := https://github.com/Minres/SystemC-Components.git
    SYSTEMC_COMPONENTS_VERSION := 2026.05
    SYSTEMC_COMPONENTS_COMMIT := b990fb032cad58478348b5bf4acd0052fc01d3f7
    CONAN_VERSION := 2.29.0
    SCC_BUILD_PRESET := Release

The Docker image must install the tools needed to build and run SCC examples: Bash, Git, CMake, Ninja, GCC/G++, Python 3, Python packaging support, Conan 2.29.0, GTKWave conversion tools such as `vcd2fst` and `fst2vcd`, and ordinary build utilities. Use explicit Debian packages for likely Conan-built dependencies and build systems, including `python3-pip`, `python3-venv`, `ca-certificates`, `curl`, `pkg-config`, `patch`, `autoconf`, `automake`, `libtool`, `flex`, `bison`, `unzip`, `perl`, and `zlib1g-dev`. It must not install unrelated HDL toolchains, editor tools, coding agents, or devcontainer convenience packages. Conan must use cache directories under `/work`, such as `CONAN_HOME=/work/.conan2`, because project containers run as the host user and the project directory is mounted read-only.

The `download` target must populate `projects/systemc-components/downloads/src` with the SCC Git repository at `SYSTEMC_COMPONENTS_COMMIT` and initialize its nested submodules recursively. It must force the parent checkout to the pinned commit, run `git reset --hard` and `git clean -ffdx` on the parent, synchronize submodule URLs, update submodules recursively, and clean/reset submodules recursively so stale local cache state cannot poison the prepared build. At this pinned release the nested submodules observed in the experiment were `third_party/axi_chi` at `042fb78916facdf6adc0fc5f1f26625d62099973` and `third_party/lwtr4sc` at `4fe2d77ad7066ffceacdec327d8803bf37e16895`; the parent SCC commit pins those submodules, so the project Makefile does not need separate variables for them unless a future change requires overriding them.

The `prepare` target must recreate `work/src` from `downloads/src`, verify the parent SCC commit, verify the expected submodule commits, apply `patches/scc-include-cxs-channel.patch` to the prepared work tree, configure SCC with the upstream `Release` CMake preset, force `BUILD_SCC_DOCUMENTATION=OFF`, force `WITH_SCP4SCC=ON`, and build the examples. This target is intentionally heavier than a plain source-copy step because artifact collection requires built example executables. The patch is the same functional patch proven in the experiment: it adds `examples/cxs-channel` to upstream `examples/CMakeLists.txt`, adds the missing include path for that example, binds the CXS clock/reset signals and clock periods, and lets `scc-tlm_target_bfs` create the CCI broker it needs at runtime. The patch is applied to `work/src`, not to tracked files or the cached download tree.

The `collect` target should run the built example executables once as a batch, because examples are discovered under one shared SCC build tree and many small artifact files come from one run phase. It is acceptable for `collect` to use a GNU Make grouped-target rule where all listed VCD/FST/FTR outputs are produced by one script invocation. The script should store scratch run directories, logs, summaries, and conversion logs under `work/`, not under `artifacts/`, unless those metadata files are intentionally added to `artifacts.list`. The default release artifacts for this project are only VCD, FST, and FTR files.

Create `projects/systemc-components/artifacts.list` as the source of truth for `make list`. Each line is a path relative to `artifacts/systemc-components/`. The default list is the 29 output files proven by the experiment:

    converted/apb_bfm__apb_bfm/apb_trace.fst
    converted/lwtr__lwtr_example/my_db.fst
    converted/transaction_recording__transaction_recording/my_db.fst
    converted/transaction_recording__transaction_recording_cftr/my_db.vcd
    converted/transaction_recording__transaction_recording_ftr/my_db.vcd
    ftr/ace-axi__ace_axi_example/ace_axi_test.ftr
    ftr/ahb_bfm__ahb_bfm/ahb_bfm.ftr
    ftr/apb_bfm__apb_bfm/apb_bfm.ftr
    ftr/axi4_tlm-pin-tlm__axi4_tlm_pin_tlm_example/axi4_tlm_pin_tlm.ftr
    ftr/axi4lite_tlm-pin-tlm__axi4lite_tlm_pin_tlm_example/axi4lite_tlm_pin_tlm.ftr
    ftr/cxs-channel__cxs_channel/cxs_tlm.ftr
    ftr/lwtr4axi__lwtr4axi_example/lwtr4axi.ftr
    ftr/simple_system__simple_system/simple_system.ftr
    ftr/transaction_recording__transaction_recording_cftr/my_db.ftr
    ftr/transaction_recording__transaction_recording_ftr/my_db.ftr
    waves/ace-ace__ace_ace_example/ace_axi_test.fst
    waves/ace-axi__ace_axi_example/ace_axi_test.fst
    waves/ahb_bfm__ahb_bfm/ahb_bfm.fst
    waves/apb_bfm__apb_bfm/apb_bfm.fst
    waves/apb_bfm__apb_bfm/apb_trace.vcd
    waves/axi-axi__axi_axi_example/axi-axi.fst
    waves/axi4_tlm-pin-tlm__axi4_tlm_pin_tlm_example/axi4_tlm_pin_tlm.fst
    waves/axi4lite_tlm-pin-tlm__axi4lite_tlm_pin_tlm_example/axi4lite_tlm_pin_tlm.fst
    waves/cxs-channel__cxs_channel/cxs_tlm.fst
    waves/lwtr__lwtr_example/my_db.vcd
    waves/simple_system__simple_system/simple_system.fst
    waves/transaction_recording__transaction_recording/my_db.vcd
    waves/transaction_recording__transaction_recording_cftr/my_db.fst
    waves/transaction_recording__transaction_recording_ftr/my_db.fst

The runner script should run the 17 expected executables under `/work/src/build/<preset>/examples`, copy simple local inputs such as `.json` and `.gtkw` from the matching SCC source example directory into an isolated per-example run directory under `/work/example-runs`, apply known arguments (`simple_system` uses `-t`; AXI TLM/pin examples use `axi-pin-axi.json`), collect native `.vcd` and `.fst` files into a staging tree, collect native `.ftr` files into the staging tree, attempt `vcd2fst` and `fst2vcd` conversions, and then copy only the files named in `artifacts.list` to `/artifacts` using temporary files and `mv`. The expected executable set is `ace-ace/ace_ace_example`, `ace-axi/ace_axi_example`, `ahb_bfm/ahb_bfm`, `apb_bfm/apb_bfm`, `axi-axi/axi_axi_example`, `axi4_tlm-pin-tlm/axi4_tlm_pin_tlm_example`, `axi4lite_tlm-pin-tlm/axi4lite_tlm_pin_tlm_example`, `cxs-channel/cxs_channel`, `lwtr/lwtr_example`, `lwtr4axi/lwtr4axi_example`, `lwtr4tlm2/lwtr4tlm2`, `scc-tlm_target_bfs/scc-tlm_target_bfs-example`, `scp/scp_example`, `simple_system/simple_system`, `transaction_recording/transaction_recording`, `transaction_recording/transaction_recording_cftr`, and `transaction_recording/transaction_recording_ftr`; if any executable is missing, the script must fail before touching `/artifacts`. If an example exits nonzero, the script must continue running remaining examples so logs and partial evidence remain in `work/`, but the final status must be nonzero. The script must validate that all manifest files exist and are non-empty in the staging tree, and it must copy staged files to `/artifacts` only after every expected executable has run successfully and every expected artifact has passed validation. This avoids a failed batch leaving fresh-looking final artifact mtimes that make a later grouped-target `make collect` skip a bad run. If any expected artifact is missing or empty, the script must fail without updating final artifact files.

Do not delete the existing root `artifacts/` tree during this extension. The current SCR1, PicoRV32, Chipyard, and `tb_complex_types` artifacts are expensive to regenerate. Validation must not run `make artifacts-clean`, root `make clean`, root `make distclean`, or project `clean`/`distclean` against the default `ARTIFACTS_DIR`. If cleanup behavior must be tested, use a disposable temporary artifact directory outside the existing `artifacts/` tree, such as `ARTIFACTS_DIR=/tmp/rtl-artifacts-clean-test/systemc-components`.

Suggested final artifact paths are:

    artifacts/systemc-components/waves/...
    artifacts/systemc-components/ftr/...
    artifacts/systemc-components/converted/...

Update the root `PROJECTS` default to include `systemc-components`, update the root README artifact scope and project layout, and ensure the release script needs no special case. The README update must make incremental `make collect` the primary command for preserving existing artifacts, and it must label `make artifacts-clean` as a destructive stale-file purge that removes the whole artifact tree. Because the release script already generates version notes from `projects/*/versions.mk` and flattens listed artifact paths, the new project should integrate by providing a correct `versions.mk` and `make list` output.


## Breadcrumb Files

Update the root `AGENTS.md` to reflect the new repository contract. Keep it short. It should say that this is an artifact workspace, root Makefile is only an orchestrator, artifacts and per-project downloads/work directories are ignored, no devcontainer is used, no Justfile is tracked, pre-commit hooks are currently not part of the workflow, and project-specific build logic belongs under `projects/<name>/`.

Create `projects/AGENTS.md` with local guidance for all project subdirectories. Keep it concise and scoped. It should define the project contract, say that project Makefiles own artifact recipes, remind agents not to write outside `downloads/`, `work/`, and the selected `ARTIFACTS_DIR`, and state that each project must remain independently runnable through `make -C projects/<name> collect`.

Do not turn either breadcrumb into a directory map or design document. The detailed architecture belongs in this ExecPlan and in the actual Makefiles, not in breadcrumbs. This follows the local breadcrumb policy: small path-scoped guidance, durable contracts, and no copied README material.


## README Requirements

Rewrite the root `README.md` so it remains concise. It should include:

    repository purpose in one short paragraph;
    host prerequisites;
    quick start commands;
    project layout summary;
    artifact location and Git ignore policy;
    release command;
    note that there is no devcontainer and no host HDL toolchain requirement.

Host prerequisites should be explicit:

    Docker with permission to build and run containers;
    GNU Make;
    Git;
    Bash and standard Unix utilities such as find, sort, awk, and xargs;
    network access for first image/source setup;
    GitHub CLI `gh` only for `make release`.

The README should not list every artifact target in detail. Put detailed target lists in project Makefiles or project READMEs where needed. Root README should be an entry point, not a hay bale with a title.


## Release Script Requirements

Update `scripts/release.sh` so it no longer reads `.devcontainer/Dockerfile` or `/opt/chipyard`. It must treat project `versions.mk` files as the source of version metadata.

The release flow must remain incremental. `make release VERSION=vX.Y.Z` should call `make collect` and rely on Make target validity. It must not force `clean`.

Because final artifacts will live in nested directories and may share basenames, update upload logic so GitHub asset names are unique. A safe rule is to use the artifact path relative to `artifacts/` with `/` replaced by `__`. For example:

    artifacts/scr1/max/axi/hello.fst -> scr1__max__axi__hello.fst
    artifacts/tb_complex_types/verilator/fst/waves.fst -> tb_complex_types__verilator__fst__waves.fst

GitHub CLI treats `file#text` as an asset display label rather than a filename rename, so do not rely on that syntax for uniqueness. Stage release assets in a temporary flat directory using the relative artifact path with `/` replaced by `__`, preferably by hardlinking and falling back to copying, then upload those staged files.

The release notes should include a short version-pin section generated from `projects/*/versions.mk`. It is acceptable to include raw `NAME := value` lines grouped by project. Avoid attempting to resolve runtime SHAs from `/opt`, because `/opt` is no longer part of the architecture.


## Implementation Milestones

### Milestone 1: Replace root orchestration and ignore policy

Start by updating `.gitignore` so generated outputs are safely ignored before moving files or running builds. It should include root `artifacts/`, per-project `downloads/`, per-project `work/`, and per-project `.build/`.

Then rewrite the root `Makefile` as a pure orchestrator. It should delegate to `projects/<name>` targets and expose the root target contract described above. At this stage, project directories may not exist yet, so keep the diff focused and do not run `make collect` until at least one project has been migrated.

Acceptance for this milestone is that `make help` from the root prints the new root targets and does not mention devcontainers, `/opt`, pre-commit, Commitizen, SCR1-specific recipes, PicoRV32-specific recipes, or Chipyard-specific recipes.

### Milestone 2: Add concise breadcrumbs

Replace the root `AGENTS.md` with short guidance for the new root. Create `projects/AGENTS.md` with the project contract. Remove `.devcontainer/AGENTS.md` when `.devcontainer/` is removed later.

Acceptance for this milestone is that reading `AGENTS.md` and `projects/AGENTS.md` gives enough local behavioral guidance for an agent without duplicating this ExecPlan.

### Milestone 3: Migrate tb_complex_types as the first project

Move `tb_complex_types/` to `projects/tb_complex_types/` using `git mv`. Add its project Dockerfile and update its Makefile so generated run directories live under `work/`. Implement the standard project targets. Make `download` a no-op that creates `downloads/`. Validate Verilator first, then validate Icarus and fix or gate unsupported SystemVerilog constructs before including Icarus in default `collect`.

Run:

    make tools-check
    make collect-tb_complex_types
    make list-tb_complex_types

Expected observable result before cleanup:

    artifacts/tb_complex_types/verilator/vcd/waves.vcd exists
    artifacts/tb_complex_types/verilator/fst/waves.fst exists
    artifacts/tb_complex_types/icarus/vcd/waves.vcd exists
    artifacts/tb_complex_types/icarus/fst/waves.fst exists

Then check the non-build contract targets:

    make -C projects/tb_complex_types -n shell
    make -C projects/tb_complex_types clean ARTIFACTS_DIR="$PWD/artifacts/tb_complex_types"
    make -C projects/tb_complex_types distclean ARTIFACTS_DIR="$PWD/artifacts/tb_complex_types"

This milestone proves the new project contract using a small internal project before touching the heavier upstream projects. It is the test bench for the architecture, in the useful sense rather than the fashionable diagram sense.

### Milestone 4: Migrate PicoRV32

Create `projects/picorv32/` with `Makefile`, `Dockerfile`, and `versions.mk`. Move the logic from `picorv32.mk` into the project Makefile and adapt it to use `downloads/`, `work/`, `/artifacts`, and the project Docker image. Remove `picorv32.mk` only after the project target works.

Run:

    make image-picorv32
    make collect-picorv32
    make list-picorv32

Expected observable result:

    artifacts/picorv32/test_vcd.fst exists
    artifacts/picorv32/test_wb_vcd.fst exists
    artifacts/picorv32/test_ez_vcd.fst exists

### Milestone 5: Migrate SCR1

Create `projects/scr1/` with `Makefile`, `Dockerfile`, and `versions.mk`. Move the logic from `scr1.mk` into the project Makefile and adapt it to use the project Docker image, `downloads/`, `work/`, and `/artifacts`. Remove `scr1.mk` only after the project target works.

Run a small first proof before the full SCR1 collect. Use an absolute artifact target so the command matches the `ARTIFACTS_DIR` contract:

    make image-scr1
    ARTDIR="$PWD/artifacts/scr1"
    make -C projects/scr1 "$ARTDIR/max/axi/hello.fst" ARTIFACTS_DIR="$ARTDIR"

If the exact direct file target path differs in the final Makefile, run the equivalent absolute target printed by `make list-scr1`. Then run:

    make collect-scr1

Expected observable result is that all fourteen SCR1 `.fst` artifacts exist under `artifacts/scr1/max/...`.

### Milestone 6: Migrate Chipyard

Create `projects/chipyard/` with `Makefile`, `Dockerfile`, and `versions.mk`. Move the logic from `chipyard.mk` into the project Makefile and adapt it to use `/work/src` inside the container instead of `/opt/chipyard`. Remove `chipyard.mk` only after at least one Chipyard artifact target works.

Start with one benchmark because Chipyard is expensive. Use an absolute artifact target so the command matches the `ARTIFACTS_DIR` contract:

    make image-chipyard
    ARTDIR="$PWD/artifacts/chipyard"
    make -C projects/chipyard "$ARTDIR/DualRocketConfig/dhrystone.fst" ARTIFACTS_DIR="$ARTDIR"

If the exact direct file target path differs in the final Makefile, run the equivalent absolute target printed by `make list-chipyard`. Then run the full project collect if the environment has enough time and disk:

    make collect-chipyard

Expected observable result is that all twelve Chipyard `.fst` artifacts exist under `artifacts/chipyard/<config>/...`.

### Milestone 7: Remove legacy devcontainer and pre-commit workflow

Remove `.devcontainer/`, `.pre-commit-config.yaml`, root references to pre-commit and Commitizen, and any documentation that tells users to enter a devcontainer. Remove old root `scr1.mk`, `picorv32.mk`, and `chipyard.mk` after their logic has been migrated and validated.

Acceptance for this milestone is:

    git ls-files .devcontainer .pre-commit-config.yaml scr1.mk picorv32.mk chipyard.mk

prints nothing, and repository documentation no longer instructs users to use a devcontainer or `/opt` source trees.

### Milestone 8: Update README and release flow

Rewrite `README.md` to match the host-driven project architecture. Update `scripts/release.sh` to collect artifacts incrementally, stage nested artifacts under temporary flat filenames with `/` replaced by `__`, and generate release notes from `projects/*/versions.mk`.

Run non-destructive validation:

    make help
    make tools-check
    bash scripts/release.sh --help

If `gh` is installed and authenticated, also run a dry inspection by setting up a test version name and stopping before release creation if the script supports a dry-run flag. If no dry-run flag exists, do not create a real release during implementation validation; just validate shell syntax with `bash -n scripts/release.sh`.

### Milestone 9: Final full validation and cleanup

Run:

    make help
    make tools-check
    make list
    make collect-tb_complex_types
    make collect-picorv32
    make collect-scr1

Run `make collect-chipyard` if the machine has enough time, disk, and network for Chipyard. If not, run at least one Chipyard artifact target and document the reason full Chipyard collection was not run.

Also run:

    git status --short
    git diff --check
    bash -n scripts/release.sh

Expected final state:

    root Makefile delegates only;
    every project has the standard targets;
    artifacts are under ignored `artifacts/<project>/...`;
    no generated downloads or work files are tracked;
    no devcontainer files remain;
    no pre-commit workflow remains;
    README lists host prerequisites and concise usage;
    release script no longer depends on `/opt` or `.devcontainer/Dockerfile`.


### Milestone 10: Plan and review the systemc-components extension

Extend this ExecPlan with the SCC experiment findings, the exact new project contract, and the no-delete validation rule for existing artifacts. Run focused read-only reviews before implementation. At minimum, use one architecture lane for project contract and release integration, and one code/build lane for the SCC Docker/Make/script feasibility. Acceptance for this milestone is that reviewers report no blocking design issues or that every blocking issue is reflected back into this plan before code is written.

### Milestone 11: Add systemc-components project files without collecting artifacts

Create `projects/systemc-components/` with `Makefile`, `Dockerfile`, `.dockerignore`, `versions.mk`, `artifacts.list`, `README.md`, `patches/scc-include-cxs-channel.patch`, and `scripts/run_examples.sh`. The Makefile must implement the standard project targets and use `artifacts.list` as the single source for `make list`. Add `systemc-components` to the root `PROJECTS` default and update the root README. Do not run collection in this milestone; only validate cheap surfaces.

Run:

    make help
    make list-systemc-components
    make -C projects/systemc-components help
    make -C projects/systemc-components list
    bash -n projects/systemc-components/scripts/run_examples.sh

Expected observable result is that list targets print 29 absolute artifact paths under `artifacts/systemc-components/` or the selected absolute `ARTIFACTS_DIR`, and no existing files under `artifacts/scr1`, `artifacts/picorv32`, `artifacts/chipyard`, or `artifacts/tb_complex_types` are removed or modified.

### Milestone 12: Build and validate systemc-components incrementally

Build the new project image, populate the SCC download cache, prepare the SCC work tree, and run the new project collection. These commands may be expensive because Conan can build packages and SCC examples, but they affect only `projects/systemc-components/downloads/`, `projects/systemc-components/work/`, `projects/systemc-components/.build/`, and `artifacts/systemc-components/`.

Run:

    find artifacts -type f ! -path 'artifacts/systemc-components/*' | sort > /tmp/rtl-artifacts-before-systemc.txt
    make image-systemc-components
    make download-systemc-components
    make prepare-systemc-components
    make collect-systemc-components
    find artifacts -type f ! -path 'artifacts/systemc-components/*' | sort > /tmp/rtl-artifacts-after-systemc.txt
    diff -u /tmp/rtl-artifacts-before-systemc.txt /tmp/rtl-artifacts-after-systemc.txt

Expected observable result:

    make list-systemc-components prints 29 files;
    every listed file exists and has nonzero size;
    the before/after diff for non-systemc artifacts is empty;
    no command used `make artifacts-clean`, root `make clean`, root `make distclean`, or default-artifact project cleanup.

If build time or network makes full validation impossible in the current session, run at least `make image-systemc-components`, `make download-systemc-components`, and `make -C projects/systemc-components -n collect`, then record the limitation in `Surprises & Discoveries` and `Outcomes & Retrospective`. Do not fake artifact validation.

### Milestone 13: Review, fix, and commit the extension

After implementation and initial validation, run code and architecture review lanes on the working tree diff. Apply findings in the main session, rerun relevant cheap checks, and rerun expensive collection only if the review finding affects build or artifact behavior. Run a final control review pass after fixes unless the first review only finds tiny wording issues.

Final validation commands are:

    git diff --check
    bash -n scripts/release.sh
    bash -n projects/systemc-components/scripts/run_examples.sh
    make list PROJECTS="systemc-components"
    make list
    find artifacts -type f | sort | sed -n '1,120p'
    make list | sort > /tmp/rtl-artifacts-expected.txt
    find "$PWD/artifacts" -type f | sort > /tmp/rtl-artifacts-actual.txt
    diff -u /tmp/rtl-artifacts-expected.txt /tmp/rtl-artifacts-actual.txt

The final `make list` should include the previous 33 artifact paths plus the 29 new `systemc-components` artifact paths when all projects are in `PROJECTS`, and the `diff` between listed files and actual files should be empty. Commit in coherent pieces. A good split is one commit for the plan update, one commit for project implementation and docs, and one commit for review fixes if any are substantive.


## Validation Strategy

Use cheap validation before expensive validation. First validate Make syntax, help output, root delegation, ignore patterns, and the internal `tb_complex_types` project. Then validate PicoRV32, then SCR1, Chipyard, and the new `systemc-components` project. During the `systemc-components` extension, preserve the existing root `artifacts/` tree; do not run root artifact cleanup against the default artifact directory.

For every migrated project, test these commands. Verify artifact existence after `collect` and before any cleanup. Run cleanup checks either after recording that evidence or with a disposable artifact directory so final validation artifacts are not accidentally erased.

    make -C projects/<name> help
    make -C projects/<name> list
    make -C projects/<name> image
    make -C projects/<name> download
    make -C projects/<name> prepare
    make -C projects/<name> collect ARTIFACTS_DIR=$(pwd)/artifacts/<name>
    make -C projects/<name> -n shell
    make -C projects/<name> clean ARTIFACTS_DIR=/tmp/rtl-artifacts-clean-test/<name>
    make -C projects/<name> distclean ARTIFACTS_DIR=/tmp/rtl-artifacts-clean-test/<name>

From the root, test:

    make help
    make tools-check
    make list
    make collect-<name>
    ARTIFACTS_DIR=/tmp/rtl-artifacts-clean-test make clean-<name>
    ARTIFACTS_DIR=/tmp/rtl-artifacts-clean-test make distclean-<name>
    make -n shell-<name>

For generated artifacts, verify files exist and have non-zero size:

    find artifacts -type f -size +0c | sort

For `systemc-components`, run cleanup targets only with a disposable artifact directory if cleanup behavior must be checked. For normal validation, use:

    make -C projects/systemc-components help
    make -C projects/systemc-components list
    make image-systemc-components
    make download-systemc-components
    make prepare-systemc-components
    make collect-systemc-components

Use `git status --short --ignored` to confirm that `artifacts/`, `projects/*/downloads/`, `projects/*/work/`, and `projects/*/.build/` are ignored. Do not commit generated artifacts.


## Progress

- [x] Inspected current root Makefile, README, project `.mk` files, global Dockerfile, release script, and `tb_complex_types` layout.
- [x] Confirmed `artifacts/` is already ignored and must remain ignored.
- [x] Confirmed `tb_complex_types` is tracked as source/docs only; generated `run-*` directories are ignored or untracked.
- [x] Decided not to introduce a tracked `Justfile`.
- [x] Authored this ExecPlan as the handoff document for implementation.
- [x] Ran focused architecture, execution-plan, and build-feasibility reviews on the initial plan.
- [x] Updated the plan for reviewer findings about stale artifacts, writable container homes/caches, project `ARTIFACTS_DIR` defaults, SCR1 download semantics, Chipyard setup and paths, target serialization, Icarus validation, and cleanup/shell validation.
- [x] Ran a final control review pass and fixed findings about download stamp dependencies, image prerequisites for containerized prepare, and host-side bind directory creation before Docker runs.
- [x] Ran a clean control review and fixed findings about `tb_complex_types/versions.mk` and nested artifact parent directory creation.
- [x] Ran a final targeted sanity check after the clean-control fixes; reviewer reported no substantive findings.
- [x] Implement Milestone 1: replaced root orchestration with a host-only delegating Makefile and removed bootstrap/pre-commit as the public workflow.
- [x] Implement Milestone 2: created `projects/`, moved `tb_complex_types` into it, added root and project breadcrumbs, and updated ignores for generated state.
- [x] Implement Milestone 3: added isolated `tb_complex_types` Docker/Make pipeline and validated its default Verilator/Icarus artifacts.
- [x] Implement Milestone 4: added isolated SCR1 Docker, source download, prepare, list, and waveform collection pipeline; validated all 14 SCR1 artifacts.
- [x] Implement Milestone 5: added isolated PicoRV32 Docker, source download, prepare, list, and waveform collection pipeline; validated all 3 PicoRV32 artifacts.
- [x] Implement Milestone 6: added isolated Chipyard Docker, source download, build-setup prepare, list, and waveform collection pipeline; validated all 12 Chipyard artifacts.
- [x] Implement Milestone 7: removed the global devcontainer, legacy root project `.mk` includes, and tracked pre-commit configuration; kept generated state ignored.
- [x] Implement Milestone 8: rewrote release flow to read project `versions.mk` files, collect incrementally, flatten nested asset names, and reject stale unlisted artifacts.
- [x] Implement Milestone 9: updated README/breadcrumb docs, ran validation commands, ran code/docs/architecture review lanes, and applied review fixes.
- [x] Read the sibling SCC experiment at `/home/esynr3z/projects/rtl-artifacts-ws/scc-experiment`, including its README, living plan, build/run scripts, patch, submodule pins, and generated artifact inventory.
- [x] Extended this ExecPlan for a new `projects/systemc-components` project and recorded that existing expensive root artifacts must not be deleted during validation.
- [x] Ran focused architecture/release and code/build review lanes on the systemc-components plan extension.
- [x] Updated the plan for review findings about disposable cleanup validation, exact make-list/find comparison, README destructive-clean warnings, batch failure atomicity, expected SCC executable inventory, Docker dependency specificity, download cache reset/clean behavior, submodule verification, and before/after artifact snapshots.
- [x] Ran a fresh control review on the revised systemc-components plan; reviewer reported no substantive findings.
- [x] Implement Milestone 11: added `projects/systemc-components` project files, root `PROJECTS` registration, root README updates, and cheap validation without collecting SCC artifacts.
- [ ] Implement Milestone 12: build, prepare, and collect the systemc-components artifact set.
- [ ] Implement Milestone 13: run implementation review, apply fixes, validate, and commit coherent changes.


## Surprises & Discoveries

The current `tb_complex_types` directory already behaves like a small internal artifact project. It has tracked source and docs plus generated `run-*` directories. This makes it the best first migration target because it validates the new project contract without external source checkout complexity.

The current release script reads SCR1 and PicoRV32 pins from `.devcontainer/Dockerfile` and resolves Chipyard from `/opt/chipyard`. That will break completely in the new architecture. Release metadata must move to project-local `versions.mk` files.

Nested artifact paths are clearer than current long flat filenames, but GitHub release assets require unique asset names. The release script must flatten relative paths at upload time or it will collide on names like `hello.fst` and `waves.fst`.

Reviewers caught several implementation traps that were easy to miss in a high-level architecture: SCR1 and PicoRV32 reuse shared waveform output paths, Chipyard setup creates required runtime state and benchmark binaries, containers running as host UID still need writable `HOME` and cache paths, and project-local `ARTIFACTS_DIR` defaults must point back to the root artifact tree for standalone project runs.

During `tb_complex_types` validation, Ubuntu 24.04's packaged Verilator 5.020 rejected `--trace-vcd`. The compatible VCD flag is `--trace`. The FST build also needed `zlib1g-dev` because Verilator compiles `verilated_fst_c.cpp` against `zlib.h`.

Docker image builds hit a transient SSL timeout while downloading the xPack RISC-V toolchain from GitHub. Adding curl retries and `docker build --network host` made image builds resilient in this VPN-heavy environment.

SCR1's upstream Verilator wrapper invokes `ccache g++`. The final SCR1 runtime image initially lacked `ccache` because it was only installed in the Verilator builder stage; adding `ccache` to the runtime image fixed SCR1 collection.

Chipyard `build-setup.sh riscv-tools --skip-ctags --skip-firesim --skip-marshal` completed inside `projects/chipyard/work/src` and produced the expected benchmark binaries under `$RISCV/riscv64-unknown-elf/share/riscv-tests/benchmarks/`.

Implementation reviewers found two important final-control gaps: root `make clean PROJECTS=<subset>` must not delete other projects' artifacts, and releases must not upload stale ignored files left under `artifacts/`. The fix was to add an explicit `make artifacts-clean` for whole-tree artifact purges and make `scripts/release.sh` upload only paths reported by `make list` while failing on unlisted extras.

The fresh control review caught three more release/build hygiene issues. GitHub CLI's `file#label` syntax does not rename release assets, so the release script now hardlinks or copies artifacts into a temporary flat staging directory with unique filenames before upload. Project `.dockerignore` files were added so `downloads/`, `work/`, and `.build/` do not enter Docker build contexts after collection. The release script also rejects dirty worktrees by default so uploaded artifacts and notes match the target commit.

The SCC experiment in the sibling `scc-experiment` repository proved the upstream tag and exact artifact set before this repository gained a project pipeline. It produced 14 native VCD/FST files, 10 native FTR files, and 5 successful VCD/FST conversion files from 17 example executables. That experiment also proved the need for a temporary patch: `cxs-channel` is present in the release source but not wired into upstream example CMake, the same example misses include and clock/reset wiring, and `scc-tlm_target_bfs` aborts unless SCC is allowed to create the CCI broker.

The SCC experiment tracked logs and generated artifacts directly because it was a standalone proving ground. This repository has a different contract: generated artifacts stay ignored, and release scope is defined by `make list`. The new `systemc-components` project therefore needs `artifacts.list` as a tracked manifest and should keep logs and run summaries under `work/` unless they are deliberately made release artifacts.

Existing root artifacts are expensive and currently present. Validation for this extension must not use `make artifacts-clean` or default-artifact cleanup commands. The safe pattern is additive collection under `artifacts/systemc-components/` plus temporary artifact directories for any cleanup checks.

Plan review found one subtle Make hazard: if a grouped SCC artifact rule copies partial outputs into final `/artifacts` and then fails, those fresh file mtimes can make a later `make collect` skip a bad run. The fix is to stage and validate every expected artifact first, and update final artifacts only after all expected executables exit successfully and the manifest is complete.

Milestone 11 cheap validation passed before any SCC artifact collection. `bash -n projects/systemc-components/scripts/run_examples.sh`, `make -C projects/systemc-components help`, `make -C projects/systemc-components --no-print-directory list`, `make list PROJECTS="systemc-components"`, `make list`, `git diff --check`, and `bash -n scripts/release.sh` all succeeded. The existing non-systemc artifact count remained 33, and `artifacts/systemc-components/` did not exist yet.


## Decision Log

Decision: Use GNU Make as the only tracked command surface. Reason: artifact production is a file-target graph with incremental outputs. A tracked `Justfile` would add a second task API without solving a real problem.

Decision: Keep `artifacts/` ignored. Reason: artifacts are generated release outputs, not source. The repository should describe how to reproduce them rather than store them in Git.

Decision: Add `projects/` and treat each child directory as an isolated artifact project. Reason: SCR1, PicoRV32, Chipyard, and the internal `tb_complex_types` fixture have different tools, source setup, and rebuild costs. Coupling them in one Docker image makes unrelated changes expensive and fragile.

Decision: Remove the global devcontainer. Reason: the user wants host-driven operation with Docker used per project, not an interactive repository-wide development image.

Decision: Remove pre-commit workflow for now. Reason: the user explicitly allowed removing pre-commit hooks, and the current hook workflow is part of the old bootstrap/devcontainer model.

Decision: Create concise root and `projects/` breadcrumbs. Reason: agents need durable local contracts, but breadcrumbs should not become a copy of this design document.

Decision: Migrate `tb_complex_types` as a first-class project. Reason: it is an internal artifact producer with no external upstream repository, and losing it would drop useful waveform fixture coverage.

Decision: Store upstream version pins in each project's `versions.mk`. Reason: version ownership belongs with the project that consumes the upstream source, and release notes can read those files without depending on `/opt` or a removed Dockerfile.

Decision: Serialize project artifact targets unless they use isolated per-artifact work directories. Reason: current upstream recipes for SCR1, PicoRV32, and Chipyard reuse shared output paths, so parallel artifact targets can race and copy the wrong waveform.

Decision: Project Docker runs must set writable `HOME` and cache directories under `/work`. Reason: running containers as the host UID avoids root-owned files, but Git, Conda, ccache, and Python still need writable state paths.

Decision: Every project gets a tracked `versions.mk`, including internal projects. Reason: uniform stamp dependencies are simpler and safer than special-casing projects without upstream source pins.

Decision: Artifact recipes must create nested parent directories before copying outputs. Reason: `artifacts/<project>/...` now contains subdirectories, and Docker only guarantees the mounted artifact root exists.

Decision: Use Ubuntu 24.04 packaged Verilator and Icarus for the internal `tb_complex_types` fixture image. Reason: this project is a simulator compatibility probe rather than an upstream CPU flow, and the first milestone needs a small image that proves the isolated project contract before heavier pinned CPU toolchains are introduced.

Decision: Add `make artifacts-clean` instead of making aggregate `make clean` delete the entire artifact root. Reason: `PROJECTS=<subset> make clean` should respect the selected project set, while stale whole-tree cleanup must remain available as an explicit command.

Decision: Generate release asset lists from `make list` and reject unlisted files under `artifacts/`. Reason: ignored stale artifacts can otherwise be uploaded silently, especially after changing from old flat names to nested project paths.

Decision: Project image stamps record the requested Docker image tag and verify that the tag exists before skipping a build. Reason: `IMAGE=custom make image` must not silently reuse a stamp created for the default image tag.

Decision: Stage release assets under temporary flat filenames before calling `gh release create`. Reason: GitHub release assets are flat and `gh` treats `file#text` as a display label rather than a filename rename, so direct nested uploads can still collide on basenames.

Decision: Add `.dockerignore` to every project image context. Reason: once downloads and work trees exist, sending them to Docker as build context is slow, fragile, and defeats project isolation.

Decision: Require a clean Git worktree for releases unless `ALLOW_DIRTY=1` is set. Reason: release assets and notes should correspond to the commit targeted by the GitHub release.

Decision: Add SCC as `projects/systemc-components` rather than copying the sibling `scc-experiment` repository. Reason: this repository's contract is project-local Docker/Make pipelines with ignored generated outputs, while the experiment is a proof workspace with tracked generated files and host virtual environment scripts.

Decision: Use `artifacts.list` for the SCC project artifact manifest. Reason: one SCC run phase produces many files, and release safety requires `make list` to know exactly which VCD/FST/FTR files are intended assets without running the examples.

Decision: Keep SCC logs, run directories, run summaries, and conversion logs under `work/` by default. Reason: the user asked for VCD/FST/FTR artifacts, and unlisted files under `artifacts/` would make the existing release script reject the tree as ambiguous.

Decision: Build SCC examples during `prepare`. Reason: artifact collection cannot run until the shared CMake/Conan build has produced example executables, and treating the built tree as prepared state keeps artifact recipes focused on running examples and copying outputs.

Decision: Do not run destructive artifact cleanup during the SCC extension. Reason: the existing 33 SCR1, PicoRV32, Chipyard, and `tb_complex_types` artifacts are expensive to regenerate and the user explicitly said not to delete current artifacts.

Decision: Copy SCC outputs to final `/artifacts` only after full batch success and manifest validation. Reason: grouped Make targets rely on artifact mtimes, so partial final updates after a failed run can make future incremental builds incorrectly appear complete.


## Outcomes & Retrospective

Original isolated-pipeline implementation milestones are complete. Root commands run from the host and delegate to project-local pipelines. SCR1, PicoRV32, Chipyard, and `tb_complex_types` each have their own Dockerfile, Makefile, versions file, ignored download/work/build directories, and artifact list. The global devcontainer and legacy root project `.mk` files are gone. The new `systemc-components` extension is planned but not yet implemented; this section must be updated again after implementation and review.

Validation produced all 33 expected artifact targets: 14 SCR1 FST files, 3 PicoRV32 FST files, 12 Chipyard FST files, and 4 `tb_complex_types` waveform files. The final clean artifact run used `make artifacts-clean && make collect`, completed successfully in 134 minutes 8 seconds, and produced 33 non-empty files totaling about 1.8 GiB under `artifacts/`. `make list` and `find artifacts -type f` matched exactly. A fake-GitHub dry run of `scripts/release.sh vDRYRUN-LOCAL` staged and counted 33 release assets without stale-artifact errors.

The final implementation review ran code, docs, and architecture lanes; findings about release stale artifacts, scoped clean behavior, image stamp metadata, README artifact accuracy, plan freshness, GitHub asset filename staging, Docker build context hygiene, and clean-release worktree checks were applied. A final targeted recheck of release staging reported no substantive findings.

Tradeoffs remain intentional: SCR1 and Chipyard build exact Verilator v5.042 in their images, while `tb_complex_types` uses Ubuntu 24.04 packaged open-source simulators for a smaller internal fixture image. Chipyard setup is expensive but project-local and reproducible from `projects/chipyard/versions.mk`.


## Revision Notes

2026-06-05: Extended the plan for the `systemc-components` project after inspecting the sibling SCC experiment. The revision records SCC pins, the artifact manifest, the project build approach, review gates, no-delete validation rules for existing artifacts, and new milestones before implementation.

2026-06-05: Applied focused plan-review findings before implementation. The plan now requires disposable cleanup validation, exact listed-vs-actual artifact comparison, README warnings for destructive artifact cleanup, atomic SCC artifact publication after batch success, an explicit expected executable inventory, stronger Docker dependency notes, clean/reset download cache semantics, submodule verification, and before/after snapshots of non-systemc artifacts. A fresh control review reported no substantive findings.

2026-06-05: Completed Milestone 11 by adding the `projects/systemc-components` skeleton, root project registration, README updates, artifact manifest, runner script, Dockerfile, versions file, and SCC patch. Cheap validation succeeded and no existing artifacts were removed.
