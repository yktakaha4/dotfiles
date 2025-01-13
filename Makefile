#!/usr/bin/make -f

MAKEFLAGS+=--warn-undefined-variables
SHELL:=/bin/bash
.SHELLFLAGS:=-eu -o pipefail -c
.DEFAULT_GOAL:=help
.SILENT:

# all targets are phony
.PHONY: $(shell egrep -o ^[a-zA-Z_-]+: $(MAKEFILE_LIST) | sed 's/://')

install: ## install files
	./install.zsh

lint: ## lint files
	find . -name '*.zsh' -or -name '*.bash' -or -name '*.sh' -or -name '.zshrc*' -or -name '.zprofile*' \
  | xargs shellcheck -S warning

test: ## test files
	shellspec -f d

help: ## Print this help
	echo 'Usage: make [target]'
	echo ''
	echo 'Targets:'
	awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
