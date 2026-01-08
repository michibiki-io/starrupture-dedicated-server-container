#!/usr/bin/env bash
set -euo pipefail

: "${SERVER_DATA_DIR:=/opt/starrupture}"
: "${SKIP_STEAMCMD_INIT:=0}"

stamp_file="${SERVER_DATA_DIR}/.steamcmd_initialized"
lock_file="/tmp/.steamcmd_running"

mkdir -p "${SERVER_DATA_DIR}"

cleanup_lock() {
  rm -f "${lock_file}"
}
trap cleanup_lock EXIT

touch "${lock_file}"

if [[ "${SKIP_STEAMCMD_INIT}" == "1" && -n "$(ls -A "${SERVER_DATA_DIR}")" ]]; then
  echo "SKIP_STEAMCMD_INIT=1 and SERVER_DATA_DIR is not empty; skipping steamcmd initialization"
  touch "${stamp_file}"
  exit 0
fi

if [[ -f "${stamp_file}" ]]; then
  /home/steam/steamcmd/steamcmd.sh \
    +force_install_dir "${SERVER_DATA_DIR}" \
    +login anonymous \
    +app_update 3809400 validate \
    +quit
else
  /home/steam/steamcmd/steamcmd.sh \
    +@sSteamCmdForcePlatformType windows \
    +force_install_dir "${SERVER_DATA_DIR}" \
    +login anonymous \
    +app_update 3809400 validate \
    +quit
fi

SKIP_STEAMCMD_INIT=1
touch "${stamp_file}"
