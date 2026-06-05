SHELL := /bin/bash
.DEFAULT_GOAL := help

PROJECTS ?= scr1 picorv32 chipyard tb_complex_types systemc-components
ARTIFACTS_DIR ?= artifacts
ARTIFACTS_ROOT := $(abspath $(ARTIFACTS_DIR))

.PHONY: help tools-check \
        images image-% \
        download download-% \
        prepare prepare-% \
        collect collect-% \
        list list-% \
        shell-% \
        clean clean-% artifacts-clean \
        distclean distclean-% \
        release

help:
	@printf '%s\n' 'Targets:'
	@printf '  %-24s %s\n' 'make tools-check' 'Check host prerequisites only.'
	@printf '  %-24s %s\n' 'make images' 'Build images for PROJECTS.'
	@printf '  %-24s %s\n' 'make image-<project>' 'Build one project image.'
	@printf '  %-24s %s\n' 'make download' 'Populate downloads for PROJECTS.'
	@printf '  %-24s %s\n' 'make prepare' 'Prepare work trees for PROJECTS.'
	@printf '  %-24s %s\n' 'make collect' 'Collect artifacts for PROJECTS.'
	@printf '  %-24s %s\n' 'make collect-<project>' 'Collect one project.'
	@printf '  %-24s %s\n' 'make list' 'List artifact targets for PROJECTS.'
	@printf '  %-24s %s\n' 'make shell-<project>' 'Open a debug shell in one project image.'
	@printf '  %-24s %s\n' 'make clean' 'Remove project work/build output and project artifacts.'
	@printf '  %-24s %s\n' 'make artifacts-clean' 'Destructively remove the whole artifacts directory.'
	@printf '  %-24s %s\n' 'make distclean' 'Run clean and remove downloads too.'
	@printf '  %-24s %s\n' 'make release VERSION=vX.Y.Z' 'Create a GitHub release from artifacts.'
	@printf '\nPROJECTS=%s\nARTIFACTS_DIR=%s\n' '$(PROJECTS)' '$(ARTIFACTS_DIR)'

tools-check:
	@missing=0; \
	for cmd in docker make git bash find sort awk xargs; do \
		if command -v "$$cmd" >/dev/null 2>&1; then \
			printf '%-8s %s\n' "$$cmd" "$$(command -v "$$cmd")"; \
		else \
			echo "missing required host tool: $$cmd"; missing=1; \
		fi; \
	done; \
	if command -v gh >/dev/null 2>&1; then \
		printf '%-8s %s (release only)\n' gh "$$(command -v gh)"; \
	else \
		echo 'note: gh not found; required only for make release'; \
	fi; \
	exit $$missing

images: $(PROJECTS:%=image-%)
image-%:
	@$(MAKE) --no-print-directory -C "projects/$*" image ARTIFACTS_DIR="$(ARTIFACTS_ROOT)/$*"

download: $(PROJECTS:%=download-%)
download-%:
	@$(MAKE) --no-print-directory -C "projects/$*" download ARTIFACTS_DIR="$(ARTIFACTS_ROOT)/$*"

prepare: $(PROJECTS:%=prepare-%)
prepare-%:
	@$(MAKE) --no-print-directory -C "projects/$*" prepare ARTIFACTS_DIR="$(ARTIFACTS_ROOT)/$*"

collect: $(PROJECTS:%=collect-%)
collect-%:
	@$(MAKE) --no-print-directory -C "projects/$*" collect ARTIFACTS_DIR="$(ARTIFACTS_ROOT)/$*"

list: $(PROJECTS:%=list-%)
list-%:
	@$(MAKE) --no-print-directory -C "projects/$*" list ARTIFACTS_DIR="$(ARTIFACTS_ROOT)/$*"

shell-%:
	@$(MAKE) --no-print-directory -C "projects/$*" shell ARTIFACTS_DIR="$(ARTIFACTS_ROOT)/$*"

clean: $(PROJECTS:%=clean-%)
clean-%:
	@$(MAKE) --no-print-directory -C "projects/$*" clean ARTIFACTS_DIR="$(ARTIFACTS_ROOT)/$*"

artifacts-clean:
	rm -rf "$(ARTIFACTS_ROOT)"

distclean: clean $(PROJECTS:%=distclean-%)
distclean-%:
	@$(MAKE) --no-print-directory -C "projects/$*" distclean ARTIFACTS_DIR="$(ARTIFACTS_ROOT)/$*"

release:
	@[ -n "$(VERSION)" ] || { echo 'Usage: make release VERSION=vX.Y.Z'; exit 1; }
	ARTIFACTS_DIR="$(ARTIFACTS_ROOT)" ./scripts/release.sh "$(VERSION)"
