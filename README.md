# SnapCast
[Snapcast](https://github.com/badaix/snapcast) is a multiroom client-server audio player, where all clients are time synchronized with the server to play perfectly synced audio. It's not a standalone player, but an extension that turns your existing audio player into a Sonos-like multiroom solution. The server's audio input is a named pipe `/tmp/snapfifo`. All data that is fed into this file will be sent to the connected clients. One of the most generic ways to use Snapcast is in conjunction with the music player daemon (MPD) or Mopidy, which can be configured to use a named pipe as audio output.

## Dockerized SnapServer
This repository contains the scripts to auto-build images for SnapServer (the *server* part of the solution) for the ARM architecture. The base image is *{arch}/alpine:latest*, and the binaries are built from source instead of using pre-built binaries from the package archive.

###### Project info
* Overall  <img alt="Docker Cloud Build Status" src="https://img.shields.io/docker/cloud/build/saiyato/snapserver?style=flat-square">  <img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/saiyato/snapserver?style=flat-square">  <img alt="Docker Image Version (latest by date)" src="https://img.shields.io/docker/v/saiyato/snapserver?style=flat-square">
* ARM32v6  <img alt="Docker Image Size (tag)" src="https://img.shields.io/docker/image-size/saiyato/snapserver/arm32v6?style=flat-square">  <img alt="MicroBadger Layers (tag)" src="https://img.shields.io/microbadger/layers/saiyato/snapserver/arm32v6?style=flat-square">
* ARM32v7  <img alt="Docker Image Size (tag)" src="https://img.shields.io/docker/image-size/saiyato/snapserver/arm32v7?style=flat-square">  <img alt="MicroBadger Layers (tag)" src="https://img.shields.io/microbadger/layers/saiyato/snapserver/arm32v7?style=flat-square">
* ARM64v8  <img alt="Docker Image Size (tag)" src="https://img.shields.io/docker/image-size/saiyato/snapserver/arm64v8?style=flat-square">  <img alt="MicroBadger Layers (tag)" src="https://img.shields.io/microbadger/layers/saiyato/snapserver/arm64v8?style=flat-square">

* i386  <img alt="Docker Image Size (tag)" src="https://img.shields.io/docker/image-size/saiyato/snapserver/i386?style=flat-square">  <img alt="MicroBadger Layers (tag)" src="https://img.shields.io/microbadger/layers/saiyato/snapserver/i386?style=flat-square">
* AMD64  <img alt="Docker Image Size (tag)" src="https://img.shields.io/docker/image-size/saiyato/snapserver/amd64?style=flat-square">  <img alt="MicroBadger Layers (tag)" src="https://img.shields.io/microbadger/layers/saiyato/snapserver/amd64?style=flat-square">

## How to use
To use the images, run (which automatically pulls) the image from the repo and set necessary parameters;
1. Mount the /tmp/fifo in the container, so SnapServer can read from it
2. Define the necessary ports for communication: 1704 (audio stream), 1705 (TCP control) and 1780 (HTTP control)
3. Define the stream (syntax: `pipe://{fifo pipe}?{name}&{mode}&{sample format}`)

You can overwrite SnapCast's config by mounting a file to /etc/snapserver.conf in the container. The default settings create a single stream called "SnapServer". See the Snapcast [docs](https://github.com/badaix/snapcast#configuration) to create your own config.

## Short and concise example
The below example demonstrates how you can run the container using the above information. Note that I have added the `--rm` option, to auto-delete the container after exiting (for cleanup purposes).

```
docker run \
--rm \
--network host \
--name snapserver \
-v /tmp/snapfifo:/tmp/snapfifo \
-p 1704:1704 \
-p 1705:1705 \
-p 1780:1780 \
saiyato/snapserver:{arch} \
-s  pipe:///tmp/snapfifo?name=VOLUMIO&mode=read&sampleformat=44100:16:2
```
Where {arch} should denote the architecture you're running on (e.g. arm32v6, arm64v8, amd64 etc).
