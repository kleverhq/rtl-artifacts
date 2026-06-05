SHELL := /bin/bash
.DEFAULT_GOAL := help
.NOTPARALLEL:

PROJECT_NAME := picorv32
IMAGE ?= rtl-artifacts-$(PROJECT_NAME):local
DOWNLOADS_DIR ?= downloads
WORK_DIR ?= work
BUILD_DIR ?= .build
ARTIFACTS_DIR ?= $(abspath ../../artifacts/$(PROJECT_NAME))
PICORV32_TOOLCHAIN_PREFIX ?= riscv64-unknown-elf-

include versions.mk

IMAGE_STAMP := $(BUILD_DIR)/image.stamp
DOWNLOAD_STAMP := $(BUILD_DIR)/download.stamp
PREPARE_STAMP := $(BUILD_DIR)/prepare.stamp
SRC_DIR := $(WORK_DIR)/src
DOWNLOAD_SRC_DIR := $(DOWNLOADS_DIR)/src

ARTIFACTS := \
	$(ARTIFACTS_DIR)/test_vcd.fst \
	$(ARTIFACTS_DIR)/test_wb_vcd.fst \
	$(ARTIFACTS_DIR)/test_ez_vcd.fst

.PHONY: help image download prepare collect list shell clean distclean

help:
	@printf '%s\n' 'Targets:'
	@printf '  %-18s %s\n' 'image' 'Build the PicoRV32 Docker image.'
	@printf '  %-18s %s\n' 'download' 'Populate downloads/src with PicoRV32 at PICORV32_COMMIT.'
	@printf '  %-18s %s\n' 'prepare' 'Copy downloads/src into work/src and verify the checkout.'
	@printf '  %-18s %s\n' 'collect' 'Collect default PicoRV32 waveform artifacts.'
	@printf '  %-18s %s\n' 'list' 'Print default artifact targets.'
	@printf '  %-18s %s\n' 'shell' 'Open a debug shell in the PicoRV32 image.'
	@printf '  %-18s %s\n' 'clean' 'Remove work, build stamps, and selected artifacts.'
	@printf '  %-18s %s\n' 'distclean' 'Run clean and remove downloads too.'

image: $(IMAGE_STAMP)
$(IMAGE_STAMP): Dockerfile versions.mk | $(BUILD_DIR)
	docker build --network host \
	  --build-arg TOOL_IMAGE_BASE="$(TOOL_IMAGE_BASE)" \
	  --build-arg RISCV_XPACK_VERSION="$(RISCV_XPACK_VERSION)" \
	  -t "$(IMAGE)" .
	mkdir -p "$(@D)"
	touch "$@"

download: $(DOWNLOAD_STAMP)
$(DOWNLOAD_STAMP): Makefile versions.mk | $(BUILD_DIR)
	@set -euo pipefail; \
	mkdir -p "$(DOWNLOADS_DIR)"; \
	if [ ! -d "$(DOWNLOAD_SRC_DIR)/.git" ]; then \
		rm -rf "$(DOWNLOAD_SRC_DIR)"; \
		git clone "$(PICORV32_URL)" "$(DOWNLOAD_SRC_DIR)"; \
	else \
		git -C "$(DOWNLOAD_SRC_DIR)" fetch --tags origin; \
	fi; \
	git -C "$(DOWNLOAD_SRC_DIR)" checkout --force "$(PICORV32_COMMIT)"; \
	git -C "$(DOWNLOAD_SRC_DIR)" reset --hard "$(PICORV32_COMMIT)"; \
	git -C "$(DOWNLOAD_SRC_DIR)" clean -ffdx; \
	test "$$(git -C "$(DOWNLOAD_SRC_DIR)" rev-parse HEAD)" = "$(PICORV32_COMMIT)"; \
	touch "$@"

prepare: $(PREPARE_STAMP)
$(PREPARE_STAMP): $(DOWNLOAD_STAMP) Makefile versions.mk | $(BUILD_DIR)
	@set -euo pipefail; \
	rm -rf "$(SRC_DIR)"; \
	mkdir -p "$(WORK_DIR)"; \
	cp -a "$(DOWNLOAD_SRC_DIR)" "$(SRC_DIR)"; \
	test "$$(git -C "$(SRC_DIR)" rev-parse HEAD)" = "$(PICORV32_COMMIT)"; \
	touch "$@"

collect: $(ARTIFACTS)

list:
	@printf '%s\n' $(ARTIFACTS)

$(BUILD_DIR):
	mkdir -p "$@"

$(ARTIFACTS_DIR)/test_vcd.fst: $(PREPARE_STAMP) $(IMAGE_STAMP) Makefile versions.mk
	@echo 'Collecting PicoRV32 test_vcd'
	@$(call RUN_IN_CONTAINER,mkdir -p /artifacts && cd /work/src && rm -f testbench.vcd && make TOOLCHAIN_PREFIX="$(PICORV32_TOOLCHAIN_PREFIX)" test_vcd && test -s testbench.vcd && vcd2fst testbench.vcd /artifacts/test_vcd.fst.tmp && mv /artifacts/test_vcd.fst.tmp /artifacts/test_vcd.fst)

$(ARTIFACTS_DIR)/test_wb_vcd.fst: $(PREPARE_STAMP) $(IMAGE_STAMP) Makefile versions.mk
	@echo 'Collecting PicoRV32 test_wb_vcd'
	@$(call RUN_IN_CONTAINER,mkdir -p /artifacts && cd /work/src && rm -f testbench.vcd && make TOOLCHAIN_PREFIX="$(PICORV32_TOOLCHAIN_PREFIX)" test_wb_vcd && test -s testbench.vcd && vcd2fst testbench.vcd /artifacts/test_wb_vcd.fst.tmp && mv /artifacts/test_wb_vcd.fst.tmp /artifacts/test_wb_vcd.fst)

$(ARTIFACTS_DIR)/test_ez_vcd.fst: $(PREPARE_STAMP) $(IMAGE_STAMP) Makefile versions.mk
	@echo 'Collecting PicoRV32 test_ez_vcd'
	@$(call RUN_IN_CONTAINER,mkdir -p /artifacts && cd /work/src && rm -f testbench.vcd && make TOOLCHAIN_PREFIX="$(PICORV32_TOOLCHAIN_PREFIX)" test_ez_vcd && test -s testbench.vcd && vcd2fst testbench.vcd /artifacts/test_ez_vcd.fst.tmp && mv /artifacts/test_ez_vcd.fst.tmp /artifacts/test_ez_vcd.fst)

shell: $(IMAGE_STAMP) $(PREPARE_STAMP)
	@mkdir -p "$(DOWNLOADS_DIR)" "$(WORK_DIR)" "$(ARTIFACTS_DIR)" "$(BUILD_DIR)"
	docker run --rm -it \
	  --user "$$(id -u):$$(id -g)" \
	  -e HOME=/work/.home \
	  -e XDG_CACHE_HOME=/work/.cache \
	  -e CCACHE_DIR=/work/.ccache \
	  -e PIP_CACHE_DIR=/work/.cache/pip \
	  -v "$(abspath .):/project:ro" \
	  -v "$(abspath $(DOWNLOADS_DIR)):/downloads" \
	  -v "$(abspath $(WORK_DIR)):/work" \
	  -v "$(abspath $(ARTIFACTS_DIR)):/artifacts" \
	  -w /work/src \
	  "$(IMAGE)" \
	  bash -lc 'mkdir -p "$$HOME" "$$XDG_CACHE_HOME" "$$CCACHE_DIR" "$$PIP_CACHE_DIR" && exec bash'

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
  -e XDG_CACHE_HOME=/work/.cache \
  -e CCACHE_DIR=/work/.ccache \
  -e PIP_CACHE_DIR=/work/.cache/pip \
  -v "$(abspath .):/project:ro" \
  -v "$(abspath $(DOWNLOADS_DIR)):/downloads" \
  -v "$(abspath $(WORK_DIR)):/work" \
  -v "$(abspath $(ARTIFACTS_DIR)):/artifacts" \
  -w /work/src \
  "$(IMAGE)" \
  bash -lc 'mkdir -p "$$HOME" "$$XDG_CACHE_HOME" "$$CCACHE_DIR" "$$PIP_CACHE_DIR" && $(1)'
endef
