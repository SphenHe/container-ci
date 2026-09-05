FROM --platform=${BUILDPLATFORM} caddy:2-builder-alpine AS builder

ARG TARGETOS
ARG TARGETARCH

RUN apk add --no-cache git

WORKDIR /build

# Clone caddy-dns/cloudflare.
RUN git clone https://github.com/caddy-dns/cloudflare.git

WORKDIR /build/cloudflare

# Apply caddy-dns/cloudflare PR #128 manually.
# PR #128 changes:
#   ^[A-Za-z0-9_-]{35,50}$
# to:
#   ^[A-Za-z0-9_-]{35,}$
#
# This permits newer long Cloudflare API token formats such as cfat_...
# The grep check intentionally fails the build if the patch was not applied.
# FIXED: The patch is no longer needed as the PR has been merged into the upstream repository.
# RUN sed -i 's/{35,50}/{35,}/' cloudflare.go \
#     && grep 'cloudflareTokenRegexp' cloudflare.go \
#     && grep -q '{35,}' cloudflare.go

WORKDIR /build

RUN --mount=type=cache,target=/root/.cache/go-build \
    GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    xcaddy build \
      --with github.com/caddy-dns/cloudflare=/build/cloudflare

FROM --platform=${TARGETPLATFORM} caddy:2-alpine

COPY --link --from=builder /build/caddy /usr/bin/caddy
