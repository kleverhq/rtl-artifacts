# Multi-simulator / multi-format Makefile for tb.sv
#
# Naming:
#   make questa
#   make questa-wlf
#   make questa-vcd
#   make questa-fsdb
#   make vcs
#   make vcs-vpd
#   make vcs-vcd
#   make vcs-fsdb
#   make xcelium
#   make xcelium-shm
#   make xcelium-vcd
#   make xcelium-fsdb
#   make verilator
#   make verilator-vcd
#   make verilator-fst
#   make icarus
#   make icarus-vcd
#   make icarus-fst
#   make clean
#
# Notes:
# - FSDB targets require Verdi/Novas dumper integration.
# - Verilator targets assume a recent Verilator with --binary support.
# - Questa VCD is generated via a do-file using "vcd file" / "vcd add".
# - Xcelium SHM/VCD/FSDB are driven via Tcl command files.
# - VCS VPD/VCD/FSDB rely on compile-time defines and TB hooks.

SHELL := /bin/bash

TB  := tb.sv
TOP := tb_complex_types

QUESTA_VLOG   ?= vlog
QUESTA_VSIM   ?= vsim

VCS_BIN       ?= vcs

XCELIUM_XRUN  ?= xrun

VERILATOR_BIN ?= verilator

IVERILOG_BIN  ?= iverilog
VVP_BIN       ?= vvp

# Optional Verdi / FSDB environment.
NOVAS_HOME    ?=
VERDI_HOME    ?= $(NOVAS_HOME)

# Common flags.
QUESTA_VLOG_FLAGS   ?= -sv
QUESTA_VSIM_FLAGS   ?= -c
VCS_FLAGS           ?= -full64 -sverilog -debug_access+all
XCELIUM_FLAGS       ?= -64bit -sv -access +rwc
VERILATOR_FLAGS     ?= -Wall -Wno-fatal -sv --binary --trace-structs
IVERILOG_FLAGS      ?= -g2012

RUN_DIRS := \
  run-questa-wlf run-questa-vcd run-questa-fsdb \
  run-vcs-vpd run-vcs-vcd run-vcs-fsdb \
  run-xcelium-shm run-xcelium-vcd run-xcelium-fsdb \
  run-verilator-vcd run-verilator-fst \
  run-icarus-vcd run-icarus-fst

QUESTA_TARGETS    := questa-wlf questa-vcd questa-fsdb
VCS_TARGETS       := vcs-vpd vcs-vcd vcs-fsdb
XCELIUM_TARGETS   := xcelium-shm xcelium-vcd xcelium-fsdb
VERILATOR_TARGETS := verilator-vcd verilator-fst
ICARUS_TARGETS    := icarus-vcd icarus-fst

.PHONY: all clean \
        questa vcs xcelium verilator icarus \
        $(QUESTA_TARGETS) \
        $(VCS_TARGETS) \
        $(XCELIUM_TARGETS) \
        $(VERILATOR_TARGETS) \
        $(ICARUS_TARGETS)

all: \
  $(QUESTA_TARGETS) \
  $(VCS_TARGETS) \
  $(XCELIUM_TARGETS) \
  $(VERILATOR_TARGETS) \
  $(ICARUS_TARGETS)

$(RUN_DIRS):
	mkdir -p $@

define copy_tb
	cp $(TB) $1/
endef

# -----------------------------------------------------------------------------
# Questa (not tested yet)
# -----------------------------------------------------------------------------

questa: $(QUESTA_TARGETS)

questa-wlf: run-questa-wlf
	$(call copy_tb,run-questa-wlf)
	cd run-questa-wlf && \
	$(QUESTA_VLOG) $(QUESTA_VLOG_FLAGS) $(TB)
	cd run-questa-wlf && \
	$(QUESTA_VSIM) $(QUESTA_VSIM_FLAGS) -wlf waves.wlf $(TOP) -do "run -all; quit -f"

questa-vcd: run-questa-vcd
	$(call copy_tb,run-questa-vcd)
	printf '%s\n' \
'vcd file waves.vcd' \
'vcd add -r /*' \
'run -all' \
'quit -f' \
	> run-questa-vcd/run.do
	cd run-questa-vcd && \
	$(QUESTA_VLOG) $(QUESTA_VLOG_FLAGS) $(TB)
	cd run-questa-vcd && \
	$(QUESTA_VSIM) $(QUESTA_VSIM_FLAGS) $(TOP) -do run.do

questa-fsdb: run-questa-fsdb
	$(call copy_tb,run-questa-fsdb)
	@test -n "$(NOVAS_HOME)" || (echo "NOVAS_HOME is required for questa-fsdb"; exit 1)
	cd run-questa-fsdb && \
	$(QUESTA_VLOG) $(QUESTA_VLOG_FLAGS) +define+WAVES_FSDB $(TB)
	cd run-questa-fsdb && \
	LD_LIBRARY_PATH="$(NOVAS_HOME)/share/PLI/ModelSim/$(shell uname -m):$$LD_LIBRARY_PATH" \
	$(QUESTA_VSIM) $(QUESTA_VSIM_FLAGS) \
	  -pli "$(NOVAS_HOME)/share/PLI/ModelSim/$(shell uname -m)/novas_fli.so" \
	  $(TOP) -do "run -all; quit -f"

# -----------------------------------------------------------------------------
# VCS (not tested yet)
# -----------------------------------------------------------------------------

vcs: $(VCS_TARGETS)

vcs-vpd: run-vcs-vpd
	$(call copy_tb,run-vcs-vpd)
	cd run-vcs-vpd && \
	$(VCS_BIN) $(VCS_FLAGS) +define+WAVES_VPD $(TB) -o simv
	cd run-vcs-vpd && \
	./simv

vcs-vcd: run-vcs-vcd
	$(call copy_tb,run-vcs-vcd)
	cd run-vcs-vcd && \
	$(VCS_BIN) $(VCS_FLAGS) +define+WAVES_VCD $(TB) -o simv
	cd run-vcs-vcd && \
	./simv

vcs-fsdb: run-vcs-fsdb
	$(call copy_tb,run-vcs-fsdb)
	@test -n "$(NOVAS_HOME)" || (echo "NOVAS_HOME is required for vcs-fsdb"; exit 1)
	cd run-vcs-fsdb && \
	$(VCS_BIN) $(VCS_FLAGS) +define+WAVES_FSDB \
	  -P "$(NOVAS_HOME)/share/PLI/VCS/LINUX64/novas.tab" \
	     "$(NOVAS_HOME)/share/PLI/VCS/LINUX64/pli.a" \
	  $(TB) -o simv
	cd run-vcs-fsdb && \
	./simv

# -----------------------------------------------------------------------------
# Xcelium (not tested yet)
# -----------------------------------------------------------------------------

xcelium: $(XCELIUM_TARGETS)

xcelium-shm: run-xcelium-shm
	$(call copy_tb,run-xcelium-shm)
	printf '%s\n' \
'database -open -shm -into waves.shm waves -default' \
'probe -create -database waves -depth all [scope -tops]' \
'run' \
'exit' \
	> run-xcelium-shm/waves.tcl
	cd run-xcelium-shm && \
	$(XCELIUM_XRUN) $(XCELIUM_FLAGS) $(TB) -top $(TOP) -input waves.tcl

xcelium-vcd: run-xcelium-vcd
	$(call copy_tb,run-xcelium-vcd)
	printf '%s\n' \
'database -open -vcd -into waves.vcd waves -default' \
'probe -create -database waves -depth all [scope -tops]' \
'run' \
'exit' \
	> run-xcelium-vcd/waves.tcl
	cd run-xcelium-vcd && \
	$(XCELIUM_XRUN) $(XCELIUM_FLAGS) $(TB) -top $(TOP) -input waves.tcl

xcelium-fsdb: run-xcelium-fsdb
	$(call copy_tb,run-xcelium-fsdb)
	@test -n "$(NOVAS_HOME)" || (echo "NOVAS_HOME is required for xcelium-fsdb"; exit 1)
	printf '%s\n' \
'call fsdbDumpfile("waves.fsdb")' \
'call fsdbDumpvars(0, "tb_complex_types")' \
'run' \
'exit' \
	> run-xcelium-fsdb/waves.tcl
	cd run-xcelium-fsdb && \
	LD_LIBRARY_PATH="$(NOVAS_HOME)/share/PLI/IUS/LINUX64:$$LD_LIBRARY_PATH" \
	$(XCELIUM_XRUN) $(XCELIUM_FLAGS) $(TB) -top $(TOP) \
	  -loadpli1 "$(NOVAS_HOME)/share/PLI/IUS/LINUX64/boot/novas_fli_boot:novas_fli_boot" \
	  -input waves.tcl

# -----------------------------------------------------------------------------
# Verilator (not tested yet)
# -----------------------------------------------------------------------------

verilator: $(VERILATOR_TARGETS)

verilator-vcd: run-verilator-vcd
	$(call copy_tb,run-verilator-vcd)
	cd run-verilator-vcd && \
	$(VERILATOR_BIN) $(VERILATOR_FLAGS) --trace-vcd +define+WAVES_VCD $(TB) --top-module $(TOP)
	cd run-verilator-vcd && \
	./obj_dir/V$(TOP)

verilator-fst: run-verilator-fst
	$(call copy_tb,run-verilator-fst)
	cd run-verilator-fst && \
	$(VERILATOR_BIN) $(VERILATOR_FLAGS) --trace-fst +define+WAVES_FST $(TB) --top-module $(TOP)
	cd run-verilator-fst && \
	./obj_dir/V$(TOP)

# -----------------------------------------------------------------------------
# Icarus (not tested yet)
# -----------------------------------------------------------------------------

icarus: $(ICARUS_TARGETS)

icarus-vcd: run-icarus-vcd
	$(call copy_tb,run-icarus-vcd)
	cd run-icarus-vcd && \
	$(IVERILOG_BIN) $(IVERILOG_FLAGS) +define+WAVES_VCD -o simv $(TB)
	cd run-icarus-vcd && \
	$(VVP_BIN) simv

icarus-fst: run-icarus-fst
	$(call copy_tb,run-icarus-fst)
	cd run-icarus-fst && \
	$(IVERILOG_BIN) $(IVERILOG_FLAGS) +define+WAVES_FST -o simv $(TB)
	cd run-icarus-fst && \
	$(VVP_BIN) -fst simv

clean:
	rm -rf $(RUN_DIRS)
