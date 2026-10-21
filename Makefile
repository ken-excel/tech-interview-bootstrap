# Convenience targets. On a brand-new Mac `make` may not exist yet
# (it comes with the Command Line Tools) — use ./bootstrap.sh for the first run.

.PHONY: install dry-run doctor gather uninstall uninstall-all lint

install:        ## full setup (idempotent)
	./bootstrap.sh

dry-run:        ## show what install would do
	./bootstrap.sh --dry-run

doctor:         ## verify the environment
	./doctor.sh

gather:         ## agents research tooling/practices into ~/interview/docs/context
	./agent-kit/gather.sh

uninstall:      ## interactive removal
	./uninstall.sh

uninstall-all:  ## remove everything incl. Homebrew/CLT if the kit installed them
	./uninstall.sh --yes --all

lint:           ## shellcheck all scripts
	shellcheck -x bootstrap.sh uninstall.sh doctor.sh bin/ibx agent-kit/gather.sh lib/common.sh steps/*.sh workspace-template/diagrams/render.sh
