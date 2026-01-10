#!/usr/bin/env bash
set -euo pipefail

: "${SERVER_DATA_DIR:=/opt/starrupture}"
: "${SKIP_STEAMCMD_INIT:=0}"

stamp_file="${SERVER_DATA_DIR}/.steamcmd_initialized"
success_file="/tmp/.successful_steamcmd_run"
run_count_file="/tmp/.steamcmd_run_count"

mkdir -p "${SERVER_DATA_DIR}"

run_count=0
if [[ -f "${run_count_file}" ]]; then
  if read -r run_count < "${run_count_file}"; then
    if ! [[ "${run_count}" =~ ^[0-9]+$ ]]; then
      run_count=0
    fi
  fi
fi
run_count=$((run_count + 1))
printf '%s\n' "${run_count}" > "${run_count_file}"

if [[ "${run_count}" -ge 4 ]]; then
  echo "steamcmd run count is ${run_count}; skipping steamcmd initialization"
  touch "${success_file}"
  exit 0
fi

if [[ "${SKIP_STEAMCMD_INIT}" == "1" && -f "${stamp_file}" ]]; then
  echo "SKIP_STEAMCMD_INIT=1 and SERVER_DATA_DIR is not empty; skipping steamcmd initialization"
  touch "${success_file}"
  exit 0
fi

if /home/steam/steamcmd/steamcmd.sh \
  +@sSteamCmdForcePlatformType windows \
  +force_install_dir "${SERVER_DATA_DIR}" \
  +login anonymous \
  +app_update 3809400 validate \
  +quit; then
  steamcmd_status=0
else
  steamcmd_status=$?
fi

if [[ "${steamcmd_status}" -ne 0 ]]; then
  echo "steamcmd failed with status ${steamcmd_status}" >&2
  exit "${steamcmd_status}"
fi

touch "${success_file}"
touch "${stamp_file}"
