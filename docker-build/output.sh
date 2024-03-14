#!/bin/sh

mkdir -p /output \
    && mv bin/${1}/* /output/ \
    && rm -rf demo && scons -c
