ARTIFACTS_DIR ?= artifacts
ARTIFACTS_CHIPYARD_DIR ?= $(ARTIFACTS_DIR)

CHIPYARD_DIR ?= /opt/chipyard
CHIPYARD_SIM_DIR ?= $(CHIPYARD_DIR)/sims/verilator
CHIPYARD_ENV_SH ?= $(CHIPYARD_DIR)/env.sh
RISCV_BENCHMARK_TESTS_DIR ?= $$RISCV/riscv64-unknown-elf/share/riscv-tests/benchmarks

CHIPYARD_FSTS := \
	$(ARTIFACTS_CHIPYARD_DIR)/chipyard_DualRocketConfig_dhrystone.fst \
	$(ARTIFACTS_CHIPYARD_DIR)/chipyard_DualRocketConfig_towers.fst \
	$(ARTIFACTS_CHIPYARD_DIR)/chipyard_DualRocketConfig_qsort.fst \
	$(ARTIFACTS_CHIPYARD_DIR)/chipyard_DualRocketConfig_memcpy.fst \
	$(ARTIFACTS_CHIPYARD_DIR)/chipyard_DualRocketConfig_mt-memcpy.fst \
	$(ARTIFACTS_CHIPYARD_DIR)/chipyard_DualRocketConfig_mt-vvadd.fst \
	$(ARTIFACTS_CHIPYARD_DIR)/chipyard_ClusteredRocketConfig_dhrystone.fst \
	$(ARTIFACTS_CHIPYARD_DIR)/chipyard_ClusteredRocketConfig_towers.fst \
	$(ARTIFACTS_CHIPYARD_DIR)/chipyard_ClusteredRocketConfig_qsort.fst \
	$(ARTIFACTS_CHIPYARD_DIR)/chipyard_ClusteredRocketConfig_memcpy.fst \
	$(ARTIFACTS_CHIPYARD_DIR)/chipyard_ClusteredRocketConfig_mt-memcpy.fst \
	$(ARTIFACTS_CHIPYARD_DIR)/chipyard_ClusteredRocketConfig_mt-vvadd.fst

$(ARTIFACTS_CHIPYARD_DIR)/chipyard_DualRocketConfig_dhrystone.fst:
	@echo "Collecting Chipyard DualRocketConfig/dhrystone"
	mkdir -p "$(ARTIFACTS_CHIPYARD_DIR)"
	bash -lc 'set -e; source "$(CHIPYARD_ENV_SH)"; set -u; $(MAKE) -C "$(CHIPYARD_SIM_DIR)" CONFIG="DualRocketConfig" run-binary-debug USE_FST=1 BINARY="$(RISCV_BENCHMARK_TESTS_DIR)/dhrystone.riscv"'
	cp "$(CHIPYARD_SIM_DIR)/output/chipyard.harness.TestHarness.DualRocketConfig/dhrystone.fst" "$@"

$(ARTIFACTS_CHIPYARD_DIR)/chipyard_DualRocketConfig_towers.fst:
	@echo "Collecting Chipyard DualRocketConfig/towers"
	mkdir -p "$(ARTIFACTS_CHIPYARD_DIR)"
	bash -lc 'set -e; source "$(CHIPYARD_ENV_SH)"; set -u; $(MAKE) -C "$(CHIPYARD_SIM_DIR)" CONFIG="DualRocketConfig" run-binary-debug USE_FST=1 BINARY="$(RISCV_BENCHMARK_TESTS_DIR)/towers.riscv"'
	cp "$(CHIPYARD_SIM_DIR)/output/chipyard.harness.TestHarness.DualRocketConfig/towers.fst" "$@"

$(ARTIFACTS_CHIPYARD_DIR)/chipyard_DualRocketConfig_qsort.fst:
	@echo "Collecting Chipyard DualRocketConfig/qsort"
	mkdir -p "$(ARTIFACTS_CHIPYARD_DIR)"
	bash -lc 'set -e; source "$(CHIPYARD_ENV_SH)"; set -u; $(MAKE) -C "$(CHIPYARD_SIM_DIR)" CONFIG="DualRocketConfig" run-binary-debug USE_FST=1 BINARY="$(RISCV_BENCHMARK_TESTS_DIR)/qsort.riscv"'
	cp "$(CHIPYARD_SIM_DIR)/output/chipyard.harness.TestHarness.DualRocketConfig/qsort.fst" "$@"

$(ARTIFACTS_CHIPYARD_DIR)/chipyard_DualRocketConfig_memcpy.fst:
	@echo "Collecting Chipyard DualRocketConfig/memcpy"
	mkdir -p "$(ARTIFACTS_CHIPYARD_DIR)"
	bash -lc 'set -e; source "$(CHIPYARD_ENV_SH)"; set -u; $(MAKE) -C "$(CHIPYARD_SIM_DIR)" CONFIG="DualRocketConfig" run-binary-debug USE_FST=1 BINARY="$(RISCV_BENCHMARK_TESTS_DIR)/memcpy.riscv"'
	cp "$(CHIPYARD_SIM_DIR)/output/chipyard.harness.TestHarness.DualRocketConfig/memcpy.fst" "$@"

$(ARTIFACTS_CHIPYARD_DIR)/chipyard_DualRocketConfig_mt-memcpy.fst:
	@echo "Collecting Chipyard DualRocketConfig/mt-memcpy"
	mkdir -p "$(ARTIFACTS_CHIPYARD_DIR)"
	bash -lc 'set -e; source "$(CHIPYARD_ENV_SH)"; set -u; $(MAKE) -C "$(CHIPYARD_SIM_DIR)" CONFIG="DualRocketConfig" run-binary-debug USE_FST=1 BINARY="$(RISCV_BENCHMARK_TESTS_DIR)/mt-memcpy.riscv"'
	cp "$(CHIPYARD_SIM_DIR)/output/chipyard.harness.TestHarness.DualRocketConfig/mt-memcpy.fst" "$@"

$(ARTIFACTS_CHIPYARD_DIR)/chipyard_DualRocketConfig_mt-vvadd.fst:
	@echo "Collecting Chipyard DualRocketConfig/mt-vvadd"
	mkdir -p "$(ARTIFACTS_CHIPYARD_DIR)"
	bash -lc 'set -e; source "$(CHIPYARD_ENV_SH)"; set -u; $(MAKE) -C "$(CHIPYARD_SIM_DIR)" CONFIG="DualRocketConfig" run-binary-debug USE_FST=1 BINARY="$(RISCV_BENCHMARK_TESTS_DIR)/mt-vvadd.riscv"'
	cp "$(CHIPYARD_SIM_DIR)/output/chipyard.harness.TestHarness.DualRocketConfig/mt-vvadd.fst" "$@"

$(ARTIFACTS_CHIPYARD_DIR)/chipyard_ClusteredRocketConfig_dhrystone.fst:
	@echo "Collecting Chipyard ClusteredRocketConfig/dhrystone"
	mkdir -p "$(ARTIFACTS_CHIPYARD_DIR)"
	bash -lc 'set -e; source "$(CHIPYARD_ENV_SH)"; set -u; $(MAKE) -C "$(CHIPYARD_SIM_DIR)" CONFIG="ClusteredRocketConfig" run-binary-debug USE_FST=1 BINARY="$(RISCV_BENCHMARK_TESTS_DIR)/dhrystone.riscv"'
	cp "$(CHIPYARD_SIM_DIR)/output/chipyard.harness.TestHarness.ClusteredRocketConfig/dhrystone.fst" "$@"

$(ARTIFACTS_CHIPYARD_DIR)/chipyard_ClusteredRocketConfig_towers.fst:
	@echo "Collecting Chipyard ClusteredRocketConfig/towers"
	mkdir -p "$(ARTIFACTS_CHIPYARD_DIR)"
	bash -lc 'set -e; source "$(CHIPYARD_ENV_SH)"; set -u; $(MAKE) -C "$(CHIPYARD_SIM_DIR)" CONFIG="ClusteredRocketConfig" run-binary-debug USE_FST=1 BINARY="$(RISCV_BENCHMARK_TESTS_DIR)/towers.riscv"'
	cp "$(CHIPYARD_SIM_DIR)/output/chipyard.harness.TestHarness.ClusteredRocketConfig/towers.fst" "$@"

$(ARTIFACTS_CHIPYARD_DIR)/chipyard_ClusteredRocketConfig_qsort.fst:
	@echo "Collecting Chipyard ClusteredRocketConfig/qsort"
	mkdir -p "$(ARTIFACTS_CHIPYARD_DIR)"
	bash -lc 'set -e; source "$(CHIPYARD_ENV_SH)"; set -u; $(MAKE) -C "$(CHIPYARD_SIM_DIR)" CONFIG="ClusteredRocketConfig" run-binary-debug USE_FST=1 BINARY="$(RISCV_BENCHMARK_TESTS_DIR)/qsort.riscv"'
	cp "$(CHIPYARD_SIM_DIR)/output/chipyard.harness.TestHarness.ClusteredRocketConfig/qsort.fst" "$@"

$(ARTIFACTS_CHIPYARD_DIR)/chipyard_ClusteredRocketConfig_memcpy.fst:
	@echo "Collecting Chipyard ClusteredRocketConfig/memcpy"
	mkdir -p "$(ARTIFACTS_CHIPYARD_DIR)"
	bash -lc 'set -e; source "$(CHIPYARD_ENV_SH)"; set -u; $(MAKE) -C "$(CHIPYARD_SIM_DIR)" CONFIG="ClusteredRocketConfig" run-binary-debug USE_FST=1 BINARY="$(RISCV_BENCHMARK_TESTS_DIR)/memcpy.riscv"'
	cp "$(CHIPYARD_SIM_DIR)/output/chipyard.harness.TestHarness.ClusteredRocketConfig/memcpy.fst" "$@"

$(ARTIFACTS_CHIPYARD_DIR)/chipyard_ClusteredRocketConfig_mt-memcpy.fst:
	@echo "Collecting Chipyard ClusteredRocketConfig/mt-memcpy"
	mkdir -p "$(ARTIFACTS_CHIPYARD_DIR)"
	bash -lc 'set -e; source "$(CHIPYARD_ENV_SH)"; set -u; $(MAKE) -C "$(CHIPYARD_SIM_DIR)" CONFIG="ClusteredRocketConfig" run-binary-debug USE_FST=1 BINARY="$(RISCV_BENCHMARK_TESTS_DIR)/mt-memcpy.riscv"'
	cp "$(CHIPYARD_SIM_DIR)/output/chipyard.harness.TestHarness.ClusteredRocketConfig/mt-memcpy.fst" "$@"

$(ARTIFACTS_CHIPYARD_DIR)/chipyard_ClusteredRocketConfig_mt-vvadd.fst:
	@echo "Collecting Chipyard ClusteredRocketConfig/mt-vvadd"
	mkdir -p "$(ARTIFACTS_CHIPYARD_DIR)"
	bash -lc 'set -e; source "$(CHIPYARD_ENV_SH)"; set -u; $(MAKE) -C "$(CHIPYARD_SIM_DIR)" CONFIG="ClusteredRocketConfig" run-binary-debug USE_FST=1 BINARY="$(RISCV_BENCHMARK_TESTS_DIR)/mt-vvadd.riscv"'
	cp "$(CHIPYARD_SIM_DIR)/output/chipyard.harness.TestHarness.ClusteredRocketConfig/mt-vvadd.fst" "$@"

## Collect Chipyard waveform artifacts
.PHONY: chipyard
chipyard: $(CHIPYARD_FSTS)
