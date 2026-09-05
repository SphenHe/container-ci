# Caddy

Custom Caddy image published as:

```text
ghcr.io/sphenhe/caddy:latest
```

## Included modules

- Caddy
- `github.com/caddy-dns/cloudflare`
- Manual application of `caddy-dns/cloudflare` PR #128

PR #128 removes the upper length limit in the Cloudflare API token validation regex:

```diff
- ^[A-Za-z0-9_-]{35,50}$
+ ^[A-Za-z0-9_-]{35,}$
```

This is needed for newer longer Cloudflare API token formats such as `cfat_...`.

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

Verify the Cloudflare DNS module:

```bash
docker run --rm ghcr.io/sphenhe/caddy:local caddy list-modules | grep cloudflare
```

Expected:

```text
dns.providers.cloudflare
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

## Host caddy-l4 passthrough

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
