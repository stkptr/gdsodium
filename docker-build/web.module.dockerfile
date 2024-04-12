FROM gdsodium-web:latest AS build

RUN git clone https://github.com/godotengine/godot.git -b 4.2.1-stable --depth=1

WORKDIR /godot

ENV BASE /godot/modules/gdsodium
COPY libsodium ${BASE}/libsodium
COPY src ${BASE}/src
COPY *SConstruct SCsub register* config.py *.patch ${BASE}

RUN scons platform=web target=template_release \
    && scons platform=web target=template_debug \
    && mkdir -p /output \
    && mv bin/*.zip /output/ \
    && scons -c


FROM scratch AS binaries
COPY --from=build /output/* /
