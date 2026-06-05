ARG TOOL_IMAGE_BASE=ubuntu:24.04
FROM ${TOOL_IMAGE_BASE} AS riscv_toolchain_builder

ARG RISCV_XPACK_VERSION=14.2.0-3
ARG RISCV_INSTALL=/opt/riscv

ENV DEBIAN_FRONTEND=noninteractive
ENV RISCV_TOOLCHAIN_INSTALL=${RISCV_INSTALL}/xpack-riscv-none-elf-gcc-${RISCV_XPACK_VERSION}

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fL --retry 5 --retry-all-errors --retry-delay 10 --connect-timeout 60 -o /tmp/riscv-toolchain.tar.gz \
    "https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/download/v${RISCV_XPACK_VERSION}/xpack-riscv-none-elf-gcc-${RISCV_XPACK_VERSION}-linux-x64.tar.gz" && \
    mkdir -p ${RISCV_INSTALL} && \
    tar -xzf /tmp/riscv-toolchain.tar.gz -C ${RISCV_INSTALL} && \
    rm -f /tmp/riscv-toolchain.tar.gz

FROM ${TOOL_IMAGE_BASE}

ARG RISCV_XPACK_VERSION=14.2.0-3
ARG RISCV_INSTALL=/opt/riscv

ENV DEBIAN_FRONTEND=noninteractive
ENV RISCV_TOOLCHAIN_INSTALL=${RISCV_INSTALL}/xpack-riscv-none-elf-gcc-${RISCV_XPACK_VERSION}
ENV PATH=${RISCV_TOOLCHAIN_INSTALL}/bin:${PATH}

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bash \
    build-essential \
    ca-certificates \
    git \
    gtkwave \
    iverilog \
    make \
    python3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=riscv_toolchain_builder ${RISCV_INSTALL} ${RISCV_INSTALL}

RUN for src in ${RISCV_TOOLCHAIN_INSTALL}/bin/riscv-none-elf-*; do \
        dst="/usr/local/bin/$(basename "$src" | sed 's/^riscv-none-elf-/riscv64-unknown-elf-/')"; \
        ln -sf "$src" "$dst"; \
    done
