#!/usr/bin/env bash
set -euo pipefail

APP_ROOT="${APP_ROOT:-/opt/super-arr-stack}"
BACKUP_ROOT="${BACKUP_ROOT:-$APP_ROOT/backups}"
stamp="$(date +%Y%m%d%H%M%S)"
archive="$BACKUP_ROOT/super-arr-stack-$stamp.tar.gz"

mkdir -p "$BACKUP_ROOT"
tar \
  --exclude "$BACKUP_ROOT" \
  -czf "$archive" \
  -C "$APP_ROOT" \
  .env docker-compose.yml data

echo "Backup created: $archive"
