# syntax=docker/dockerfile:1

FROM node:24-bookworm-slim

ARG DSH_VERSION=latest
ARG PNPM_VERSION=11.7.0

ENV NODE_ENV=production
ENV DSH_HOME=/home/node/.dsh

RUN set -eu; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        curl \
        git \
        jq \
        libgcc-s1 \
        libstdc++6 \
        openssh-client \
        unzip; \
    rm -rf /var/lib/apt/lists/*; \
    npm install --global --no-audit --no-fund \
        "pnpm@${PNPM_VERSION}" \
        "@deepseek-ai/dsh@${DSH_VERSION}"; \
    npm cache clean --force; \
    if [ "${DSH_VERSION}" != "latest" ]; then \
        test "$(dsh --version)" = "${DSH_VERSION}"; \
    fi

RUN mkdir -p /workspace /home/node/.dsh \
    && chown -R node:node /workspace /home/node/.dsh

COPY web-docker.cordis.yml /etc/dsh/web-docker.cordis.yml

WORKDIR /workspace
USER node

EXPOSE 3080

ENTRYPOINT ["dsh"]
CMD ["web", "--patch", "/etc/dsh/web-docker.cordis.yml", "--no-open", "--trusted-host", "dsh"]
