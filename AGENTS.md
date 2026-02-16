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

- `make bootstrap` - verify external sources, verify tools, install git hooks.
- `make tools-check` - print versions of required tooling.
- `make sources-check` - verify external source trees are present and writable.
- `make pre-commit` - run hooks on all files.
- `make check-commit` - validate the current commit message.

## External Source Policy

- Upstream RTL projects are installed by `.devcontainer/Dockerfile` under `/opt`.
- Keep upstream revisions pinned explicitly in Docker build arguments.
- Avoid editing files inside `/opt` trees directly; bump pinned upstream revisions instead.
- When changing pinned revisions, include upstream commit intent in commit message.

## Container Policy

- `.devcontainer/Dockerfile` defines a single image used both locally and in CI.
- The devcontainer image includes standalone installs for SCR1, PicoRV32, and
  Chipyard under `/opt`.
- Keep tooling setup in one place; avoid parallel "dev" and "ci" variants.
- The image should contain only tooling needed for artifact generation/inspection.
