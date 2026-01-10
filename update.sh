#!/usr/bin/env bash

set -euo pipefail

base_dir="$(cd "$(dirname "$0")"; pwd)"

(
  cd "$base_dir"
  git stash save
  git chm
  git pl
  make install
)
