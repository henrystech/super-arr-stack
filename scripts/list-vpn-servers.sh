#!/usr/bin/env bash
set -euo pipefail

PROVIDER_SLUG="${1:-private-internet-access}"
OUTPUT_FILE="${2:-}"
APP_ROOT="${APP_ROOT:-/opt/super-arr-stack}"
GLUETUN_DIR="${GLUETUN_DIR:-$APP_ROOT/data/gluetun}"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is required to list Gluetun VPN servers."
  exit 1
fi

mkdir -p "$GLUETUN_DIR"

echo "Listing Gluetun servers for provider: $PROVIDER_SLUG" >&2
echo "Using Gluetun data directory: $GLUETUN_DIR" >&2

if [[ -n "$OUTPUT_FILE" ]]; then
  docker run --rm \
    -v "$GLUETUN_DIR:/gluetun" \
    qmcgaw/gluetun:latest \
    format-servers "-$PROVIDER_SLUG" | tee "$OUTPUT_FILE"
  echo "Server list written to: $OUTPUT_FILE" >&2
else
  docker run --rm \
    -v "$GLUETUN_DIR:/gluetun" \
    qmcgaw/gluetun:latest \
    format-servers "-$PROVIDER_SLUG"
fi
