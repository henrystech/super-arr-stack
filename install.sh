#!/usr/bin/env bash
set -euo pipefail

PROJECT_NAME="super-arr-stack"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    echo "Please run with sudo: sudo ./install.sh"
    exit 1
  fi
}

prompt() {
  local label="$1"
  local default="$2"
  local value
  read -r -p "${label} [${default}]: " value
  echo "${value:-$default}"
}

prompt_secret() {
  local label="$1"
  local value
  read -r -s -p "${label}: " value
  echo
  echo "$value"
}

yes_no() {
  local label="$1"
  local default="$2"
  local value
  read -r -p "${label} [${default}]: " value
  value="${value:-$default}"
  [[ "${value,,}" =~ ^(y|yes)$ ]]
}

install_docker_if_needed() {
  if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    return
  fi

  echo "Docker with Compose v2 was not found."
  if ! yes_no "Install Docker now using Docker's official convenience script?" "yes"; then
    echo "Install Docker and rerun this installer."
    exit 1
  fi

  if ! command -v curl >/dev/null 2>&1; then
    apt-get update
    apt-get install -y curl ca-certificates
  fi

  curl -fsSL https://get.docker.com | sh
}

configure_nfs_mount() {
  local data_root="$1"
  local nfs_server="$2"
  local nfs_export="$3"

  apt-get update
  apt-get install -y nfs-common
  mkdir -p "$data_root"

  local unit_name
  unit_name="$(systemd-escape -p --suffix=mount "$data_root")"
  cat > "/etc/systemd/system/${unit_name}" <<EOF
[Unit]
Description=Super Arr Stack data mount
After=network-online.target
Wants=network-online.target

[Mount]
What=${nfs_server}:${nfs_export}
Where=${data_root}
Type=nfs
Options=_netdev,nofail,rw,vers=4

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable --now "$unit_name"
}

write_env() {
  local env_path="$1"
  cat > "$env_path" <<EOF
APP_ROOT=${APP_ROOT}
DATA_ROOT=${DATA_ROOT}
TZ=${TZ_VALUE}
PUID=${PUID_VALUE}
PGID=${PGID_VALUE}

LAN_NETWORK=${LAN_NETWORK}

PIA_USER=${PIA_USER}
PIA_PASSWORD=${PIA_PASSWORD}
VPN_TYPE=${VPN_TYPE}
VPN_REGIONS=${VPN_REGIONS}
VPN_PORT_FORWARDING=on

QBIT_WEBUI_PORT=${QBIT_WEBUI_PORT}
QBIT_TORRENT_PORT=${QBIT_TORRENT_PORT}
PROWLARR_PORT=${PROWLARR_PORT}
SONARR_PORT=${SONARR_PORT}
RADARR_PORT=${RADARR_PORT}
LIDARR_PORT=${LIDARR_PORT}
FILEBROWSER_PORT=${FILEBROWSER_PORT}
SABNZBD_PORT=${SABNZBD_PORT}
BAZARR_PORT=${BAZARR_PORT}
READARR_PORT=${READARR_PORT}
DOZZLE_AGENT_PORT=${DOZZLE_AGENT_PORT}

COMPOSE_PROFILES=${COMPOSE_PROFILES}
EOF
  chmod 600 "$env_path"
}

main() {
  require_root

  echo "Super Arr Stack installer"
  echo

  APP_ROOT="$(prompt "Install folder" "/opt/super-arr-stack")"
  DATA_ROOT="$(prompt "Data/media mount path" "/data")"
  TZ_VALUE="$(prompt "Timezone" "America/Chicago")"
  PUID_VALUE="$(prompt "PUID" "1000")"
  PGID_VALUE="$(prompt "PGID" "1000")"
  LAN_NETWORK="$(prompt "LAN subnet allowed through Gluetun firewall" "192.168.1.0/24")"

  echo
  echo "Private Internet Access"
  PIA_USER="$(prompt "PIA username" "")"
  PIA_PASSWORD="$(prompt_secret "PIA password")"
  VPN_TYPE="$(prompt "VPN protocol: wireguard or openvpn" "wireguard")"
  VPN_REGIONS="$(prompt "Preferred PIA regions, comma separated" "Mexico,Panama,US Florida,Netherlands,Switzerland,Sweden")"

  echo
  echo "Ports"
  QBIT_WEBUI_PORT="$(prompt "qBittorrent Web UI port" "8090")"
  QBIT_TORRENT_PORT="$(prompt "qBittorrent torrent port" "6881")"
  PROWLARR_PORT="$(prompt "Prowlarr port" "9696")"
  SONARR_PORT="$(prompt "Sonarr port" "8989")"
  RADARR_PORT="$(prompt "Radarr port" "7878")"
  LIDARR_PORT="$(prompt "Lidarr port" "8686")"
  FILEBROWSER_PORT="$(prompt "File Browser port" "9898")"
  SABNZBD_PORT="$(prompt "SABnzbd port" "8080")"
  BAZARR_PORT="$(prompt "Bazarr port" "6767")"
  READARR_PORT="$(prompt "Readarr port" "8787")"
  DOZZLE_AGENT_PORT="$(prompt "Dozzle Agent port" "7007")"

  echo
  echo "Optional apps"
  profiles=()
  yes_no "Install SABnzbd?" "no" && profiles+=("sabnzbd")
  yes_no "Install Bazarr subtitles?" "yes" && profiles+=("bazarr")
  yes_no "Install Readarr books/audiobooks?" "no" && profiles+=("readarr")
  yes_no "Install FlareSolverr?" "yes" && profiles+=("flaresolverr")
  yes_no "Install Unpackerr?" "yes" && profiles+=("unpackerr")
  yes_no "Install Dozzle Agent?" "no" && profiles+=("dozzle")
  COMPOSE_PROFILES="$(IFS=,; echo "${profiles[*]}")"

  echo
  echo "Storage"
  if yes_no "Mount NFS directly from a NAS?" "no"; then
    NFS_SERVER="$(prompt "NFS server IP/host" "192.168.1.10")"
    NFS_EXPORT="$(prompt "NFS export path" "/volume1/data")"
    configure_nfs_mount "$DATA_ROOT" "$NFS_SERVER" "$NFS_EXPORT"
  else
    mkdir -p "$DATA_ROOT"
    echo "Using existing data path: $DATA_ROOT"
  fi

  install_docker_if_needed

  mkdir -p "$APP_ROOT"/{data,backups,logs,scripts}
  cp "$SCRIPT_DIR/compose/docker-compose.yml" "$APP_ROOT/docker-compose.yml"
  cp "$SCRIPT_DIR"/scripts/*.sh "$APP_ROOT/scripts/"
  chmod +x "$APP_ROOT"/scripts/*.sh
  write_env "$APP_ROOT/.env"

  mkdir -p \
    "$APP_ROOT/data/gluetun" \
    "$APP_ROOT/data/qbittorrent" \
    "$APP_ROOT/data/prowlarr" \
    "$APP_ROOT/data/sonarr" \
    "$APP_ROOT/data/radarr" \
    "$APP_ROOT/data/lidarr" \
    "$APP_ROOT/data/filebrowser" \
    "$DATA_ROOT/torrents/incomplete" \
    "$DATA_ROOT/torrents/completed/movies" \
    "$DATA_ROOT/torrents/completed/tv" \
    "$DATA_ROOT/torrents/completed/anime" \
    "$DATA_ROOT/torrents/completed/music" \
    "$DATA_ROOT/usenet/incomplete" \
    "$DATA_ROOT/usenet/complete" \
    "$DATA_ROOT/media"

  docker compose --env-file "$APP_ROOT/.env" -f "$APP_ROOT/docker-compose.yml" up -d

  if yes_no "Install systemd VPN health and monthly region rotation timers?" "yes"; then
    for unit in "$SCRIPT_DIR"/systemd/super-arr-stack-*.service "$SCRIPT_DIR"/systemd/super-arr-stack-*.timer; do
      sed "s|/opt/super-arr-stack|$APP_ROOT|g" "$unit" > "/etc/systemd/system/$(basename "$unit")"
    done
    systemctl daemon-reload
    systemctl enable --now super-arr-stack-vpn-health.timer
    systemctl enable --now super-arr-stack-region-rotate.timer
  fi

  echo
  echo "Super Arr Stack is starting."
  echo "Open qBittorrent: http://SERVER_IP:${QBIT_WEBUI_PORT}"
  echo "Open Prowlarr:     http://SERVER_IP:${PROWLARR_PORT}"
  echo "Open Sonarr:      http://SERVER_IP:${SONARR_PORT}"
  echo "Open Radarr:      http://SERVER_IP:${RADARR_PORT}"
  echo "Open Lidarr:      http://SERVER_IP:${LIDARR_PORT}"
  echo "Open FileBrowser: http://SERVER_IP:${FILEBROWSER_PORT}"
  echo
  echo "Config root: $APP_ROOT"
  echo "Data root:   $DATA_ROOT"
}

main "$@"
