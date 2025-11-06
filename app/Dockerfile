FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3.10 \
    python3-pip \
    git \
    \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install ultralytics grpcio grpcio-tools

COPY scripts/ /scripts
RUN chmod -R +x /scripts

CMD ["python3", "/scripts/grpc-server.py"]
