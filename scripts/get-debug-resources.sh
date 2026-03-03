#!/bin/bash

set -eo pipefail
pushd "$(dirname "${BASH_SOURCE[0]}")/.." > /dev/null
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

DOCKER_IMAGE="docker.io/node:lts-slim"
PROCESS="npm"

do_it() {
	RESOURCES_DIR="./.debug_resources"

	rm -rf "$RESOURCES_DIR"
	mkdir -p "$RESOURCES_DIR"

	npm ci

	# TODO: also get hx-sse.min.js after next htmx4 release
	cp ./node_modules/htmx.org/dist/htmx.min.js "$RESOURCES_DIR/htmx.min.js"
	cp ./node_modules/@picocss/pico/css/pico.css "$RESOURCES_DIR/pico.css"
}

source scripts/_script-wrapper.sh
