#!/bin/sh

export DOCKER_BUILDKIT=1

docker build -t androidsdk:latest -f Dockerfile.androidsdk .
docker build -t androidgd:latest -f Dockerfile.androidgd .

docker build \
    --output=../bin/android --target=binaries -f Dockerfile.androidbuild ..

cp ../bin/android/* ../demo/bin/android

docker build \
    --output=../builds --target=binaries -f Dockerfile.androidexport ..
