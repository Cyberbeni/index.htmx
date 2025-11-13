# syntax=docker/dockerfile:1

FROM --platform=$BUILDPLATFORM docker.io/swift:6.2.0 AS swift-build
WORKDIR /workspace
RUN swift sdk install \
	https://download.swift.org/swift-6.2-release/static-sdk/swift-6.2-RELEASE/swift-6.2-RELEASE_static-linux-0.0.1.artifactbundle.tar.gz \
	--checksum d2225840e592389ca517bbf71652f7003dbf45ac35d1e57d98b9250368769378

COPY ./Package.swift ./Package.resolved /workspace/
RUN --mount=type=cache,target=/workspace/.spm-cache,id=spm-cache \
	swift package \
		--cache-path /workspace/.spm-cache \
		--only-use-versions-from-resolved-file \
		resolve

COPY ./scripts /workspace/scripts
COPY ./Sources /workspace/Sources
ARG TARGETPLATFORM
RUN --mount=type=cache,target=/workspace/.build,id=build-$TARGETPLATFORM \
	--mount=type=cache,target=/workspace/.spm-cache,id=spm-cache \
	scripts/build-release.sh && \
	mkdir -p dist && \
	cp .build/release/index_htmx dist

FROM --platform=$BUILDPLATFORM docker.io/node:lts-alpine AS npm-build
WORKDIR /workspace
COPY ./package.json ./package-lock.json /workspace/
RUN npm ci

FROM docker.io/alpine:latest AS release
RUN apk add --no-cache \
	tzdata
COPY ./Resources /data
COPY --from=npm-build /workspace/node_modules/@picocss/pico/css/pico.css /data/public/pico.css
COPY --from=npm-build /workspace/node_modules/htmx.org/dist/htmx.min.js /data/public/htmx.min.js
RUN date +%s%N | tr -d '\n' > /data/static_files_timestamp
COPY --from=swift-build /workspace/dist/index_htmx /usr/local/bin/index_htmx
ENTRYPOINT ["/usr/local/bin/index_htmx"]
