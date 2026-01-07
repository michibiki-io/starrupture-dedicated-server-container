#!/usr/bin/env bash
set -euo pipefail

: "${SERVER_DATA_DIR:=/opt/starrupture}"

install -d -o steam -g steam "${SERVER_DATA_DIR}"

exec /usr/bin/supervisord -c /etc/supervisord.conf
