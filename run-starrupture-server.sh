#!/usr/bin/env bash
set -euo pipefail

: "${SERVER_DATA_DIR:=/opt/starrupture}"
: "${PORT:=7777}"

stamp_file="${SERVER_DATA_DIR}/.steamcmd_initialized"

while [[ ! -f "${stamp_file}" ]]; do
  sleep 2
done

cleanup() {
  wineboot -k || true
  wineserver -k || true
  wineserver64 -k || true
  pkill -f wineserver || true
}

trap cleanup TERM INT

exec wine64 "${SERVER_DATA_DIR}/StarRuptureServerEOS.exe" -Log -Port="${PORT}"
