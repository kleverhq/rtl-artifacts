ARTIFACTS_DIR ?= artifacts
ARTIFACTS_SCR1_DIR ?= $(ARTIFACTS_DIR)/scr1
ARTIFACTS_PICORV32_DIR ?= $(ARTIFACTS_DIR)/picorv32

SCR1_DIR ?= third_party/scr1
SCR1_COLLECT_CFG ?= MAX
SCR1_COLLECT_TRACE ?= 0
SCR1_COLLECT_BUSES ?= AXI AHB
SCR1_COLLECT_TARGETS ?= isr_sample riscv_arch riscv_compliance riscv_isa hello coremark dhrystone21
SCR1_BENCH_TARGETS ?= coremark dhrystone21
SCR1_BENCH_ADD_LDFLAGS ?= -Wl,--start-group -lc -lgcc -lnosys -Wl,--end-group -Wl,--defsym=end=_end

PICORV32_DIR ?= third_party/picorv32
PICORV32_TOOLCHAIN_PREFIX ?= riscv64-unknown-elf-
PICORV32_COLLECT_TARGETS ?= test_vcd test_wb_vcd test_ez_vcd

.DEFAULT_GOAL := all

.PHONY: all clean scr1 picorv32

## Collect all artifacts
all: scr1 picorv32

## Run SCR1 waveform collection matrix
scr1:
	@set -eu; \
	mkdir -p $(ARTIFACTS_SCR1_DIR);
	cfg_lc=$$(printf '%s' "$(SCR1_COLLECT_CFG)" | tr '[:upper:]' '[:lower:]'); \
	for bus in $(SCR1_COLLECT_BUSES); do \
		bus_lc=$$(printf '%s' "$$bus" | tr '[:upper:]' '[:lower:]'); \
		build_dir="$(SCR1_DIR)/build/verilator_wf_$${bus}_$(SCR1_COLLECT_CFG)_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)"; \
		for target in $(SCR1_COLLECT_TARGETS); do \
			echo "Collecting $$bus/$$target"; \
			case " $(SCR1_BENCH_TARGETS) " in \
				*" $$target "*) $(MAKE) -C $(SCR1_DIR) run_verilator_wf CFG=$(SCR1_COLLECT_CFG) BUS=$$bus TARGETS="$$target" TRACE=$(SCR1_COLLECT_TRACE) ADD_LDFLAGS='$(SCR1_BENCH_ADD_LDFLAGS)' ;; \
				*) $(MAKE) -C $(SCR1_DIR) run_verilator_wf CFG=$(SCR1_COLLECT_CFG) BUS=$$bus TARGETS="$$target" TRACE=$(SCR1_COLLECT_TRACE) ADD_LDFLAGS= ;; \
			esac; \
			vcd2fst "$$build_dir/simx.vcd" "$(ARTIFACTS_SCR1_DIR)/scr1_$${cfg_lc}_$${bus_lc}_$${target}.fst"; \
		done; \
	done

## Run PicoRV32 waveform collection
picorv32:
	@set -eu; \
	mkdir -p $(ARTIFACTS_PICORV32_DIR); \
	for target in $(PICORV32_COLLECT_TARGETS); do \
		echo "Collecting $$target"; \
		$(MAKE) -C $(PICORV32_DIR) TOOLCHAIN_PREFIX="$(PICORV32_TOOLCHAIN_PREFIX)" $$target; \
		vcd2fst "$(PICORV32_DIR)/testbench.vcd" "$(ARTIFACTS_PICORV32_DIR)/picorv32_$${target}.fst"; \
	done

## Remove all build artifacts
clean:
	rm -rf $(ARTIFACTS_DIR)
	$(MAKE) -C $(SCR1_DIR) clean
	$(MAKE) -C $(PICORV32_DIR) clean
