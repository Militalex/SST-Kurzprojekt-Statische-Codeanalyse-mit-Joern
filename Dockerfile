# syntax=docker/dockerfile:1.5

# ==============================================================================
# Stage 1: Typst Builder
# ==============================================================================
ARG VARIANT
FROM mcr.microsoft.com/devcontainers/rust:${VARIANT} as typst-builder
ARG TYPST_VERSION
ENV CARGO_REGISTRIES_CRATES_IO_PROTOCOL="sparse"

RUN git clone --branch ${TYPST_VERSION} --depth 1 https://github.com/typst/typst.git /typst
WORKDIR /typst
RUN cargo update
RUN cargo build -p typst-cli --release

# ==============================================================================
# Stage 2: Typstyle Builder (Lädt die neueste stabile Version von crates.io)
# ==============================================================================
FROM mcr.microsoft.com/devcontainers/rust:${VARIANT} as typstyle-builder
ENV CARGO_REGISTRIES_CRATES_IO_PROTOCOL="sparse"

# Holt und baut die aktuelle Stable-Release ohne Umweg über Git-Tags
RUN cargo install --locked typstyle --root /typstyle

# ==============================================================================
# Stage 3: Final Toolchain Target (Java + SAST + Typst)
# ==============================================================================
FROM eclipse-temurin:17-jdk

ENV DEBIAN_FRONTEND=noninteractive

# Base toolchain: Maven, git, curl, ca-certificates, sudo
RUN apt-get update && apt-get install -y --no-install-recommends \
        maven \
        git \
        curl \
        ca-certificates \
        gnupg \
        sudo \
    && rm -rf /var/lib/apt/lists/*

# Developer shell & editor tools
RUN apt-get update && apt-get install -y --no-install-recommends \
        vim \
        zsh \
        less \
        tree \
        jq \
        cloc \
    && rm -rf /var/lib/apt/lists/*

# GitLab CLI (glab)
RUN ARCH=$(dpkg --print-architecture) \
    && URL=$(curl -fsSL "https://gitlab.com/api/v4/projects/gitlab-org%2Fcli/releases?per_page=1" \
        | grep -oE "\"direct_asset_url\":\"[^\"]*linux_${ARCH}\\.deb\"" \
        | head -n 1 \
        | sed 's/.*"direct_asset_url":"\(.*\)"/\1/') \
    && curl -fsSL "$URL" -o /tmp/glab.deb \
    && apt-get update && apt-get install -y --no-install-recommends /tmp/glab.deb \
    && rm /tmp/glab.deb \
    && rm -rf /var/lib/apt/lists/*

# GitHub CLI (gh)
RUN ARCH=$(dpkg --print-architecture) \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
         -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=${ARCH} signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update && apt-get install -y --no-install-recommends gh \
    && rm -rf /var/lib/apt/lists/*

# Scala build tools (sbt) — Metals IDE support for .sc/.scala files
RUN curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" \
        | gpg --dearmor -o /etc/apt/keyrings/sbt.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/sbt.gpg] https://repo.scala-sbt.org/scalasbt/debian all main" \
        > /etc/apt/sources.list.d/sbt.list \
    && apt-get update && apt-get install -y --no-install-recommends sbt \
    && rm -rf /var/lib/apt/lists/*

# Joern code-analysis platform (~2 GB download)
RUN apt-get update && apt-get install -y --no-install-recommends unzip \
    && curl -fsSL "https://github.com/joernio/joern/releases/latest/download/joern-install.sh" -o /tmp/joern-install.sh \
    && chmod +x /tmp/joern-install.sh \
    && /tmp/joern-install.sh --reinstall --install-dir=/opt/joern --link-dir=/usr/local/bin \
    && rm /tmp/joern-install.sh \
    && rm -rf /var/lib/apt/lists/*

# Semgrep static-analysis tool
RUN apt-get update && apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        python3-venv \
    && python3 -m venv /opt/semgrep-venv \
    && /opt/semgrep-venv/bin/pip install --no-cache-dir semgrep \
    && ln -s /opt/semgrep-venv/bin/semgrep /usr/local/bin/semgrep \
    && rm -rf /var/lib/apt/lists/*

# Scala CLI für VS Code Metals Autocomplete
RUN curl -sSLf https://scala-cli.virtuslab.org/get | sh

# ---- Typst & Typstyle aus Builder-Stages kopieren ----
COPY --from=typst-builder /typst/target/release/typst /usr/local/bin/typst
COPY --from=typstyle-builder /typstyle/bin/typstyle /usr/local/bin/typstyle

# scc (Sloc, Cloc and Code) über feste URLs installieren
RUN ARCH=$(dpkg --print-architecture) \
    && if [ "$ARCH" = "amd64" ]; then \
        curl -fsSL "https://github.com/boyter/scc/releases/download/v3.4.0/scc_Linux_x86_64.tar.gz" -o /tmp/scc.tar.gz; \
       else \
        curl -fsSL "https://github.com/boyter/scc/releases/download/v3.4.0/scc_Linux_arm64.tar.gz" -o /tmp/scc.tar.gz; \
       fi \
    && tar -xzf /tmp/scc.tar.gz -C /usr/local/bin scc \
    && rm /tmp/scc.tar.gz

# Verifiziere Erreichbarkeit aller installierten Werkzeuge
RUN joern --version \
    && semgrep --version \
    && java --version \
    && mvn --version \
    && typst --version \
    && typstyle --version \
    && cloc --version \
    && scc --version

CMD ["bash"]
