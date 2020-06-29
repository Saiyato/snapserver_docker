# SnapCast
[Snapcast](https://github.com/badaix/snapcast) is a multiroom client-server audio player, where all clients are time synchronized with the server to play perfectly synced audio. It's not a standalone player, but an extension that turns your existing audio player into a Sonos-like multiroom solution. The server's audio input is a named pipe `/tmp/snapfifo`. All data that is fed into this file will be sent to the connected clients. One of the most generic ways to use Snapcast is in conjunction with the music player daemon (MPD) or Mopidy, which can be configured to use a named pipe as audio output.

## Dockerized SnapServer
This repository contains the scripts to auto-build images for SnapServer (the *server* part of the solution) for the ARM architecture. The base image is *arm32v7/alpine:latest*, and the binaries are built from source instead of using pre-built binaries from the package archive.

###### Project info
<img alt="Docker Cloud Build Status" src="https://img.shields.io/docker/cloud/build/saiyato/snapserver?style=flat-square">  <img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/saiyato/snapserver?style=flat-square">  <img alt="Docker Image Size (tag)" src="https://img.shields.io/docker/image-size/saiyato/snapserver/alpine?style=flat-square">  <img alt="MicroBadger Layers (tag)" src="https://img.shields.io/microbadger/layers/saiyato/snapserver/alpine?style=flat-square">  <img alt="Docker Image Version (latest by date)" src="https://img.shields.io/docker/v/saiyato/snapserver?style=flat-square">

## How to use
To use the images, run (which automatically pulls) the image from the repo and set necessary parameters;
1. Mount the /tmp/fifo in the container, so SnapServer can read from it
2. Define the necessary ports for communication: 1704 (Stream), 1705 (TCP) and 1780 (HTTP)

## Short and concise example
The below example demonstrates how you can run the container using the above information. Note that I have added the `--rm` option, to auto-delete the container after exiting (for cleanup purposes).

```
docker run \
--rm \
-v /tmp/snapfifo:/tmp/snapfifo \
-p 1704:1704 \
-p 1705:1705 \
-p 1780:1780 \
saiyato/snapserver:alpine \
-s  pipe:///tmp/snapfifo?name=VOLUMIO&mode=read&sampleformat=44100:16:2
```
