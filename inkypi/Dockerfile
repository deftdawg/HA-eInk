ARG BUILD_FROM=debian:bookworm-slim
FROM $BUILD_FROM

ARG INKYPI_VERSION=main
ARG INKYPI_REPO=deftdawg

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-venv \
    python3-pip \
    python3-dev \
    libtiff-dev \
    libopenblas-dev \
    libopenjp2-7 \
    libfreetype6-dev \
    fonts-noto-color-emoji \
    swig \
    libheif-dev \
    jq \
    curl \
    git \
    gcc \
    g++ \
    make \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 https://github.com/joan2937/lg /tmp/lg && \
    cd /tmp/lg && make && make install && \
    rm -rf /tmp/lg

WORKDIR /opt/inkypi

RUN git clone --depth 1 --branch "${INKYPI_VERSION}" \
    https://github.com/${INKYPI_REPO}/InkyPi.git /tmp/InkyPi && \
    cp -r /tmp/InkyPi/src/ ./src/ && \
    cp /tmp/InkyPi/install/requirements.txt ./requirements.txt && \
    cp -r /tmp/InkyPi/install/config_base/ ./config_base/ && \
    cp /tmp/InkyPi/install/update_vendors.sh ./update_vendors.sh && \
    rm -rf /tmp/InkyPi

RUN python3 -m venv /opt/inkypi/venv && \
    /opt/inkypi/venv/bin/pip install --upgrade pip setuptools wheel && \
    /opt/inkypi/venv/bin/pip install -r requirements.txt

RUN bash update_vendors.sh

COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
