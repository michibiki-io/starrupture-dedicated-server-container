# Helm Deployment

## English

This chart deploys the StarRupture dedicated server to Kubernetes.

### Requirements
- Two persistent volumes are required:
  - Server data: `/opt/starrupture`
  - Save data: `/home/steam/starrupture/savedata`
- The init container changes ownership of both mount paths to `10000:10000`.
- The service exposes **both TCP and UDP** on the same port.
- `PORT` is always derived from `service.port`.
- `env.skipSteamcmdInit` is a boolean. The chart maps `true` -> `SKIP_STEAMCMD_INIT=1` and `false` -> `SKIP_STEAMCMD_INIT=0`.
- Ingress is not included. Use `NodePort` or `LoadBalancer` if you need external access.

### Install / Upgrade

```bash
helm upgrade --install starrupture deploy/chart
```

### Examples

Use existing PVCs:

```bash
helm upgrade --install starrupture deploy/chart \
  --set persistence.serverData.existingClaim=starrupture-server-data \
  --set persistence.saveData.existingClaim=starrupture-save-data
```

Create PVs with hostPath (example for a single-node setup):
If `persistence.*.pv.hostPath` is set, the chart creates a hostPath PV. If it is empty, only a PVC is created.

```bash
helm upgrade --install starrupture deploy/chart \
  --set persistence.serverData.pv.hostPath=/data/starrupture \
  --set persistence.saveData.pv.hostPath=/data/starrupture-savedata
```

Expose with NodePort and change the game port:

```bash
helm upgrade --install starrupture deploy/chart \
  --set service.type=NodePort \
  --set service.port=32768
```

### Storage class notes
- To use the cluster default storage class, leave `storageClassName` empty.
- To force an empty storage class (no provisioner), set `storageClassName` to `-`.

### Values (defaults)

| Key | Default | Description |
| --- | --- | --- |
| `replicaCount` | `1` | Number of replicas for the Deployment. |
| `image.repository` | `michibiki/starrupture-dedicated-server` | Container image repository. |
| `image.tag` | `latest` | Container image tag. |
| `image.pullPolicy` | `IfNotPresent` | Image pull policy. |
| `imagePullSecrets` | `[]` | Image pull secret names. |
| `nameOverride` | `""` | Override chart name. |
| `fullnameOverride` | `""` | Override full release name. |
| `serviceAccount.create` | `true` | Create a ServiceAccount. |
| `serviceAccount.name` | `""` | Use an existing ServiceAccount name when set. |
| `podAnnotations` | `{}` | Extra annotations for the Pod. |
| `podLabels` | `{}` | Extra labels for the Pod. |
| `podSecurityContext.fsGroup` | `10000` | fsGroup for mounted volumes. |
| `securityContext.runAsUser` | `10000` | Container user ID. |
| `securityContext.runAsGroup` | `10000` | Container group ID. |
| `securityContext.runAsNonRoot` | `true` | Require non-root user. |
| `initContainer.enabled` | `true` | Enable the init container for ownership fix. |
| `initContainer.image` | `busybox:1.36` | Init container image. |
| `initContainer.pullPolicy` | `IfNotPresent` | Init container pull policy. |
| `initContainer.securityContext.runAsUser` | `0` | Init container user ID. |
| `initContainer.securityContext.runAsGroup` | `0` | Init container group ID. |
| `service.type` | `ClusterIP` | Service type. |
| `service.port` | `7777` | Service port for TCP/UDP. |
| `service.nodePorts.tcp` | `null` | NodePort for TCP when using NodePort/LoadBalancer. |
| `service.nodePorts.udp` | `null` | NodePort for UDP when using NodePort/LoadBalancer. |
| `env.serverDataDir` | `/opt/starrupture` | `SERVER_DATA_DIR` environment variable. |
| `env.serverSaveDir` | `/home/steam/starrupture/savedata` | `SERVER_SAVE_DIR` environment variable. |
| `env.skipSteamcmdInit` | `false` | Map to `SKIP_STEAMCMD_INIT` (`true` -> `1`, `false` -> `0`). |
| `resources` | `{}` | Container resources requests/limits. |
| `nodeSelector` | `{}` | Node selector. |
| `tolerations` | `[]` | Tolerations for scheduling. |
| `affinity` | `{}` | Affinity rules. |
| `persistence.serverData.enabled` | `true` | Enable server data persistence. |
| `persistence.serverData.existingClaim` | `""` | Use an existing PVC name when set. |
| `persistence.serverData.size` | `30Gi` | PVC size for server data. |
| `persistence.serverData.accessModes` | `["ReadWriteOnce"]` | PVC access modes. |
| `persistence.serverData.storageClassName` | `""` | StorageClass name for the PVC. |
| `persistence.serverData.mountPath` | `/opt/starrupture` | Mount path for server data. |
| `persistence.serverData.pv.hostPath` | `""` | If set, create a hostPath PV (single-node use). |
| `persistence.saveData.enabled` | `true` | Enable save data persistence. |
| `persistence.saveData.existingClaim` | `""` | Use an existing PVC name when set. |
| `persistence.saveData.size` | `5Gi` | PVC size for save data. |
| `persistence.saveData.accessModes` | `["ReadWriteOnce"]` | PVC access modes. |
| `persistence.saveData.storageClassName` | `""` | StorageClass name for the PVC. |
| `persistence.saveData.mountPath` | `/home/steam/starrupture/savedata` | Mount path for save data. |
| `persistence.saveData.pv.hostPath` | `""` | If set, create a hostPath PV (single-node use). |

## 日本語

このチャートは StarRupture 専用サーバを Kubernetes にデプロイします。

### 必須事項
- 永続ボリュームは 2 つ必要です:
  - サーバデータ: `/opt/starrupture`
  - セーブデータ: `/home/steam/starrupture/savedata`
- init コンテナが両方のマウントパスの所有者を `10000:10000` に変更します。
- Service は **TCP/UDP を同一ポート** で公開します。
- `PORT` は常に `service.port` から設定されます。
- `env.skipSteamcmdInit` は boolean です。チャートは `true` -> `SKIP_STEAMCMD_INIT=1`、`false` -> `SKIP_STEAMCMD_INIT=0` に変換します。
- Ingress は不要です。外部公開は `NodePort` または `LoadBalancer` を使用してください。

### インストール / 更新

```bash
helm upgrade --install starrupture deploy/chart
```

### 例

既存 PVC を使う場合:

```bash
helm upgrade --install starrupture deploy/chart \
  --set persistence.serverData.existingClaim=starrupture-server-data \
  --set persistence.saveData.existingClaim=starrupture-save-data
```

hostPath で PV を作成する例（単一ノード想定）:
`persistence.*.pv.hostPath` を設定すると hostPath PV を作成します。空の場合は PVC のみ作成します。

```bash
helm upgrade --install starrupture deploy/chart \
  --set persistence.serverData.pv.hostPath=/data/starrupture \
  --set persistence.saveData.pv.hostPath=/data/starrupture-savedata
```

NodePort で公開し、ポートを変更する場合:

```bash
helm upgrade --install starrupture deploy/chart \
  --set service.type=NodePort \
  --set service.port=32768
```

### StorageClass の注意
- デフォルトの StorageClass を使う場合は `storageClassName` を空にしてください。
- StorageClass を明示的に空にする場合は `storageClassName` を `-` に設定してください。

### Values（デフォルト）

| キー | デフォルト | 説明 |
| --- | --- | --- |
| `replicaCount` | `1` | Deployment のレプリカ数。 |
| `image.repository` | `michibiki/starrupture-dedicated-server` | コンテナイメージのリポジトリ。 |
| `image.tag` | `latest` | コンテナイメージのタグ。 |
| `image.pullPolicy` | `IfNotPresent` | イメージの取得ポリシー。 |
| `imagePullSecrets` | `[]` | イメージ取得用 Secret 名の配列。 |
| `nameOverride` | `""` | チャート名の上書き。 |
| `fullnameOverride` | `""` | リリース名の完全上書き。 |
| `serviceAccount.create` | `true` | ServiceAccount を作成するか。 |
| `serviceAccount.name` | `""` | 既存の ServiceAccount 名を指定する場合。 |
| `podAnnotations` | `{}` | Pod の追加アノテーション。 |
| `podLabels` | `{}` | Pod の追加ラベル。 |
| `podSecurityContext.fsGroup` | `10000` | ボリュームの fsGroup。 |
| `securityContext.runAsUser` | `10000` | コンテナのユーザ ID。 |
| `securityContext.runAsGroup` | `10000` | コンテナのグループ ID。 |
| `securityContext.runAsNonRoot` | `true` | 非 root を要求するか。 |
| `initContainer.enabled` | `true` | 所有者変更用 init コンテナを有効化。 |
| `initContainer.image` | `busybox:1.36` | init コンテナのイメージ。 |
| `initContainer.pullPolicy` | `IfNotPresent` | init コンテナの取得ポリシー。 |
| `initContainer.securityContext.runAsUser` | `0` | init コンテナのユーザ ID。 |
| `initContainer.securityContext.runAsGroup` | `0` | init コンテナのグループ ID。 |
| `service.type` | `ClusterIP` | Service の種別。 |
| `service.port` | `7777` | TCP/UDP の Service ポート。 |
| `service.nodePorts.tcp` | `null` | NodePort/LoadBalancer 時の TCP NodePort。 |
| `service.nodePorts.udp` | `null` | NodePort/LoadBalancer 時の UDP NodePort。 |
| `env.serverDataDir` | `/opt/starrupture` | `SERVER_DATA_DIR` 環境変数。 |
| `env.serverSaveDir` | `/home/steam/starrupture/savedata` | `SERVER_SAVE_DIR` 環境変数。 |
| `env.skipSteamcmdInit` | `false` | `SKIP_STEAMCMD_INIT` へ変換（`true` -> `1`, `false` -> `0`）。 |
| `resources` | `{}` | コンテナのリソース要求/制限。 |
| `nodeSelector` | `{}` | ノードセレクタ。 |
| `tolerations` | `[]` | スケジューリングの許容設定。 |
| `affinity` | `{}` | アフィニティ設定。 |
| `persistence.serverData.enabled` | `true` | サーバデータの永続化を有効化。 |
| `persistence.serverData.existingClaim` | `""` | 既存の PVC 名を使う場合。 |
| `persistence.serverData.size` | `30Gi` | サーバデータ用 PVC サイズ。 |
| `persistence.serverData.accessModes` | `["ReadWriteOnce"]` | PVC のアクセスモード。 |
| `persistence.serverData.storageClassName` | `""` | PVC の StorageClass 名。 |
| `persistence.serverData.mountPath` | `/opt/starrupture` | サーバデータのマウントパス。 |
| `persistence.serverData.pv.hostPath` | `""` | 設定時に hostPath PV を作成（単一ノード向け）。 |
| `persistence.saveData.enabled` | `true` | セーブデータの永続化を有効化。 |
| `persistence.saveData.existingClaim` | `""` | 既存の PVC 名を使う場合。 |
| `persistence.saveData.size` | `5Gi` | セーブデータ用 PVC サイズ。 |
| `persistence.saveData.accessModes` | `["ReadWriteOnce"]` | PVC のアクセスモード。 |
| `persistence.saveData.storageClassName` | `""` | PVC の StorageClass 名。 |
| `persistence.saveData.mountPath` | `/home/steam/starrupture/savedata` | セーブデータのマウントパス。 |
| `persistence.saveData.pv.hostPath` | `""` | 設定時に hostPath PV を作成（単一ノード向け）。 |
