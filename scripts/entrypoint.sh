#!/usr/bin/env bash
set -euo pipefail

: "${SERVER_DATA_DIR:=/opt/starrupture}"

if ! mkdir -p "${SERVER_DATA_DIR}"; then
  echo "Failed to create SERVER_DATA_DIR: ${SERVER_DATA_DIR}" >&2
  exit 1
fi
if [[ ! -w "${SERVER_DATA_DIR}" ]]; then
  echo "SERVER_DATA_DIR is not writable: ${SERVER_DATA_DIR}" >&2
  exit 1
fi

exec /usr/bin/supervisord -c /etc/supervisord.conf
