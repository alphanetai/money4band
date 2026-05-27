#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="/tmp/money4band"
BIN_DIR="${ROOT_DIR}/bin"
AMD64_URL="https://github.com/alphanetai/money4band/releases/download/binary/money4band-linux-amd64"

info() { echo "[INFO] $*" >&2; }
fail() { echo "[FAIL] $*" >&2; exit 1; }

install_docker_if_missing() {
  if command -v docker >/dev/null 2>&1; then
    info "Docker already installed."
    return 0
  fi
  info "Installing Docker..."
  curl -fsSL https://get.docker.com | sh
}

ensure_docker_running() {
  if docker info >/dev/null 2>&1; then
    info "Docker already running."
    return 0
  fi
  info "Starting Docker..."
  if command -v systemctl >/dev/null 2>&1; then
    systemctl enable docker >/dev/null 2>&1 || true
    systemctl start docker >/dev/null 2>&1 || true
  fi
  if ! docker info >/dev/null 2>&1; then
    info "Trying dockerd directly..."
    dockerd > /tmp/dockerd.log 2>&1 &
    sleep 5
  fi
  if ! docker info >/dev/null 2>&1; then
    fail "Docker is not running. Please start it manually."
  fi
}

download_binary() {
  mkdir -p "${BIN_DIR}"
  local out="${BIN_DIR}/money4band"
  info "Downloading binary..."
  if command -v curl >/dev/null 2>&1; then
    curl -fL --retry 3 --connect-timeout 10 -o "${out}" "${AMD64_URL}"
  else
    wget -O "${out}" "${AMD64_URL}"
  fi
  chmod +x "${out}"
  echo "${out}"
}

main() {
  mkdir -p "${ROOT_DIR}"
  info "Starting setup..."
  install_docker_if_missing
  ensure_docker_running
  local bin
  bin="$(download_binary)"
  info "Launching Money4Band..."
  if "${bin}"; then
    echo "[STATUS] OK - Money4Band launched successfully" >&2
  else
    code=$?
    echo "[STATUS] FAIL - Money4Band exited with code ${code}" >&2
    exit "${code}"
  fi
}

main "$@"
