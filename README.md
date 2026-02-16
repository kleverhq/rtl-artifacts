# rtl-artifacts

Repository for generating and storing RTL artifacts: simulator logs,
waveform dumps, binaries, and other reproducible outputs.

The goal is to keep heavy HDL toolchains out of application repositories
(Rust/Python/etc) and centralize artifact production in one place.

## Included RTL components

- SCR1: `third_party/scr1`
- PicoRV32: `third_party/picorv32`
- Chipyard: preinstalled in the Docker image at `/opt/chipyard`

## Current artifact scope

At the moment, `make collect` stores only simulation waveform dumps from test
runs in `.fst` format (Verilator-based collection flow).

| Project | Configs | Tests |
| --- | --- | --- |
| SCR1 | `MAX` (buses: `AXI`, `AHB`) | `isr_sample`, `riscv_arch`, `riscv_compliance`, `riscv_isa`, `hello`, `coremark`, `dhrystone21` |
| PicoRV32 | Target defaults | `test_vcd`, `test_wb_vcd`, `test_ez_vcd` |
| Chipyard | `DualRocketConfig`, `ClusteredRocketConfig` | `dhrystone`, `towers`, `qsort`, `memcpy`, `mt-memcpy`, `mt-vvadd` |

## Quick start

Clone the repository first:

```bash
git clone --recurse-submodules <repo-url>
cd rtl-artifacts
```

Run all commands inside the Docker image defined in
`.devcontainer/Dockerfile`.

You can use either:
- Dev Containers (recommended): open this repository in a devcontainer.
- Manual Docker run: build and run the same image yourself.

```bash
docker build -f .devcontainer/Dockerfile -t rtl-artifacts:dev .
docker run --rm -it --network host \
  -v "$(pwd):/workspaces/rtl-artifacts" \
  -w /workspaces/rtl-artifacts \
  rtl-artifacts:dev bash
```

Then run bootstrap inside the container:

```bash
make bootstrap
```

## Collect all artifacts

```bash
make collect
```

## Other commands

```bash
make help
```
