#!/bin/sh
set -u

repo_raw="${M4B_REPO_RAW:-https://raw.githubusercontent.com/alphanetai/money4band/refs/heads/main}"
bin_url="${M4B_BIN_URL:-$repo_raw/dist/money4band-linux-amd64}"
install_dir="${M4B_INSTALL_DIR:-$HOME/.local/share/money4band}"
bin_path="$install_dir/money4band-linux-amd64"
log_dir="$install_dir/logs"

mkdir -p "$install_dir" "$log_dir" >/dev/null 2>&1 || {
  echo "[STATUS] FAIL"
  exit 1
}

if command -v wget >/dev/null 2>&1; then
  wget -qO "$bin_path" "$bin_url" >/dev/null 2>&1 || {
    echo "[STATUS] FAIL"
    exit 1
  }
elif command -v curl >/dev/null 2>&1; then
  curl -fsSL "$bin_url" -o "$bin_path" >/dev/null 2>&1 || {
    echo "[STATUS] FAIL"
    exit 1
  }
else
  echo "[STATUS] FAIL"
  exit 1
fi

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
