#!/usr/bin/env bash

# スクリプトのいずれかの行でエラーが発生したら、直ちに終了する
set -e

# スクリプトが置かれているディレクトリに移動する
cd "$(dirname "$0")"

TARGET_SERVICE=""
POWER_SOURCE_MESSAGE=""

# OSを判定
#if [[ "$(uname)" == "Linux" ]]; then
#    # ACアダプタのパスを検索
#    AC_ADAPTER=$(find /sys/class/power_supply/ -name 'AC*' -o -name 'ADP*' | head -n 1)
#
#    # ACアダプタが見つかり、かつオンライン状態かチェック
#    if [[ -n "$AC_ADAPTER" && -f "$AC_ADAPTER/online" && "$(cat "$AC_ADAPTER/online")" == "1" ]]; then
#        TARGET_SERVICE="app-ac"
#        POWER_SOURCE_MESSAGE="AC Power"
#    else
#        TARGET_SERVICE="app-battery"
#        POWER_SOURCE_MESSAGE="Battery Power (or status unknown)"
#    fi
#
#elif [[ "$(uname)" == "Darwin" ]]; then
#    # macOSの電源状態をチェック
#    if pmset -g batt | grep -q "AC Power"; then
#        TARGET_SERVICE="app-ac"
#        POWER_SOURCE_MESSAGE="AC Power"
#    else
#        TARGET_SERVICE="app-battery"
#        POWER_SOURCE_MESSAGE="Battery Power"
#    fi
#else
#    echo "Unsupported OS: $(uname)"
#    exit 1
#fi

# --- [テスト用] 偽の電源情報を使ってターゲットサービスを決定 ---

# 偽の電源情報を生成するスクリプトを実行し、出力を取得
FAKE_STATUS=$(./fake_power_source.sh)
echo "Acquired fake power status: $FAKE_STATUS"

# 偽のステータスに応じてサービスを決定
if [[ "$FAKE_STATUS" == "AC" ]]; then
    TARGET_SERVICE="app-ac"
    POWER_SOURCE_MESSAGE="Fake AC Power"
else
    TARGET_SERVICE="app-battery"
    POWER_SOURCE_MESSAGE="Fake Battery Power"
fi

# --- Dockerサービスの管理 ---

# 現在実行中のサービス名を取得 (コンテナが存在する場合のみ)
CURRENT_SERVICE=""
if docker ps -q --filter "name=my-app-container" | grep -q .; then
    CURRENT_SERVICE=$(docker inspect my-app-container --format '{{ index .Config.Labels "com.docker.compose.service" }}')
fi

# 実行中のサービスと目標のサービスが同じなら、何もせず終了
if [[ "$CURRENT_SERVICE" == "$TARGET_SERVICE" ]]; then
    echo "No change required. Power: $POWER_SOURCE_MESSAGE. Service: '$CURRENT_SERVICE' is already active."
    exit 0
fi

echo "Power source: $POWER_SOURCE_MESSAGE. Switching from '$CURRENT_SERVICE' to '$TARGET_SERVICE'."

# 既存のサービスをすべて停止
docker-compose down --remove-orphans

# 目標のサービスを起動
echo "Starting '$TARGET_SERVICE'..."
docker-compose up -d "$TARGET_SERVICE"

echo "Service '$TARGET_SERVICE' started successfully."

