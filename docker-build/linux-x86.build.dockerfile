FROM gdsodium-linux-x86:latest AS build

COPY godot-cpp /extension/godot-cpp
COPY libsodium /extension/libsodium
COPY src /extension/src
COPY *SConstruct /extension/

COPY docker-build/output.sh /usr/local/bin

WORKDIR /extension

RUN scons platform=linux target=template_release arch=x86_64 \
    && scons platform=linux target=template_debug arch=x86_64 \
    && output.sh linux
RUN scons platform=linux target=template_release arch=x86_32 \
        sodium_use_zig=yes \
    && scons platform=linux target=template_debug arch=x86_32 \
        sodium_use_zig=yes \
    && output.sh linux


FROM scratch AS binaries
COPY --from=build /output/* /
