.DEFAULT_GOAL := help

HELP_MAKEFILES ?= Makefile scr1.mk picorv32.mk chipyard.mk

include scr1.mk
include picorv32.mk
include chipyard.mk

.PHONY: bootstrap tools-check sources-check pre-commit check-commit collect clean help

.NOTPARALLEL: collect scr1 picorv32 chipyard

## Bootstrap workspace (tools + hooks + external source checks)
bootstrap: sources-check tools-check
	pre-commit install --hook-type pre-commit --hook-type commit-msg

## Print versions of required tools
tools-check:
	verilator --version
	gtkwave --version
	surfer --version
	slang-server --version
	riscv64-unknown-elf-gcc --version
	riscv64-unknown-elf-objcopy --version
	iverilog -V
	pre-commit --version
	cz version

## Verify external RTL source trees from image
sources-check:
	@[ -d "$(SCR1_DIR)" ] || { echo "Missing SCR1 sources at $(SCR1_DIR)"; exit 1; }
	@[ -d "$(PICORV32_DIR)" ] || { echo "Missing PicoRV32 sources at $(PICORV32_DIR)"; exit 1; }
	@[ -f "$(CHIPYARD_ENV_SH)" ] || { echo "Missing Chipyard env.sh at $(CHIPYARD_ENV_SH)"; exit 1; }
	@[ -w "$(SCR1_DIR)" ] || { echo "SCR1 sources are not writable: $(SCR1_DIR)"; exit 1; }
	@[ -w "$(PICORV32_DIR)" ] || { echo "PicoRV32 sources are not writable: $(PICORV32_DIR)"; exit 1; }
	@[ -w "$(CHIPYARD_DIR)" ] || { echo "Chipyard sources are not writable: $(CHIPYARD_DIR)"; exit 1; }

## Run pre-commit hooks on all files
pre-commit:
	pre-commit run --all-files

## Check commit messages
check-commit:
	cz check --commit-msg-file "$$(git rev-parse --git-path COMMIT_EDITMSG)"

## Collect all artifacts
collect: scr1 picorv32 chipyard

## Clean up
clean:
	rm -rf $(ARTIFACTS_DIR)
	$(MAKE) -C $(SCR1_DIR) clean
	$(MAKE) -C $(PICORV32_DIR) clean

## Show targets
help:
	@awk 'BEGIN{tabstop=8;targetcol=32} /^##/{desc=$$0;sub(/^##[ ]*/,"",desc);next} /^[a-zA-Z0-9_-]+:/{name=$$1;sub(/:.*/,"",name);col=length(name);pos=col;ntabs=0;while(pos<targetcol){ntabs++;pos=int(pos/tabstop+1)*tabstop}printf "%s",name;for(i=0;i<ntabs;i++)printf "\t\t\t";printf "%s\n",desc;desc=""}' $(HELP_MAKEFILES)
