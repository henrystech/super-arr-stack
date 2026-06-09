#!/usr/bin/env bash
set -euo pipefail

APP_ROOT="${APP_ROOT:-/opt/super-arr-stack}"
ENV_FILE="${ENV_FILE:-$APP_ROOT/.env}"
COMPOSE_FILE="${COMPOSE_FILE:-$APP_ROOT/docker-compose.yml}"
STATE_FILE="${STATE_FILE:-$APP_ROOT/data/gluetun/current-region-index}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing env file: $ENV_FILE"
  exit 1
fi

regions_line="$(grep '^VPN_REGIONS=' "$ENV_FILE" | cut -d= -f2-)"
IFS=',' read -r -a regions <<< "$regions_line"

if [[ "${#regions[@]}" -eq 0 || -z "${regions[0]}" ]]; then
  echo "No VPN regions configured in $ENV_FILE"
  exit 1
fi

mkdir -p "$(dirname "$STATE_FILE")"
current_index="0"
[[ -f "$STATE_FILE" ]] && current_index="$(cat "$STATE_FILE")"
next_index=$(( (current_index + 1) % ${#regions[@]} ))
next_region="$(echo "${regions[$next_index]}" | xargs)"

tmp_env="$(mktemp)"
awk -v region="$next_region" '
  BEGIN { replaced=0 }
  /^VPN_REGIONS=/ { print "VPN_REGIONS=" region; replaced=1; next }
  { print }
  END { if (replaced == 0) print "VPN_REGIONS=" region }
' "$ENV_FILE" > "$tmp_env"
cat "$tmp_env" > "$ENV_FILE"
rm -f "$tmp_env"

echo "$next_index" > "$STATE_FILE"
echo "Rotating VPN location to: $next_region"
docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" up -d --force-recreate gluetun
