# Install SnapServer on minimal OS
FROM amd64/alpine:latest

MAINTAINER Saiyato

RUN apk -U add git bash build-base asio-dev avahi-dev flac-dev libvorbis-dev alsa-lib-dev opus-dev soxr-dev cmake \
 && cd /root \
 && git clone --recursive https://github.com/badaix/snapcast.git \
 && cd snapcast/server \
 && make \
 && cp snapserver /usr/local/bin \
 && cd /root \
 && git clone https://github.com/badaix/snapweb \
 && mkdir -p /var/www/html \
 && cp snapweb/page/* /var/www/html \
 && wget -O /etc/snapserver.conf https://raw.githubusercontent.com/Saiyato/snapserver_docker/master/snapserver/snapserver.conf \ 
 && cd / \
 && apk --purge del git build-base asio-dev avahi-dev flac-dev libvorbis-dev alsa-lib-dev opus-dev soxr-dev cmake \
 && apk add avahi-libs flac libvorbis opus soxr alsa-lib \
 && rm -rf /etc/ssl /var/cache/apk/* /lib/apk/db/* /root/snapcast /root/snapweb

EXPOSE 1704
EXPOSE 1705
EXPOSE 1780

ENTRYPOINT ["snapserver"]
