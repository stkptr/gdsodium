#!/bin/bash
shopt -s globstar

coverage() {
    for x in ./*.cpp ./*.h src/**/*.cpp src/**/*.h; do
        srcdir=$(dirname "${x}")
        srcfile=$(basename "${x}")
        mkdir -p "${2}/${srcdir}"
        gcov ${1} "${x}" && mv "${srcfile}.gcov" "${2}/${srcdir}"
    done
}

path="${1}"
if [ -z "${path}" ]; then
    path=coverage
fi

rm -rf ${path}
mkdir -p ${path}

coverage -ma ${path}/regular
coverage -mb ${path}/branch

gcovr -s -e godot-cpp/ -o ${path}/coverage.txt
gcovr -e godot-cpp/ --xml-pretty -o ${path}/coverage.xml
gcovr -e godot-cpp/ --branches -o ${path}/branches.txt

rm -f *.gcov src/*.gcov
