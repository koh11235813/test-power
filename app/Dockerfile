FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3.10 \
    python3-pip \
    git \
    libgl1 \
    libglib2.0-0 \
    libpng-dev \
    libjpeg-dev \
    zlib1g-dev \
    ninja-build \
    libopenmpi-dev libpostproc-dev libswscale-dev libavdevice-dev libavfilter-dev libavcodec-dev libavutil-dev \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install  --no-cache-dir torch torchvision timm pillow grpcio grpcio-tools transformers

COPY scripts/ /scripts
RUN chmod -R +x /scripts

CMD ["python3", "/scripts/grpc-server.py"]
