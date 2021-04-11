# Install SnapServer on minimal OS - script v2.0.3 [2021-04-11]
FROM amd64/alpine:latest

LABEL maintainer="Saiyato"
WORKDIR /root

RUN apk -U add alsa-lib-dev avahi-dev bash build-base ccache cmake expat-dev flac-dev git libvorbis-dev opus-dev soxr-dev \
 && git clone --recursive https://github.com/badaix/snapcast.git \
 && cd snapcast \
 && wget https://dl.bintray.com/boostorg/release/1.75.0/source/boost_1_75_0.tar.bz2 && tar -xvjf boost_1_75_0.tar.bz2 \
 && cmake -S . -B build -DBOOST_ROOT=boost_1_75_0 -DCMAKE_CXX_COMPILER_LAUNCHER=ccache -DBUILD_WITH_PULSE=OFF -DCMAKE_BUILD_TYPE=Release -DBUILD_CLIENT=OFF .. \
 && cmake --build build --parallel 3 \
 && cp bin/snapserver /usr/local/bin \
 && git clone https://github.com/badaix/snapweb \
 && mkdir -p /var/www/html \
 && cp -r snapweb/page/* /var/www/html \
 && wget -O /etc/snapserver.conf https://raw.githubusercontent.com/Saiyato/snapserver_docker/master/snapserver/snapserver.conf \ 
 && apk --purge del alsa-lib-dev avahi-dev bash build-base ccache cmake expat-dev flac-dev git libvorbis-dev opus-dev soxr-dev \
 && apk add alsa-lib avahi-libs expat flac libvorbis opus soxr \
 && rm -rf /etc/ssl /var/cache/apk/* /lib/apk/db/* /root/snapcast

EXPOSE 1704
EXPOSE 1705
EXPOSE 1780

ENTRYPOINT ["snapserver"]
