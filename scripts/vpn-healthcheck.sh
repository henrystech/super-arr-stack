#!/usr/bin/env bash
set -euo pipefail

APP_ROOT="${APP_ROOT:-/opt/super-arr-stack}"
ENV_FILE="${ENV_FILE:-$APP_ROOT/.env}"
COMPOSE_FILE="${COMPOSE_FILE:-$APP_ROOT/docker-compose.yml}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing env file: $ENV_FILE"
  exit 1
fi

health="$(docker inspect --format '{{.State.Health.Status}}' gluetun 2>/dev/null || true)"
if [[ "$health" != "healthy" ]]; then
  echo "Gluetun is not healthy: ${health:-missing}"
  exit 2
fi

public_ip="$(docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" exec -T gluetun wget -qO- https://ifconfig.me 2>/dev/null || true)"
if [[ -z "$public_ip" ]]; then
  echo "VPN public IP check failed"
  exit 3
fi

echo "Gluetun healthy. VPN public IP: $public_ip"
