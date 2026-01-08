#!/usr/bin/env bash
set -euo pipefail

: "${SERVER_DATA_DIR:=/opt/starrupture}"
: "${SERVER_SAVE_DIR:=/home/steam/starrupture/savedata}"
: "${PORT:=7777}"

stamp_file="${SERVER_DATA_DIR}/.steamcmd_initialized"
lock_file="/tmp/.steamcmd_running"

if [[ "${SKIP_STEAMCMD_INIT:-}" == "1" && -n "$(ls -A "${SERVER_DATA_DIR}")" ]]; then
  while [[ ! -f "${stamp_file}" ]]; do
    sleep 2
  done
else
  while [[ ! -f "${lock_file}" ]]; do
    sleep 1
  done
  while [[ -f "${lock_file}" ]]; do
    sleep 2
  done
  while [[ ! -f "${stamp_file}" ]]; do
    sleep 2
  done
fi

if [[ ! -d "${SERVER_SAVE_DIR}" ]]; then
  if ! install -d -m 0755 "${SERVER_SAVE_DIR}"; then
    echo "cannnot create SERVER_SAVE_DIR: ${SERVER_SAVE_DIR}" >&2
    exit 1
  fi
fi

save_link="${SERVER_DATA_DIR}/StarRupture/Saved"
save_parent="${SERVER_DATA_DIR}/StarRupture"

if [[ ! -d "${save_parent}" ]]; then
  echo "Server data not found: ${save_parent}" >&2
  exit 1
fi

if [[ -d "${save_link}" && ! -L "${save_link}" ]]; then
  if [[ -n "$(ls -A "${save_link}")" ]]; then
    echo "Existing Saved data detected, leaving as-is: ${save_link}" >&2
  else
    rmdir "${save_link}"
    ln -s "${SERVER_SAVE_DIR}" "${save_link}"
  fi
elif [[ -e "${save_link}" && ! -L "${save_link}" ]]; then
  echo "Existing Saved entry is not a directory: ${save_link}" >&2
  exit 1
else
  ln -sfn "${SERVER_SAVE_DIR}" "${save_link}"
fi

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
