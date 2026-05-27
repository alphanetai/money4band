#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${ROOT_DIR}/bin"
AMD64_URL="https://github.com/alphanetai/money4band/releases/download/binary/money4band-linux-amd64"
SUDO=""

info() { echo "[INFO] $*" >&2; }
fail() { echo "[FAIL] $*" >&2; exit 1; }

install_docker_if_missing() {
  command -v docker >/dev/null 2>&1 && { info "Docker already installed."; return; }
  info "Installing Docker..."
  curl -fsSL https://get.docker.com | sh
}

ensure_docker_running() {
  docker info >/dev/null 2>&1 && { info "Docker running."; return; }
  sudo systemctl start docker
}

download_binary() {
  mkdir -p "${BIN_DIR}"
  local out="${BIN_DIR}/money4band"
  info "Downloading binary..."
  curl -fL --retry 3 -o "${out}" "${AMD64_URL}"
  chmod +x "${out}"
  echo "${out}"
}

main() {
  install_docker_if_missing
  ensure_docker_running
  local bin; bin="$(download_binary)"
  info "Starting Money4Band..."
  "${bin}"
}

main "$@"
