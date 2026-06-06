FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bash \
    build-essential \
    ca-certificates \
    git \
    gtkwave \
    iverilog \
    make \
    perl \
    python3 \
    verilator \
    zlib1g-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
