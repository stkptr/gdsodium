#!/bin/sh

clean_in() {
    rm -rvf "$1"/android/*.so "$1"/windows/*.dll
    rm -rvf "$1"/linux/*.so "$1"/macos/lib*
    rm -rvf "$1"/web/*.wasm
}

clean() {
    clean_in ../extension
    clean_in ../demo/bin
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

if [ "$1" = export ]; then
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

buildkit() {
    DOCKER_BUILDKIT=1 DOCKER_SCAN_SUGGEST=false docker build $@
}

docker_build() {
    dockerfile=${1}.base.dockerfile
    args="-t gdsodium-${1}:latest -f ${dockerfile} ${extra_args} ."
    extra_args=""
    echo Building ${dockerfile}
    if [ "${2}" = insecure ]; then
        docker buildx build --allow security.insecure ${args}
    else
        buildkit ${args}
    fi
}

platform() {
    printf "%s" ${1%%-*}
}

gdbuild_to() {
    dir=$(platform ${2})
    dockerfile=${2}.${3}.dockerfile
    if [ ! -e ${dockerfile} ]; then
        return 1
    fi
    buildkit --output="../${1}/${dir}" --target=binaries \
        -f ${dockerfile} ..
}

gdbuild() {
    dir=$(platform ${1})
    gdbuild_to extension ${1} build
}

modbuild() {
    gdbuild_to module ${1} module
}

gdexport() {
    buildkit \
        --output=../builds/${1} --target=binaries -f ${1}.export.dockerfile ..
}

build_all() {
    echo Building ${1}
    docker_build ${1}
    gdbuild ${1}
    modbuild ${1}
    if [ ! -z "$EXPORT" ]; then
        echo Exporting ${1}
        gdexport ${1}
    fi
    cp -ru ../extension ../demo/bin
}

docker_build debian
docker_build zig
#docker_build darwin insecure
#docker_build xcode insecure

build_all linux-x86
build_all linux-cross
build_all android
build_all windows
build_all web
