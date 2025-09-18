#!/bin/bash

set -eo pipefail
pushd "$(dirname "${BASH_SOURCE[0]}")/.." > /dev/null
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

DOCKER_IMAGE="ghcr.io/krzysztofzablocki/sourcery:2.3.0"
PROCESS=""

do_it() {
	sourcery \
		--sources ./Sources/index_htmx \
		--templates ./tools/Sourcery \
		--output ./Sources/index_htmx/Generated \
		--disableCache
}

source scripts/_script-wrapper.sh
