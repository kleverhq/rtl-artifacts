# Agent Guide (projects)

This subtree contains isolated artifact-producing projects. Each project must remain runnable on its own with `make -C projects/<name> collect`.

## Local Guidance

- Each project owns its `Makefile`, `Dockerfile`, `versions.mk`, downloads, work tree, and artifact recipes.
- Keep project containers project-specific; do not install unrelated editor tools, coding agents, or other convenience packages.
- Project recipes may write only to `downloads/`, `work/`, `.build/`, and the selected `ARTIFACTS_DIR`.
- Keep `versions.mk` tracked for every project, including internal projects without upstream source pins.
- Make `collect` depend on real artifact files where practical so incremental builds stay meaningful.
- Serialize project artifact targets unless each artifact has isolated upstream output paths.

## Required Targets

Every project Makefile must provide `image`, `download`, `prepare`, `collect`, `list`, `shell`, `clean`, `distclean`, and `help`.
