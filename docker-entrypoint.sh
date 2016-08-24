#!/bin/bash
set -e

# user must pass as env var or host mount the following (relative to /etc/openvpn)
# BIND_PASSWORD
# CA_PEM/ca.pem
# DOMAIN
# DH_PEM/dh.pem
# MGMTPASS/mgmtpass
# SERVER_KEY/server.key
# SERVER_PEM/server.pem

# check that required env vars or files are available
if [[ -z "${CA_PEM}" && ! -f /etc/openvpn/ca.pem ]]; then
  echo "You must pass in CA_PEM or mount a ca.pem file to /etc/openvpn."
  exit 1
fi
if [[ -z "${DH_PEM}" && ! -f /etc/openvpn/dh.pem ]]; then
  echo "You must pass in DH_PEM or mount a dh.pem file to /etc/openvpn."
  exit 1
fi
if [[ -z "${MGMTPASS}" && ! -f /etc/openvpn/mgmtpass ]]; then
  echo "You must pass in MGMTPASS or mount a mgmtpass file to /etc/openvpn."
  exit 1
fi
if [[ -z "${SERVER_KEY}" && ! -f /etc/openvpn/server.key ]]; then
  echo "You must pass in SERVER_KEY or mount a server.key file to /etc/openvpn."
  exit 1
fi
if [[ -z "${SERVER_PEM}" && ! -f /etc/openvpn/server.pem ]]; then
  echo "You must pass in SERVER_PEM or mount a server.pem file to /etc/openvpn."
  exit 1
fi
if [ -z "${DOMAIN}" ]; then
  echo "You must pass in your DOMAIN."
  exit 1
fi
if [ -z "${BIND_PASSWORD}" ]; then
  echo "You must pass in your BIND_PASSWORD."
  exit 1
fi

# now render needed files from env vars if they are passed
if [ -n "${CA_PEM}" ]; then
  consul-template -once -template /etc/openvpn/ca.pem.ctmpl:/etc/openvpn/ca.pem
fi
if [ -n "${DH_PEM}" ]; then
  consul-template -once -template /etc/openvpn/dh.pem.ctmpl:/etc/openvpn/dh.pem
fi
if [ -n "${MGMTPASS}" ]; then
  consul-template -once -template /etc/openvpn/mgmtpass.ctmpl:/etc/openvpn/mgmtpass
fi
if [ -n "${SERVER_KEY}" ]; then
  consul-template -once -template /etc/openvpn/server.key.ctmpl:/etc/openvpn/server.key
fi
if [ -n "${SERVER_PEM}" ]; then
  consul-template -once -template /etc/openvpn/server.pem.ctmpl:/etc/openvpn/server.pem
fi

# render the server.conf and auth_ldap.conf
consul-template -once -template /etc/openvpn/server.conf.ctmpl:/etc/openvpn/server.conf
consul-template -once -template /etc/openvpn/auth_ldap.conf.ctmpl:/etc/openvpn/auth_ldap.conf

iptables -t nat -A POSTROUTING -s $VPN_NET/24 -o eth0 -j MASQUERADE
exec /usr/sbin/openvpn /etc/openvpn/server.conf
