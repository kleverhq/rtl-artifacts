# rtl-artifacts Repo Guide

This repository is an RTL artifact workspace. Root automation orchestrates isolated project pipelines; project-specific build logic belongs under `projects/<name>/`.

## Local Guidance

- Use root `Makefile` targets as the public command surface.
- Keep the root `Makefile` small: host checks, project delegation, release flow.
- Generated outputs live in ignored `artifacts/`, `projects/*/downloads/`, `projects/*/work/`, and `projects/*/.build/`.
- Do not commit generated artifacts, downloaded sources, build outputs, credentials, or tool caches.

## Repository Map

- `Makefile` is the host entry point. It checks host tools, delegates root targets to projects, lists expected artifacts, and calls the release script.
- `README.md` is the user-facing overview, quick start, project summary, artifact inventory, and brief release note.
- `scripts/release.sh` creates GitHub releases from the generated artifact tree.
- `projects/AGENTS.md` defines the shared contract for project subdirectories.
- `projects/scr1/` builds SCR1 artifacts from a pinned upstream checkout.
- `projects/picorv32/` builds PicoRV32 artifacts from a pinned upstream checkout.
- `projects/chipyard/` builds Chipyard artifacts from a pinned upstream checkout.
- `projects/tb_complex_types/` builds the internal SystemVerilog waveform fixture using supported open-source simulators.
- `projects/systemc-components/` builds MINRES SystemC-Components VCD/FST/FTR example artifacts.
- `artifacts/` is ignored generated output and release input.

Every project directory should own these files or targets unless there is a documented reason not to:

- `Makefile` with `image`, `download`, `prepare`, `collect`, `list`, `shell`, `clean`, `distclean`, and `help` targets.
- `Dockerfile` for the project-specific tool image.
- `versions.mk` for upstream source pins and tool pins.
- `README.md` for project-local usage notes.
- `downloads/` for source caches.
- `work/` for prepared source trees, build output, logs, and run scratch state.
- `.build/` for Make stamp files.

## Workflow

- Use `make tools-check` to verify host prerequisites.
- Use `make collect PROJECTS="scr1 tb_complex_types"` to run a reduced project set.
- Use `make -C projects/<name> collect` when changing one project pipeline.
- Use `make list` and `find "$PWD/artifacts" -type f | sort` to compare expected and actual artifacts.
- Do not run `make artifacts-clean`, root `make clean`, or root `make distclean` unless deleting generated outputs is intended.

## Release Procedure

Use `make release VERSION=vX.Y.Z` only when release assets are ready and GitHub CLI is authenticated.

Before a real release, run:

```bash
make tools-check
make collect
make list | sort > /tmp/rtl-artifacts-expected.txt
find "$PWD/artifacts" -type f | sort > /tmp/rtl-artifacts-actual.txt
diff -u /tmp/rtl-artifacts-expected.txt /tmp/rtl-artifacts-actual.txt
git status --short
```

Then release:

```bash
make release VERSION=vX.Y.Z
```
