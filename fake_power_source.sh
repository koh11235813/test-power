#!/usr/bin/env bash

# 現在の状態を保存しておくファイル
STATE_FILE="/tmp/power_state.txt"

# 状態ファイルがなければ、最初の状態を「BATTERY」として作成
# (これにより、初回の実行で「AC」が出力される)
if [[ ! -f "$STATE_FILE" ]]; then
    echo "BATTERY" > "$STATE_FILE"
fi

# 現在の状態をファイルから読み込む
CURRENT_STATE=$(cat "$STATE_FILE")

# 状態を反転させて、新しい状態をファイルに書き込み、標準出力にも表示する
if [[ "$CURRENT_STATE" == "AC" ]]; then
    echo "BATTERY" > "$STATE_FILE"
    echo "BATTERY"
else
    echo "AC" > "$STATE_FILE"
    echo "AC"
fi

