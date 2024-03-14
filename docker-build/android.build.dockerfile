FROM gdsodium-android:latest AS build

COPY godot-cpp /extension/godot-cpp
COPY libsodium /extension/libsodium
COPY src /extension/src
COPY *SConstruct /extension

COPY docker-build/output.sh /usr/local/bin

WORKDIR /extension

RUN scons platform=android target=template_release arch=arm64 \
    && scons platform=android target=template_debug arch=arm64 \
    && output.sh android
RUN scons platform=android target=template_release arch=arm32 \
    && scons platform=android target=template_debug arch=arm32 \
    && output.sh android
RUN scons platform=android target=template_release arch=x86_64 \
    && scons platform=android target=template_debug arch=x86_64 \
    && output.sh android
RUN scons platform=android target=template_release arch=x86_32 \
    && scons platform=android target=template_debug arch=x86_32 \
    && output.sh android


FROM scratch AS binaries
COPY --from=build /output/* /
