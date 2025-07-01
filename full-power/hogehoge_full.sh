#!/bin/bash
echo "--- Starting FULL POWER mode (YOLOv8s) ---"

# 無限ループで推論を実行
while true; do
  echo "[FULL] Running inference with YOLOv8s..."
  # こちらはより高精度な "s" モデルを使用
  yolo predict model=yolov8s.pt source='https://ultralytics.com/images/bus.jpg' save=True
  
  # 待機時間を短くして、より集中的に処理
  sleep 10
done
