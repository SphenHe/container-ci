ARG CADDY_VERSION=2.11.4
ARG CADDY_L4_VERSION=v0.1.2
ARG CLOUDFLARE_DNS_VERSION=v0.2.4

FROM --platform=${BUILDPLATFORM} caddy:${CADDY_VERSION}-builder-alpine AS builder

ARG TARGETOS
ARG TARGETARCH
ARG CADDY_VERSION
ARG CADDY_L4_VERSION
ARG CLOUDFLARE_DNS_VERSION

RUN apk add --no-cache git

WORKDIR /build

RUN --mount=type=cache,target=/root/.cache/go-build \
    GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    xcaddy build v${CADDY_VERSION} \
      --with github.com/caddy-dns/cloudflare@${CLOUDFLARE_DNS_VERSION} \
      --with github.com/mholt/caddy-l4@${CADDY_L4_VERSION}

FROM --platform=${TARGETPLATFORM} caddy:${CADDY_VERSION}-alpine

COPY --link --from=builder /build/caddy /usr/bin/caddy
