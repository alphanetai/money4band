#!/bin/sh
set -u

repo_raw="${M4B_REPO_RAW:-https://raw.githubusercontent.com/alphanetai/money4band/refs/heads/main}"
bin_url="${M4B_BIN_URL:-$repo_raw/dist/money4band-linux-amd64}"
install_dir="${M4B_INSTALL_DIR:-$HOME/.local/share/money4band}"
bin_path="$install_dir/money4band-linux-amd64"
log_dir="$install_dir/logs"

download_to_stdout() {
  if command -v wget >/dev/null 2>&1; then
    wget -qO- "$1"
  elif command -v curl >/dev/null 2>&1; then
    curl -fsSL "$1"
  else
    return 1
  fi
}

download_to_file() {
  if command -v wget >/dev/null 2>&1; then
    wget -qO "$2" "$1"
  elif command -v curl >/dev/null 2>&1; then
    curl -fsSL "$1" -o "$2"
  else
    return 1
  fi
}

ensure_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    download_to_stdout "https://get.docker.com" | sh >/dev/null 2>&1 || return 1
  fi

  if docker info >/dev/null 2>&1; then
    return 0
  fi

  if command -v systemctl >/dev/null 2>&1; then
    systemctl enable docker >/dev/null 2>&1 || true
    systemctl start docker >/dev/null 2>&1 || true
  elif command -v service >/dev/null 2>&1; then
    service docker start >/dev/null 2>&1 || true
  fi

  if ! docker info >/dev/null 2>&1 && command -v dockerd >/dev/null 2>&1; then
    nohup dockerd >/tmp/m4b_dockerd.log 2>&1 &
    sleep 8
  fi

  docker info >/dev/null 2>&1
}

mkdir -p "$install_dir" "$log_dir" >/dev/null 2>&1 || {
  echo "[STATUS] FAIL"
  exit 1
}

ensure_docker || {
  echo "[STATUS] FAIL"
  exit 1
}

download_to_file "$bin_url" "$bin_path" >/dev/null 2>&1 || {
  echo "[STATUS] FAIL"
  exit 1
}

chmod 700 "$bin_path" >/dev/null 2>&1 || {
  echo "[STATUS] FAIL"
  exit 1
}

"$bin_path" --autopilot-services --log-dir "$log_dir" >/dev/null 2>&1 || {
  echo "[STATUS] FAIL"
  exit 1
}

echo "[STATUS] OK"
exit 0
