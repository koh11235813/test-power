# test-power

電源モード／実行環境（Jetson or デスクトップGPU）に応じて、適切な Docker 構成でアプリを起動するためのサンプルです。  
`docker-compose.yml`（ベース）に対して、`docker-compose-desktop.yml` または `docker-compose-jetson.yml` を重ねて使います。

> 参考: 電源状態に応じて起動を切り替える `power_manager.sh` と、模擬用の `fake_power_source.sh` を同梱しています。

---

## 必要要件

- Docker / Docker Compose v2
- NVIDIA GPU を使う場合
  - デスクトップ: NVIDIA Driver + NVIDIA Container Toolkit
  - Jetson: JetPack (CUDA あり)

---

## クイックスタート

### 1) リポジトリ取得
```bash
git clone https://github.com/koh11235813/test-power
cd test-power
```

### 2) 起動

#### デスクトップ（dGPU）
```bash
docker-compose -f docker-compose.yml -f docker-compose-desktop.yml up -d --build
```

#### Jetson
```bash
docker-compose -f docker-compose.yml -f docker-compose-jetson.yml up -d --build
```
> ※ Jetson の CUDA パス（例: `/usr/local/cuda-12.6`）のマウント設定は、環境に合わせて必要なら調整してください。

### 3) 停止・ログ
```bash
# 停止・削除
docker-compose -f docker-compose.yml -f docker-compose-<desktop|jetson>.yml down

# 稼働状況
docker compose ps

# ログ追尾（サービス名が app の場合）
docker compose logs -f app
```

---

## 電源モードによる自動切替（任意）

`power_manager.sh` は AC/バッテリーなどの電源状態に応じて、どちらの Compose を起動するかを切り替えるサンプルです。  
テスト用途では `fake_power_source.sh` で電源状態を模擬できます。

```bash
chmod +x power_manager.sh fake_power_source.sh
./power_manager.sh
```

> 例: AC ならデスクトップ用、バッテリーなら Jetson 用を起動…など、手元の運用に合わせて分岐を編集してください。

---

## COMPOSE_FILE を使った省略形（任意）

毎回 `-f` を書かずに済むよう、環境変数で指定できます。

```bash
# 例: デスクトップ
export COMPOSE_FILE=docker-compose.yml:docker-compose-desktop.yml
docker-compose up -d --build
```

---

## ライセンス

`LICENSE` を参照してください。
