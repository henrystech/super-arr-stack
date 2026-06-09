#!/usr/bin/env bash
set -euo pipefail

APP_ROOT="${APP_ROOT:-/opt/super-arr-stack}"
ENV_FILE="${ENV_FILE:-$APP_ROOT/.env}"
COMPOSE_FILE="${COMPOSE_FILE:-$APP_ROOT/docker-compose.yml}"

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

original_env="$(mktemp)"
cp "$ENV_FILE" "$original_env"
trap 'cp "$original_env" "$ENV_FILE"; rm -f "$original_env"' EXIT

printf "%-28s %s\n" "REGION" "SECONDS_TO_HEALTH"
for region in "${regions[@]}"; do
  region="$(echo "$region" | xargs)"
  tmp_env="$(mktemp)"
  awk -v region="$region" '
    /^VPN_REGIONS=/ { print "VPN_REGIONS=" region; next }
    { print }
  ' "$ENV_FILE" > "$tmp_env"
  cat "$tmp_env" > "$ENV_FILE"
  rm -f "$tmp_env"

  start="$(date +%s)"
  docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" up -d --force-recreate gluetun >/dev/null

  healthy="no"
  for _ in $(seq 1 60); do
    health="$(docker inspect --format '{{.State.Health.Status}}' gluetun 2>/dev/null || true)"
    if [[ "$health" == "healthy" ]]; then
      healthy="yes"
      break
    fi
    sleep 2
  done

  end="$(date +%s)"
  if [[ "$healthy" == "yes" ]]; then
    printf "%-28s %s\n" "$region" "$((end - start))"
  else
    printf "%-28s %s\n" "$region" "failed"
  fi
done
