#!/usr/bin/env bash
set -euo pipefail

REPO_OWNER="${REPO_OWNER:-henrystech}"
REPO_NAME="${REPO_NAME:-super-arr-stack}"
BRANCH="${BRANCH:-main}"
INSTALL_PARENT="${INSTALL_PARENT:-$HOME}"
CLONE_DIR="${CLONE_DIR:-$INSTALL_PARENT/$REPO_NAME}"
TARBALL_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/heads/${BRANCH}.tar.gz"

have_command() {
  command -v "$1" >/dev/null 2>&1
}

run_installer() {
  cd "$CLONE_DIR"
  if [[ "${EUID}" -eq 0 ]]; then
    ./install.sh
  else
    sudo ./install.sh
  fi
}

download_with_git() {
  if [[ -d "$CLONE_DIR/.git" ]]; then
    echo "Updating existing checkout: $CLONE_DIR"
    git -C "$CLONE_DIR" pull --ff-only
  elif [[ -e "$CLONE_DIR" ]]; then
    echo "Path exists and is not a Git checkout: $CLONE_DIR"
    echo "Set CLONE_DIR=/another/path and rerun."
    exit 1
  else
    git clone "https://github.com/${REPO_OWNER}/${REPO_NAME}.git" "$CLONE_DIR"
  fi
}

download_with_curl() {
  local temp_dir
  temp_dir="$(mktemp -d)"
  trap 'rm -rf "$temp_dir"' EXIT

  if [[ -e "$CLONE_DIR" ]]; then
    echo "Path already exists and Git is not installed: $CLONE_DIR"
    echo "Install git or set CLONE_DIR=/another/path and rerun."
    exit 1
  fi

  mkdir -p "$CLONE_DIR"
  curl -fsSL "$TARBALL_URL" -o "$temp_dir/${REPO_NAME}.tar.gz"
  tar -xzf "$temp_dir/${REPO_NAME}.tar.gz" --strip-components=1 -C "$CLONE_DIR"
}

main() {
  echo "Super Arr Stack bootstrap"
  echo "Repository: https://github.com/${REPO_OWNER}/${REPO_NAME}"
  echo "Install checkout: $CLONE_DIR"
  echo

  if have_command git; then
    download_with_git
  else
    if ! have_command curl || ! have_command tar; then
      echo "Install git, or install curl and tar, then rerun."
      exit 1
    fi
    download_with_curl
  fi

  chmod +x "$CLONE_DIR/install.sh" "$CLONE_DIR"/scripts/*.sh
  run_installer
}

main "$@"
