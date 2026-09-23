#!/bin/sh
# Own the bind-mounted state, then hand over to slapd as the unprivileged user.
set -e

install -d -o openldap -g openldap -m 0750 /var/lib/ldap /var/run/slapd
chown -R openldap:openldap /var/lib/ldap /etc/ldap/slapd.d

exec /usr/sbin/slapd \
	-h "ldap:/// ldapi:///" \
	-g openldap -u openldap \
	-F /etc/ldap/slapd.d \
	-d 0
