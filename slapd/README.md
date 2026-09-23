# slapd

Custom OpenLDAP server image published as:

```text
ghcr.io/sphenhe/slapd:2.6.10
ghcr.io/sphenhe/slapd:latest
```

## Why not an off-the-shelf image

- Ubuntu 24.04 base, so yescrypt (`$y$`) password hashes produced by
  Debian/Ubuntu hosts verify directly at bind time. Users keep their existing
  passwords instead of being forced through a reset.
- The `openldap` service account is pinned to uid `147` / gid `156`, matching
  the Debian/Ubuntu defaults, so bind-mounted `slapd.d` and `data` keep a stable
  owner on the host.
- `entrypoint.sh` takes ownership of the bind-mounted directories and then drops
  to the unprivileged user, so the host does not have to pre-chown them.

The image carries no configuration of its own. `slapd.d` (cn=config, including
schemas) and the MDB database are supplied by the deployment through bind
mounts.

## Repository layout

```text
container-ci/
├── .github/
│   └── workflows/
│       └── slapd.yml
└── slapd/
    ├── Dockerfile
    ├── entrypoint.sh
    └── docker-compose.example.yml
```

## Build locally

From the repository root:

```bash
docker build -t ghcr.io/sphenhe/slapd:local ./slapd
```

## GitHub Actions

Push a change under `slapd/**` or `.github/workflows/slapd.yml`, or run the
workflow manually with `workflow_dispatch`.

The workflow publishes `linux/amd64` and `linux/arm64` for both tags.

The Dockerfile fails the build when the distro ships a slapd whose version does
not match `SLAPD_VERSION`, so a version tag can never point at another version.
Bump `SLAPD_VERSION` in `slapd/Dockerfile` and `.github/workflows/slapd.yml`
together.

## Use in Docker Compose

```yaml
services:
  slapd:
    image: ghcr.io/sphenhe/slapd:2.6.10
    container_name: slapd
    restart: unless-stopped
    volumes:
      - ./slapd.d:/etc/ldap/slapd.d
      - ./data:/var/lib/ldap
    ports:
      - "389:389"
```

```bash
docker compose pull slapd
docker compose up -d slapd
```

## Notes

- The container listens on `ldap:///` and `ldapi:///` only. TLS is expected to be
  terminated by a separate gateway container.
- `slapd.d` is the source of truth for the running configuration: the
  `openssh-lpk` schema, the MDB database and every imported account live in that
  tree.
