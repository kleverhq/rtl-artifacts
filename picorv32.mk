ARTIFACTS_DIR ?= artifacts
ARTIFACTS_PICORV32_DIR ?= $(ARTIFACTS_DIR)

PICORV32_DIR ?= third_party/picorv32
PICORV32_TOOLCHAIN_PREFIX ?= riscv64-unknown-elf-

PICORV32_FSTS := \
	$(ARTIFACTS_PICORV32_DIR)/picorv32_test_vcd.fst \
	$(ARTIFACTS_PICORV32_DIR)/picorv32_test_wb_vcd.fst \
	$(ARTIFACTS_PICORV32_DIR)/picorv32_test_ez_vcd.fst

$(ARTIFACTS_PICORV32_DIR)/picorv32_test_vcd.fst:
	@echo "Collecting PicoRV32 test_vcd"
	mkdir -p "$(ARTIFACTS_PICORV32_DIR)"
	$(MAKE) -C $(PICORV32_DIR) TOOLCHAIN_PREFIX="$(PICORV32_TOOLCHAIN_PREFIX)" test_vcd
	vcd2fst "$(PICORV32_DIR)/testbench.vcd" "$@"

$(ARTIFACTS_PICORV32_DIR)/picorv32_test_wb_vcd.fst:
	@echo "Collecting PicoRV32 test_wb_vcd"
	mkdir -p "$(ARTIFACTS_PICORV32_DIR)"
	$(MAKE) -C $(PICORV32_DIR) TOOLCHAIN_PREFIX="$(PICORV32_TOOLCHAIN_PREFIX)" test_wb_vcd
	vcd2fst "$(PICORV32_DIR)/testbench.vcd" "$@"

$(ARTIFACTS_PICORV32_DIR)/picorv32_test_ez_vcd.fst:
	@echo "Collecting PicoRV32 test_ez_vcd"
	mkdir -p "$(ARTIFACTS_PICORV32_DIR)"
	$(MAKE) -C $(PICORV32_DIR) TOOLCHAIN_PREFIX="$(PICORV32_TOOLCHAIN_PREFIX)" test_ez_vcd
	vcd2fst "$(PICORV32_DIR)/testbench.vcd" "$@"

## Collect PicoRV32 waveform artifacts
.PHONY: picorv32
picorv32: $(PICORV32_FSTS)
