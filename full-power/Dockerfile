FROM ubuntu:22.04

# 対話形式のプロンプトを無効化
ENV DEBIAN_FRONTEND=noninteractive

# Python3, pip, gitなどをインストール
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3-pip \
    git \
    # 不要なキャッシュを削除
    && rm -rf /var/lib/apt/lists/*

# Ultralyticsライブラリをインストール (PyTorchなども自動で入ります)
RUN pip3 install ultralytics

COPY hogehoge_full.sh /hogehoge.sh
RUN chmod +x /hogehoge.sh

CMD ["/hogehoge.sh"]
