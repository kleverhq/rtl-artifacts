ARTIFACTS_DIR ?= artifacts
ARTIFACTS_SCR1_DIR ?= $(ARTIFACTS_DIR)

SCR1_DIR ?= /opt/scr1
SCR1_COLLECT_TRACE ?= 0
SCR1_BENCH_ADD_LDFLAGS ?= -Wl,--start-group -lc -lgcc -lnosys -Wl,--end-group -Wl,--defsym=end=_end

SCR1_FSTS := \
	$(ARTIFACTS_SCR1_DIR)/scr1_max_axi_isr_sample.fst \
	$(ARTIFACTS_SCR1_DIR)/scr1_max_axi_riscv_arch.fst \
	$(ARTIFACTS_SCR1_DIR)/scr1_max_axi_riscv_compliance.fst \
	$(ARTIFACTS_SCR1_DIR)/scr1_max_axi_riscv_isa.fst \
	$(ARTIFACTS_SCR1_DIR)/scr1_max_axi_hello.fst \
	$(ARTIFACTS_SCR1_DIR)/scr1_max_axi_coremark.fst \
	$(ARTIFACTS_SCR1_DIR)/scr1_max_axi_dhrystone21.fst \
	$(ARTIFACTS_SCR1_DIR)/scr1_max_ahb_isr_sample.fst \
	$(ARTIFACTS_SCR1_DIR)/scr1_max_ahb_riscv_arch.fst \
	$(ARTIFACTS_SCR1_DIR)/scr1_max_ahb_riscv_compliance.fst \
	$(ARTIFACTS_SCR1_DIR)/scr1_max_ahb_riscv_isa.fst \
	$(ARTIFACTS_SCR1_DIR)/scr1_max_ahb_hello.fst \
	$(ARTIFACTS_SCR1_DIR)/scr1_max_ahb_coremark.fst \
	$(ARTIFACTS_SCR1_DIR)/scr1_max_ahb_dhrystone21.fst

$(ARTIFACTS_SCR1_DIR)/scr1_max_axi_isr_sample.fst:
	@echo "Collecting SCR1 AXI/isr_sample"
	mkdir -p "$(ARTIFACTS_SCR1_DIR)"
	$(MAKE) -C $(SCR1_DIR) run_verilator_wf CFG=MAX BUS=AXI TARGETS="isr_sample" TRACE=$(SCR1_COLLECT_TRACE) ADD_LDFLAGS=
	vcd2fst "$(SCR1_DIR)/build/verilator_wf_AXI_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd" "$@"

$(ARTIFACTS_SCR1_DIR)/scr1_max_axi_riscv_arch.fst:
	@echo "Collecting SCR1 AXI/riscv_arch"
	mkdir -p "$(ARTIFACTS_SCR1_DIR)"
	$(MAKE) -C $(SCR1_DIR) run_verilator_wf CFG=MAX BUS=AXI TARGETS="riscv_arch" TRACE=$(SCR1_COLLECT_TRACE) ADD_LDFLAGS=
	vcd2fst "$(SCR1_DIR)/build/verilator_wf_AXI_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd" "$@"

$(ARTIFACTS_SCR1_DIR)/scr1_max_axi_riscv_compliance.fst:
	@echo "Collecting SCR1 AXI/riscv_compliance"
	mkdir -p "$(ARTIFACTS_SCR1_DIR)"
	$(MAKE) -C $(SCR1_DIR) run_verilator_wf CFG=MAX BUS=AXI TARGETS="riscv_compliance" TRACE=$(SCR1_COLLECT_TRACE) ADD_LDFLAGS=
	vcd2fst "$(SCR1_DIR)/build/verilator_wf_AXI_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd" "$@"

$(ARTIFACTS_SCR1_DIR)/scr1_max_axi_riscv_isa.fst:
	@echo "Collecting SCR1 AXI/riscv_isa"
	mkdir -p "$(ARTIFACTS_SCR1_DIR)"
	$(MAKE) -C $(SCR1_DIR) run_verilator_wf CFG=MAX BUS=AXI TARGETS="riscv_isa" TRACE=$(SCR1_COLLECT_TRACE) ADD_LDFLAGS=
	vcd2fst "$(SCR1_DIR)/build/verilator_wf_AXI_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd" "$@"

$(ARTIFACTS_SCR1_DIR)/scr1_max_axi_hello.fst:
	@echo "Collecting SCR1 AXI/hello"
	mkdir -p "$(ARTIFACTS_SCR1_DIR)"
	$(MAKE) -C $(SCR1_DIR) run_verilator_wf CFG=MAX BUS=AXI TARGETS="hello" TRACE=$(SCR1_COLLECT_TRACE) ADD_LDFLAGS=
	vcd2fst "$(SCR1_DIR)/build/verilator_wf_AXI_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd" "$@"

$(ARTIFACTS_SCR1_DIR)/scr1_max_axi_coremark.fst:
	@echo "Collecting SCR1 AXI/coremark"
	mkdir -p "$(ARTIFACTS_SCR1_DIR)"
	$(MAKE) -C $(SCR1_DIR) run_verilator_wf CFG=MAX BUS=AXI TARGETS="coremark" TRACE=$(SCR1_COLLECT_TRACE) ADD_LDFLAGS='$(SCR1_BENCH_ADD_LDFLAGS)'
	vcd2fst "$(SCR1_DIR)/build/verilator_wf_AXI_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd" "$@"

$(ARTIFACTS_SCR1_DIR)/scr1_max_axi_dhrystone21.fst:
	@echo "Collecting SCR1 AXI/dhrystone21"
	mkdir -p "$(ARTIFACTS_SCR1_DIR)"
	$(MAKE) -C $(SCR1_DIR) run_verilator_wf CFG=MAX BUS=AXI TARGETS="dhrystone21" TRACE=$(SCR1_COLLECT_TRACE) ADD_LDFLAGS='$(SCR1_BENCH_ADD_LDFLAGS)'
	vcd2fst "$(SCR1_DIR)/build/verilator_wf_AXI_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd" "$@"

$(ARTIFACTS_SCR1_DIR)/scr1_max_ahb_isr_sample.fst:
	@echo "Collecting SCR1 AHB/isr_sample"
	mkdir -p "$(ARTIFACTS_SCR1_DIR)"
	$(MAKE) -C $(SCR1_DIR) run_verilator_wf CFG=MAX BUS=AHB TARGETS="isr_sample" TRACE=$(SCR1_COLLECT_TRACE) ADD_LDFLAGS=
	vcd2fst "$(SCR1_DIR)/build/verilator_wf_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd" "$@"

$(ARTIFACTS_SCR1_DIR)/scr1_max_ahb_riscv_arch.fst:
	@echo "Collecting SCR1 AHB/riscv_arch"
	mkdir -p "$(ARTIFACTS_SCR1_DIR)"
	$(MAKE) -C $(SCR1_DIR) run_verilator_wf CFG=MAX BUS=AHB TARGETS="riscv_arch" TRACE=$(SCR1_COLLECT_TRACE) ADD_LDFLAGS=
	vcd2fst "$(SCR1_DIR)/build/verilator_wf_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd" "$@"

$(ARTIFACTS_SCR1_DIR)/scr1_max_ahb_riscv_compliance.fst:
	@echo "Collecting SCR1 AHB/riscv_compliance"
	mkdir -p "$(ARTIFACTS_SCR1_DIR)"
	$(MAKE) -C $(SCR1_DIR) run_verilator_wf CFG=MAX BUS=AHB TARGETS="riscv_compliance" TRACE=$(SCR1_COLLECT_TRACE) ADD_LDFLAGS=
	vcd2fst "$(SCR1_DIR)/build/verilator_wf_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd" "$@"

$(ARTIFACTS_SCR1_DIR)/scr1_max_ahb_riscv_isa.fst:
	@echo "Collecting SCR1 AHB/riscv_isa"
	mkdir -p "$(ARTIFACTS_SCR1_DIR)"
	$(MAKE) -C $(SCR1_DIR) run_verilator_wf CFG=MAX BUS=AHB TARGETS="riscv_isa" TRACE=$(SCR1_COLLECT_TRACE) ADD_LDFLAGS=
	vcd2fst "$(SCR1_DIR)/build/verilator_wf_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd" "$@"

$(ARTIFACTS_SCR1_DIR)/scr1_max_ahb_hello.fst:
	@echo "Collecting SCR1 AHB/hello"
	mkdir -p "$(ARTIFACTS_SCR1_DIR)"
	$(MAKE) -C $(SCR1_DIR) run_verilator_wf CFG=MAX BUS=AHB TARGETS="hello" TRACE=$(SCR1_COLLECT_TRACE) ADD_LDFLAGS=
	vcd2fst "$(SCR1_DIR)/build/verilator_wf_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd" "$@"

$(ARTIFACTS_SCR1_DIR)/scr1_max_ahb_coremark.fst:
	@echo "Collecting SCR1 AHB/coremark"
	mkdir -p "$(ARTIFACTS_SCR1_DIR)"
	$(MAKE) -C $(SCR1_DIR) run_verilator_wf CFG=MAX BUS=AHB TARGETS="coremark" TRACE=$(SCR1_COLLECT_TRACE) ADD_LDFLAGS='$(SCR1_BENCH_ADD_LDFLAGS)'
	vcd2fst "$(SCR1_DIR)/build/verilator_wf_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd" "$@"

$(ARTIFACTS_SCR1_DIR)/scr1_max_ahb_dhrystone21.fst:
	@echo "Collecting SCR1 AHB/dhrystone21"
	mkdir -p "$(ARTIFACTS_SCR1_DIR)"
	$(MAKE) -C $(SCR1_DIR) run_verilator_wf CFG=MAX BUS=AHB TARGETS="dhrystone21" TRACE=$(SCR1_COLLECT_TRACE) ADD_LDFLAGS='$(SCR1_BENCH_ADD_LDFLAGS)'
	vcd2fst "$(SCR1_DIR)/build/verilator_wf_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_$(SCR1_COLLECT_TRACE)/simx.vcd" "$@"

## Collect SCR1 waveform artifacts
.PHONY: scr1
scr1: $(SCR1_FSTS)
