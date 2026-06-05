# Agent Guide (rtl-artifacts)

This repository is an RTL artifact workspace. Root automation orchestrates isolated project pipelines; project-specific build logic belongs under `projects/<name>/`.

## Local Guidance

- Use root `Makefile` targets as the public command surface.
- Keep the root `Makefile` small: host checks, project delegation, release flow.
- Do not add a tracked `Justfile` or restore pre-commit hooks without a new design decision.
- Do not rely on a devcontainer or global `/opt` source trees; project Docker images own their tools.
- Generated outputs live in ignored `artifacts/`, `projects/*/downloads/`, `projects/*/work/`, and `projects/*/.build/`.
- Do not commit generated artifacts, downloaded sources, build outputs, credentials, or tool caches.

## Workflow

- Use `make tools-check` to verify host prerequisites.
- Use `make collect PROJECTS="scr1 tb_complex_types"` to run a reduced project set.
- Use `make -C projects/<name> collect` when changing one project pipeline.
- Use `make release VERSION=vX.Y.Z` only when release assets are ready and GitHub CLI is authenticated.
