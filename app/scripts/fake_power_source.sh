#!/usr/bin/env bash

# 各状態を維持する時間（秒）
INTERVAL=60

# 現在のUNIXタイムスタンプ（1970年1月1日からの経過秒数）を取得
TIMESTAMP=$(date +%s)

# タイムスタンプをインターバルで割り、現在の「時間帯ID」を計算
# このIDは30秒ごとに1つずつ増えていく数値になる
CYCLE_ID=$((TIMESTAMP / INTERVAL))

# 時間帯IDが偶数か奇数かで出力を決定する
# これにより、30秒ごとにACとBATTERYが自動で切り替わる
if (( CYCLE_ID % 2 == 0 )); then
  echo "AC"
else
  echo "BATTERY"
fi

