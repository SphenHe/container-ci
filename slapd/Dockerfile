# OpenLDAP slapd on Ubuntu, so yescrypt (`$y$`) password hashes taken from
# Debian/Ubuntu hosts verify directly at bind time. Alpine/musl images cannot
# do this, which would force every user to reset their password.
ARG UBUNTU_VERSION=24.04

FROM ubuntu:${UBUNTU_VERSION}

ARG SLAPD_VERSION=2.6.10
ARG SLAPD_UID=147
ARG SLAPD_GID=156

ENV DEBIAN_FRONTEND=noninteractive

# no_configuration: the cn=config tree is supplied (and bind-mounted) by the
# deployment, so the package must not generate one of its own.
RUN printf 'slapd slapd/no_configuration boolean true\n' | debconf-set-selections \
 && apt-get update \
 && apt-get install -y --no-install-recommends slapd ldap-utils ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Fail the build when the distro ships a different slapd than the tag claims,
# so `:${SLAPD_VERSION}` can never silently point at another version.
RUN installed="$(dpkg-query -W -f='${Version}' slapd)" \
 && echo "slapd package version: ${installed}" \
 && case "${installed}" in \
      "${SLAPD_VERSION}"*) : ;; \
      *) echo "expected slapd ${SLAPD_VERSION}, got ${installed}: bump SLAPD_VERSION" >&2; exit 1 ;; \
    esac

# Pin the service account so bind-mounted state keeps a stable owner on the host.
RUN groupmod -g "${SLAPD_GID}" openldap \
 && usermod -u "${SLAPD_UID}" -g "${SLAPD_GID}" -d /var/lib/ldap openldap

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 0755 /usr/local/bin/entrypoint.sh

EXPOSE 389 636

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
