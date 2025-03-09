#!/bin/bash

set -eo pipefail

pushd "$(dirname "${BASH_SOURCE[0]}")/.." > /dev/null
DOCKER_IMAGE="docker.io/node:lts-slim"

if which npm > /dev/null 2>&1; then
	RESOURCES_DIR="./.debug_resources"

	rm -rf "$RESOURCES_DIR"
	mkdir -p "$RESOURCES_DIR"

	npm ci

	cp ./node_modules/htmx.org/dist/htmx.min.js "$RESOURCES_DIR/htmx.min.js"
	cp ./node_modules/htmx-ext-sse/dist/sse.min.js "$RESOURCES_DIR/htmxsse.min.js"
	cp ./node_modules/@picocss/pico/css/pico.css "$RESOURCES_DIR/pico.css"
elif which docker > /dev/null 2>&1; then
	docker run --rm \
		--volume .:/workspace \
		--user "$(id -u):$(id -g)" \
		"$DOCKER_IMAGE" \
		"/workspace/scripts/$(basename "${BASH_SOURCE[0]}")"
elif which podman > /dev/null 2>&1; then
	podman run --rm \
		--volume .:/workspace \
		--userns=keep-id \
		"$DOCKER_IMAGE" \
		"/workspace/scripts/$(basename "${BASH_SOURCE[0]}")"
else
	echo "Either 'npm', 'docker' or 'podman' has to be installed to export the npm dependencies."
	exit 1
fi
