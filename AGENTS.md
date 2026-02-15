# Agent Guide (rtl-artifacts)

This repository is an RTL artifact workspace, not an application codebase.
Use it to keep heavy HDL tooling, upstream RTL sources, and generated fixtures
in one place.

## Scope and Intent

- Keep this repo focused on deterministic artifact production workflows.
- Prefer updating root automation (`Makefile`, container setup, hooks) over
  adding ad-hoc scripts.

## Main Commands

Use `Makefile` targets as the primary interface:

- `make bootstrap` - initialize submodules, verify tools, install git hooks.
- `make tools-check` - print versions of required tooling.
- `make submodules-init` - init/sync all submodules recursively.
- `make submodules-update` - update submodules to configured upstream branches.
- `make submodules-status` - show pinned submodule commits.
- `make pre-commit` - run hooks on all files.
- `make check-commit` - validate the current commit message.

## Submodule Policy

- Upstream RTL projects are tracked via git submodules under `third_party/`.
- Avoid editing files inside submodules directly; bump submodule commits instead.
- Keep `.gitmodules` URLs explicit and reproducible.
- When changing submodule refs, include upstream commit intent in commit message.

## Container Policy

- `.devcontainer/Dockerfile` defines a single image used both locally and in CI.
- The devcontainer image includes a standalone Chipyard install at `/opt/chipyard`
  (outside this repo and not as a submodule); use it as a toolchain dependency.
- Keep tooling setup in one place; avoid parallel "dev" and "ci" variants.
- The image should contain only tooling needed for artifact generation/inspection.
