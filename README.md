# rtl-artifacts

Repository for generating and storing RTL artifacts: simulator logs,
waveform dumps, binaries, and other reproducible outputs.

The goal is to keep heavy HDL toolchains out of application repositories
(Rust/Python/etc) and centralize artifact production in one place.

## Quick start

```bash
git clone --recurse-submodules <repo-url>
cd rtl-artifacts
make bootstrap
```

If the repository is already cloned without submodules:

```bash
make submodules-init
```

## ModelSim GUI in devcontainer

`vsim` works in this workspace both in console mode and with GUI.

### What is configured in this repo

- `.devcontainer/devcontainer.json` passes host `DISPLAY` into the container.
- `.devcontainer/devcontainer.json` mounts `/tmp/.X11-unix` into the container.
- We intentionally do not mount `~/.Xauthority` by default because it is absent on some hosts and can break container startup.

### Host-side step for GUI access

Before starting ModelSim GUI, allow your local user to connect to the X server:

```bash
xhost +SI:localuser:$(id -un)
```

This permission is typically reset when the graphical session restarts (logout/reboot/X server restart), so in practice you may need to run it once per new desktop session.

You can revoke the permission later with:

```bash
xhost -SI:localuser:$(id -un)
```

### Verification

- Console (headless): `vsim -c -do "quit -f"`
- GUI: `vsim`

If GUI fails with `Tk initialization failed: couldn't connect to display`, re-check `xhost` access and rebuild/reopen the devcontainer.
