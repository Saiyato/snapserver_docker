# Install SnapServer on minimal OS - script v3.0.2 [2021-10-03]

# Define architecture (e.g amd64, i386, arm32v6, arm64v8 etc)
ARG ARCHITECTURE="amd64"
# Define Alpine version (default '3.14.2')
ARG ALPINE_BASE="3.14.3"

# SnapCast build stage
FROM ${ARCHITECTURE}/alpine:${ALPINE_BASE} as snapcast
WORKDIR /root
# Dummy file is needed, because there's no conditional copy
COPY dummy qemu-*-static /usr/bin/

RUN apk -U add alsa-lib-dev avahi-dev bash build-base ccache cmake expat-dev flac-dev git libvorbis-dev opus-dev soxr-dev \
 && git clone --recursive https://github.com/badaix/snapcast.git \
 && cd snapcast \
 && wget https://boostorg.jfrog.io/artifactory/main/release/1.78.0/source/boost_1_78_0.tar.bz2 && tar -xjf boost_1_78_0.tar.bz2 \
 && cmake -S . -B build -DBOOST_ROOT=boost_1_78_0 -DCMAKE_CXX_COMPILER_LAUNCHER=ccache -DBUILD_WITH_PULSE=OFF -DCMAKE_BUILD_TYPE=Release -DBUILD_CLIENT=OFF .. \
 && cmake --build build --parallel 3

# SnapWeb build stage
FROM node:alpine as snapweb
WORKDIR /root

RUN apk add build-base git \
 && npm install -g typescript \
 && git clone https://github.com/badaix/snapweb \
 && make -C snapweb

# Final stage
FROM ${ARCHITECTURE}/alpine:${ALPINE_BASE}
WORKDIR /root
COPY dummy qemu-*-static /usr/bin/
LABEL maintainer="Saiyato"

RUN mkdir -p /var/www/html \
 && wget -O /etc/snapserver.conf https://raw.githubusercontent.com/Saiyato/snapserver_docker/master/snapserver/snapserver.conf

RUN apk add alsa-lib avahi-libs expat flac libvorbis opus soxr \
 && rm -rf /etc/ssl /var/cache/apk/* /lib/apk/db/* /root/snapcast /usr/bin/dummy

COPY --from=snapcast /root/snapcast/bin/snapserver /usr/local/bin
COPY --from=snapweb /root/snapweb/dist/ /var/www/html/

EXPOSE 1704
EXPOSE 1705
EXPOSE 1780

ENTRYPOINT ["snapserver"]
