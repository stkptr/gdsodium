FROM gdsodium-web:latest AS build

COPY godot-cpp /extension/godot-cpp
COPY libsodium /extension/libsodium
COPY src /extension/src
COPY *SConstruct /extension/

COPY docker-build/output.sh /usr/local/bin

WORKDIR /extension

RUN scons platform=web target=template_release \
    && scons platform=web target=template_debug \
    && output.sh web


FROM scratch AS binaries
COPY --from=build /output/* /
