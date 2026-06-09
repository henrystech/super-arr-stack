#!/usr/bin/env bash
set -euo pipefail

APP_ROOT="${APP_ROOT:-/opt/super-arr-stack}"
ENV_FILE="${ENV_FILE:-$APP_ROOT/.env}"
FORWARDED_PORT_FILE="${FORWARDED_PORT_FILE:-$APP_ROOT/data/gluetun/forwarded_port}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing env file: $ENV_FILE"
  exit 1
fi

get_env_value() {
  local key="$1"
  grep "^${key}=" "$ENV_FILE" | tail -n 1 | cut -d= -f2-
}

QBIT_WEBUI_PORT="$(get_env_value QBIT_WEBUI_PORT)"

if [[ ! -f "$FORWARDED_PORT_FILE" ]]; then
  echo "Forwarded port file not found: $FORWARDED_PORT_FILE"
  echo "Wait for Gluetun to connect and request a forwarded port from your VPN provider."
  exit 1
fi

forwarded_port="$(tr -cd '0-9' < "$FORWARDED_PORT_FILE")"
if [[ -z "$forwarded_port" ]]; then
  echo "Forwarded port file is empty."
  exit 1
fi

qbit_url="http://127.0.0.1:${QBIT_WEBUI_PORT}"
cookie_file="$(mktemp)"
trap 'rm -f "$cookie_file"' EXIT

echo "Forwarded VPN port: $forwarded_port"
echo "Trying qBittorrent anonymous/local API session at $qbit_url"

if curl -fsS -c "$cookie_file" "$qbit_url/api/v2/app/version" >/dev/null; then
  curl -fsS -b "$cookie_file" \
    --data-urlencode "json={\"listen_port\":${forwarded_port}}" \
    "$qbit_url/api/v2/app/setPreferences" >/dev/null
  echo "qBittorrent listen port updated to $forwarded_port"
else
  echo "Could not reach qBittorrent API without authentication."
  echo "Log in to qBittorrent and set the listening port to: $forwarded_port"
fi
