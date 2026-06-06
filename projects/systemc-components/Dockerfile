ARG TOOL_IMAGE_BASE=ubuntu:24.04
FROM ${TOOL_IMAGE_BASE}

ARG CONAN_VERSION=2.29.0

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=/opt/conan-venv/bin:${PATH}

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    bash \
    bison \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    flex \
    git \
    gtkwave \
    libtool \
    ninja-build \
    patch \
    perl \
    pkg-config \
    python3 \
    python3-pip \
    python3-venv \
    unzip \
    xz-utils \
    zlib1g-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/conan-venv && \
    /opt/conan-venv/bin/python -m pip install --upgrade pip setuptools wheel && \
    /opt/conan-venv/bin/python -m pip install "conan==${CONAN_VERSION}"
