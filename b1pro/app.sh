#!/bin/sh -eu

base_dir="$(cd $(dirname $0); pwd)"

. "$base_dir/app.env"

$APP_PYTHON_PATH "$base_dir/app.py"
