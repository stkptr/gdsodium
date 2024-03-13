#!/bin/sh

GDBASE=https://github.com/godotengine/godot/releases/download/
TEMPLATES=4.2.1-stable/Godot_v4.2.1-stable_export_templates.tpz

if [ ! -f templates.zip ]; then
    wget -O templates.zip "${GDBASE}/${TEMPLATES}"
fi

if [ ! -d templates ]; then
    unzip templates.zip
fi

export DOCKER_BUILDKIT=1

docker_build() {
    docker build -t ${1}:latest -f ${1}.docker .
}

gdbuild() {
    docker build \
        --output=../bin/${1} --target=binaries -f ${1}-build.docker ..
    cp ../bin/${1}/* ../demo/bin/${1}
}

gdexport() {
    docker build \
        --output=../builds/${1} --target=binaries -f ${1}-export.docker ..
}

docker_build debgd

docker_build androidgd
gdbuild android
gdexport android
