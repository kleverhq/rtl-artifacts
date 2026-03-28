ARG RISCV_XPACK_VERSION=14.2.0-3
ARG VERILATOR_VERSION=v5.042
ARG SLANG_SERVER_VERSION=v0.2.1
ARG SURFER_VERSION=v0.6.0
ARG RUST_VERSION=1.93.0
ARG OPENCODE_VERSION=1.2.27
ARG PRECOMMIT_VERSION=4.5.1
ARG COMMITIZEN_VERSION=4.12.1
ARG MINIFORGE_VERSION=26.1.0-0
ARG CHIPYARD_VERSION=1.13.0
ARG PICORV32_COMMIT=87c89acc18994c8cf9a2311e871818e87d304568
ARG SCR1_COMMIT=ebb5e3551a9d93c0ee95f0b767dd878b8927e702

ARG VERILATOR_INSTALL=/opt/verilator
ARG SLANG_SERVER_INSTALL=/opt/slang-server
ARG SURFER_INSTALL=/opt/surfer
ARG RISCV_INSTALL=/opt/riscv
ARG CONDA_INSTALL=/opt/conda
ARG CHIPYARD_INSTALL=/opt/chipyard
ARG PICORV32_INSTALL=/opt/picorv32
ARG SCR1_INSTALL=/opt/scr1

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

# ---- RTL Sources Base Builder ------------------------------------------------
FROM ubuntu:24.04 AS rtl_sources_base_builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ---- PicoRV32 Sources Builder ------------------------------------------------
FROM rtl_sources_base_builder AS picorv32_sources_builder

ARG PICORV32_COMMIT
ARG PICORV32_INSTALL

ENV PICORV32_INSTALL=${PICORV32_INSTALL}

RUN git clone https://github.com/YosysHQ/picorv32.git ${PICORV32_INSTALL} && \
    cd ${PICORV32_INSTALL} && \
    git checkout ${PICORV32_COMMIT} && \
    rm -rf .git

# ---- SCR1 Sources Builder ----------------------------------------------------
FROM rtl_sources_base_builder AS scr1_sources_builder

ARG SCR1_COMMIT
ARG SCR1_INSTALL

ENV SCR1_INSTALL=${SCR1_INSTALL}

RUN git clone --recurse-submodules https://github.com/syntacore/scr1.git ${SCR1_INSTALL} && \
    cd ${SCR1_INSTALL} && \
    git checkout ${SCR1_COMMIT} && \
    git submodule update --init --recursive && \
    find ${SCR1_INSTALL} -name .git -type d -prune -exec rm -rf {} + && \
    find ${SCR1_INSTALL} -name .git -type f -delete

# ---- Chipyard Builder --------------------------------------------------------
FROM ubuntu:24.04 AS chipyard_builder

ARG MINIFORGE_VERSION
ARG CHIPYARD_VERSION
ARG CONDA_INSTALL
ARG CHIPYARD_INSTALL

ENV DEBIAN_FRONTEND=noninteractive
ENV CONDA_INSTALL=${CONDA_INSTALL}
ENV CHIPYARD_INSTALL=${CHIPYARD_INSTALL}
ENV PATH=${CONDA_INSTALL}/bin:${PATH}

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    bzip2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL -o /tmp/miniforge.sh \
    "https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE_VERSION}/Miniforge3-${MINIFORGE_VERSION}-Linux-x86_64.sh" && \
    bash /tmp/miniforge.sh -b -p ${CONDA_INSTALL} && \
    rm -f /tmp/miniforge.sh && \
    conda install -n base -y conda-libmamba-solver && \
    conda config --system --set solver libmamba && \
    conda clean -afy

RUN git clone --branch ${CHIPYARD_VERSION} --depth 1 https://github.com/ucb-bar/chipyard.git ${CHIPYARD_INSTALL} && \
    cd ${CHIPYARD_INSTALL} && \
    ./build-setup.sh riscv-tools --skip-ctags --skip-firesim --skip-marshal && \
    conda clean -afy

# ---- Main --------------------------------------------------------------------
FROM ubuntu:24.04

ARG RISCV_XPACK_VERSION
ARG VERILATOR_INSTALL
ARG SLANG_SERVER_INSTALL
ARG SURFER_INSTALL
ARG RISCV_INSTALL
ARG CONDA_INSTALL
ARG CHIPYARD_INSTALL
ARG PICORV32_INSTALL
ARG SCR1_INSTALL
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
ENV RISCV_TOOLCHAIN_INSTALL=${RISCV_INSTALL}/xpack-riscv-none-elf-gcc-${RISCV_XPACK_VERSION}
ENV CONDA_INSTALL=${CONDA_INSTALL}
ENV CHIPYARD_INSTALL=${CHIPYARD_INSTALL}
ENV CHIPYARD_DIR=${CHIPYARD_INSTALL}
ENV PICORV32_INSTALL=${PICORV32_INSTALL}
ENV SCR1_INSTALL=${SCR1_INSTALL}
ENV ADD_LDFLAGS="-lc -lnosys -Wl,--defsym=end=_end"
ENV WINIT_UNIX_BACKEND=x11

RUN apt-get update && \
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
    iverilog \
    python3 \
    pipx && \
    locale-gen en_US.UTF-8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN if ! id -u ubuntu >/dev/null 2>&1; then useradd -m -s /bin/bash ubuntu; fi
RUN mkdir -p /workspaces && chown ubuntu:ubuntu /workspaces && chmod 775 /workspaces
RUN mkdir -p /home/ubuntu/.config /home/ubuntu/.local/share /home/ubuntu/.cache && \
    chown -R ubuntu:ubuntu /home/ubuntu/.config /home/ubuntu/.local /home/ubuntu/.cache

COPY --from=verilator_builder ${VERILATOR_INSTALL} ${VERILATOR_INSTALL}
COPY --from=slang_server_builder ${SLANG_SERVER_INSTALL} ${SLANG_SERVER_INSTALL}
COPY --from=surfer_builder ${SURFER_INSTALL} ${SURFER_INSTALL}
COPY --from=riscv_toolchain_builder ${RISCV_INSTALL} ${RISCV_INSTALL}
COPY --from=picorv32_sources_builder --chown=ubuntu:ubuntu ${PICORV32_INSTALL} ${PICORV32_INSTALL}
COPY --from=scr1_sources_builder --chown=ubuntu:ubuntu ${SCR1_INSTALL} ${SCR1_INSTALL}
COPY --from=chipyard_builder --chown=ubuntu:ubuntu ${CONDA_INSTALL} ${CONDA_INSTALL}
COPY --from=chipyard_builder --chown=ubuntu:ubuntu ${CHIPYARD_INSTALL} ${CHIPYARD_INSTALL}

RUN for src in ${RISCV_TOOLCHAIN_INSTALL}/bin/riscv-none-elf-*; do \
        dst="/usr/local/bin/$(basename "$src" | sed 's/^riscv-none-elf-/riscv64-unknown-elf-/')"; \
        ln -sf "$src" "$dst"; \
    done

ENV PATH="/home/ubuntu/.local/bin:${VERILATOR_INSTALL}/bin:${SLANG_SERVER_INSTALL}/bin:${SURFER_INSTALL}/bin:${RISCV_TOOLCHAIN_INSTALL}/bin:${PATH}:${CONDA_INSTALL}/bin"

USER ubuntu

RUN curl -fsSL https://opencode.ai/install | bash -s -- --version ${OPENCODE_VERSION}
RUN pipx install pre-commit==${PRECOMMIT_VERSION} && \
    pipx install commitizen==${COMMITIZEN_VERSION}
