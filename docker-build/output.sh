#!/bin/sh

mkdir -p /output \
    && mv extension/${1}/* /output/ \
    && rm -rf demo && scons -c
