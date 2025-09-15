FROM --platform=$BUILDPLATFORM tonistiigi/xx:1.7.0 AS xx

FROM --platform=$BUILDPLATFORM golang:1.24-bookworm AS builder
COPY --from=xx / /

WORKDIR /src

# Install toolchain for CGO and cross compilation helpers
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	   ca-certificates pkg-config clang lld musl-tools \
	&& rm -rf /var/lib/apt/lists/*

ARG TARGETPLATFORM
# Install target C toolchain/libs via xx (maps to correct arch)
RUN xx-apt-get update \
	&& xx-apt-get install -y xx-c-essentials

# Pre-download modules for better caching
COPY go.mod go.sum ./

RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
	go mod download && go mod verify

COPY . .

# Enable CGO and build the single main at repo root using xx-go for cross builds
ENV CGO_ENABLED=1 CC=musl-gcc
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg/mod \
	go mod tidy && \
	xx-go build -trimpath \
		-ldflags="-s -w -linkmode external -extldflags \"-static\"" \
		-o /build/example . && \
        xx-verify /build/example

FROM --platform=$BUILDPLATFORM scratch AS export
COPY --from=builder /build/example /example