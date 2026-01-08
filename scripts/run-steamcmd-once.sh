#!/usr/bin/env bash
set -euo pipefail

: "${SERVER_DATA_DIR:=/opt/starrupture}"
: "${SKIP_STEAMCMD_INIT:=}"

stamp_file="${SERVER_DATA_DIR}/.steamcmd_initialized"

mkdir -p "${SERVER_DATA_DIR}"

if [[ -n "${SKIP_STEAMCMD_INIT}" ]]; then
  echo "SKIP_STEAMCMD_INIT is set; skipping steamcmd initialization"
  touch "${stamp_file}"
  exit 0
fi

if [[ -f "${stamp_file}" ]]; then
  echo "steamcmd already initialized at ${SERVER_DATA_DIR}"
  exit 0
fi

/home/steam/steamcmd/steamcmd.sh \
  +@sSteamCmdForcePlatformType windows \
  +force_install_dir "${SERVER_DATA_DIR}" \
  +login anonymous \
  +app_update 3809400 validate \
  +quit

touch "${stamp_file}"
