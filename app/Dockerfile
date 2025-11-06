FROM ubuntu:22.04

# 対話形式のプロンプトを無効化
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3.10 \
    python3-pip \
    git \
    \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install ultralytics

COPY grpc-server.py /grpc-server.py
RUN chmod +x grpc-server.py

CMD ["python /grpc-server.py"]
