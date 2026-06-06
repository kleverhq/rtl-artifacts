SHELL := /bin/bash
.DEFAULT_GOAL := help

PROJECT_NAME := tb_complex_types
IMAGE ?= rtl-artifacts-$(PROJECT_NAME):local
DOWNLOADS_DIR ?= downloads
WORK_DIR ?= work
BUILD_DIR ?= .build
ARTIFACTS_DIR ?= $(abspath ../../artifacts/$(PROJECT_NAME))

include versions.mk

TB := tb.sv
TOP := tb_complex_types
PROJECT_SOURCES := Makefile Dockerfile versions.mk $(TB)

IMAGE_STAMP := $(BUILD_DIR)/image.stamp
DOWNLOAD_STAMP := $(BUILD_DIR)/download.stamp
PREPARE_STAMP := $(BUILD_DIR)/prepare.stamp

ARTIFACTS := \
	$(ARTIFACTS_DIR)/verilator/vcd/waves.vcd \
	$(ARTIFACTS_DIR)/verilator/fst/waves.fst \
	$(ARTIFACTS_DIR)/icarus/vcd/waves.vcd \
	$(ARTIFACTS_DIR)/icarus/fst/waves.fst

.PHONY: help image download prepare collect list shell clean distclean \
        verilator verilator-vcd verilator-fst icarus icarus-vcd icarus-fst FORCE

help:
	@printf '%s\n' 'Targets:'
	@printf '  %-18s %s\n' 'image' 'Build the project Docker image.'
	@printf '  %-18s %s\n' 'download' 'Create the project download cache (no external source for this project).'
	@printf '  %-18s %s\n' 'prepare' 'Create the project work directory.'
	@printf '  %-18s %s\n' 'collect' 'Build default Verilator and Icarus VCD/FST artifacts.'
	@printf '  %-18s %s\n' 'list' 'Print default artifact targets.'
	@printf '  %-18s %s\n' 'shell' 'Open a debug shell in the project image.'
	@printf '  %-18s %s\n' 'clean' 'Remove work, build stamps, and selected artifacts.'
	@printf '  %-18s %s\n' 'distclean' 'Run clean and remove downloads too.'

image: $(IMAGE_STAMP)
$(IMAGE_STAMP): Dockerfile .dockerignore versions.mk Makefile FORCE | $(BUILD_DIR)
	@set -euo pipefail; \
	if [ -f "$@" ] && [ "$@" -nt Dockerfile ] && [ "$@" -nt .dockerignore ] && [ "$@" -nt versions.mk ] && [ "$@" -nt Makefile ] && grep -Fx 'IMAGE=$(IMAGE)' "$@" >/dev/null 2>&1 && docker image inspect "$(IMAGE)" >/dev/null 2>&1; then \
		exit 0; \
	fi; \
	docker build --network host -t "$(IMAGE)" .; \
	mkdir -p "$(@D)"; \
	printf 'IMAGE=%s\n' "$(IMAGE)" > "$@"

FORCE:

download: $(DOWNLOAD_STAMP)
$(DOWNLOAD_STAMP): Makefile versions.mk | $(BUILD_DIR)
	mkdir -p "$(DOWNLOADS_DIR)"
	touch "$@"

prepare: $(PREPARE_STAMP)
$(PREPARE_STAMP): $(DOWNLOAD_STAMP) Makefile versions.mk $(TB) | $(BUILD_DIR)
	mkdir -p "$(WORK_DIR)"
	touch "$@"

collect: $(ARTIFACTS)

list:
	@printf '%s\n' $(ARTIFACTS)

$(BUILD_DIR):
	mkdir -p "$@"

$(ARTIFACTS_DIR)/verilator/vcd/waves.vcd: $(PREPARE_STAMP) $(IMAGE_STAMP) $(PROJECT_SOURCES)
	@echo 'Collecting tb_complex_types Verilator VCD'
	@$(call RUN_IN_CONTAINER,rm -rf /work/run-verilator-vcd && mkdir -p /work/run-verilator-vcd /artifacts/verilator/vcd && cd /work/run-verilator-vcd && verilator -Wall -Wno-fatal -sv --binary --trace-structs --trace +define+WAVES_VCD /project/$(TB) --top-module $(TOP) && ./obj_dir/V$(TOP) && test -s waves.vcd && cp waves.vcd /artifacts/verilator/vcd/waves.vcd.tmp && mv /artifacts/verilator/vcd/waves.vcd.tmp /artifacts/verilator/vcd/waves.vcd)

$(ARTIFACTS_DIR)/verilator/fst/waves.fst: $(PREPARE_STAMP) $(IMAGE_STAMP) $(PROJECT_SOURCES)
	@echo 'Collecting tb_complex_types Verilator FST'
	@$(call RUN_IN_CONTAINER,rm -rf /work/run-verilator-fst && mkdir -p /work/run-verilator-fst /artifacts/verilator/fst && cd /work/run-verilator-fst && verilator -Wall -Wno-fatal -sv --binary --trace-structs --trace-fst +define+WAVES_FST /project/$(TB) --top-module $(TOP) && ./obj_dir/V$(TOP) && test -s waves.fst && cp waves.fst /artifacts/verilator/fst/waves.fst.tmp && mv /artifacts/verilator/fst/waves.fst.tmp /artifacts/verilator/fst/waves.fst)

$(ARTIFACTS_DIR)/icarus/vcd/waves.vcd: $(PREPARE_STAMP) $(IMAGE_STAMP) $(PROJECT_SOURCES)
	@echo 'Collecting tb_complex_types Icarus VCD'
	@$(call RUN_IN_CONTAINER,rm -rf /work/run-icarus-vcd && mkdir -p /work/run-icarus-vcd /artifacts/icarus/vcd && cd /work/run-icarus-vcd && iverilog -g2012 -DICARUS -DWAVES_VCD -o simv /project/$(TB) && vvp simv && test -s waves.vcd && cp waves.vcd /artifacts/icarus/vcd/waves.vcd.tmp && mv /artifacts/icarus/vcd/waves.vcd.tmp /artifacts/icarus/vcd/waves.vcd)

$(ARTIFACTS_DIR)/icarus/fst/waves.fst: $(PREPARE_STAMP) $(IMAGE_STAMP) $(PROJECT_SOURCES)
	@echo 'Collecting tb_complex_types Icarus FST'
	@$(call RUN_IN_CONTAINER,rm -rf /work/run-icarus-fst && mkdir -p /work/run-icarus-fst /artifacts/icarus/fst && cd /work/run-icarus-fst && iverilog -g2012 -DICARUS -DWAVES_FST -o simv /project/$(TB) && vvp simv -fst && test -s waves.fst && cp waves.fst /artifacts/icarus/fst/waves.fst.tmp && mv /artifacts/icarus/fst/waves.fst.tmp /artifacts/icarus/fst/waves.fst)

shell: $(IMAGE_STAMP)
	@mkdir -p "$(DOWNLOADS_DIR)" "$(WORK_DIR)" "$(ARTIFACTS_DIR)" "$(BUILD_DIR)"
	docker run --rm -it \
	  --user "$$(id -u):$$(id -g)" \
	  -e HOME=/work/.home \
	  -e XDG_CACHE_HOME=/work/.cache \
	  -e CCACHE_DIR=/work/.ccache \
	  -e CONDA_PKGS_DIRS=/work/.conda/pkgs \
	  -e PIP_CACHE_DIR=/work/.cache/pip \
	  -v "$(abspath .):/project:ro" \
	  -v "$(abspath $(DOWNLOADS_DIR)):/downloads" \
	  -v "$(abspath $(WORK_DIR)):/work" \
	  -v "$(abspath $(ARTIFACTS_DIR)):/artifacts" \
	  -w /work \
	  "$(IMAGE)" \
	  bash -lc 'mkdir -p "$$HOME" "$$XDG_CACHE_HOME" "$$CCACHE_DIR" "$$CONDA_PKGS_DIRS" "$$PIP_CACHE_DIR" && exec bash'

clean:
	rm -rf "$(WORK_DIR)" "$(BUILD_DIR)" "$(ARTIFACTS_DIR)"

distclean: clean
	rm -rf "$(DOWNLOADS_DIR)"

verilator: verilator-vcd verilator-fst
verilator-vcd: $(ARTIFACTS_DIR)/verilator/vcd/waves.vcd
verilator-fst: $(ARTIFACTS_DIR)/verilator/fst/waves.fst
icarus: icarus-vcd icarus-fst
icarus-vcd: $(ARTIFACTS_DIR)/icarus/vcd/waves.vcd
icarus-fst: $(ARTIFACTS_DIR)/icarus/fst/waves.fst

define RUN_IN_CONTAINER
mkdir -p "$(DOWNLOADS_DIR)" "$(WORK_DIR)" "$(ARTIFACTS_DIR)" "$(BUILD_DIR)" && \
test -w "$(DOWNLOADS_DIR)" && test -w "$(WORK_DIR)" && test -w "$(ARTIFACTS_DIR)" && \
docker run --rm \
  --user "$$(id -u):$$(id -g)" \
  -e HOME=/work/.home \
  -e XDG_CACHE_HOME=/work/.cache \
  -e CCACHE_DIR=/work/.ccache \
  -e CONDA_PKGS_DIRS=/work/.conda/pkgs \
  -e PIP_CACHE_DIR=/work/.cache/pip \
  -v "$(abspath .):/project:ro" \
  -v "$(abspath $(DOWNLOADS_DIR)):/downloads" \
  -v "$(abspath $(WORK_DIR)):/work" \
  -v "$(abspath $(ARTIFACTS_DIR)):/artifacts" \
  -w /work \
  "$(IMAGE)" \
  bash -lc 'mkdir -p "$$HOME" "$$XDG_CACHE_HOME" "$$CCACHE_DIR" "$$CONDA_PKGS_DIRS" "$$PIP_CACHE_DIR" && $(1)'
endef
