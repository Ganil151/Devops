#!/usr/bin/env bash
# wireguard_dynamic.sh
# Purpose: idempotent installer + dynamic peer management for WireGuard (Debian/Ubuntu)
# Run as root: sudo bash wireguard_dynamic.sh [install|add-client|remove-client|list-clients|info]
# Example: sudo bash wireguard_dynamic.sh install
# Example: sudo bash wireguard_dynamic.sh add-client alice 10.10.0.3/32
# Example: sudo bash wireguard_dynamic.sh remove-client alice
# Example: sudo bash wireguard_dynamic.sh list-clients

set -euo pipefail
WG_IF="wg0"
WG_CONF_DIR="/etc/wireguard"
WG_CONF_FILE="${WG_CONF_DIR}/${WG_IF}.conf"
SERVER_PRIV="${WG_CONF_DIR}/server_private.key"
SERVER_PUB="${WG_CONF_DIR}/server_public.key"
CLIENT_DIR="/etc/wireguard/clients"
PORT="${WG_PORT:-51820}"
SERVER_VPN_NET="${SERVER_VPN_NET:-10.10.0.0/24}"
SERVER_VPN_IP="${SERVER_VPN_IP:-10.10.0.1/24}"
DNS_PUSH="${DNS_PUSH:-1.1.1.1}"
BACKEND_IP="$(hostname -I | awk '{print $1}')"  # public IP detection is best-effort; replace if behind NAT.
QR_CMD="$(command -v qrencode || true)"

# Helpers
command_exists() { command -v "$1" >/dev/null 2>&1; }

ensure_root(){
  if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo." >&2
    exit 2
  fi
}

install_prereqs(){
  echo "Updating APT and installing WireGuard + tools..."
  apt-get update -y
  apt-get install -y wireguard iptables qrencode wget curl ca-certificates
}

generate_server_keys(){
  mkdir -p "${WG_CONF_DIR}"
  if [ ! -f "${SERVER_PRIV}" ]; then
    umask 077
    wg genkey | tee "${SERVER_PRIV}" | wg pubkey > "${SERVER_PUB}"
    chmod 600 "${SERVER_PRIV}" "${SERVER_PUB}"
    echo "Generated server keys."
  else
    echo "Server keys already exist."
  fi
}

create_server_conf(){
  mkdir -p "${CLIENT_DIR}"
  SERVER_PUBLIC_KEY="$(cat ${SERVER_PUB})"
  SERVER_PRIVATE_KEY="$(cat ${SERVER_PRIV})"
  cat > "${WG_CONF_FILE}" <<EOF
[Interface]
Address = ${SERVER_VPN_IP}
ListenPort = ${PORT}
PrivateKey = ${SERVER_PRIVATE_KEY}
SaveConfig = true

# PostUp/PostDown handle NAT rules (iptables). Adjust for nftables if needed.
PostUp = /usr/sbin/iptables -t nat -A POSTROUTING -s ${SERVER_VPN_NET} -o $(ip route get 1.1.1.1 | awk '{print $5; exit}') -j MASQUERADE
PostDown = /usr/sbin/iptables -t nat -D POSTROUTING -s ${SERVER_VPN_NET} -o $(ip route get 1.1.1.1 | awk '{print $5; exit}') -j MASQUERADE

# Clients will be added dynamically below as [Peer] blocks.
EOF
  chmod 600 "${WG_CONF_FILE}"
  echo "Wg config created at ${WG_CONF_FILE}"
}

enable_ip_forwarding(){
  echo "Enabling IP forwarding (sysctl)..."
  sysctl -w net.ipv4.ip_forward=1
  grep -q "^net.ipv4.ip_forward=1" /etc/sysctl.conf || echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
}

start_enable_service(){
  systemctl enable --now wg-quick@${WG_IF}.service
  echo "wg-quick@${WG_IF} enabled and started."
}

# Dynamic client add (no full restart)
add_client(){
  local NAME="$1"; shift
  local CLIENT_IP="$1"  # e.g. 10.10.0.3/32
  if [ -z "${NAME}" ] || [ -z "${CLIENT_IP}" ]; then
    echo "Usage: add-client <name> <ip/32>" >&2; exit 1
  fi
  mkdir -p "${CLIENT_DIR}"
  CLIENT_PRIV="${CLIENT_DIR}/${NAME}_priv.key"
  CLIENT_PUB="${CLIENT_DIR}/${NAME}_pub.key"
  CLIENT_CONF="${CLIENT_DIR}/${NAME}.conf"
  if [ -f "${CLIENT_CONF}" ]; then
    echo "Client ${NAME} already exists at ${CLIENT_CONF}"; return 0
  fi

  umask 077
  wg genkey | tee "${CLIENT_PRIV}" | wg pubkey > "${CLIENT_PUB}"
  CLIENT_PRIV_KEY=$(cat "${CLIENT_PRIV}")
  CLIENT_PUB_KEY=$(cat "${CLIENT_PUB}")
  SERVER_PUB_KEY=$(cat "${SERVER_PUB}")

  # Add peer at runtime
  wg set ${WG_IF} peer "${CLIENT_PUB_KEY}" allowed-ips "${CLIENT_IP%/*}/32" preshared-key /dev/null
  echo "Added peer to running interface."

  # Persist in config file (append Peer block)
  cat >> "${WG_CONF_FILE}" <<EOF

[Peer]
# ${NAME}
PublicKey = ${CLIENT_PUB_KEY}
AllowedIPs = ${CLIENT_IP%/*}/32
EOF

  # client config
  cat > "${CLIENT_CONF}" <<EOF
[Interface]
PrivateKey = ${CLIENT_PRIV_KEY}
Address = ${CLIENT_IP}
DNS = ${DNS_PUSH}

[Peer]
PublicKey = ${SERVER_PUB_KEY}
Endpoint = ${BACKEND_IP}:${PORT}
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF
  chmod 600 "${CLIENT_CONF}"
  echo "Wrote client config to ${CLIENT_CONF}"

  if [ -n "${QR_CMD}" ]; then
    echo "Client QR (use WireGuard app to scan):"
    qrencode -t ansiutf8 < "${CLIENT_CONF}"
  fi
}

remove_client(){
  local NAME="$1"; shift
  CLIENT_PUB="${CLIENT_DIR}/${NAME}_pub.key"
  CLIENT_CONF="${CLIENT_DIR}/${NAME}.conf"
  if [ ! -f "${CLIENT_PUB}" ]; then
    echo "No such client ${NAME}"; exit 1
  fi
  CLIENT_PUB_KEY=$(cat "${CLIENT_PUB}")

  # remove from running interface
  wg set ${WG_IF} peer "${CLIENT_PUB_KEY}" remove || true
  echo "Removed peer from running interface (if present)."

  # Remove from configuration file (safe edit)
  if grep -q "${CLIENT_PUB_KEY}" "${WG_CONF_FILE}"; then
    awk -v pk="${CLIENT_PUB_KEY}" 'BEGIN{skip=0} /\\[Peer\\]/{buf=""; skip=0} {buf=buf $0 "\n"} index(buf, pk){buf=""; next} {if(length(buf)>0){printf "%s", buf; buf="";}} END{printf "%s", buf}' "${WG_CONF_FILE}" > "${WG_CONF_FILE}.tmp" && mv "${WG_CONF_FILE}.tmp" "${WG_CONF_FILE}"
    echo "Removed persisted peer block from ${WG_CONF_FILE}"
  fi

  # cleanup keys and client conf
  rm -f "${CLIENT_CONF}" "${CLIENT_DIR}/${NAME}_priv.key" "${CLIENT_DIR}/${NAME}_pub.key"
  echo "Removed client files."
}

list_clients(){
  echo "Clients (client .conf files in ${CLIENT_DIR}):"
  ls -1 "${CLIENT_DIR}"/*.conf 2>/dev/null || echo "(no clients)"
  echo
  echo "Running peers (wg show):"
  wg show
}

info(){
  echo "WG interface: ${WG_IF}"
  echo "Config file: ${WG_CONF_FILE}"
  echo "Client configs dir: ${CLIENT_DIR}"
  echo "Server public key: $(cat ${SERVER_PUB} 2>/dev/null || echo '(missing)')"
  echo "Uptime/status:"
  wg show
}

case "${1:-}" in
  install)
    ensure_root
    install_prereqs
    generate_server_keys
    create_server_conf
    enable_ip_forwarding
    start_enable_service
    echo "Install complete. Add clients with: $0 add-client <name> <ip/32>"
    ;;
  add-client)
    ensure_root
    add_client "$2" "$3"
    ;;
  remove-client)
    ensure_root
    remove_client "$2"
    ;;
  list-clients)
    list_clients
    ;;
  info)
    info
    ;;
  *)
    echo "Usage: $0 {install|add-client|remove-client|list-clients|info}"
    exit 1
    ;;
esac
