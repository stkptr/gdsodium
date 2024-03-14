#!/bin/sh

PLATFORM=${1}
CC=${2}
HOST=${3}
GDARCH=${4}

sconsbuild() {
    scons target=${1} platform=${PLATFORM} arch=${GDARCH} \
        "sodium_configure=CC=${CC} --host=${HOST}"
}

echo -n ${CC} > /tmp/CC

sconsbuild template_release && sconsbuild template_debug || exit 1

output.sh ${PLATFORM}
rm -f /tmp/CC
