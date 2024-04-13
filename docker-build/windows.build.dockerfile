FROM gdsodium-windows:latest AS build

COPY godot-cpp /extension/godot-cpp
COPY libsodium /extension/libsodium
COPY src /extension/src
COPY *SConstruct register* /extension/

COPY docker-build/output.sh /usr/local/bin

WORKDIR /extension

ENV SBUILD scons platform=windows sodium_use_zig=yes

RUN ${SBUILD} target=template_release arch=x86_64 \
    && ${SBUILD} target=template_debug arch=x86_64 \
    && output.sh windows
RUN ${SBUILD} target=template_release arch=x86_32 \
    && ${SBUILD} target=template_debug arch=x86_32 \
    && output.sh windows
#RUN ${SBUILD} target=template_release arch=arm64 \
#    && ${SBUILD} target=template_debug arch=arm64 \
#    && output.sh windows


FROM scratch AS binaries
COPY --from=build /output/* /
