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
