#!/bin/bash

set -eo pipefail

pushd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null

BUILD_ARGS=(
	--product index_htmx
	--configuration release
	--cache-path /workspace/.spm-cache
	-Xlinker -ljemalloc
)

swift build "${BUILD_ARGS[@]}"
