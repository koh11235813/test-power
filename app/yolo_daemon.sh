#!/usr/bin/env bash

echo "--- YOLO Daemon Started ---"
# デフォルトモードをLOWに設定
CURRENT_MODE="LOW"
YOLO_PID=0

# --- シグナルを検知した時の処理を定義 ---

# SIGUSR1 (フルパワー)を受け取った時の関数
mode_full() {
    echo "[Signal] Received request to switch to FULL power."
    CURRENT_MODE="FULL"
    # 現在実行中のYOLOプロセスがあれば、終了させてループを再起動させる
    if [[ $YOLO_PID -ne 0 ]]; then kill $YOLO_PID; fi
}

# SIGUSR2 (ローパワー)を受け取った時の関数
mode_low() {
    echo "[Signal] Received request to switch to LOW power."
    CURRENT_MODE="LOW"
    # 現在実行中のYOLOプロセスがあれば、終了させる
    if [[ $YOLO_PID -ne 0 ]]; then kill $YOLO_PID; fi
}

# --- シグナルの受付設定 (trap) ---
# SIGUSR1 を受け取ったら `mode_full` 関数を実行
trap 'mode_full' SIGUSR1
# SIGUSR2 を受け取ったら `mode_low` 関数を実行
trap 'mode_low' SIGUSR2


# --- メインループ ---
while true; do
    echo "--------------------------------"
    echo "Loop Start. Current Mode: $CURRENT_MODE"

    # モードに応じて実行するYOLOコマンドを決定
    if [[ "$CURRENT_MODE" == "FULL" ]]; then
        yolo segment predict model='nvidia/segformer-b5-finetuned-ade-640-640' source='https://ultralytics.com/images/bus.jpg' &
    else
        yolo segment predict model='nvidia/segformer-b0-finetuned-ade-512-512' source='https://ultralytics.com/images/bus.jpg' &
    fi
    
    # バックグラウンドで実行したYOLOのプロセスIDを保存
    YOLO_PID=$!
    echo "Started YOLO (PID: $YOLO_PID) in $CURRENT_MODE mode."

    # YOLOプロセスが終了するのを待つ (正常終了 or killされるまで)
    wait $YOLO_PID
    YOLO_PID=0 # PIDをリセット
    
    echo "YOLO process finished. Restarting loop after a short delay."
    sleep 3 # 予期せぬ連続ループを防ぐための小休止
done
