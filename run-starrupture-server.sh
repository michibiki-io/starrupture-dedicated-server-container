#!/usr/bin/env bash
set -euo pipefail

: "${SERVER_DATA_DIR:=/opt/starrupture}"
: "${PORT:=7777}"

stamp_file="${SERVER_DATA_DIR}/.steamcmd_initialized"

while [[ ! -f "${stamp_file}" ]]; do
  sleep 2
done

cleanup() {
  pkill -TERM -f StarRuptureServerEOS.exe || true
  pkill -TERM -f wineserver || true
  pkill -TERM -f "Z:" || true
  pkill -TERM -f "C:" || true
}

term_handler() {
  local status=0
  status="${1:-0}"
  cleanup
  exit "${status}"
}

trap 'term_handler 143' TERM
trap 'term_handler 130' INT
trap 'term_handler $?' EXIT

wine64 "${SERVER_DATA_DIR}/StarRuptureServerEOS.exe" -Log -Port="${PORT}" &
server_pid=$!

wait "${server_pid}"
