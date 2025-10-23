# syntax=docker/dockerfile:1

FROM docker.io/swift:6.2.0 AS swift-build
WORKDIR /workspace
RUN swift sdk install \
	https://download.swift.org/swift-6.2-release/static-sdk/swift-6.2-RELEASE/swift-6.2-RELEASE_static-linux-0.0.1.artifactbundle.tar.gz \
	--checksum d2225840e592389ca517bbf71652f7003dbf45ac35d1e57d98b9250368769378
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && \
	apt-get -q update && \
	apt-get install -y \
		libjemalloc-dev

COPY ./Package.swift ./Package.resolved /workspace/
RUN --mount=type=cache,target=/workspace/.spm-cache,id=spm-cache \
	swift package \
		--cache-path /workspace/.spm-cache \
		--only-use-versions-from-resolved-file \
		resolve

COPY ./scripts /workspace/scripts
COPY ./Sources /workspace/Sources
RUN --mount=type=cache,target=/workspace/.build,id=build \
	--mount=type=cache,target=/workspace/.spm-cache,id=spm-cache \
	scripts/build-release.sh && \
	mkdir -p dist && \
	cp .build/release/index_htmx dist

FROM docker.io/node:lts-alpine AS npm-build
WORKDIR /workspace
COPY ./package.json ./package-lock.json /workspace/
RUN npm ci

FROM docker.io/swift:6.2.0-slim AS release
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q install -y \
      libjemalloc2 \
      tzdata \
    && rm -r /var/lib/apt/lists/*
COPY ./Resources /data
COPY --from=npm-build /workspace/node_modules/@picocss/pico/css/pico.css /data/public/pico.css
COPY --from=npm-build /workspace/node_modules/htmx.org/dist/htmx.min.js /data/public/htmx.min.js
COPY --from=npm-build /workspace/node_modules/htmx-ext-sse/dist/sse.min.js /data/public/htmxsse.min.js
RUN date +%s%N | tr -d '\n' > /data/static_files_timestamp
COPY --from=swift-build /workspace/dist/index_htmx /usr/local/bin/index_htmx
ENTRYPOINT ["/usr/local/bin/index_htmx"]
