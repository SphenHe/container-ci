# DeepSeek Harness

Custom DeepSeek Harness image published as:

```text
ghcr.io/sphenhe/dsh:latest
```

The image installs the published npm CLI `@deepseek-ai/dsh`, which is the
officially supported way to run the harness without building the repository.
The image applies a small Cordis overlay that makes the web profile bind
`0.0.0.0`, so it can be reached over a Docker container network without host
port mapping.

## Contents

- Node.js 24 on Debian bookworm slim
- `dsh` npm `latest` by default (`DSH_VERSION` build arg in the Dockerfile)
- `pnpm` `11.7.0`, used by `dsh plugin`
- Common shell tooling: bash, git, curl, jq, unzip, and OpenSSH client

DeepSeek Harness is in developer preview and changes quickly. CI resolves the
npm dist-tag to an exact version at build time, then tags the image with that
exact dsh version as well as `latest`.

## Repository layout

```text
container-ci/
|-- .github/
|   `-- workflows/
|       |-- caddy.yml
|       `-- dsh.yml
`-- dsh/
    |-- Dockerfile
    |-- README.md
    |-- docker-compose.example.yml
    `-- web-docker.cordis.yml
```

## Build locally

From the repository root:

```bash
docker build -t ghcr.io/sphenhe/dsh:local ./dsh
```

This uses the current npm `latest` dist-tag. To pin an exact version:

```bash
docker build --build-arg DSH_VERSION=0.1.2-rc.1 \
  -t ghcr.io/sphenhe/dsh:0.1.2-rc.1 ./dsh
```

Verify the version:

```bash
docker run --rm ghcr.io/sphenhe/dsh:local --version
```

It prints the dsh version installed in the image.

## Run the Web UI

The web profile listens on `0.0.0.0:3080` inside the container network. Other
containers on the same Docker network can open:

```bash
http://dsh:3080
```

The container log prints the tokenized startup URL, for example:

```text
dsh web: http://127.0.0.1:3080/?token=... (LAN: http://172.18.0.2:3080/?token=...)
```

To run the same service from the host shell without publishing a host port:

```bash
docker network create dsh-internal

docker run --rm -d \
  --network dsh-internal \
  --name dsh \
  -v "$PWD:/workspace" \
  -v dsh-home:/home/node/.dsh \
  ghcr.io/sphenhe/dsh:latest
```

Access it from another container on `dsh-internal`, or from the host with
`docker exec` / an SSH tunnel. Mount a workspace at `/workspace`, then choose it
inside the Web UI.

The `dsh` hostname is trusted through the startup `--trusted-host dsh` option.
If you rename the service in Compose, also rename the trust entry in the
default command or add the new authority with another `--trusted-host`.

## Network exposure

Upstream keeps the Web UI on `127.0.0.1` and deliberately rejects
`--host 0.0.0.0`. This image changes that through the Cordis overlay in
`web-docker.cordis.yml`, so only run it on a trusted Docker network: every
container on that network can reach the listener, and dsh can execute commands
inside the mounted workspace. The Compose example intentionally publishes no
host port.

## Run one headless task

```bash
docker run --rm -it \
  -v "$PWD:/workspace" \
  -v dsh-home:/home/node/.dsh \
  ghcr.io/sphenhe/dsh:latest \
  --profile headless "Summarize this repository"
```

Other entry modes such as `sdk`, `sdk-minimal`, and `acp` work the same way:

```bash
docker run --rm -it \
  -v "$PWD:/workspace" \
  -v dsh-home:/home/node/.dsh \
  ghcr.io/sphenhe/dsh:latest \
  --profile sdk
```

## GitHub Actions

Push a change under `dsh/**` or `.github/workflows/dsh.yml`.

The push workflow resolves the npm `latest` dist-tag and publishes both:

```text
ghcr.io/sphenhe/dsh:latest
ghcr.io/sphenhe/dsh:<resolved dsh version>
```

To release another dsh version manually:

1. Open **Actions** in GitHub.
2. Choose **Build DeepSeek Harness**.
3. Click **Run workflow**.
4. Leave **dsh version** as `latest`, or enter an exact version such as
   `0.1.2-rc.1` or another npm dist-tag such as `next`.

The same job then publishes `latest` and the resolved exact version tag.
