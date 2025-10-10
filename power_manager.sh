#!/usr/bin/env bash

# 操作対象のコンテナ名
CONTAINER_NAME="test-power"

echo "--- Power Manager (Signal Mode) Started ---"
echo "Will send signals to container '$CONTAINER_NAME' to switch modes."

while true; do
    # 偽の電源情報から、あるべき状態を取得
    REQUIRED_STATUS=$(./fake_power_source.sh)
    
    # あるべき状態に応じて、送信するシグナルを決定
    if [[ "$REQUIRED_STATUS" == "AC" ]]; then
        TARGET_SIGNAL="SIGUSR1" # フルパワーモード
    else
        TARGET_SIGNAL="SIGUSR2" # ローパワーモード
    fi

    # 前回送信したシグナルを記録しておき、状態変化があった場合のみ送信する
    STATE_FILE="/tmp/power_manager_last_signal.txt"
    LAST_SIGNAL=$(cat "$STATE_FILE" 2>/dev/null)
    
    if [[ "$LAST_SIGNAL" != "$TARGET_SIGNAL" ]]; then
        echo "State change required. Sending $TARGET_SIGNAL to container..."
        # docker kill --signal コマンドでコンテナにシグナルを送信
        sudo docker kill --signal="$TARGET_SIGNAL" "$CONTAINER_NAME"
        # 送信したシグナルを記録
        echo "$TARGET_SIGNAL" > "$STATE_FILE"
    fi

    sleep 10
done
