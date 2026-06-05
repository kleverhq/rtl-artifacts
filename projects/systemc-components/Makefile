SHELL := /bin/bash
.DEFAULT_GOAL := help
.NOTPARALLEL:

PROJECT_NAME := systemc-components
IMAGE ?= rtl-artifacts-$(PROJECT_NAME):local
DOWNLOADS_DIR ?= downloads
WORK_DIR ?= work
BUILD_DIR ?= .build
ARTIFACTS_DIR ?= $(abspath ../../artifacts/$(PROJECT_NAME))
JOBS ?= $(shell getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)

include versions.mk

IMAGE_STAMP := $(BUILD_DIR)/image.stamp
DOWNLOAD_STAMP := $(BUILD_DIR)/download.stamp
PREPARE_STAMP := $(BUILD_DIR)/prepare.stamp
SRC_DIR := $(WORK_DIR)/src
DOWNLOAD_SRC_DIR := $(DOWNLOADS_DIR)/src
PATCH_FILE := patches/scc-include-cxs-channel.patch
ARTIFACT_RELATIVE := $(shell sed '/^[[:space:]]*$$/d' artifacts.list)
ARTIFACTS := $(addprefix $(ARTIFACTS_DIR)/,$(ARTIFACT_RELATIVE))
PROJECT_SOURCES := Makefile Dockerfile .dockerignore versions.mk artifacts.list scripts/run_examples.sh $(PATCH_FILE)

.PHONY: help image download prepare collect list shell clean distclean FORCE

help:
	@printf '%s\n' 'Targets:'
	@printf '  %-18s %s\n' 'image' 'Build the SystemC-Components Docker image.'
	@printf '  %-18s %s\n' 'download' 'Populate downloads/src with SCC at SYSTEMC_COMPONENTS_COMMIT.'
	@printf '  %-18s %s\n' 'prepare' 'Copy, patch, configure, and build SCC examples under work/src.'
	@printf '  %-18s %s\n' 'collect' 'Run SCC examples and collect VCD/FST/FTR artifacts.'
	@printf '  %-18s %s\n' 'list' 'Print default artifact targets.'
	@printf '  %-18s %s\n' 'shell' 'Open a debug shell in the SystemC-Components image.'
	@printf '  %-18s %s\n' 'clean' 'Remove work, build stamps, and selected artifacts.'
	@printf '  %-18s %s\n' 'distclean' 'Run clean and remove downloads too.'

image: $(IMAGE_STAMP)
$(IMAGE_STAMP): Dockerfile .dockerignore versions.mk Makefile FORCE | $(BUILD_DIR)
	@set -euo pipefail; \
	if [ -f "$@" ] && [ "$@" -nt Dockerfile ] && [ "$@" -nt .dockerignore ] && [ "$@" -nt versions.mk ] && [ "$@" -nt Makefile ] && grep -Fx 'IMAGE=$(IMAGE)' "$@" >/dev/null 2>&1 && docker image inspect "$(IMAGE)" >/dev/null 2>&1; then \
		exit 0; \
	fi; \
	docker build --network host \
	  --build-arg TOOL_IMAGE_BASE="$(TOOL_IMAGE_BASE)" \
	  --build-arg CONAN_VERSION="$(CONAN_VERSION)" \
	  -t "$(IMAGE)" .; \
	mkdir -p "$(@D)"; \
	printf 'IMAGE=%s\n' "$(IMAGE)" > "$@"

FORCE:

download: $(DOWNLOAD_STAMP)
$(DOWNLOAD_STAMP): Makefile versions.mk | $(BUILD_DIR)
	@set -euo pipefail; \
	mkdir -p "$(DOWNLOADS_DIR)"; \
	if [ ! -d "$(DOWNLOAD_SRC_DIR)/.git" ]; then \
		rm -rf "$(DOWNLOAD_SRC_DIR)"; \
		git clone "$(SYSTEMC_COMPONENTS_URL)" "$(DOWNLOAD_SRC_DIR)"; \
	else \
		git -C "$(DOWNLOAD_SRC_DIR)" remote set-url origin "$(SYSTEMC_COMPONENTS_URL)"; \
		git -C "$(DOWNLOAD_SRC_DIR)" fetch --tags origin; \
	fi; \
	git -C "$(DOWNLOAD_SRC_DIR)" checkout --force "$(SYSTEMC_COMPONENTS_COMMIT)"; \
	git -C "$(DOWNLOAD_SRC_DIR)" reset --hard "$(SYSTEMC_COMPONENTS_COMMIT)"; \
	git -C "$(DOWNLOAD_SRC_DIR)" clean -ffdx; \
	git -C "$(DOWNLOAD_SRC_DIR)" submodule sync --recursive; \
	git -C "$(DOWNLOAD_SRC_DIR)" submodule update --init --recursive; \
	git -C "$(DOWNLOAD_SRC_DIR)" submodule foreach --recursive 'git reset --hard && git clean -ffdx'; \
	test "$$(git -C "$(DOWNLOAD_SRC_DIR)" rev-parse HEAD)" = "$(SYSTEMC_COMPONENTS_COMMIT)"; \
	test "$$(git -C "$(DOWNLOAD_SRC_DIR)/third_party/axi_chi" rev-parse HEAD)" = "$(SYSTEMC_COMPONENTS_AXI_CHI_COMMIT)"; \
	test "$$(git -C "$(DOWNLOAD_SRC_DIR)/third_party/lwtr4sc" rev-parse HEAD)" = "$(SYSTEMC_COMPONENTS_LWTR4SC_COMMIT)"; \
	touch "$@"

prepare: $(PREPARE_STAMP)
$(PREPARE_STAMP): $(DOWNLOAD_STAMP) $(IMAGE_STAMP) Makefile versions.mk $(PATCH_FILE) | $(BUILD_DIR)
	@set -euo pipefail; \
	rm -rf "$(SRC_DIR)"; \
	mkdir -p "$(WORK_DIR)"; \
	cp -a "$(DOWNLOAD_SRC_DIR)" "$(SRC_DIR)"; \
	git -C "$(SRC_DIR)" reset --hard "$(SYSTEMC_COMPONENTS_COMMIT)"; \
	git -C "$(SRC_DIR)" clean -ffdx; \
	git -C "$(SRC_DIR)" submodule update --init --recursive; \
	git -C "$(SRC_DIR)" submodule foreach --recursive 'git reset --hard && git clean -ffdx'; \
	test "$$(git -C "$(SRC_DIR)" rev-parse HEAD)" = "$(SYSTEMC_COMPONENTS_COMMIT)"; \
	test "$$(git -C "$(SRC_DIR)/third_party/axi_chi" rev-parse HEAD)" = "$(SYSTEMC_COMPONENTS_AXI_CHI_COMMIT)"; \
	test "$$(git -C "$(SRC_DIR)/third_party/lwtr4sc" rev-parse HEAD)" = "$(SYSTEMC_COMPONENTS_LWTR4SC_COMMIT)"; \
	git -C "$(SRC_DIR)" apply --check "$(abspath $(PATCH_FILE))"; \
	git -C "$(SRC_DIR)" apply "$(abspath $(PATCH_FILE))"
	@$(call RUN_IN_CONTAINER,if ! conan profile path default >/dev/null 2>&1; then conan profile detect --force; fi && cd /work/src && cmake --preset "$(SCC_BUILD_PRESET)" -S /work/src -DBUILD_SCC_DOCUMENTATION=OFF -DWITH_SCP4SCC=ON && cmake --build "/work/src/build/$(SCC_BUILD_PRESET)" --parallel "$(JOBS)")
	@touch "$@"

collect: $(ARTIFACTS)

list:
	@printf '%s\n' $(ARTIFACTS)

$(BUILD_DIR):
	mkdir -p "$@"

$(ARTIFACTS) &: $(PREPARE_STAMP) $(IMAGE_STAMP) $(PROJECT_SOURCES)
	@echo 'Collecting SystemC-Components example artifacts'
	@$(call RUN_IN_CONTAINER,SCC_ARTIFACTS_LIST=/project/artifacts.list SCC_BUILD_PRESET="$(SCC_BUILD_PRESET)" SCC_EXAMPLE_TIMEOUT_SECONDS="$(SCC_EXAMPLE_TIMEOUT_SECONDS)" /project/scripts/run_examples.sh)

shell: $(IMAGE_STAMP) $(PREPARE_STAMP)
	@mkdir -p "$(DOWNLOADS_DIR)" "$(WORK_DIR)" "$(ARTIFACTS_DIR)" "$(BUILD_DIR)"
	docker run --rm -it \
	  --user "$$(id -u):$$(id -g)" \
	  -e HOME=/work/.home \
	  -e XDG_CACHE_HOME=/work/.cache \
	  -e CCACHE_DIR=/work/.ccache \
	  -e PIP_CACHE_DIR=/work/.cache/pip \
	  -e CONAN_HOME=/work/.conan2 \
	  -e SCC_BUILD_PRESET="$(SCC_BUILD_PRESET)" \
	  -e SCC_EXAMPLE_TIMEOUT_SECONDS="$(SCC_EXAMPLE_TIMEOUT_SECONDS)" \
	  -v "$(abspath .):/project:ro" \
	  -v "$(abspath $(DOWNLOADS_DIR)):/downloads" \
	  -v "$(abspath $(WORK_DIR)):/work" \
	  -v "$(abspath $(ARTIFACTS_DIR)):/artifacts" \
	  -w /work/src \
	  "$(IMAGE)" \
	  bash -lc 'mkdir -p "$$HOME" "$$XDG_CACHE_HOME" "$$CCACHE_DIR" "$$PIP_CACHE_DIR" "$$CONAN_HOME" && exec bash'

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
  -e CONAN_HOME=/work/.conan2 \
  -e SCC_BUILD_PRESET="$(SCC_BUILD_PRESET)" \
  -e SCC_EXAMPLE_TIMEOUT_SECONDS="$(SCC_EXAMPLE_TIMEOUT_SECONDS)" \
  -v "$(abspath .):/project:ro" \
  -v "$(abspath $(DOWNLOADS_DIR)):/downloads" \
  -v "$(abspath $(WORK_DIR)):/work" \
  -v "$(abspath $(ARTIFACTS_DIR)):/artifacts" \
  -w /work/src \
  "$(IMAGE)" \
  bash -lc 'mkdir -p "$$HOME" "$$XDG_CACHE_HOME" "$$CCACHE_DIR" "$$PIP_CACHE_DIR" "$$CONAN_HOME" && $(1)'
endef
