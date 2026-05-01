ARG BUILD_FROM=debian:bookworm-slim
FROM $BUILD_FROM

ARG NEOFRAME_VERSION=main
ARG NEOFRAME_REPO=deftdawg

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    build-essential \
    python3 \
    pkg-config \
    libcairo2-dev \
    libjpeg-dev \
    libpango1.0-dev \
    libgif-dev \
    librsvg2-dev \
    libpixman-1-dev \
    dnsutils \
    unzip \
    && rm -rf /var/lib/apt/lists/*

ENV BUN_INSTALL=/usr/local
RUN curl -fsSL https://bun.sh/install | bash

RUN git clone --depth 1 --branch "${NEOFRAME_VERSION}" \
    https://github.com/${NEOFRAME_REPO}/neoframe.git /opt/neoframe

# IPv6 seems to be default, this results in 'Connection reset by peer' -> Restrict to IPv4 in /etc/gai.conf
RUN sed -i 's/^#precedence ::ffff:0:0\/96  100/precedence ::ffff:0:0\/96 100/' /etc/gai.conf

WORKDIR /opt/neoframe

RUN bun install
RUN bun run build-cli.ts

COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
