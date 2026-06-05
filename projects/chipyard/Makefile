SHELL := /bin/bash
.DEFAULT_GOAL := help
.NOTPARALLEL:

PROJECT_NAME := chipyard
IMAGE ?= rtl-artifacts-$(PROJECT_NAME):local
DOWNLOADS_DIR ?= downloads
WORK_DIR ?= work
BUILD_DIR ?= .build
ARTIFACTS_DIR ?= $(abspath ../../artifacts/$(PROJECT_NAME))
CHIPYARD_SETUP_ARGS ?= riscv-tools --skip-ctags --skip-firesim --skip-marshal

include versions.mk

IMAGE_STAMP := $(BUILD_DIR)/image.stamp
DOWNLOAD_STAMP := $(BUILD_DIR)/download.stamp
PREPARE_STAMP := $(BUILD_DIR)/prepare.stamp
SRC_DIR := $(WORK_DIR)/src
DOWNLOAD_SRC_DIR := $(DOWNLOADS_DIR)/src

ARTIFACTS := \
	$(ARTIFACTS_DIR)/DualRocketConfig/dhrystone.fst \
	$(ARTIFACTS_DIR)/DualRocketConfig/towers.fst \
	$(ARTIFACTS_DIR)/DualRocketConfig/qsort.fst \
	$(ARTIFACTS_DIR)/DualRocketConfig/memcpy.fst \
	$(ARTIFACTS_DIR)/DualRocketConfig/mt-memcpy.fst \
	$(ARTIFACTS_DIR)/DualRocketConfig/mt-vvadd.fst \
	$(ARTIFACTS_DIR)/ClusteredRocketConfig/dhrystone.fst \
	$(ARTIFACTS_DIR)/ClusteredRocketConfig/towers.fst \
	$(ARTIFACTS_DIR)/ClusteredRocketConfig/qsort.fst \
	$(ARTIFACTS_DIR)/ClusteredRocketConfig/memcpy.fst \
	$(ARTIFACTS_DIR)/ClusteredRocketConfig/mt-memcpy.fst \
	$(ARTIFACTS_DIR)/ClusteredRocketConfig/mt-vvadd.fst

.PHONY: help image download prepare collect list shell clean distclean

help:
	@printf '%s\n' 'Targets:'
	@printf '  %-18s %s\n' 'image' 'Build the Chipyard Docker image.'
	@printf '  %-18s %s\n' 'download' 'Populate downloads/src with Chipyard at CHIPYARD_COMMIT.'
	@printf '  %-18s %s\n' 'prepare' 'Copy downloads/src into work/src and run build-setup.'
	@printf '  %-18s %s\n' 'collect' 'Collect default Chipyard waveform artifacts.'
	@printf '  %-18s %s\n' 'list' 'Print default artifact targets.'
	@printf '  %-18s %s\n' 'shell' 'Open a debug shell in the Chipyard image.'
	@printf '  %-18s %s\n' 'clean' 'Remove work, build stamps, and selected artifacts.'
	@printf '  %-18s %s\n' 'distclean' 'Run clean and remove downloads too.'

image: $(IMAGE_STAMP)
$(IMAGE_STAMP): Dockerfile versions.mk | $(BUILD_DIR)
	docker build --network host \
	  --build-arg TOOL_IMAGE_BASE="$(TOOL_IMAGE_BASE)" \
	  --build-arg MINIFORGE_VERSION="$(MINIFORGE_VERSION)" \
	  --build-arg VERILATOR_VERSION="$(VERILATOR_VERSION)" \
	  -t "$(IMAGE)" .
	mkdir -p "$(@D)"
	touch "$@"

download: $(DOWNLOAD_STAMP)
$(DOWNLOAD_STAMP): Makefile versions.mk | $(BUILD_DIR)
	@set -euo pipefail; \
	mkdir -p "$(DOWNLOADS_DIR)"; \
	if [ ! -d "$(DOWNLOAD_SRC_DIR)/.git" ]; then \
		rm -rf "$(DOWNLOAD_SRC_DIR)"; \
		git clone --branch "$(CHIPYARD_VERSION)" "$(CHIPYARD_URL)" "$(DOWNLOAD_SRC_DIR)"; \
	else \
		git -C "$(DOWNLOAD_SRC_DIR)" fetch --tags origin; \
	fi; \
	git -C "$(DOWNLOAD_SRC_DIR)" checkout --force "$(CHIPYARD_COMMIT)"; \
	git -C "$(DOWNLOAD_SRC_DIR)" reset --hard "$(CHIPYARD_COMMIT)"; \
	git -C "$(DOWNLOAD_SRC_DIR)" clean -ffdx; \
	test "$$(git -C "$(DOWNLOAD_SRC_DIR)" rev-parse HEAD)" = "$(CHIPYARD_COMMIT)"; \
	touch "$@"

prepare: $(PREPARE_STAMP)
$(PREPARE_STAMP): $(DOWNLOAD_STAMP) $(IMAGE_STAMP) Makefile versions.mk Dockerfile | $(BUILD_DIR)
	@set -euo pipefail; \
	rm -rf "$(SRC_DIR)"; \
	mkdir -p "$(WORK_DIR)"; \
	cp -a "$(DOWNLOAD_SRC_DIR)" "$(SRC_DIR)"; \
	test "$$(git -C "$(SRC_DIR)" rev-parse HEAD)" = "$(CHIPYARD_COMMIT)"
	@$(call RUN_IN_CONTAINER,cd /work/src && ./build-setup.sh $(CHIPYARD_SETUP_ARGS) && . /work/src/env.sh && test -f "$$RISCV/riscv64-unknown-elf/share/riscv-tests/benchmarks/dhrystone.riscv")
	@touch "$@"

collect: $(ARTIFACTS)

list:
	@printf '%s\n' $(ARTIFACTS)

$(BUILD_DIR):
	mkdir -p "$@"

$(ARTIFACTS_DIR)/DualRocketConfig/dhrystone.fst: $(PREPARE_STAMP) $(IMAGE_STAMP) Makefile versions.mk
	@echo 'Collecting Chipyard DualRocketConfig/dhrystone'
	@$(call RUN_IN_CONTAINER,mkdir -p /artifacts/DualRocketConfig && cd /work/src && . /work/src/env.sh && make -C /work/src/sims/verilator CONFIG="DualRocketConfig" run-binary-debug USE_FST=1 BINARY="$$RISCV/riscv64-unknown-elf/share/riscv-tests/benchmarks/dhrystone.riscv" && test -s /work/src/sims/verilator/output/chipyard.harness.TestHarness.DualRocketConfig/dhrystone.fst && cp /work/src/sims/verilator/output/chipyard.harness.TestHarness.DualRocketConfig/dhrystone.fst /artifacts/DualRocketConfig/dhrystone.fst.tmp && mv /artifacts/DualRocketConfig/dhrystone.fst.tmp /artifacts/DualRocketConfig/dhrystone.fst)

$(ARTIFACTS_DIR)/DualRocketConfig/towers.fst: $(PREPARE_STAMP) $(IMAGE_STAMP) Makefile versions.mk
	@echo 'Collecting Chipyard DualRocketConfig/towers'
	@$(call RUN_IN_CONTAINER,mkdir -p /artifacts/DualRocketConfig && cd /work/src && . /work/src/env.sh && make -C /work/src/sims/verilator CONFIG="DualRocketConfig" run-binary-debug USE_FST=1 BINARY="$$RISCV/riscv64-unknown-elf/share/riscv-tests/benchmarks/towers.riscv" && test -s /work/src/sims/verilator/output/chipyard.harness.TestHarness.DualRocketConfig/towers.fst && cp /work/src/sims/verilator/output/chipyard.harness.TestHarness.DualRocketConfig/towers.fst /artifacts/DualRocketConfig/towers.fst.tmp && mv /artifacts/DualRocketConfig/towers.fst.tmp /artifacts/DualRocketConfig/towers.fst)

$(ARTIFACTS_DIR)/DualRocketConfig/qsort.fst: $(PREPARE_STAMP) $(IMAGE_STAMP) Makefile versions.mk
	@echo 'Collecting Chipyard DualRocketConfig/qsort'
	@$(call RUN_IN_CONTAINER,mkdir -p /artifacts/DualRocketConfig && cd /work/src && . /work/src/env.sh && make -C /work/src/sims/verilator CONFIG="DualRocketConfig" run-binary-debug USE_FST=1 BINARY="$$RISCV/riscv64-unknown-elf/share/riscv-tests/benchmarks/qsort.riscv" && test -s /work/src/sims/verilator/output/chipyard.harness.TestHarness.DualRocketConfig/qsort.fst && cp /work/src/sims/verilator/output/chipyard.harness.TestHarness.DualRocketConfig/qsort.fst /artifacts/DualRocketConfig/qsort.fst.tmp && mv /artifacts/DualRocketConfig/qsort.fst.tmp /artifacts/DualRocketConfig/qsort.fst)

$(ARTIFACTS_DIR)/DualRocketConfig/memcpy.fst: $(PREPARE_STAMP) $(IMAGE_STAMP) Makefile versions.mk
	@echo 'Collecting Chipyard DualRocketConfig/memcpy'
	@$(call RUN_IN_CONTAINER,mkdir -p /artifacts/DualRocketConfig && cd /work/src && . /work/src/env.sh && make -C /work/src/sims/verilator CONFIG="DualRocketConfig" run-binary-debug USE_FST=1 BINARY="$$RISCV/riscv64-unknown-elf/share/riscv-tests/benchmarks/memcpy.riscv" && test -s /work/src/sims/verilator/output/chipyard.harness.TestHarness.DualRocketConfig/memcpy.fst && cp /work/src/sims/verilator/output/chipyard.harness.TestHarness.DualRocketConfig/memcpy.fst /artifacts/DualRocketConfig/memcpy.fst.tmp && mv /artifacts/DualRocketConfig/memcpy.fst.tmp /artifacts/DualRocketConfig/memcpy.fst)

$(ARTIFACTS_DIR)/DualRocketConfig/mt-memcpy.fst: $(PREPARE_STAMP) $(IMAGE_STAMP) Makefile versions.mk
	@echo 'Collecting Chipyard DualRocketConfig/mt-memcpy'
	@$(call RUN_IN_CONTAINER,mkdir -p /artifacts/DualRocketConfig && cd /work/src && . /work/src/env.sh && make -C /work/src/sims/verilator CONFIG="DualRocketConfig" run-binary-debug USE_FST=1 BINARY="$$RISCV/riscv64-unknown-elf/share/riscv-tests/benchmarks/mt-memcpy.riscv" && test -s /work/src/sims/verilator/output/chipyard.harness.TestHarness.DualRocketConfig/mt-memcpy.fst && cp /work/src/sims/verilator/output/chipyard.harness.TestHarness.DualRocketConfig/mt-memcpy.fst /artifacts/DualRocketConfig/mt-memcpy.fst.tmp && mv /artifacts/DualRocketConfig/mt-memcpy.fst.tmp /artifacts/DualRocketConfig/mt-memcpy.fst)

$(ARTIFACTS_DIR)/DualRocketConfig/mt-vvadd.fst: $(PREPARE_STAMP) $(IMAGE_STAMP) Makefile versions.mk
	@echo 'Collecting Chipyard DualRocketConfig/mt-vvadd'
	@$(call RUN_IN_CONTAINER,mkdir -p /artifacts/DualRocketConfig && cd /work/src && . /work/src/env.sh && make -C /work/src/sims/verilator CONFIG="DualRocketConfig" run-binary-debug USE_FST=1 BINARY="$$RISCV/riscv64-unknown-elf/share/riscv-tests/benchmarks/mt-vvadd.riscv" && test -s /work/src/sims/verilator/output/chipyard.harness.TestHarness.DualRocketConfig/mt-vvadd.fst && cp /work/src/sims/verilator/output/chipyard.harness.TestHarness.DualRocketConfig/mt-vvadd.fst /artifacts/DualRocketConfig/mt-vvadd.fst.tmp && mv /artifacts/DualRocketConfig/mt-vvadd.fst.tmp /artifacts/DualRocketConfig/mt-vvadd.fst)

$(ARTIFACTS_DIR)/ClusteredRocketConfig/dhrystone.fst: $(PREPARE_STAMP) $(IMAGE_STAMP) Makefile versions.mk
	@echo 'Collecting Chipyard ClusteredRocketConfig/dhrystone'
	@$(call RUN_IN_CONTAINER,mkdir -p /artifacts/ClusteredRocketConfig && cd /work/src && . /work/src/env.sh && make -C /work/src/sims/verilator CONFIG="ClusteredRocketConfig" run-binary-debug USE_FST=1 BINARY="$$RISCV/riscv64-unknown-elf/share/riscv-tests/benchmarks/dhrystone.riscv" && test -s /work/src/sims/verilator/output/chipyard.harness.TestHarness.ClusteredRocketConfig/dhrystone.fst && cp /work/src/sims/verilator/output/chipyard.harness.TestHarness.ClusteredRocketConfig/dhrystone.fst /artifacts/ClusteredRocketConfig/dhrystone.fst.tmp && mv /artifacts/ClusteredRocketConfig/dhrystone.fst.tmp /artifacts/ClusteredRocketConfig/dhrystone.fst)

$(ARTIFACTS_DIR)/ClusteredRocketConfig/towers.fst: $(PREPARE_STAMP) $(IMAGE_STAMP) Makefile versions.mk
	@echo 'Collecting Chipyard ClusteredRocketConfig/towers'
	@$(call RUN_IN_CONTAINER,mkdir -p /artifacts/ClusteredRocketConfig && cd /work/src && . /work/src/env.sh && make -C /work/src/sims/verilator CONFIG="ClusteredRocketConfig" run-binary-debug USE_FST=1 BINARY="$$RISCV/riscv64-unknown-elf/share/riscv-tests/benchmarks/towers.riscv" && test -s /work/src/sims/verilator/output/chipyard.harness.TestHarness.ClusteredRocketConfig/towers.fst && cp /work/src/sims/verilator/output/chipyard.harness.TestHarness.ClusteredRocketConfig/towers.fst /artifacts/ClusteredRocketConfig/towers.fst.tmp && mv /artifacts/ClusteredRocketConfig/towers.fst.tmp /artifacts/ClusteredRocketConfig/towers.fst)

$(ARTIFACTS_DIR)/ClusteredRocketConfig/qsort.fst: $(PREPARE_STAMP) $(IMAGE_STAMP) Makefile versions.mk
	@echo 'Collecting Chipyard ClusteredRocketConfig/qsort'
	@$(call RUN_IN_CONTAINER,mkdir -p /artifacts/ClusteredRocketConfig && cd /work/src && . /work/src/env.sh && make -C /work/src/sims/verilator CONFIG="ClusteredRocketConfig" run-binary-debug USE_FST=1 BINARY="$$RISCV/riscv64-unknown-elf/share/riscv-tests/benchmarks/qsort.riscv" && test -s /work/src/sims/verilator/output/chipyard.harness.TestHarness.ClusteredRocketConfig/qsort.fst && cp /work/src/sims/verilator/output/chipyard.harness.TestHarness.ClusteredRocketConfig/qsort.fst /artifacts/ClusteredRocketConfig/qsort.fst.tmp && mv /artifacts/ClusteredRocketConfig/qsort.fst.tmp /artifacts/ClusteredRocketConfig/qsort.fst)

$(ARTIFACTS_DIR)/ClusteredRocketConfig/memcpy.fst: $(PREPARE_STAMP) $(IMAGE_STAMP) Makefile versions.mk
	@echo 'Collecting Chipyard ClusteredRocketConfig/memcpy'
	@$(call RUN_IN_CONTAINER,mkdir -p /artifacts/ClusteredRocketConfig && cd /work/src && . /work/src/env.sh && make -C /work/src/sims/verilator CONFIG="ClusteredRocketConfig" run-binary-debug USE_FST=1 BINARY="$$RISCV/riscv64-unknown-elf/share/riscv-tests/benchmarks/memcpy.riscv" && test -s /work/src/sims/verilator/output/chipyard.harness.TestHarness.ClusteredRocketConfig/memcpy.fst && cp /work/src/sims/verilator/output/chipyard.harness.TestHarness.ClusteredRocketConfig/memcpy.fst /artifacts/ClusteredRocketConfig/memcpy.fst.tmp && mv /artifacts/ClusteredRocketConfig/memcpy.fst.tmp /artifacts/ClusteredRocketConfig/memcpy.fst)

$(ARTIFACTS_DIR)/ClusteredRocketConfig/mt-memcpy.fst: $(PREPARE_STAMP) $(IMAGE_STAMP) Makefile versions.mk
	@echo 'Collecting Chipyard ClusteredRocketConfig/mt-memcpy'
	@$(call RUN_IN_CONTAINER,mkdir -p /artifacts/ClusteredRocketConfig && cd /work/src && . /work/src/env.sh && make -C /work/src/sims/verilator CONFIG="ClusteredRocketConfig" run-binary-debug USE_FST=1 BINARY="$$RISCV/riscv64-unknown-elf/share/riscv-tests/benchmarks/mt-memcpy.riscv" && test -s /work/src/sims/verilator/output/chipyard.harness.TestHarness.ClusteredRocketConfig/mt-memcpy.fst && cp /work/src/sims/verilator/output/chipyard.harness.TestHarness.ClusteredRocketConfig/mt-memcpy.fst /artifacts/ClusteredRocketConfig/mt-memcpy.fst.tmp && mv /artifacts/ClusteredRocketConfig/mt-memcpy.fst.tmp /artifacts/ClusteredRocketConfig/mt-memcpy.fst)

$(ARTIFACTS_DIR)/ClusteredRocketConfig/mt-vvadd.fst: $(PREPARE_STAMP) $(IMAGE_STAMP) Makefile versions.mk
	@echo 'Collecting Chipyard ClusteredRocketConfig/mt-vvadd'
	@$(call RUN_IN_CONTAINER,mkdir -p /artifacts/ClusteredRocketConfig && cd /work/src && . /work/src/env.sh && make -C /work/src/sims/verilator CONFIG="ClusteredRocketConfig" run-binary-debug USE_FST=1 BINARY="$$RISCV/riscv64-unknown-elf/share/riscv-tests/benchmarks/mt-vvadd.riscv" && test -s /work/src/sims/verilator/output/chipyard.harness.TestHarness.ClusteredRocketConfig/mt-vvadd.fst && cp /work/src/sims/verilator/output/chipyard.harness.TestHarness.ClusteredRocketConfig/mt-vvadd.fst /artifacts/ClusteredRocketConfig/mt-vvadd.fst.tmp && mv /artifacts/ClusteredRocketConfig/mt-vvadd.fst.tmp /artifacts/ClusteredRocketConfig/mt-vvadd.fst)

shell: $(IMAGE_STAMP) $(PREPARE_STAMP)
	@mkdir -p "$(DOWNLOADS_DIR)" "$(WORK_DIR)" "$(ARTIFACTS_DIR)" "$(BUILD_DIR)"
	docker run --rm -it \
	  --user "$$(id -u):$$(id -g)" \
	  -e HOME=/work/.home \
	  -e USER=host \
	  -e LOGNAME=host \
	  -e XDG_CACHE_HOME=/work/.cache \
	  -e CCACHE_DIR=/work/.ccache \
	  -e CONDA_PKGS_DIRS=/work/.conda/pkgs \
	  -e PIP_CACHE_DIR=/work/.cache/pip \
	  -v "$(abspath .):/project:ro" \
	  -v "$(abspath $(DOWNLOADS_DIR)):/downloads" \
	  -v "$(abspath $(WORK_DIR)):/work" \
	  -v "$(abspath $(ARTIFACTS_DIR)):/artifacts" \
	  -w /work/src \
	  "$(IMAGE)" \
	  bash -lc 'mkdir -p "$$HOME" "$$XDG_CACHE_HOME" "$$CCACHE_DIR" "$$CONDA_PKGS_DIRS" "$$PIP_CACHE_DIR" && . /work/src/env.sh && exec bash'

clean:
	rm -rf "$(WORK_DIR)" "$(BUILD_DIR)" "$(ARTIFACTS_DIR)"

distclean: clean
	rm -rf "$(DOWNLOADS_DIR)"

define RUN_IN_CONTAINER
mkdir -p "$(DOWNLOADS_DIR)" "$(WORK_DIR)" "$(ARTIFACTS_DIR)" "$(BUILD_DIR)" && \
test -w "$(DOWNLOADS_DIR)" && test -w "$(WORK_DIR)" && test -w "$(ARTIFACTS_DIR)" && \
docker run --rm \
  --user "$$(id -u):$$(id -g)" \
  -e HOME=/work/.home \
  -e USER=host \
  -e LOGNAME=host \
  -e XDG_CACHE_HOME=/work/.cache \
  -e CCACHE_DIR=/work/.ccache \
  -e CONDA_PKGS_DIRS=/work/.conda/pkgs \
  -e PIP_CACHE_DIR=/work/.cache/pip \
  -v "$(abspath .):/project:ro" \
  -v "$(abspath $(DOWNLOADS_DIR)):/downloads" \
  -v "$(abspath $(WORK_DIR)):/work" \
  -v "$(abspath $(ARTIFACTS_DIR)):/artifacts" \
  -w /work/src \
  "$(IMAGE)" \
  bash -lc 'mkdir -p "$$HOME" "$$XDG_CACHE_HOME" "$$CCACHE_DIR" "$$CONDA_PKGS_DIRS" "$$PIP_CACHE_DIR" && $(1)'
endef
