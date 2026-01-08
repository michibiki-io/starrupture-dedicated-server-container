#!/usr/bin/env bash
set -euo pipefail

: "${SERVER_DATA_DIR:=/opt/starrupture}"
: "${SERVER_SAVE_DIR:=/home/steam/starrupture/savedata}"
: "${PORT:=7777}"

stamp_file="${SERVER_DATA_DIR}/.steamcmd_initialized"
lock_file="/tmp/.steamcmd_running"
server_started_file="/tmp/.server_started"

if [[ ! -f "${server_started_file}" ]]; then
  if [[ -f "${stamp_file}" ]]; then
    waited=0
    while [[ ! -f "${lock_file}" && "${waited}" -lt 10 ]]; do
      sleep 1
      waited=$((waited + 1))
    done
  else
    while [[ ! -f "${stamp_file}" && ! -f "${lock_file}" ]]; do
      sleep 1
    done
  fi
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
  if [[ -n "${server_pid:-}" ]]; then
    kill -TERM -"${server_pid}" 2>/dev/null || true
  fi
  sleep 2
  if [[ -n "${server_pid:-}" ]]; then
    kill -KILL -"${server_pid}" 2>/dev/null || true
  fi
}

term_handler() {
  local status=0
  status="${1:-0}"
  cleanup
  exit "${status}"
}

random_guid() {
  if command -v uuidgen >/dev/null 2>&1; then
    uuidgen
  else
    cat /proc/sys/kernel/random/uuid
  fi
}

update_machine_guid() {
  local guid=""
  guid="$(random_guid)"
  if ! xvfb-run -a wine reg add 'HKCU\Software\Epic Games\Unreal Engine\Identifiers' \
    /v 'MachineId' /t REG_SZ /d "${guid}" /f >/dev/null 2>&1; then
    echo "Failed to update Epic MachineId" >&2
    exit 1
  fi
  echo "Updated MachineGuid to ${guid}"
}

trap 'term_handler 143' TERM
trap 'term_handler 130' INT
trap 'term_handler $?' EXIT

if ! touch "${server_started_file}"; then
  echo "Failed to write server started marker: ${server_started_file}" >&2
  exit 1
fi

update_machine_guid

server_pid=""
xvfb-run wine "${SERVER_DATA_DIR}/StarRuptureServerEOS.exe" -Log -Port="${PORT}" &
server_pid=$!

wait "${server_pid}"
