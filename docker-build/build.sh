#!/bin/sh

DOCKER_BUILDKIT=1 docker build \
    --output=../bin/android --target=binaries -f Dockerfile.android .
