SHELL := /bin/bash
.DEFAULT_GOAL := help
.NOTPARALLEL:

PROJECT_NAME := scr1
IMAGE ?= rtl-artifacts-$(PROJECT_NAME):local
DOWNLOADS_DIR ?= downloads
WORK_DIR ?= work
BUILD_DIR ?= .build
ARTIFACTS_DIR ?= $(abspath ../../artifacts/$(PROJECT_NAME))
SCR1_COLLECT_TRACE ?= 0
SCR1_BENCH_ADD_LDFLAGS ?= -Wl,--start-group -lc -lgcc -lnosys -Wl,--end-group -Wl,--defsym=end=_end

include versions.mk

IMAGE_STAMP := $(BUILD_DIR)/image.stamp
DOWNLOAD_STAMP := $(BUILD_DIR)/download.stamp
PREPARE_STAMP := $(BUILD_DIR)/prepare.stamp
SRC_DIR := $(WORK_DIR)/src
DOWNLOAD_SRC_DIR := $(DOWNLOADS_DIR)/src

ARTIFACTS := \
	$(ARTIFACTS_DIR)/max/axi/isr_sample.fst \
	$(ARTIFACTS_DIR)/max/axi/riscv_arch.fst \
	$(ARTIFACTS_DIR)/max/axi/riscv_compliance.fst \
	$(ARTIFACTS_DIR)/max/axi/riscv_isa.fst \
	$(ARTIFACTS_DIR)/max/axi/hello.fst \
	$(ARTIFACTS_DIR)/max/axi/coremark.fst \
	$(ARTIFACTS_DIR)/max/axi/dhrystone21.fst \
	$(ARTIFACTS_DIR)/max/ahb/isr_sample.fst \
	$(ARTIFACTS_DIR)/max/ahb/riscv_arch.fst \
	$(ARTIFACTS_DIR)/max/ahb/riscv_compliance.fst \
	$(ARTIFACTS_DIR)/max/ahb/riscv_isa.fst \
	$(ARTIFACTS_DIR)/max/ahb/hello.fst \
	$(ARTIFACTS_DIR)/max/ahb/coremark.fst \
	$(ARTIFACTS_DIR)/max/ahb/dhrystone21.fst

.PHONY: help image download prepare collect list shell clean distclean

help:
	@printf '%s\n' 'Targets:'
	@printf '  %-18s %s\n' 'image' 'Build the SCR1 Docker image.'
	@printf '  %-18s %s\n' 'download' 'Populate downloads/src with SCR1 and submodules at SCR1_COMMIT.'
	@printf '  %-18s %s\n' 'prepare' 'Copy downloads/src into work/src and verify the checkout.'
	@printf '  %-18s %s\n' 'collect' 'Collect default SCR1 MAX AXI/AHB waveform artifacts.'
	@printf '  %-18s %s\n' 'list' 'Print default artifact targets.'
	@printf '  %-18s %s\n' 'shell' 'Open a debug shell in the SCR1 image.'
	@printf '  %-18s %s\n' 'clean' 'Remove work, build stamps, and selected artifacts.'
	@printf '  %-18s %s\n' 'distclean' 'Run clean and remove downloads too.'

image: $(IMAGE_STAMP)
$(IMAGE_STAMP): Dockerfile versions.mk | $(BUILD_DIR)
	docker build --network host \
	  --build-arg TOOL_IMAGE_BASE="$(TOOL_IMAGE_BASE)" \
	  --build-arg VERILATOR_VERSION="$(VERILATOR_VERSION)" \
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
		git clone --recurse-submodules "$(SCR1_URL)" "$(DOWNLOAD_SRC_DIR)"; \
	else \
		git -C "$(DOWNLOAD_SRC_DIR)" fetch --tags origin; \
	fi; \
	git -C "$(DOWNLOAD_SRC_DIR)" checkout --force "$(SCR1_COMMIT)"; \
	git -C "$(DOWNLOAD_SRC_DIR)" reset --hard "$(SCR1_COMMIT)"; \
	git -C "$(DOWNLOAD_SRC_DIR)" clean -ffdx; \
	git -C "$(DOWNLOAD_SRC_DIR)" submodule sync --recursive; \
	git -C "$(DOWNLOAD_SRC_DIR)" -c protocol.file.allow=always submodule update --init --recursive; \
	test "$$(git -C "$(DOWNLOAD_SRC_DIR)" rev-parse HEAD)" = "$(SCR1_COMMIT)"; \
	touch "$@"

prepare: $(PREPARE_STAMP)
$(PREPARE_STAMP): $(DOWNLOAD_STAMP) Makefile versions.mk | $(BUILD_DIR)
	@set -euo pipefail; \
	rm -rf "$(SRC_DIR)"; \
	mkdir -p "$(WORK_DIR)"; \
	cp -a "$(DOWNLOAD_SRC_DIR)" "$(SRC_DIR)"; \
	git -C "$(SRC_DIR)" submodule update --init --recursive; \
	test "$$(git -C "$(SRC_DIR)" rev-parse HEAD)" = "$(SCR1_COMMIT)"; \
	touch "$@"

collect: $(ARTIFACTS)

list:
	@printf '%s\n' $(ARTIFACTS)

$(BUILD_DIR):
	mkdir -p "$@"

$(ARTIFACTS_DIR)/max/axi/isr_sample.fst: $(PREPARE_STAMP) $(IMAGE_STAMP) Makefile versions.mk
	@echo 'Collecting SCR1 MAX/AXI/isr_sample'
	@$(call RUN_IN_CONTAINER,mkdir -p /artifacts/max/axi && cd /work/src && rm -f /work/src/build/verilator_wf_AXI_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd && make run_verilator_wf CFG=MAX BUS=AXI TARGETS="isr_sample" TRACE=$(SCR1_COLLECT_TRACE) ADD_LDFLAGS="" && test -s /work/src/build/verilator_wf_AXI_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd && vcd2fst /work/src/build/verilator_wf_AXI_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd /artifacts/max/axi/isr_sample.fst.tmp && mv /artifacts/max/axi/isr_sample.fst.tmp /artifacts/max/axi/isr_sample.fst)

$(ARTIFACTS_DIR)/max/axi/riscv_arch.fst: $(PREPARE_STAMP) $(IMAGE_STAMP) Makefile versions.mk
	@echo 'Collecting SCR1 MAX/AXI/riscv_arch'
	@$(call RUN_IN_CONTAINER,mkdir -p /artifacts/max/axi && cd /work/src && rm -f /work/src/build/verilator_wf_AXI_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd && make run_verilator_wf CFG=MAX BUS=AXI TARGETS="riscv_arch" TRACE=$(SCR1_COLLECT_TRACE) ADD_LDFLAGS="" && test -s /work/src/build/verilator_wf_AXI_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd && vcd2fst /work/src/build/verilator_wf_AXI_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd /artifacts/max/axi/riscv_arch.fst.tmp && mv /artifacts/max/axi/riscv_arch.fst.tmp /artifacts/max/axi/riscv_arch.fst)

$(ARTIFACTS_DIR)/max/axi/riscv_compliance.fst: $(PREPARE_STAMP) $(IMAGE_STAMP) Makefile versions.mk
	@echo 'Collecting SCR1 MAX/AXI/riscv_compliance'
	@$(call RUN_IN_CONTAINER,mkdir -p /artifacts/max/axi && cd /work/src && rm -f /work/src/build/verilator_wf_AXI_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd && make run_verilator_wf CFG=MAX BUS=AXI TARGETS="riscv_compliance" TRACE=$(SCR1_COLLECT_TRACE) ADD_LDFLAGS="" && test -s /work/src/build/verilator_wf_AXI_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd && vcd2fst /work/src/build/verilator_wf_AXI_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd /artifacts/max/axi/riscv_compliance.fst.tmp && mv /artifacts/max/axi/riscv_compliance.fst.tmp /artifacts/max/axi/riscv_compliance.fst)

$(ARTIFACTS_DIR)/max/axi/riscv_isa.fst: $(PREPARE_STAMP) $(IMAGE_STAMP) Makefile versions.mk
	@echo 'Collecting SCR1 MAX/AXI/riscv_isa'
	@$(call RUN_IN_CONTAINER,mkdir -p /artifacts/max/axi && cd /work/src && rm -f /work/src/build/verilator_wf_AXI_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd && make run_verilator_wf CFG=MAX BUS=AXI TARGETS="riscv_isa" TRACE=$(SCR1_COLLECT_TRACE) ADD_LDFLAGS="" && test -s /work/src/build/verilator_wf_AXI_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd && vcd2fst /work/src/build/verilator_wf_AXI_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd /artifacts/max/axi/riscv_isa.fst.tmp && mv /artifacts/max/axi/riscv_isa.fst.tmp /artifacts/max/axi/riscv_isa.fst)

$(ARTIFACTS_DIR)/max/axi/hello.fst: $(PREPARE_STAMP) $(IMAGE_STAMP) Makefile versions.mk
	@echo 'Collecting SCR1 MAX/AXI/hello'
	@$(call RUN_IN_CONTAINER,mkdir -p /artifacts/max/axi && cd /work/src && rm -f /work/src/build/verilator_wf_AXI_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd && make run_verilator_wf CFG=MAX BUS=AXI TARGETS="hello" TRACE=$(SCR1_COLLECT_TRACE) ADD_LDFLAGS="" && test -s /work/src/build/verilator_wf_AXI_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd && vcd2fst /work/src/build/verilator_wf_AXI_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd /artifacts/max/axi/hello.fst.tmp && mv /artifacts/max/axi/hello.fst.tmp /artifacts/max/axi/hello.fst)

$(ARTIFACTS_DIR)/max/axi/coremark.fst: $(PREPARE_STAMP) $(IMAGE_STAMP) Makefile versions.mk
	@echo 'Collecting SCR1 MAX/AXI/coremark'
	@$(call RUN_IN_CONTAINER,mkdir -p /artifacts/max/axi && cd /work/src && rm -f /work/src/build/verilator_wf_AXI_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd && make run_verilator_wf CFG=MAX BUS=AXI TARGETS="coremark" TRACE=$(SCR1_COLLECT_TRACE) ADD_LDFLAGS="$(SCR1_BENCH_ADD_LDFLAGS)" && test -s /work/src/build/verilator_wf_AXI_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd && vcd2fst /work/src/build/verilator_wf_AXI_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd /artifacts/max/axi/coremark.fst.tmp && mv /artifacts/max/axi/coremark.fst.tmp /artifacts/max/axi/coremark.fst)

$(ARTIFACTS_DIR)/max/axi/dhrystone21.fst: $(PREPARE_STAMP) $(IMAGE_STAMP) Makefile versions.mk
	@echo 'Collecting SCR1 MAX/AXI/dhrystone21'
	@$(call RUN_IN_CONTAINER,mkdir -p /artifacts/max/axi && cd /work/src && rm -f /work/src/build/verilator_wf_AXI_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd && make run_verilator_wf CFG=MAX BUS=AXI TARGETS="dhrystone21" TRACE=$(SCR1_COLLECT_TRACE) ADD_LDFLAGS="$(SCR1_BENCH_ADD_LDFLAGS)" && test -s /work/src/build/verilator_wf_AXI_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd && vcd2fst /work/src/build/verilator_wf_AXI_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd /artifacts/max/axi/dhrystone21.fst.tmp && mv /artifacts/max/axi/dhrystone21.fst.tmp /artifacts/max/axi/dhrystone21.fst)

$(ARTIFACTS_DIR)/max/ahb/isr_sample.fst: $(PREPARE_STAMP) $(IMAGE_STAMP) Makefile versions.mk
	@echo 'Collecting SCR1 MAX/AHB/isr_sample'
	@$(call RUN_IN_CONTAINER,mkdir -p /artifacts/max/ahb && cd /work/src && rm -f /work/src/build/verilator_wf_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd && make run_verilator_wf CFG=MAX BUS=AHB TARGETS="isr_sample" TRACE=$(SCR1_COLLECT_TRACE) ADD_LDFLAGS="" && test -s /work/src/build/verilator_wf_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd && vcd2fst /work/src/build/verilator_wf_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd /artifacts/max/ahb/isr_sample.fst.tmp && mv /artifacts/max/ahb/isr_sample.fst.tmp /artifacts/max/ahb/isr_sample.fst)

$(ARTIFACTS_DIR)/max/ahb/riscv_arch.fst: $(PREPARE_STAMP) $(IMAGE_STAMP) Makefile versions.mk
	@echo 'Collecting SCR1 MAX/AHB/riscv_arch'
	@$(call RUN_IN_CONTAINER,mkdir -p /artifacts/max/ahb && cd /work/src && rm -f /work/src/build/verilator_wf_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd && make run_verilator_wf CFG=MAX BUS=AHB TARGETS="riscv_arch" TRACE=$(SCR1_COLLECT_TRACE) ADD_LDFLAGS="" && test -s /work/src/build/verilator_wf_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd && vcd2fst /work/src/build/verilator_wf_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd /artifacts/max/ahb/riscv_arch.fst.tmp && mv /artifacts/max/ahb/riscv_arch.fst.tmp /artifacts/max/ahb/riscv_arch.fst)

$(ARTIFACTS_DIR)/max/ahb/riscv_compliance.fst: $(PREPARE_STAMP) $(IMAGE_STAMP) Makefile versions.mk
	@echo 'Collecting SCR1 MAX/AHB/riscv_compliance'
	@$(call RUN_IN_CONTAINER,mkdir -p /artifacts/max/ahb && cd /work/src && rm -f /work/src/build/verilator_wf_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd && make run_verilator_wf CFG=MAX BUS=AHB TARGETS="riscv_compliance" TRACE=$(SCR1_COLLECT_TRACE) ADD_LDFLAGS="" && test -s /work/src/build/verilator_wf_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd && vcd2fst /work/src/build/verilator_wf_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd /artifacts/max/ahb/riscv_compliance.fst.tmp && mv /artifacts/max/ahb/riscv_compliance.fst.tmp /artifacts/max/ahb/riscv_compliance.fst)

$(ARTIFACTS_DIR)/max/ahb/riscv_isa.fst: $(PREPARE_STAMP) $(IMAGE_STAMP) Makefile versions.mk
	@echo 'Collecting SCR1 MAX/AHB/riscv_isa'
	@$(call RUN_IN_CONTAINER,mkdir -p /artifacts/max/ahb && cd /work/src && rm -f /work/src/build/verilator_wf_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd && make run_verilator_wf CFG=MAX BUS=AHB TARGETS="riscv_isa" TRACE=$(SCR1_COLLECT_TRACE) ADD_LDFLAGS="" && test -s /work/src/build/verilator_wf_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd && vcd2fst /work/src/build/verilator_wf_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd /artifacts/max/ahb/riscv_isa.fst.tmp && mv /artifacts/max/ahb/riscv_isa.fst.tmp /artifacts/max/ahb/riscv_isa.fst)

$(ARTIFACTS_DIR)/max/ahb/hello.fst: $(PREPARE_STAMP) $(IMAGE_STAMP) Makefile versions.mk
	@echo 'Collecting SCR1 MAX/AHB/hello'
	@$(call RUN_IN_CONTAINER,mkdir -p /artifacts/max/ahb && cd /work/src && rm -f /work/src/build/verilator_wf_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd && make run_verilator_wf CFG=MAX BUS=AHB TARGETS="hello" TRACE=$(SCR1_COLLECT_TRACE) ADD_LDFLAGS="" && test -s /work/src/build/verilator_wf_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd && vcd2fst /work/src/build/verilator_wf_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd /artifacts/max/ahb/hello.fst.tmp && mv /artifacts/max/ahb/hello.fst.tmp /artifacts/max/ahb/hello.fst)

$(ARTIFACTS_DIR)/max/ahb/coremark.fst: $(PREPARE_STAMP) $(IMAGE_STAMP) Makefile versions.mk
	@echo 'Collecting SCR1 MAX/AHB/coremark'
	@$(call RUN_IN_CONTAINER,mkdir -p /artifacts/max/ahb && cd /work/src && rm -f /work/src/build/verilator_wf_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd && make run_verilator_wf CFG=MAX BUS=AHB TARGETS="coremark" TRACE=$(SCR1_COLLECT_TRACE) ADD_LDFLAGS="$(SCR1_BENCH_ADD_LDFLAGS)" && test -s /work/src/build/verilator_wf_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd && vcd2fst /work/src/build/verilator_wf_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd /artifacts/max/ahb/coremark.fst.tmp && mv /artifacts/max/ahb/coremark.fst.tmp /artifacts/max/ahb/coremark.fst)

$(ARTIFACTS_DIR)/max/ahb/dhrystone21.fst: $(PREPARE_STAMP) $(IMAGE_STAMP) Makefile versions.mk
	@echo 'Collecting SCR1 MAX/AHB/dhrystone21'
	@$(call RUN_IN_CONTAINER,mkdir -p /artifacts/max/ahb && cd /work/src && rm -f /work/src/build/verilator_wf_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd && make run_verilator_wf CFG=MAX BUS=AHB TARGETS="dhrystone21" TRACE=$(SCR1_COLLECT_TRACE) ADD_LDFLAGS="$(SCR1_BENCH_ADD_LDFLAGS)" && test -s /work/src/build/verilator_wf_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd && vcd2fst /work/src/build/verilator_wf_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd /artifacts/max/ahb/dhrystone21.fst.tmp && mv /artifacts/max/ahb/dhrystone21.fst.tmp /artifacts/max/ahb/dhrystone21.fst)

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
