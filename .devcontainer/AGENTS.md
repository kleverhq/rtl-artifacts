# Devcontainer Notes For Agents

This directory is intentionally simple: one Docker image, reused in local
development and CI.

## Why this layout exists

- `.devcontainer/Dockerfile` uses dedicated builder stages for heavy tools
  (`verilator`, `modelsim`, `slang-server`, `surfer`, RISC-V toolchain) and one final runtime
  image. This keeps rebuild caching effective without maintaining separate
  `dev`/`ci` runtime targets.
- `.devcontainer/devcontainer.json` points to that same image so local sessions
  and automation converge on one environment definition.

## Non-obvious decisions

- The workspace mounts the repository parent into `/workspaces` so sibling
  worktrees can be used without extra mount changes.
- OpenCode state is bind-mounted from the host and pre-created in
  `initializeCommand` to survive container recreation.
- Host networking is enabled because bridge networking often breaks in
  VPN-heavy setups.
- X11 GUI tools (for example ModelSim) use host `DISPLAY` plus a bind mount of
  `/tmp/.X11-unix`. Access control is done host-side with
  `xhost +SI:localuser:$(id -un)` instead of `.Xauthority` mounting, because
  `.Xauthority` is not guaranteed to exist on all host setups.
- `postStartCommand: make bootstrap` re-converges hooks and submodules on each
  start instead of relying on one-time setup.
- `safe.directory` is configured in `postCreateCommand` to avoid Git ownership
  warnings when host UID/GID mappings differ.
