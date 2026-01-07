# StarRupture Dedicated Server (Docker)

## English

This container runs the StarRupture dedicated server under supervisord.

### Requirements
- A persistent volume mount is required to keep server data.
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
  -t michibiki/starrupture-dedicated-server
```

### Skip steamcmd validation (faster startup)

```bash
docker run -d --rm \
  -e PORT=32768 \
  -e SKIP_STEAMCMD_INIT=1 \
  -p 32768:32768/tcp \
  -p 32768:32768/udp \
  -v /data:/opt \
  -t michibiki/starrupture-dedicated-server
```

### Restart server process

```bash
docker exec -it <container-name-or-id> supervisorctl restart starrupture-server
```

## 日本語

このコンテナは supervisord で StarRupture の専用サーバを実行します。

### 必須事項
- サーバデータを保持するため、永続ボリュームのマウントが必要です。
- TCP/UDP を同じ PORT で公開してください。
- PORT 環境変数を指定してください。
- ゲームクライアントからの接続にはサーバの Public IP を使用してください。

### 起動例

```bash
docker run -d --rm \
  -e PORT=32768 \
  -p 32768:32768/tcp \
  -p 32768:32768/udp \
  -v /data:/opt \
  -t michibiki/starrupture-dedicated-server
```

### steamcmd の検証をスキップ（起動を短縮）

```bash
docker run -d --rm \
  -e PORT=32768 \
  -e SKIP_STEAMCMD_INIT=1 \
  -p 32768:32768/tcp \
  -p 32768:32768/udp \
  -v /data:/opt \
  -t michibiki/starrupture-dedicated-server
```

### サーバプロセスの再起動

```bash
docker exec -it <container-name-or-id> supervisorctl restart starrupture-server
```
