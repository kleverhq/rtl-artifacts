ARTIFACTS_DIR ?= artifacts
ARTIFACTS_SCR1_DIR ?= $(ARTIFACTS_DIR)/scr1

SCR1_DIR ?= third_party/scr1
SCR1_COLLECT_CFG ?= MAX
SCR1_COLLECT_TRACE ?= 0
SCR1_COLLECT_BUSES ?= AXI AHB
SCR1_COLLECT_TARGETS ?= isr_sample riscv_arch riscv_compliance riscv_isa hello coremark dhrystone21
SCR1_BENCH_TARGETS ?= coremark dhrystone21
SCR1_BENCH_ADD_LDFLAGS ?= -Wl,--start-group -lc -lgcc -lnosys -Wl,--end-group -Wl,--defsym=end=_end

.DEFAULT_GOAL := all

.PHONY: all clean scr1

## Collect all artifacts
all: scr1

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

## Remove all build artifacts
clean:
	rm -rf $(ARTIFACTS_DIR)
	$(MAKE) -C $(SCR1_DIR) clean
