#!/bin/bash

set -eo pipefail

pushd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null

BUILD_ARGS=(
	--product index_htmx
	--configuration release
	-Xlinker -ljemalloc
)

if [[ "$DOCKER_BUILD" = true ]]; then
	BUILD_ARGS+=(--cache-path /workspace/.spm-cache)
fi

swift build "${BUILD_ARGS[@]}"
