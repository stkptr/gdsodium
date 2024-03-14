#!/bin/sh

clean() {
    rm -rvf ../bin/android/*.so ../bin/windows/*.dll
    rm -rvf ../bin/linux/*.so ../bin/macos/lib*
    rm -rvf ../demo/bin/android/*.so ../demo/bin/windows/*.dll
    rm -rvf ../demo/bin/linux/*.so ../demo/bin/macos/lib*
    rm -rvf ../build
}

distclean() {
    clean
    rm -rvf templates.zip templates
}

if [ "$1" = clean ]; then
    clean
    exit
fi

if [ "$1" = distclean ]; then
    clean
    exit
fi

if [ "$1" == export ]; then
    EXPORT=true
fi

GDBASE=https://github.com/godotengine/godot/releases/download/
TEMPLATES=4.2.1-stable/Godot_v4.2.1-stable_export_templates.tpz

if [ ! -f templates.zip ]; then
    wget -O templates.zip "${GDBASE}/${TEMPLATES}"
fi

if [ ! -d templates ]; then
    unzip templates.zip
fi

buildx() {
    DOCKER_BUILDKIT=1 docker build $@
}

docker_build() {
    buildx -t gdsodium-${1}:latest -f ${1}.base.dockerfile .
}

gdbuild() {
    dir=${1%%-*}
    buildx --output=../bin/${dir} --target=binaries \
        -f ${1}.build.dockerfile .. \
    && cp ../bin/${dir}/* ../demo/bin/${dir}
}

gdexport() {
    buildx \
        --output=../builds/${1} --target=binaries -f ${1}.export.dockerfile ..
}

build_all() {
    echo Building ${1}
    docker_build ${1}
    gdbuild ${1}
    if [ ! -z "$EXPORT" ]; then
        echo Exporting ${1}
        gdexport ${1}
    fi
}

docker_build debian
docker_build zig

build_all linux-x86
build_all linux-cross
build_all android
build_all windows
