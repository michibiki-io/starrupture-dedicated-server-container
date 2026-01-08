# StarRupture Dedicated Server (Docker)

## English

This container runs the StarRupture dedicated server under supervisord.

### Requirements
- A persistent volume mount is required to keep server data.
- Ensure the persistent storage is writable by `10000:10000` (steam user/group).
- You must expose both TCP and UDP on the same PORT.
- Set the PORT environment variable.
- Players must connect from the game client using the server's public IP.

### Run

```bash
docker run -d --rm \
  -e PORT=32768 \
  -p 32768:32768/tcp \
  -p 32768:32768/udp \
  -v /data:/opt \
  -v ./savedata:/home/steam/starrupture/savedata \
  -t michibiki/starrupture-dedicated-server
```

### Environment variables

| Name | Default | Description |
| --- | --- | --- |
| `SERVER_DATA_DIR` | `/opt/starrupture` | Directory where server data and installed files are stored. |
| `SERVER_SAVE_DIR` | `/home/steam/starrupture/savedata` | Directory used for save data only. If existing save data is already present under `SERVER_DATA_DIR/StarRupture/Saved`, the container keeps it in place for backward compatibility and does not re-link. |
| `PORT` | `7777` | TCP/UDP port used by the server process. |
| `SKIP_STEAMCMD_INIT` | `0` | If set (non-empty), skip steamcmd initialization/validation for faster startup. |

### Skip steamcmd validation (faster startup)

```bash
docker run -d --rm \
  -e PORT=32768 \
  -e SKIP_STEAMCMD_INIT=1 \
  -p 32768:32768/tcp \
  -p 32768:32768/udp \
  -v ./data:/opt \
  -v ./savedata:/home/steam/starrupture/savedata \
  -t michibiki/starrupture-dedicated-server
```

## 日本語

このコンテナは supervisord で StarRupture の専用サーバを実行します。

### 必須事項
- サーバデータを保持するため、永続ボリュームのマウントが必要です。
- 永続記憶領域のパーミッションは `10000:10000`（steam ユーザ/グループ）で書き込み可能にしてください。
- TCP/UDP を同じ PORT で公開してください。
- PORT 環境変数を指定してください。
- ゲームクライアントからの接続にはサーバの Public IP を使用してください。

### 起動例

```bash
docker run -d --rm \
  -e PORT=32768 \
  -p 32768:32768/tcp \
  -p 32768:32768/udp \
  -v ./data:/opt \
  -v ./savedata:/home/steam/starrupture/savedata \
  -t michibiki/starrupture-dedicated-server
```

### 環境変数

| 変数名 | デフォルト | 説明 |
| --- | --- | --- |
| `SERVER_DATA_DIR` | `/opt/starrupture` | サーバデータとインストール済みファイルの保存先ディレクトリ。 |
| `SERVER_SAVE_DIR` | `/home/steam/starrupture/savedata` | セーブデータ専用の保存先ディレクトリ。既に `SERVER_DATA_DIR/StarRupture/Saved` にデータがある場合は互換性維持のためそのまま利用し、分離（リンク作成）は行いません。 |
| `PORT` | `7777` | サーバプロセスが使用する TCP/UDP ポート。 |
| `SKIP_STEAMCMD_INIT` | `0` | 設定（空でない）されている場合は steamcmd の初期化/検証をスキップして起動を短縮します。 |

### steamcmd の検証をスキップ（起動を短縮）

```bash
docker run -d --rm \
  -e PORT=32768 \
  -e SKIP_STEAMCMD_INIT=1 \
  -p 32768:32768/tcp \
  -p 32768:32768/udp \
  -v /data:/opt \
  -v ./savedata:/home/steam/starrupture/savedata \
  -t michibiki/starrupture-dedicated-server
```
