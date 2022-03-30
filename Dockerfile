# Install SnapServer on minimal OS - script v4.0.1 [2022-03-30]
ARG ALPINE_BASE="3.12"

# SnapCast build stage
FROM alpine:${ALPINE_BASE} as compiler
RUN <<EOF
    apk -U add \
    alsa-lib-dev \
    avahi-dev \
    bash \
    boost-dev \
    build-base \
    ccache \
    cmake \
    expat-dev \
    flac-dev \
    git \
    libvorbis-dev \
    opus-dev \
    soxr-dev
EOF

ARG VERSION=main
RUN <<EOF 
    git clone --recursive https://github.com/badaix/snapcast.git
    cd snapcast

    cmake -S . -B build \
        -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
        -DBUILD_WITH_PULSE=OFF \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_CLIENT=OFF \
        ..
    cmake --build build --parallel 3
EOF

# SnapWeb build stage
FROM node:alpine as snapweb

RUN <<EOF
    apk -U add build-base git
    npm install -g typescript
    git clone https://github.com/badaix/snapweb
    make -C snapweb
EOF

# Final stage
FROM alpine:${ALPINE_BASE}
LABEL maintainer="Saiyato"

RUN <<EOF
    apk add --no-cache \
        alsa-lib \
        avahi-libs \
        expat \
        flac \
        libvorbis \
        opus \
        soxr

EOF

COPY --from=compiler snapcast/bin/snapserver /usr/local/bin/
COPY --from=snapweb snapweb/dist/ /usr/share/snapserver/snapweb

EXPOSE 1704
EXPOSE 1705
EXPOSE 1780

ENTRYPOINT ["snapserver"]
