# Caddy

Custom Caddy image published as:

```text
ghcr.io/sphenhe/caddy:latest
```

## Included modules

- Caddy `2.11.4`
- `github.com/caddy-dns/cloudflare` `v0.2.4`
- `github.com/mholt/caddy-l4` `v0.1.2`

The versions are pinned in `caddy/Dockerfile` so builds are reproducible. The
Cloudflare DNS provider includes support for newer `cfat_...` API token formats.

## Repository layout

```text
container-ci/
├── .github/
│   └── workflows/
│       └── caddy.yml
└── caddy/
    ├── Dockerfile
    ├── Caddyfile.example
    ├── docker-compose.example.yml
    └── .env.example
```

## Build locally

From the repository root:

```bash
docker build -t ghcr.io/sphenhe/caddy:local ./caddy
```

Verify the Cloudflare DNS and Layer 4 modules:

```bash
docker run --rm ghcr.io/sphenhe/caddy:local caddy list-modules \
  | grep -E 'cloudflare|layer4'
```

Expected modules include:

```text
dns.providers.cloudflare
layer4
layer4.handlers.proxy
```

## GitHub Actions

Push a change under `caddy/**` or `.github/workflows/caddy.yml`.

The workflow publishes:

```text
ghcr.io/sphenhe/caddy:latest
```

You can also run the workflow manually with `workflow_dispatch`.

## Use in Docker Compose

Example:

```yaml
services:
  caddy:
    image: ghcr.io/sphenhe/caddy:latest
```

Then:

```bash
docker compose pull caddy
docker compose up -d caddy
```

## Caddyfile

Use:

```caddy
{$CADDY_HOSTNAME} {
    tls {
        issuer acme {
            profile shortlived
            disable_http_challenge
            disable_tlsalpn_challenge
            dns cloudflare {env.CF_API_TOKEN}
        }
    }

    reverse_proxy cli-proxy-api:8317
}
```

The Caddy environment variable syntax for the Cloudflare token is:

```text
{env.CF_API_TOKEN}
```

## Layer 4 TLS passthrough

This image includes `caddy-l4`, so the host/edge Caddy can route raw TCP by TLS
SNI while each backend Caddy terminates TLS itself. The edge must listen on
`:443`, while each backend should listen on a separate internal port such as
`:8443`.

If the host machine later owns TCP :443 with caddy-l4 and only passes TLS through to this Docker Caddy, change:

```yaml
ports:
  - "443:443"
```

to:

```yaml
ports:
  - "127.0.0.1:10443:443"
```

Then point the host caddy-l4 SNI route at `127.0.0.1:10443`.
