#!/usr/bin/make -f

MAKEFLAGS+=--warn-undefined-variables
SHELL:=/bin/bash
.SHELLFLAGS:=-eu -o pipefail -c
.DEFAULT_GOAL:=help
.SILENT:

# all targets are phony
.PHONY: $(shell egrep -o ^[a-zA-Z_-]+: $(MAKEFILE_LIST) | sed 's/://')

install: ## install files
	./install.sh

dev: ## install dev
	DOTFILES_INSTALL_DEV=1 ./install.sh

update: ## update files
	./update.sh

lint: ## lint files
	git config --list >/dev/null
	find . -name '*.zsh' -or -name '*.bash' -or -name '*.sh' -or -name '.zshrc*' -or -name '.zprofile*' \
  | grep -v ".ignore" \
  | xargs shellcheck -S warning

test: ## test files
	shellspec -f d

build-tools: ## build tools
	cd tools/capytool && go build -o ../../bin/capytool

test-tools: ## test tools
	cd tools/capytool && go test -v ./...

install-tools: build-tools ## install tools
	mkdir -p $(HOME)/bin
	cp bin/capytool $(HOME)/bin/

clean-tools: ## clean tools build artifacts
	rm -f bin/capytool

help: ## Print this help
	echo 'Usage: make [target]'
	echo ''
	echo 'Targets:'
	awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
