.DEFAULT_GOAL := help

## Bootstrap workspace (tools + hooks + submodules)
bootstrap: submodules-init tools-check
	pre-commit install --hook-type pre-commit --hook-type commit-msg

## Print versions of required tools
tools-check:
	verilator --version
	gtkwave --version
	surfer --version
	slang-server --version
	riscv64-unknown-elf-gcc --version
	riscv64-unknown-elf-objcopy --version
	pre-commit --version
	cz version

## Sync submodule URLs with .gitmodules
submodules-sync:
	git submodule sync --recursive

## Init and update all submodules recursively
submodules-init: submodules-sync
	git submodule update --init --recursive

## Pull latest configured submodule branches
submodules-update: submodules-sync
	git submodule update --remote --recursive

## Show current submodule commits
submodules-status:
	git submodule status --recursive

## Run pre-commit hooks on all files
pre-commit:
	pre-commit run --all-files

## Check commit messages
check-commit:
	cz check --commit-msg-file "$$(git rev-parse --git-path COMMIT_EDITMSG)"

## Clean up
clean:
	echo "Nothing to clean yet"

## Show targets
help:
	@awk 'BEGIN{tabstop=8;targetcol=32} /^##/{desc=$$0;sub(/^##[ ]*/,"",desc);next} /^[a-zA-Z0-9_-]+:/{name=$$1;sub(/:.*/,"",name);col=length(name);pos=col;ntabs=0;while(pos<targetcol){ntabs++;pos=int(pos/tabstop+1)*tabstop}printf "%s",name;for(i=0;i<ntabs;i++)printf "\t";printf "%s\n",desc;desc=""}' Makefile
