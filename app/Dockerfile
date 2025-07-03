# ベースイメージ
FROM ubuntu:22.04

# 対話形式のプロンプトを無効化
ENV DEBIAN_FRONTEND=noninteractive

# 必要なライブラリをインストール
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3-pip \
    git \
    \
    && rm -rf /var/lib/apt/lists/*

# Ultralyticsライブラリをインストール
RUN pip3 install ultralytics

# デーモンスクリプトをコンテナにコピー
COPY yolo_daemon.sh /yolo_daemon.sh
RUN chmod +x /yolo_daemon.sh

# コンテナ起動時にデーモンスクリプトを実行
CMD ["/yolo_daemon.sh"]
