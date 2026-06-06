ARG TOOL_IMAGE_BASE=ubuntu:24.04
FROM ${TOOL_IMAGE_BASE} AS verilator_builder

ARG VERILATOR_VERSION=v5.042
ARG VERILATOR_INSTALL=/opt/verilator

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    autoconf \
    bison \
    ca-certificates \
    ccache \
    flex \
    g++ \
    git \
    help2man \
    libfl-dev \
    libfl2 \
    make \
    perl \
    python3 \
    zlib1g-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN git clone --branch ${VERILATOR_VERSION} --depth 1 https://github.com/verilator/verilator.git /tmp/verilator && \
    cd /tmp/verilator && \
    autoconf && \
    ./configure --prefix ${VERILATOR_INSTALL} && \
    make -j"$(nproc)" && \
    make install && \
    rm -rf /tmp/verilator

FROM ${TOOL_IMAGE_BASE}

ARG MINIFORGE_VERSION=26.1.0-0
ARG CONDA_INSTALL=/opt/conda
ARG VERILATOR_INSTALL=/opt/verilator

ENV DEBIAN_FRONTEND=noninteractive
ENV CONDA_INSTALL=${CONDA_INSTALL}
ENV PATH=${VERILATOR_INSTALL}/bin:${CONDA_INSTALL}/bin:${PATH}

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    bash \
    bison \
    bzip2 \
    build-essential \
    ca-certificates \
    ccache \
    curl \
    device-tree-compiler \
    file \
    flex \
    git \
    libglib2.0-dev \
    libpixman-1-dev \
    libtool \
    make \
    patch \
    perl \
    pkg-config \
    python3 \
    python3-pip \
    unzip \
    wget \
    zlib1g-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fL --retry 5 --retry-all-errors --retry-delay 10 --connect-timeout 60 -o /tmp/miniforge.sh \
    "https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE_VERSION}/Miniforge3-${MINIFORGE_VERSION}-Linux-x86_64.sh" && \
    bash /tmp/miniforge.sh -b -p ${CONDA_INSTALL} && \
    rm -f /tmp/miniforge.sh && \
    conda install -n base -y conda-libmamba-solver && \
    conda config --system --set solver libmamba && \
    conda clean -afy

COPY --from=verilator_builder ${VERILATOR_INSTALL} ${VERILATOR_INSTALL}
