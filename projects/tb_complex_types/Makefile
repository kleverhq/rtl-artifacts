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
        verilator verilator-vcd verilator-fst icarus icarus-vcd icarus-fst \
        questa questa-wlf questa-vcd questa-fsdb \
        vcs vcs-vpd vcs-vcd vcs-fsdb \
        xcelium xcelium-shm xcelium-vcd xcelium-fsdb

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
	@printf '\nOptional host/vendor targets still exist: questa, vcs, xcelium and format-specific variants.\n'

image: $(IMAGE_STAMP)
$(IMAGE_STAMP): Dockerfile versions.mk | $(BUILD_DIR)
	docker build --network host -t "$(IMAGE)" .
	mkdir -p "$(@D)"
	touch "$@"

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

# Optional host/vendor-tool paths. These run outside Docker and remain outside default collect.
WORK_DIR ?= work
TB_SRC := $(abspath $(TB))
QUESTA_VLOG ?= vlog
QUESTA_VSIM ?= vsim
VCS_BIN ?= vcs
XCELIUM_XRUN ?= xrun
NOVAS_HOME ?=
VERDI_HOME ?= $(NOVAS_HOME)
QUESTA_VLOG_FLAGS ?= -sv
QUESTA_VSIM_FLAGS ?= -c
VCS_FLAGS ?= -full64 -sverilog -debug_access+all
XCELIUM_FLAGS ?= -64bit -sv -access +rwc

$(WORK_DIR)/run-%:
	mkdir -p "$@"

questa: questa-wlf questa-vcd questa-fsdb
questa-wlf: $(WORK_DIR)/run-questa-wlf
	cd "$<" && $(QUESTA_VLOG) $(QUESTA_VLOG_FLAGS) "$(TB_SRC)"
	cd "$<" && $(QUESTA_VSIM) $(QUESTA_VSIM_FLAGS) -wlf waves.wlf $(TOP) -do 'run -all; quit -f'
questa-vcd: $(WORK_DIR)/run-questa-vcd
	printf '%s\n' 'vcd file waves.vcd' 'vcd add -r /*' 'run -all' 'quit -f' > "$</run.do"
	cd "$<" && $(QUESTA_VLOG) $(QUESTA_VLOG_FLAGS) "$(TB_SRC)"
	cd "$<" && $(QUESTA_VSIM) $(QUESTA_VSIM_FLAGS) $(TOP) -do run.do
questa-fsdb: $(WORK_DIR)/run-questa-fsdb
	@test -n "$(NOVAS_HOME)" || (echo 'NOVAS_HOME is required for questa-fsdb'; exit 1)
	cd "$<" && $(QUESTA_VLOG) $(QUESTA_VLOG_FLAGS) +define+WAVES_FSDB "$(TB_SRC)"
	cd "$<" && LD_LIBRARY_PATH="$(NOVAS_HOME)/share/PLI/ModelSim/$$(uname -m):$$LD_LIBRARY_PATH" $(QUESTA_VSIM) $(QUESTA_VSIM_FLAGS) -pli "$(NOVAS_HOME)/share/PLI/ModelSim/$$(uname -m)/novas_fli.so" $(TOP) -do 'run -all; quit -f'

vcs: vcs-vpd vcs-vcd vcs-fsdb
vcs-vpd: $(WORK_DIR)/run-vcs-vpd
	cd "$<" && $(VCS_BIN) $(VCS_FLAGS) +define+WAVES_VPD "$(TB_SRC)" -o simv && ./simv
vcs-vcd: $(WORK_DIR)/run-vcs-vcd
	cd "$<" && $(VCS_BIN) $(VCS_FLAGS) +define+WAVES_VCD "$(TB_SRC)" -o simv && ./simv
vcs-fsdb: $(WORK_DIR)/run-vcs-fsdb
	@test -n "$(NOVAS_HOME)" || (echo 'NOVAS_HOME is required for vcs-fsdb'; exit 1)
	cd "$<" && $(VCS_BIN) $(VCS_FLAGS) +define+WAVES_FSDB -P "$(NOVAS_HOME)/share/PLI/VCS/LINUX64/novas.tab" "$(NOVAS_HOME)/share/PLI/VCS/LINUX64/pli.a" "$(TB_SRC)" -o simv && ./simv

xcelium: xcelium-shm xcelium-vcd xcelium-fsdb
xcelium-shm: $(WORK_DIR)/run-xcelium-shm
	printf '%s\n' 'database -open -shm -into waves.shm waves -default' 'probe -create -database waves -depth all [scope -tops]' 'run' 'exit' > "$</waves.tcl"
	cd "$<" && $(XCELIUM_XRUN) $(XCELIUM_FLAGS) "$(TB_SRC)" -top $(TOP) -input waves.tcl
xcelium-vcd: $(WORK_DIR)/run-xcelium-vcd
	printf '%s\n' 'database -open -vcd -into waves.vcd waves -default' 'probe -create -database waves -depth all [scope -tops]' 'run' 'exit' > "$</waves.tcl"
	cd "$<" && $(XCELIUM_XRUN) $(XCELIUM_FLAGS) "$(TB_SRC)" -top $(TOP) -input waves.tcl
xcelium-fsdb: $(WORK_DIR)/run-xcelium-fsdb
	@test -n "$(NOVAS_HOME)" || (echo 'NOVAS_HOME is required for xcelium-fsdb'; exit 1)
	printf '%s\n' 'call fsdbDumpfile("waves.fsdb")' 'call fsdbDumpvars(0, "tb_complex_types")' 'run' 'exit' > "$</waves.tcl"
	cd "$<" && LD_LIBRARY_PATH="$(NOVAS_HOME)/share/PLI/IUS/LINUX64:$$LD_LIBRARY_PATH" $(XCELIUM_XRUN) $(XCELIUM_FLAGS) "$(TB_SRC)" -top $(TOP) -loadpli1 "$(NOVAS_HOME)/share/PLI/IUS/LINUX64/boot/novas_fli_boot:novas_fli_boot" -input waves.tcl

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
