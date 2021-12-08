# SnapCast
[SnapCast](https://github.com/badaix/snapcast) is a multiroom client-server audio player, where all clients are time synchronized with the server to play perfectly synced audio. It's not a standalone player, but an extension that turns your existing audio player into a Sonos-like multiroom solution. The server's audio input is a named pipe `/tmp/snapfifo`. All data that is fed into this file will be sent to the connected clients. One of the most generic ways to use Snapcast is in conjunction with the music player daemon (MPD) or Mopidy, which can be configured to use a named pipe as audio output.

## Dockerized SnapServer
This repository contains the scripts to auto-build images for SnapServer (the *server* part of the solution) for the ARM architecture. The base image is *{arch}/alpine:latest*, and the binaries are built from source instead of using pre-built binaries from the package archive.

Unfortunately Docker auto-build has been discontinued for free use, so I have to manually build, push and create manifests. If you want to do this yourself, no problem.
1. Clone the repo
2. Make the bash-files executable (`chmod +x build-multiarch.sh push_to_dockerhub.sh`)
3. Install Docker desktop
4. `./build-multiarch.sh -i <image_name> -a <architecure>`
e.g. `./build-multiarch.sh -i saiyato/snapserver -a arm32v7`

Want to upload it to your own Docker Hub repo? Also no problem
1. Continue from the above (clone, chmod, etc)
2. Login to Docker (`docker login`) to save your credentials on your machine
3. `./push_to_dockerhub.sh -i <the_image_you_want_to_upload_for>`
e.g. `./push_to_dockerhub.sh -i saiyato/snapserver`

Note that the upload script will look for the arm32v6, arm32v7, arm64v8, amd64 and i386 tags to push and annotate.

###### Overall
<img alt="Docker Cloud Build Status" src="https://img.shields.io/docker/cloud/build/saiyato/snapserver?style=flat-square">   <img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/saiyato/snapserver?style=flat-square">

###### ARM32v6
<img alt="Docker Image Size (tag)" src="https://img.shields.io/docker/image-size/saiyato/snapserver/arm32v6?style=flat-square">

###### ARM32v7
<img alt="Docker Image Size (tag)" src="https://img.shields.io/docker/image-size/saiyato/snapserver/arm32v7?style=flat-square">

###### ARM64v8
<img alt="Docker Image Size (tag)" src="https://img.shields.io/docker/image-size/saiyato/snapserver/arm64v8?style=flat-square">


###### i386
<img alt="Docker Image Size (tag)" src="https://img.shields.io/docker/image-size/saiyato/snapserver/i386?style=flat-square">

###### AMD64
<img alt="Docker Image Size (tag)" src="https://img.shields.io/docker/image-size/saiyato/snapserver/amd64?style=flat-square">

## Building the container
The Dockerfiles can be found in [my GitHub project](https://github.com/Saiyato/snapserver_docker) and they're built cross platform, qemu is downloaded in the builder to allow for arm builds on commodity hardware and Docker Hub. Development packages and the source code are downloaded, whereafter the binary is built from source. The container is then cleaned from any build artifacts and the dependencies are added. As a final step, a vulnerability scan is performed by [microscanner](https://github.com/aquasecurity/microscanner) (Aqua Security).

## How to use the container
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
saiyato/snapserver:{arch} \
--stream.stream  pipe:///tmp/snapfifo?name={stream_name}&mode=read&sampleformat=44100:16:2
```
Or, if you want it to be hosted on a separate IP
```
docker run \
--rm \
--name snapserver \
-v /tmp/snapfifo:/tmp/snapfifo \
-p 1704:1704 \
-p 1705:1705 \
-p 1780:1780 \
saiyato/snapserver:{arch} \
--stream.stream  pipe:///tmp/snapfifo?name={stream_name}&mode=read&sampleformat=44100:16:2
```
Or as a docker-compose
```
version: "3"

services:
  snapserver:
    image: saiyato/snapserver:{arch}
    container_name: snapserver
    restart: unless-stopped
    network_mode: host
    volumes:
      - /tmp/snapfifo:/tmp/snapfifo
    command: --stream.stream  pipe:///tmp/snapfifo?name={stream_name}&mode=read&sampleformat=44100:16:2
```

Where {arch} should denote the architecture you're running on (e.g. arm32v6, arm64v8, amd64 etc). And {stream_name} should denote the name you want to assign to the particular stream.

Test your setup by connecting to the server (easiest way is to use SnapDroid from the App Store) and stream noise into the fifo file.
`sudo cat /dev/urandom > /tmp/snapfifo`
