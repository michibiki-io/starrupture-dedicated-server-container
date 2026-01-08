FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
  dpkg --add-architecture i386; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    ca-certificates curl \
    xvfb xauth \
    supervisor \
    cabextract unzip p7zip-full \
    wine64 wine32:i386 winetricks \
    libx11-6:i386 libxext6:i386 libxrender1:i386 libxi6:i386 libxrandr2:i386 \
  ; \
  rm -rf /var/lib/apt/lists/*

# winetricks のハッシュ追従（--self-update は公式オプション）
RUN set -eux; \
  winetricks --self-update

# --- root: steam ユーザ作成 ---
# UID/GID は必要に応じて調整（ホストマウントの権限整合用）
RUN set -eux; \
  groupadd -g 10000 steam; \
  useradd  -m -u 10000 -g 10000 -s /bin/bash steam

ENV PATH=$PATH:/usr/lib/wine

# --- ここから非 root ---
USER steam
ENV HOME=/home/steam

# steam ユーザの HOME 配下に prefix を置く（推奨）
ENV WINEARCH=win64
ENV WINEPREFIX=/home/steam/.wine
ENV WINETRICKS_LATEST_VERSION_CHECK=disabled
ENV WINETRICKS_CACHE=/home/steam/.cache/winetricks
ENV WINEDEBUG=-all
ENV XDG_RUNTIME_DIR=/tmp/xdg-steam
ENV SERVER_DATA_DIR=/opt/starrupture
ENV SKIP_STEAMCMD_INIT=0

# XDG runtime とキャッシュディレクトリ準備
RUN set -eux; \
  mkdir -p "$XDG_RUNTIME_DIR" "$WINETRICKS_CACHE" "$(dirname "$WINEPREFIX")"; \
  chmod 700 "$XDG_RUNTIME_DIR"

# winetricks 自身の更新（ユーザ実行でOK）
RUN set -eux; \
  winetricks --self-update

# prefix 初期化
RUN set -eux; \
  xvfb-run -a -s "-screen 0 1024x768x24" wineboot --init; \
  wineserver -w

# vcrun2022
RUN set -eux; \
  rm -rf "$WINETRICKS_CACHE/vcrun2022"; \
  xvfb-run -a -s "-screen 0 1024x768x24" winetricks -q --force vcrun2022; \
  wineserver -w

# steamcmd インストール
RUN set -eux; \
  cd /home/steam; \
  mkdir -p steamcmd; \
  cd steamcmd; \
  curl -sSL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -; \
  chmod +x steamcmd.sh

WORKDIR /home/steam

# --- root に戻る ---
USER root

COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY scripts/run-steamcmd-once.sh /usr/local/bin/run-steamcmd-once.sh
COPY scripts/run-starrupture-server.sh /usr/local/bin/run-starrupture-server.sh
COPY scripts/supervisorctl /usr/local/bin/supervisorctl
COPY scripts/supervisord.conf /etc/supervisord.conf
RUN set -eux; \
  chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/run-steamcmd-once.sh /usr/local/bin/run-starrupture-server.sh /usr/local/bin/supervisorctl
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
