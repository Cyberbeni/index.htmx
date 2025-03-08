#!/bin/bash

set -eo pipefail

pushd "$(dirname "${BASH_SOURCE[0]}")/.." > /dev/null
DOCKER_IMAGE="ghcr.io/krzysztofzablocki/sourcery:2.2.6"

if which sourcery > /dev/null 2>&1; then
	sourcery \
		--sources ./Sources/index_htmx \
		--templates ./tools/Sourcery \
		--output ./Sources/index_htmx/Generated \
		--disableCache
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
	echo "Either 'docker' or 'podman' has to be installed to run swiftformat."
	exit 1
fi
