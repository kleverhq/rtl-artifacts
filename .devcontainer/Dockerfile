ARG RISCV_XPACK_VERSION=14.2.0-3
ARG VERILATOR_VERSION=v5.042
ARG SLANG_SERVER_VERSION=v0.2.1
ARG SURFER_VERSION=v0.6.0
ARG RUST_VERSION=1.93.0
ARG OPENCODE_VERSION=1.1.53
ARG PRECOMMIT_VERSION=4.5.1
ARG COMMITIZEN_VERSION=4.12.1
ARG MODELSIM_INSTALLER=ModelSimSetup-20.1.0.711-linux.run
ARG MODELSIM_INSTALLER_URL=https://downloads.intel.com/akdlm/software/acdsinst/20.1std/711/ib_installers/ModelSimSetup-20.1.0.711-linux.run

ARG VERILATOR_INSTALL=/opt/verilator
ARG SLANG_SERVER_INSTALL=/opt/slang-server
ARG SURFER_INSTALL=/opt/surfer
ARG RISCV_INSTALL=/opt/riscv
ARG MODELSIM_INSTALL=/opt/modelsim

# ---- Verilator Builder -------------------------------------------------------
FROM ubuntu:24.04 AS verilator_builder

ARG VERILATOR_VERSION
ARG VERILATOR_INSTALL

ENV DEBIAN_FRONTEND=noninteractive
ENV VERILATOR_INSTALL=${VERILATOR_INSTALL}

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    help2man \
    perl \
    python3 \
    make \
    autoconf \
    g++ \
    mold \
    flex \
    bison \
    ccache \
    libfl2 \
    libfl-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN git clone --branch ${VERILATOR_VERSION} --depth 1 https://github.com/verilator/verilator.git /tmp/verilator && \
    cd /tmp/verilator && \
    autoconf && \
    ./configure --prefix ${VERILATOR_INSTALL} && \
    make -j"$(nproc)" && \
    make install && \
    rm -rf /tmp/verilator

# ---- Modelsim Installer ------------------------------------------------------
FROM ubuntu:24.04 AS modelsim_installer

ARG MODELSIM_INSTALLER
ARG MODELSIM_INSTALLER_URL
ARG MODELSIM_INSTALL

ENV DEBIAN_FRONTEND=noninteractive
ENV MODELSIM_INSTALLER=${MODELSIM_INSTALLER}
ENV MODELSIM_INSTALLER_URL=${MODELSIM_INSTALLER_URL}
ENV MODELSIM_INSTALL=${MODELSIM_INSTALL}

RUN dpkg --add-architecture i386 && \
    echo "deb http://security.ubuntu.com/ubuntu focal-security main universe" > /etc/apt/sources.list.d/ubuntu-focal-sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    wget \
    libc6:i386 \
    libxtst6:i386 \
    libncurses5:i386 \
    libxft2:i386 \
    libstdc++6:i386 \
    libc6-dev-i386 \
    lib32z1 \
    libqt5xml5 \
    liblzma-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget -O /tmp/${MODELSIM_INSTALLER} ${MODELSIM_INSTALLER_URL} && \
    chmod +x /tmp/${MODELSIM_INSTALLER} && \
    /tmp/${MODELSIM_INSTALLER} --mode unattended --accept_eula 1 \
        --installdir ${MODELSIM_INSTALL} --unattendedmodeui none && \
    chmod -R a+rX ${MODELSIM_INSTALL} && \
    rm -f /tmp/${MODELSIM_INSTALLER}

# ---- Slang-server Builder ----------------------------------------------------
FROM ubuntu:24.04 AS slang_server_builder

ARG SLANG_SERVER_VERSION
ARG SLANG_SERVER_INSTALL

ENV DEBIAN_FRONTEND=noninteractive
ENV SLANG_SERVER_INSTALL=${SLANG_SERVER_INSTALL}

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    cmake \
    g++ \
    ninja-build \
    python3 \
    python3-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN git clone --branch ${SLANG_SERVER_VERSION} --depth 1 https://github.com/hudson-trading/slang-server.git /tmp/slang-server && \
    cd /tmp/slang-server && \
    git submodule update --init --recursive --depth 1 && \
    cmake -B build -DCMAKE_BUILD_TYPE=Release -G Ninja && \
    cmake --build build --target slang_server && \
    mkdir -p ${SLANG_SERVER_INSTALL}/bin && \
    cp build/bin/slang-server ${SLANG_SERVER_INSTALL}/bin/ && \
    rm -rf /tmp/slang-server

# ---- Surfer Builder ----------------------------------------------------------
FROM ubuntu:24.04 AS surfer_builder

ARG SURFER_INSTALL
ARG RUST_VERSION
ARG SURFER_VERSION

ENV DEBIAN_FRONTEND=noninteractive
ENV SURFER_INSTALL=${SURFER_INSTALL} \
    RUSTUP_HOME=/opt/rustup \
    CARGO_HOME=/opt/cargo \
    RUST_VERSION=${RUST_VERSION}

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    pkg-config \
    libssl-dev \
    build-essential && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --profile minimal && \
    ${CARGO_HOME}/bin/rustup toolchain install ${RUST_VERSION} --profile minimal && \
    ${CARGO_HOME}/bin/rustup default ${RUST_VERSION}

RUN ${CARGO_HOME}/bin/cargo install --locked \
    --git https://gitlab.com/surfer-project/surfer.git \
    --tag ${SURFER_VERSION} \
    --root ${SURFER_INSTALL} \
    surfer

# ---- RISC-V Toolchain Builder ------------------------------------------------
FROM ubuntu:24.04 AS riscv_toolchain_builder

ARG RISCV_XPACK_VERSION
ARG RISCV_INSTALL

ENV DEBIAN_FRONTEND=noninteractive
ENV RISCV_INSTALL=${RISCV_INSTALL}
ENV RISCV_TOOLCHAIN_INSTALL=${RISCV_INSTALL}/xpack-riscv-none-elf-gcc-${RISCV_XPACK_VERSION}

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL -o /tmp/riscv-toolchain.tar.gz \
    "https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/download/v${RISCV_XPACK_VERSION}/xpack-riscv-none-elf-gcc-${RISCV_XPACK_VERSION}-linux-x64.tar.gz" && \
    mkdir -p ${RISCV_INSTALL} && \
    tar -xzf /tmp/riscv-toolchain.tar.gz -C ${RISCV_INSTALL} && \
    rm -f /tmp/riscv-toolchain.tar.gz

# ---- Main --------------------------------------------------------------------
FROM ubuntu:24.04

ARG RISCV_XPACK_VERSION
ARG VERILATOR_INSTALL
ARG SLANG_SERVER_INSTALL
ARG SURFER_INSTALL
ARG RISCV_INSTALL
ARG MODELSIM_INSTALL
ARG OPENCODE_VERSION
ARG PRECOMMIT_VERSION
ARG COMMITIZEN_VERSION

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV VERILATOR_INSTALL=${VERILATOR_INSTALL}
ENV SLANG_SERVER_INSTALL=${SLANG_SERVER_INSTALL}
ENV SURFER_INSTALL=${SURFER_INSTALL}
ENV RISCV_INSTALL=${RISCV_INSTALL}
ENV MODELSIM_INSTALL=${MODELSIM_INSTALL}
ENV RISCV_TOOLCHAIN_INSTALL=${RISCV_INSTALL}/xpack-riscv-none-elf-gcc-${RISCV_XPACK_VERSION}
ENV ADD_LDFLAGS="-lc -lnosys -Wl,--defsym=end=_end"
ENV WINIT_UNIX_BACKEND=x11

RUN dpkg --add-architecture i386 && \
    echo "deb http://security.ubuntu.com/ubuntu focal-security main universe" > /etc/apt/sources.list.d/ubuntu-focal-sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    make \
    libatomic1 \
    openssl \
    libssl-dev \
    pkg-config \
    g++ \
    mold \
    ccache \
    locales \
    nano \
    openssh-client \
    bash-completion \
    libx11-xcb1 \
    libc6:i386 \
    libxtst6:i386 \
    libncurses5:i386 \
    libxft2:i386 \
    libstdc++6:i386 \
    libc6-dev-i386 \
    lib32z1 \
    libqt5xml5 \
    liblzma-dev \
    libxkbcommon-x11-0 \
    libegl1 \
    libgl1 \
    libglx-mesa0 \
    libgl1-mesa-dri \
    jq \
    ripgrep \
    gh \
    perl-doc \
    z3 \
    gtkwave \
    python3 \
    pipx && \
    locale-gen en_US.UTF-8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=verilator_builder ${VERILATOR_INSTALL} ${VERILATOR_INSTALL}
COPY --from=slang_server_builder ${SLANG_SERVER_INSTALL} ${SLANG_SERVER_INSTALL}
COPY --from=surfer_builder ${SURFER_INSTALL} ${SURFER_INSTALL}
COPY --from=riscv_toolchain_builder ${RISCV_INSTALL} ${RISCV_INSTALL}
COPY --from=modelsim_installer ${MODELSIM_INSTALL} ${MODELSIM_INSTALL}

RUN for src in ${RISCV_TOOLCHAIN_INSTALL}/bin/riscv-none-elf-*; do \
        dst="/usr/local/bin/$(basename "$src" | sed 's/^riscv-none-elf-/riscv64-unknown-elf-/')"; \
        ln -sf "$src" "$dst"; \
    done

RUN if ! id -u ubuntu >/dev/null 2>&1; then useradd -m -s /bin/bash ubuntu; fi
RUN mkdir -p /workspaces && chown ubuntu:ubuntu /workspaces && chmod 775 /workspaces

ENV PATH="/home/ubuntu/.local/bin:${MODELSIM_INSTALL}/modelsim_ase/bin:${VERILATOR_INSTALL}/bin:${SLANG_SERVER_INSTALL}/bin:${SURFER_INSTALL}/bin:${RISCV_TOOLCHAIN_INSTALL}/bin:${PATH}"

USER ubuntu

RUN curl -fsSL https://opencode.ai/install | bash -s -- --version ${OPENCODE_VERSION}
RUN pipx install pre-commit==${PRECOMMIT_VERSION} && \
    pipx install commitizen==${COMMITIZEN_VERSION}
