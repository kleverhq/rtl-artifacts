# Agent Guide (rtl-artifacts)

This repository is an RTL artifact workspace. Root automation orchestrates isolated project pipelines; project-specific build logic belongs under `projects/<name>/`.

## Local Guidance

- Use root `Makefile` targets as the public command surface.
- Keep the root `Makefile` small: host checks, project delegation, release flow.
- Do not add a tracked `Justfile` or restore pre-commit hooks without a new design decision.
- Do not rely on a devcontainer or global `/opt` source trees; project Docker images own their tools.
- Generated outputs live in ignored `artifacts/`, `projects/*/downloads/`, `projects/*/work/`, and `projects/*/.build/`.
- Do not commit generated artifacts, downloaded sources, build outputs, credentials, or tool caches.

## Repository Map

- `Makefile` is the host entry point. It checks host tools, delegates root targets to projects, lists expected artifacts, and calls the release script.
- `README.md` is the user-facing overview, quick start, project summary, artifact inventory, and brief release note.
- `scripts/release.sh` creates GitHub releases from the generated artifact tree.
- `EXECPLAN-isolated-project-pipelines.md` is the living implementation plan for the isolated project pipeline work.
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

The release script performs these steps:

1. Verifies required commands are available: `gh`, `make`, `git`, `awk`, `find`, `sort`, and `mktemp`.
2. Verifies `gh auth status` succeeds.
3. Verifies an `origin` remote exists, unless `GH_REPO` is set.
4. Rejects an already existing GitHub release with the requested version.
5. Reads project version notes from every `projects/*/versions.mk` file.
6. Requires a clean Git worktree by default. Set `ALLOW_DIRTY=1` only for deliberate local dry runs.
7. Runs `make collect` incrementally with the selected `ARTIFACTS_DIR`, defaulting to `artifacts/`.
8. Builds the expected artifact list with `make list`.
9. Fails if any listed artifact is missing.
10. Fails if any extra unlisted file exists under the artifact directory, because stale files make releases ambiguous.
11. Stages release assets in a temporary flat directory by replacing `/` with `__` in artifact paths.
12. Fails on duplicate flattened asset names.
13. Creates the GitHub release with one uploaded asset per artifact file.

Nested artifact paths become flat release asset names. For example, `artifacts/chipyard/DualRocketConfig/dhrystone.fst` is uploaded as `chipyard__DualRocketConfig__dhrystone.fst`.

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
